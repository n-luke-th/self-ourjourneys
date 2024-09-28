/// lib/services/auth/local/local_auth_service.dart
///
/// a biometric/local authentication service
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      return await _localAuthentication.authenticate(
        localizedReason: 'Please authenticate to proceed',
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> canCheckBiometrics() async {
    return await _localAuthentication.canCheckBiometrics;
  }
}
