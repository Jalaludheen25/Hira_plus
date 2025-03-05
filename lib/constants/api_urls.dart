class ApiUrls {
  static const String _apiUrl =
      'https://jih-membership-api-xlhnn.ondigitalocean.app';
  static const String imageAppend =
      "https://event-manager.syd1.cdn.digitaloceanspaces.com";

  // Use thingproxy.freeboard.io
  // static String get _baseApi =>
  //     'https://thingproxy.freeboard.io/fetch/$_apiUrl';

  // GET endpoints
  static String getDistricts() => '$_apiUrl/api/v1/district';
  static String getAreaByDistrict(String district) =>
      '$_apiUrl/api/v1/area/area-by-district?district=$district';
  static String getPJUnitByArea(String area) =>
      '$_apiUrl/api/v1/pj-unit/area?area=$area';
  static String getLocalUnitByArea(String area) =>
      '$_apiUrl/api/v1/local-unit/area?area=$area';
 

  // POST endpoints
  static String postKarkun() => '$_apiUrl/api/v1/karkoon-form';
  static String postRukn() => '$_apiUrl/api/v1/rukn-registration';
}
