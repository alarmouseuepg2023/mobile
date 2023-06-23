import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/models/Login/login_response_model.dart';
import 'package:mobile/shared/models/Response/server_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

BaseOptions options = BaseOptions(baseUrl: '${dotenv.env['API_URL']}api/');

class DioApi {
  Dio dio = Dio(options);

  DioApi() {
    dio.interceptors.add(InterceptorsWrapper(
        onRequest: (RequestOptions requestOptions,
            RequestInterceptorHandler requestHandler) async {
          final pref = await SharedPreferences.getInstance();
          final storedAccessToken =
              pref.getString('ALARMOUSE:accessToken') ?? "";
          requestOptions.headers
              .putIfAbsent('Authorization', () => 'Bearer $storedAccessToken');

          requestHandler.next(requestOptions);
        },
        onResponse:
            (Response response, ResponseInterceptorHandler responseHandler) =>
                responseHandler.next(response),
        onError: (DioError error, ErrorInterceptorHandler errorHandler) async {
          if (error.response?.statusCode == 400) {
            final pref = await SharedPreferences.getInstance();
            ServerResponse rawServerResponse =
                ServerResponse.fromJson(error.response?.data);

            if (rawServerResponse.message ==
                'As credencias de atualização são inválidas. Por favor, realize a autenticação novamente.') {
              pref.clear();
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  "/login", (Route<dynamic> route) => false);
            } else {
              errorHandler.reject(error);
            }
            return;
          }

          if (error.response?.statusCode == 401) {
            final pref = await SharedPreferences.getInstance();
            final storedRefreshToken =
                pref.getString('ALARMOUSE:refreshToken') ?? "";
            ServerResponse serverResponse =
                ServerResponse.fromJson(error.response?.data);

            if (serverResponse.message !=
                    "As credenciais de autenticação são inválidas. Por favor, tente realizar a autenticação antes de acessar este conteúdo." &&
                serverResponse.message !=
                    "As credenciais de autenticação expiraram. Por favor, realize a autenticação novamente.") {
              errorHandler.reject(error);
              return;
            }

            if (serverResponse.message ==
                "As credenciais de autenticação são inválidas. Por favor, tente realizar a autenticação antes de acessar este conteúdo.") {
              pref.clear();
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  "/login", (Route<dynamic> route) => false);

              return;
            }

            if (serverResponse.message ==
                "As credenciais de autenticação expiraram. Por favor, realize a autenticação novamente.") {
              try {
                final response = await dio.post('auth/refresh',
                    data: {'refreshToken': storedRefreshToken});

                LoginResponse data = LoginResponse.fromJson(response.data);
                pref.setString(
                    "ALARMOUSE:refreshToken", data.content.refreshToken);

                pref.setString(
                    "ALARMOUSE:accessToken", data.content.accessToken);
                options.headers["Authorization"] =
                    "Bearer ${data.content.accessToken}";
              } on DioError catch (error) {
                errorHandler.reject(error);
              }
              try {
                RequestOptions errOptions = error.requestOptions;
                final previousResponse = await dio.request(errOptions.path,
                    data: errOptions.data,
                    cancelToken: errOptions.cancelToken,
                    onReceiveProgress: errOptions.onReceiveProgress,
                    onSendProgress: errOptions.onSendProgress,
                    queryParameters: errOptions.queryParameters);

                errorHandler.resolve(previousResponse);
              } on DioError catch (error) {
                errorHandler.reject(error);
              }
              return;
            }
            return;
          }

          return errorHandler.reject(error);
        }));
  }
}
