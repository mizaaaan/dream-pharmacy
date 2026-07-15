enum AppRole { customer, admin, guest }

class AppUser {
  final String id;
  final String email;
  final AppRole role;
  AppUser({required this.id, required this.email, required this.role});
}
