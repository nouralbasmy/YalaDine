class Review {
  final String reviewId;
  final String userId;
  final String menuItemId;
  final int rating; // 0-5 stars
  final String comment;
  final DateTime createdAt = DateTime.now();

  Review({
    required this.reviewId,
    required this.userId,
    required this.menuItemId,
    required this.rating,
    required this.comment,
  });
}
