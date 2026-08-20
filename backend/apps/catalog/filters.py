import django_filters

from .models import SparePart


class SparePartFilter(django_filters.FilterSet):
    """GET /parts?make=&model=&year=&category= per PLAN.md §4."""

    make = django_filters.CharFilter(field_name="compatible_make", lookup_expr="icontains")
    model = django_filters.CharFilter(field_name="compatible_model", lookup_expr="icontains")
    category = django_filters.CharFilter(field_name="category", lookup_expr="iexact")
    # A plain field filter can't express "year falls within [year_start,
    # year_end], where either bound may be NULL (open-ended)" — that's a
    # range-containment check, not an equality/lookup on one column, hence
    # a method filter instead of a declarative one.
    year = django_filters.NumberFilter(method="filter_year")

    class Meta:
        model = SparePart
        fields = ["make", "model", "category", "year"]

    def filter_year(self, queryset, name, value):
        from django.db.models import Q

        return queryset.filter(
            Q(year_start__isnull=True) | Q(year_start__lte=value),
            Q(year_end__isnull=True) | Q(year_end__gte=value),
        )
