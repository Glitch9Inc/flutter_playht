import 'package:meta/meta.dart';

const String defaultEndpoint = "https://api.play.ht/api/{version}/tts";
const String streamEndpoint = "https://api.play.ht/api/{version}/tts/stream";
const String version = "v2";

@immutable
abstract class PlayHTConfig {
  static Uri parse({String? endpoint, bool? isStream}) {
    bool stream = isStream ?? false;
    String result = _versionEndpoint(stream ? streamEndpoint : defaultEndpoint);

    // check if endpoint is null
    if (endpoint != null) {
      if (!endpoint.startsWith('/')) {
        result += '/$endpoint';
      } else {
        result += endpoint;
      }
    }

    return Uri.parse(result);
  }

  static String parseAsString({String? endpoint, bool? isStream}) {
    bool stream = isStream ?? false;
    String result = _versionEndpoint(stream ? streamEndpoint : defaultEndpoint);

    // check if endpoint is null
    if (endpoint != null) {
      if (!endpoint.startsWith('/')) {
        result += '/$endpoint';
      } else {
        result += endpoint;
      }
    }

    return result;
  }

  static String _versionEndpoint(String endpoint) {
    return endpoint.replaceAll('{version}', version);
  }
}
