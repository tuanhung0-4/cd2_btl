class CafeItem {
  final int? id;
  final String name;
  final String? note;
  final int? parentId;
  final String price;
  final String? status;
  final int userId;

  CafeItem({
    this.id,
    required this.name,
    this.note,
    this.parentId,
    required this.price,
    this.status,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'note': note,
      'parentId': parentId,
      'price': price,
      'status': status,
      'userId': userId,
    };
  }

  factory CafeItem.fromMap(Map<String, dynamic> map) {
    return CafeItem(
      id: map['id'],
      name: map['name'],
      note: map['note'],
      parentId: map['parentId'],
      price: map['price'],
      status: map['status'],
      userId: map['userId'],
    );
  }
}