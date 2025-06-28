class BorrowRecord {
  final String id;
  final String name;
  final String phone;
  final String bookName;
  final String glNo;
  final DateTime dateTaken;
  final DateTime dueDate;

  BorrowRecord({
    required this.id,
    required this.name,
    required this.phone,
    required this.bookName,
    required this.glNo,
    required this.dateTaken,
    required this.dueDate,
  });

  factory BorrowRecord.fromMap(Map<String, dynamic> map) {
    return BorrowRecord(
      id: map['id'],
      name: map['name'],
      phone: map['phone'] ?? '',
      bookName: map['book_name'],
      glNo: map['gl_no'],
      dateTaken: DateTime.parse(map['date_taken']),
      dueDate: DateTime.parse(map['due_date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'book_name': bookName,
      'gl_no': glNo,
      'date_taken': dateTaken.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
    };
  }
}