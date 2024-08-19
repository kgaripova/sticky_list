class Item {
  final String header;
  final String uselessData;

  Item({
    required this.header,
    required this.uselessData,
  });

  factory Item.fromJson(Map<String, dynamic> json,
      {bool includeUselessData = true}) {
    return Item(
      header: json['header'],
      uselessData: includeUselessData ? json['useless_data'] : '',
    );
  }
}
