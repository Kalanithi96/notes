// Register Exceptions

class EmailAlreadyInUseException implements Exception {}

class WeakPasswordException implements Exception {}

class InvalidEmailException implements Exception {}

// Login Exceptions

class InvalidCredentialsException implements Exception {}

// Generic

class EmptyChannelException implements Exception{}

class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}

class UserNotFoundAuthException implements Exception {}
