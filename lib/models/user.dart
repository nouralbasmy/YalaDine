class User {
  final String id; //doc ID - same as the id generated from authentication
  final String usertype; //client or admin
  final String name;
  final String email;
  String? restaurantID; //doesn't exist if usertype is client

  User(
      {required this.id,
      required this.usertype,
      required this.name,
      required this.email,
      this.restaurantID});
}
