class Offer {
  //subcollection "offers" for "restaurant" collection
  final String id; //doc Id auto generated
  final String title;
  final String description;
  final double discount; //percentage discount e.g. 10% input stored as 0.1
  final double minOrderTotal; //0 if no restriction
  final bool isActive;

  Offer(
      {required this.id,
      required this.title,
      required this.description,
      required this.discount,
      required this.minOrderTotal,
      required this.isActive});
}
