class RankModel {
  final String name;
  final int coin;
  final int sec;

  RankModel({required this.name, required this.coin, required this.sec});

  factory RankModel.fromJson(Map json) =>
      RankModel(name: json["name"], coin: json["coin"], sec: json["sec"]);

  Map toJson() => {"name": name, "coin": coin, "sec": sec};

  @override
  bool operator ==(Object other) {
    return name == (other as RankModel).name &&
        coin == other.coin &&
        other.sec == sec;
  }
}
