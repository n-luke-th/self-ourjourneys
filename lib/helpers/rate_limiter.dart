/// lib/helpers/rate_limiter.dart
///
/// a rate limiter

class RateLimiter {
  final Map<String, int> _attempts = {};
  final Map<String, DateTime> _lastAttempt = {};

  /// a function to limit the attempt rate to perform such action(s)
  bool canAttempt(String identifier,
      {Duration duration = const Duration(minutes: 15)}) {
    final now = DateTime.now();
    if (_lastAttempt.containsKey(identifier) &&
        now.difference(_lastAttempt[identifier]!) < duration) {
      _attempts[identifier] = (_attempts[identifier] ?? 0) + 1;
      if (_attempts[identifier]! > 5) {
        return false;
      }
    } else {
      _attempts[identifier] = 1;
    }
    _lastAttempt[identifier] = now;
    return true;
  }
}
