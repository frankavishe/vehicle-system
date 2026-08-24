import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/models/service_request.dart';

void main() {
  group('allowedStatusTransitions (mirrors backend transitions.py)', () {
    test('PENDING can only reach CANCELLED — ACCEPTED is /accept-only', () {
      expect(allowedStatusTransitions[ServiceStatus.pending], {ServiceStatus.cancelled});
    });

    test('ACCEPTED can advance to EN_ROUTE or CANCELLED', () {
      expect(
        allowedStatusTransitions[ServiceStatus.accepted],
        {ServiceStatus.enRoute, ServiceStatus.cancelled},
      );
    });

    test('EN_ROUTE can advance to IN_PROGRESS or CANCELLED', () {
      expect(
        allowedStatusTransitions[ServiceStatus.enRoute],
        {ServiceStatus.inProgress, ServiceStatus.cancelled},
      );
    });

    test('IN_PROGRESS can advance to COMPLETED or CANCELLED', () {
      expect(
        allowedStatusTransitions[ServiceStatus.inProgress],
        {ServiceStatus.completed, ServiceStatus.cancelled},
      );
    });

    test('COMPLETED and CANCELLED are terminal', () {
      expect(allowedStatusTransitions[ServiceStatus.completed], isEmpty);
      expect(allowedStatusTransitions[ServiceStatus.cancelled], isEmpty);
    });

    test('every ServiceStatus value has an entry (no silent gaps)', () {
      for (final status in ServiceStatus.values) {
        expect(allowedStatusTransitions.containsKey(status), isTrue, reason: '$status missing');
      }
    });
  });

  group('serviceStatusWireValue', () {
    test('round-trips every enum value to its backend wire string', () {
      expect(serviceStatusWireValue(ServiceStatus.pending), 'PENDING');
      expect(serviceStatusWireValue(ServiceStatus.accepted), 'ACCEPTED');
      expect(serviceStatusWireValue(ServiceStatus.enRoute), 'EN_ROUTE');
      expect(serviceStatusWireValue(ServiceStatus.inProgress), 'IN_PROGRESS');
      expect(serviceStatusWireValue(ServiceStatus.completed), 'COMPLETED');
      expect(serviceStatusWireValue(ServiceStatus.cancelled), 'CANCELLED');
    });
  });
}
