class MenuItem {
  final String id;
  final String imageURL;
  final String name;
  final String description;
  final String category; // Starter, Main Course, Sides, Dessert, Beverages
  final double price;

  MenuItem({
    required this.id,
    required this.imageURL,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
  });
}
