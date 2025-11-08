import 'package:logger/logger.dart';

class LoggerService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
      
    ),
  );

  static void debug(String message, [dynamic? error, StackTrace? stackTrace]) {
    _logger.d(message,error: error,stackTrace:  stackTrace);
  }

  static void info(String message, [dynamic? error, StackTrace? stackTrace]) {
    _logger.i(message,error: error,stackTrace:  stackTrace);
  }
  
  static void error(String message, [dynamic? error, StackTrace? stackTrace]) {
    _logger.e(message,error: error,stackTrace:  stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  static void network(String method, String url, {int? statusCode, dynamic data}) {
    _logger.i(
      '🌐 $method $url${statusCode != null ? ' → $statusCode' : ''}',
      error: data,
    );
  }

  static void payment(String message, {dynamic data}) {
    _logger.i('💳 $message', error: data);
  }

  static void auth(String message, {dynamic data}) {
    _logger.i('🔐 $message', error: data);
  }
}