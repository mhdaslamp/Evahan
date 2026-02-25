/// Shared data model passed between steps of the sell flow.
class ListingDraft {
  String category;
  String brand;
  String model;
  String year;
  String transmission; // 'Automatic' or 'Manual'
  String location;
  String kmDriven;
  String noOfOwners;
  String adTitle;
  String price;
  List<String> photoPaths; // local file paths (will be uploaded later)
  String? batteryCertPath; // local file path for battery cert

  ListingDraft({
    this.category = '',
    this.brand = '',
    this.model = '',
    this.year = '',
    this.transmission = 'Automatic',
    this.location = '',
    this.kmDriven = '',
    this.noOfOwners = '',
    this.adTitle = '',
    this.price = '',
    List<String>? photoPaths,
    this.batteryCertPath,
  }) : photoPaths = photoPaths ?? [];

  ListingDraft copyWith({
    String? category,
    String? brand,
    String? model,
    String? year,
    String? transmission,
    String? location,
    String? kmDriven,
    String? noOfOwners,
    String? adTitle,
    String? price,
    List<String>? photoPaths,
    String? batteryCertPath,
  }) {
    return ListingDraft(
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      transmission: transmission ?? this.transmission,
      location: location ?? this.location,
      kmDriven: kmDriven ?? this.kmDriven,
      noOfOwners: noOfOwners ?? this.noOfOwners,
      adTitle: adTitle ?? this.adTitle,
      price: price ?? this.price,
      photoPaths: photoPaths ?? List.from(this.photoPaths),
      batteryCertPath: batteryCertPath ?? this.batteryCertPath,
    );
  }
}
