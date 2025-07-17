enum AppEnvironment { dev, staging, prod }

class AppConfig {
  static late AppEnvironment _env;

  static void setEnvironment(AppEnvironment env) {
    _env = env;
  }

  static AppEnvironment get env => _env;

  static String get baseUrl {
    switch (_env) {
      case AppEnvironment.dev:
        return "http://app.maklife.in:10000/api/";
      case AppEnvironment.staging:
        return "http://app.maklife.in:6040/api/";
      case AppEnvironment.prod:
      default:
        return "https://app.maklife.in:6040/api/";
    }
  }

  static String get socketUrl {
    switch (_env) {
      case AppEnvironment.dev:
        return "http://app.maklife.in:10000";
      case AppEnvironment.staging:
        return "http://app.maklife.in:6040";
      case AppEnvironment.prod:
      default:
        return "https://app.maklife.in:6040";
    }
  }
}
