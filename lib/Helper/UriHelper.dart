class UriHelper {
  static const String _baseUrl = 'https://10.0.2.2:7128/api';

  static Uri build(String endpoint) {
    return Uri.parse('$_baseUrl$endpoint');
  }
}
