from django.contrib.gis.geos import Point
from rest_framework import serializers

from .models import PartsSourcingRequest, Review, ServiceRequest, ServiceStatus, ServiceType
from .services.fare import estimate_fare


def _point_to_dict(point):
    if point is None:
        return None
    return {"lat": point.y, "lng": point.x}


def _user_summary(user):
    if user is None:
        return None
    return {"id": user.id, "full_name": user.full_name, "phone": user.phone}


class ServiceRequestCreateSerializer(serializers.Serializer):
    service_type = serializers.ChoiceField(choices=ServiceType.choices)
    pickup_lat = serializers.FloatField()
    pickup_lng = serializers.FloatField()
    dropoff_lat = serializers.FloatField(required=False, allow_null=True)
    dropoff_lng = serializers.FloatField(required=False, allow_null=True)
    problem_description = serializers.CharField(required=False, allow_blank=True, allow_null=True)

    def validate(self, attrs):
        if attrs["service_type"] == ServiceType.RECOVERY:
            if attrs.get("dropoff_lat") is None or attrs.get("dropoff_lng") is None:
                raise serializers.ValidationError(
                    "dropoff_lat/dropoff_lng are required for RECOVERY requests."
                )
        return attrs


class ServiceRequestSerializer(serializers.ModelSerializer):
    pickup_location = serializers.SerializerMethodField()
    dropoff_location = serializers.SerializerMethodField()
    customer = serializers.SerializerMethodField()
    provider = serializers.SerializerMethodField()

    class Meta:
        model = ServiceRequest
        fields = [
            "id", "customer", "provider", "service_type", "status",
            "pickup_location", "dropoff_location", "problem_description",
            "estimated_fare", "final_fare", "created_at",
            # 002-recovery-towing-web-portal: additive-only (plain model
            # fields on an already-fully-serialized model) — every existing
            # caller (mechanic portal, customer tracking page, mobile apps)
            # already ignores unknown-to-them extra fields.
            "accepted_at", "completed_at",
        ]
        read_only_fields = fields

    def get_pickup_location(self, obj):
        return _point_to_dict(obj.pickup_location)

    def get_dropoff_location(self, obj):
        return _point_to_dict(obj.dropoff_location)

    def get_customer(self, obj):
        return _user_summary(obj.customer)

    def get_provider(self, obj):
        return _user_summary(obj.provider)


class ServiceRequestStatusUpdateSerializer(serializers.Serializer):
    status = serializers.ChoiceField(choices=ServiceStatus.choices)


def build_service_request(*, customer, validated_data) -> ServiceRequest:
    pickup = Point(validated_data["pickup_lng"], validated_data["pickup_lat"], srid=4326)
    dropoff = None
    if validated_data.get("dropoff_lat") is not None:
        dropoff = Point(validated_data["dropoff_lng"], validated_data["dropoff_lat"], srid=4326)
    service_type = validated_data["service_type"]
    return ServiceRequest.objects.create(
        customer=customer,
        service_type=service_type,
        pickup_location=pickup,
        dropoff_location=dropoff,
        problem_description=validated_data.get("problem_description"),
        # Phase 4 (PLAN.md §5.2): OSRM/Haversine for RECOVERY, flat
        # FARE_BASE_FEE for MECHANIC (no dropoff to price a distance from).
        estimated_fare=estimate_fare(service_type=service_type, pickup=pickup, dropoff=dropoff),
    )


class PartsSourcingRequestCreateSerializer(serializers.Serializer):
    spare_part_id = serializers.UUIDField()
    quantity = serializers.IntegerField(min_value=1, default=1)


class PartsSourcingRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = PartsSourcingRequest
        fields = [
            "id", "service_request", "requested_by", "spare_part", "quantity",
            "status", "order", "created_at",
        ]
        read_only_fields = fields


class PartsSourcingRequestApproveSerializer(serializers.Serializer):
    approved = serializers.BooleanField()


class PartsSourcingRequestOrderSerializer(serializers.Serializer):
    delivery_address = serializers.CharField(required=False, allow_blank=True, allow_null=True)


class ReviewCreateSerializer(serializers.Serializer):
    rating = serializers.IntegerField(min_value=1, max_value=5)
    comment = serializers.CharField(required=False, allow_blank=True, allow_null=True)


class ReviewSerializer(serializers.ModelSerializer):
    class Meta:
        model = Review
        fields = ["id", "service_request", "customer", "rating", "comment", "created_at"]
        read_only_fields = fields
