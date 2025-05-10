
abstract class AuthEvent {
  const AuthEvent();
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});
}

class LogoutRequested extends AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String? name;

  RegisterRequested({
    required this.email,
    required this.password,
    this.name,
  });
}
