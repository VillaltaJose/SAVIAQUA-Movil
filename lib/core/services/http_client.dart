import 'package:http_interceptor/http_interceptor.dart';
import 'package:saviaqua/core/services/interceptors/auth_interceptor.dart';

final httpClient = InterceptedClient.build(
  interceptors: [AuthInterceptor()],
  requestTimeout: const Duration(seconds: 10),
);
