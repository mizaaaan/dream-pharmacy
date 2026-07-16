class Product {
  final String id;
  final String name;
  final String? genericName;
  final String? description;
  final String category;
  final bool prescriptionRequired;
  final double price;
  final int stockQuantity;
  final String? dosageForm;
  final String? strength;
  final String? manufacturer;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    this.genericName,
    this.description,
    required this.category,
    required this.prescriptionRequired,
    required this.price,
    required this.stockQuantity,
    this.dosageForm,
    this.strength,
    this.manufacturer,
    this.imageUrl,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      genericName: map['generic_name'] as String?,
      description: map['description'] as String?,
      category: map['category'] as String,
      prescriptionRequired: map['prescription_required'] as bool,
      price: (map['price'] as num).toDouble(),
      stockQuantity: map['stock_quantity'] as int,
      dosageForm: map['dosage_form'] as String?,
      strength: map['strength'] as String?,
      manufacturer: map['manufacturer'] as String?,
      imageUrl: map['image_url'] as String?,
    );
  }

  bool get inStock => stockQuantity > 0;
}
