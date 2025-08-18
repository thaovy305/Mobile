class UriHelper {
  static const String _baseUrl = 'https://10.0.2.2:7128/api';
  // static const String _baseUrl = 'https://192.168.1.232:7128/api';

  // static const String _baseUrl =
      // 'https://intellipm-c5c2a5athaa2b9cp.southeastasia-01.azurewebsites.net/api';

  static Uri build(String endpoint) {
    return Uri.parse('$_baseUrl$endpoint');
  }
}
