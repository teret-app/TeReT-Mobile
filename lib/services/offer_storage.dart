class OfferStorage {
  static final List<Map<String, dynamic>> offers = [];

  static void addOffer(Map<String, dynamic> offer) {
    offers.insert(0, offer);
  }

  static List<Map<String, dynamic>> getOffersForShipment(int shipmentId) {
    return offers.where((o) => o['shipmentId'] == shipmentId).toList();
  }

  static int getOfferCountForShipment(int shipmentId) {
    return offers.where((o) => o['shipmentId'] == shipmentId).length;
  }
}