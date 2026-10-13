class CardModel {
  final String id;
  final String title;
  final String barcode;
  final String barcodeFormat; // e.g., 'EAN13', 'CODE128', 'QR'
  final String colorHex;
  final bool isFavorite;
  final String? notes;
  final String? category;

  CardModel({
    required this.id,
    required this.title,
    required this.barcode,
    required this.barcodeFormat,
    required this.colorHex,
    this.isFavorite = false,
    this.notes,
    this.category,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'barcode': barcode,
        'barcodeFormat': barcodeFormat,
        'colorHex': colorHex,
        'isFavorite': isFavorite,
        'notes': notes,
        'category': category,
      };

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
        id: json['id'] as String,
        title: json['title'] as String,
        barcode: json['barcode'] as String,
        barcodeFormat: json['barcodeFormat'] as String,
        colorHex: json['colorHex'] as String,
        isFavorite: json['isFavorite'] as bool? ?? false,
        notes: json['notes'] as String?,
        category: json['category'] as String?,
      );
}
