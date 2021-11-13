import 'package:dio/dio.dart';
import 'package:recipeapi/core/constants/string_const.dart';
import 'package:recipeapi/data/services/api_key.dart';
import '../../../core/exceptions/server_exception.dart';
import '../remote_src.dart';

class RemoteSourceImpl implements RemoteSource {
  static const String API_KEY = APIKeys.apiKey;
  Dio dio;

  RemoteSourceImpl({
    required this.dio,
  }) {
    _setDioInitialInterceptors();
  }

  @override
  Future get(
    String url, {
    Map<String, dynamic> queryParam = const {
      'apiKey': API_KEY,
    },
  }) async {
    try {
      final response = await dio.get(
        url,
        queryParameters: queryParam,
      );
      return response.data;
    } on DioError catch (e) {
      getServerException(e);
    }
  }

  @override
  Future post(String url,
      {Map<String, dynamic> queryParam = const {
        'apiKey': API_KEY,
      },
      Map<String, dynamic> body = const {}}) async {
    try {
      final response = await dio.post(
        url,
        queryParameters: queryParam,
        data: body,
      );
      return response.data;
    } on DioError catch (e) {
      throw getServerException(e);
    }
  }

  void _setDioInitialInterceptors() {
    dio.interceptors.add(InterceptorsWrapper(onRequest: (initialOptions, handler) async {
      final finalOptions = await _setOptions(initialOptions) as RequestOptions;
      return handler.next(finalOptions);
    }));
  }

  Future<dynamic> _setOptions(options) async {
    options.headers['Content-Type'] = 'application/json';
    options.baseUrl = 'https://api.spoonacular.com/';
    return options;
  }
}

ServerException getServerException(DioError e) {
  switch (e.type) {
    case DioErrorType.connectTimeout:
      return ServerException(code: 522, message: 'Connection Timedout');
    case DioErrorType.other:
      return ServerException(code: 400, message: dioDefaultMessage);
    case DioErrorType.response:
      final responseMsg = e.response!.data['message'] ?? somethingWentWrong;
      return ServerException(
        code: e.response!.statusCode!,
        message: responseMsg.toString(),
      );
    default:
      return ServerException(
        code: 404,
        message: somethingWentWrong,
      );
  }
}
