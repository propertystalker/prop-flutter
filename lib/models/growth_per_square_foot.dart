
class GrowthPerSquareFootData {
  final String date;
  final int price;
  final String? growth;

  GrowthPerSquareFootData({
    required this.date,
    required this.price,
    this.growth,
  });

  factory GrowthPerSquareFootData.fromJson(List<dynamic> json) {
    return GrowthPerSquareFootData(
      date: json[0],
      price: json[1],
      growth: json[2],
    );
  }
}
