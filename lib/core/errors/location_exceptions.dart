/// Thrown when the device's location service (GPS) itself is turned off.
class LocationServiceDisabledException implements Exception {
  const LocationServiceDisabledException();
}

/// Thrown when the user denies the location permission prompt.
class LocationPermissionDeniedException implements Exception {
  const LocationPermissionDeniedException();
}

/// Thrown when the user has permanently denied location access and must
/// re-enable it from system settings.
class LocationPermissionDeniedForeverException implements Exception {
  const LocationPermissionDeniedForeverException();
}
