import 'package:http_interceptor/http_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/env.dart';

class AuthInterceptor implements InterceptorContract {
  @override
  Future<bool> shouldInterceptRequest() async => true;

  @override
  Future<bool> shouldInterceptResponse() async => true;

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('session_token');

    final originalUrl = request.url.toString();
    if (!originalUrl.startsWith('http')) {
      final separator = originalUrl.startsWith('/') ? '' : '/';
      final fullUrl = Uri.parse('${Env.apiBaseUrl}$separator$originalUrl');
      final updatedRequest = request is Request
          ? Request(request.method, fullUrl)
          : request is MultipartRequest
              ? MultipartRequest(request.method, fullUrl)
              : null;
      if (updatedRequest != null) {
        updatedRequest.headers.addAll(request.headers);
        if (request is Request && updatedRequest is Request) {
          updatedRequest.bodyBytes = await request.finalize().toBytes();
        }
        request = updatedRequest;
      }
    }

    request.headers['Content-Type'] = 'application/json';

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    print('Intercepted URL: ${request.url}');

    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    return response;
  }
}
