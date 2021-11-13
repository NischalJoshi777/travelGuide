abstract class RemoteSource {
  ///return map of data when success and throws [ServerException]
  ///with status code and message in any failure
  Future get(String url, {Map<String, dynamic> queryParam});

  ///return map of data when success and throws [ServerException]
  /// with status code and message in any failure
  Future post(String url,
      {Map<String, dynamic> queryParam, Map<String, dynamic> body});
}
