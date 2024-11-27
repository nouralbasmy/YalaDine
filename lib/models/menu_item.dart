class MenuItem {
  //found in subcollection "menu" (which is in collection "restaurants")
  final String id; //auto generated (doc id)
  final String imageUrl;
  final String name;
  final String description;
  final String category; // Appetizers, Main Course, Sides, Desserts, Beverages
  final double price; //in db as String
  final int numOfRatings;
  final double rating;

  MenuItem(
      {required this.id,
      required this.imageUrl,
      required this.name,
      required this.description,
      required this.category,
      required this.price,
      required this.rating,
      required this.numOfRatings});
}
