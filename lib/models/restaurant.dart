class Restaurant {
  final String restaurantId; //auto generated (doc id)
  final String restaurantName;
  final String logoUrl;
  final String adminID;

  Restaurant(
      {required this.restaurantId,
      required this.restaurantName,
      required this.logoUrl,
      required this.adminID});
}
