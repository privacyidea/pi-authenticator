import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/container_policies.dart';

void main() {
  group('ContainerPolicies', () {
    test('defaultSetting has all values false', () {
      const policies = ContainerPolicies.defaultSetting;
      expect(policies.rolloverAllowed, isFalse);
      expect(policies.initialTokenAssignment, isFalse);
      expect(policies.disabledTokenDeletion, isFalse);
      expect(policies.disabledUnregister, isFalse);
    });

    test('constructor creates with given values', () {
      const policies = ContainerPolicies(
        rolloverAllowed: true,
        initialTokenAssignment: true,
        disabledTokenDeletion: false,
        disabledUnregister: true,
      );
      expect(policies.rolloverAllowed, isTrue);
      expect(policies.initialTokenAssignment, isTrue);
      expect(policies.disabledTokenDeletion, isFalse);
      expect(policies.disabledUnregister, isTrue);
    });

    test('fromUriMap parses correctly', () {
      final map = {
        ContainerPolicies.ROLLOVER_ALLOWED: true,
        ContainerPolicies.INITIAL_TOKEN_ASSIGNMENT: false,
        ContainerPolicies.DISABLED_TOKEN_DELETION: true,
        ContainerPolicies.DISABLED_UNREGISTER: false,
      };
      final policies = ContainerPolicies.fromUriMap(map);
      expect(policies.rolloverAllowed, isTrue);
      expect(policies.initialTokenAssignment, isFalse);
      expect(policies.disabledTokenDeletion, isTrue);
      expect(policies.disabledUnregister, isFalse);
    });

    test('toUriMap produces correct keys', () {
      const policies = ContainerPolicies(
        rolloverAllowed: true,
        initialTokenAssignment: false,
        disabledTokenDeletion: true,
        disabledUnregister: false,
      );
      final map = policies.toUriMap();
      expect(map[ContainerPolicies.ROLLOVER_ALLOWED], isTrue);
      expect(map[ContainerPolicies.INITIAL_TOKEN_ASSIGNMENT], isFalse);
      expect(map[ContainerPolicies.DISABLED_TOKEN_DELETION], isTrue);
      expect(map[ContainerPolicies.DISABLED_UNREGISTER], isFalse);
    });

    test('fromUriMap and toUriMap roundtrip', () {
      const original = ContainerPolicies(
        rolloverAllowed: true,
        initialTokenAssignment: true,
        disabledTokenDeletion: true,
        disabledUnregister: true,
      );
      final map = original.toUriMap();
      final restored = ContainerPolicies.fromUriMap(map);
      expect(restored, equals(original));
    });

    test('fromJson and toJson roundtrip', () {
      const original = ContainerPolicies(
        rolloverAllowed: false,
        initialTokenAssignment: true,
        disabledTokenDeletion: false,
        disabledUnregister: true,
      );
      final json = original.toJson();
      final restored = ContainerPolicies.fromJson(json);
      expect(restored, equals(original));
    });

    test('equality works correctly', () {
      const a = ContainerPolicies(
        rolloverAllowed: true,
        initialTokenAssignment: false,
        disabledTokenDeletion: true,
        disabledUnregister: false,
      );
      const b = ContainerPolicies(
        rolloverAllowed: true,
        initialTokenAssignment: false,
        disabledTokenDeletion: true,
        disabledUnregister: false,
      );
      const c = ContainerPolicies(
        rolloverAllowed: false,
        initialTokenAssignment: false,
        disabledTokenDeletion: true,
        disabledUnregister: false,
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('static constants match expected keys', () {
      expect(
        ContainerPolicies.DISABLED_UNREGISTER,
        'disable_client_container_unregister',
      );
      expect(
        ContainerPolicies.DISABLED_TOKEN_DELETION,
        'disable_client_token_deletion',
      );
      expect(ContainerPolicies.ROLLOVER_ALLOWED, 'container_client_rollover');
      expect(
        ContainerPolicies.INITIAL_TOKEN_ASSIGNMENT,
        'initially_add_tokens_to_container',
      );
    });
  });
}
