
class PricePerSquareFoot {
  final int average;
  final List<int> range70pc;
  final List<int> range80pc;
  final List<int> range90pc;
  final List<int> range100pc;

  PricePerSquareFoot({
    required this.average,
    required this.range70pc,
    required this.range80pc,
    required this.range90pc,
    required this.range100pc,
  });

  factory PricePerSquareFoot.fromJson(Map<String, dynamic> json) {
    return PricePerSquareFoot(
      average: json['average'],
      range70pc: List<int>.from(json['70pc_range']),
      range80pc: List<int>.from(json['80pc_range']),
      range90pc: List<int>.from(json['90pc_range']),
      range100pc: List<int>.from(json['100pc_range']),
    );
  }
}
