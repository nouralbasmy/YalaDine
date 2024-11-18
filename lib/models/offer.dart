class Offer {
  final String offerId;
  final String title;
  final String description;
  final DateTime createdAt = DateTime.now();
  final DateTime validUntil;
  final String createdBy; //id of restaurant or admin creating it (TBD)

  Offer(
      {required this.offerId,
      required this.title,
      required this.description,
      required this.validUntil,
      required this.createdBy});
}
