/// 使用用途
class UseType {
  /// 用途名
  final String useType;

  /// ID
  final int id;

  /// 初期時に表示される使用用途一覧
  static List<UseType> templates = <UseType>[
    UseType(id: 1, useType: "食品"),
    UseType(id: 2, useType: "交通費"),
    UseType(id: 3, useType: "娯楽"),
    UseType(id: 4, useType: "その他"),
  ];

  const UseType({this.id, this.useType})
      : assert(id != null),
        assert(useType != null);

  @override
  String toString() {
    return "id: $id, useType: $useType";
  }

  bool operator== (other) {
    if (other is! UseType) return false;
    UseType useType = other;
    return this.id == useType.id && this.useType == useType.useType;
  }

  @override
  int get hashCode => super.hashCode;
}
