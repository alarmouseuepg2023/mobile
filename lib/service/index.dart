import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

BaseOptions options = BaseOptions(baseUrl: '${dotenv.env['API_URL']}api/');

final dio = Dio(options);
