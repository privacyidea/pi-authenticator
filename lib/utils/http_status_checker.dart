abstract class HttpStatusChecker {
  static bool isInformational(int statusCode) {
    return statusCode >= 100 && statusCode < 200;
  }

  static bool isSuccessful(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  static bool isRedirect(int statusCode) {
    return statusCode >= 300 && statusCode < 400;
  }

  static bool isClientError(int statusCode) {
    return statusCode >= 400 && statusCode < 500;
  }

  static bool isServerError(int statusCode) {
    return statusCode >= 500 && statusCode < 600;
  }

  static bool isInvalidStatus(int statusCode) {
    return statusCode < 100 || statusCode >= 600;
  }

  static bool isError(int statusCode) {
    return isClientError(statusCode) || isServerError(statusCode) || isInvalidStatus(statusCode);
  }
}
