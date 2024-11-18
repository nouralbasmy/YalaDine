class User {
  final String userId;
  final String userType; //client or admin
  final String name;
  String? restaurantID; //null if usertype is client

  User(
      {required this.userId,
      required this.userType,
      required this.name,
      this.restaurantID});
}
