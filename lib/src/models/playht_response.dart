/*{
  "id": "BSMLoEyCqOhfHDGvcA",
  "created": "2024-08-01T02:28:47.969Z",
  "input": {
    "output_format": "mp3",
    "quality": "high",
    "sample_rate": 44100,
    "seed": null,
    "speed": 1,
    "temperature": null,
    "text": "I'm here.",
    "voice": "s3://voice-cloning-zero-shot/d9ff78ba-d016-47f6-b0ef-dd630f59414e/female-cs/manifest.json"
  },
  "status": "pending",
  "output": null,
  "_links": [
    {
      "contentType": "application/json",
      "description": "Fetches this job's data. Poll it for the latest status.",
      "href": "https://api.play.ht/api/v2/tts/BSMLoEyCqOhfHDGvcA",
      "method": "GET",
      "rel": "self"
    },
    {
      "contentType": "text/event-stream",
      "description": "Fetches (live) the job status (in SSE/text stream format) as the generation progresses.",
      "href": "https://api.play.ht/api/v2/tts/BSMLoEyCqOhfHDGvcA?format=event-stream",
      "method": "GET",
      "rel": "related"
    },
    {
      "contentType": "audio/mpeg",
      "description": "Streams the audio bytes.",
      "href": "https://api.play.ht/api/v2/tts/BSMLoEyCqOhfHDGvcA?format=audio-mpeg",
      "method": "GET",
      "rel": "related"
    }
  ]
}
*/

import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_playht/flutter_playht.dart';

class PlayHTResponse {
  final String id;
  final DateTime created;
  final PlayHTRequest input;
  final String status;
  //final PlayHTOutput? output; << idk what this is
  final List<PlayHTLink> links;

  PlayHTResponse({
    required this.id,
    required this.created,
    required this.input,
    required this.status,
    required this.links,
  });

  factory PlayHTResponse.fromJson(Map<String, dynamic> json) {
    return PlayHTResponse(
      id: json.getString('id'),
      created: json.getDateTime('created'),
      input: PlayHTRequest.fromJson(json['input']),
      status: json.getString('status'),
      //output: PlayHTOutput.fromJson(json['output']),
      links: List<PlayHTLink>.from(json['_links'].map((x) => PlayHTLink.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created': created.toIso8601String(),
      'input': input.toJson(),
      'status': status,
      '_links': links.map((x) => x.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'PlayHTResponse{id: $id, created: $created, input: $input, status: $status, links: $links}';
  }
}

class PlayHTLink {
  final String contentType;
  final String description;
  final String href;
  final String method;
  final String rel;

  PlayHTLink({
    required this.contentType,
    required this.description,
    required this.href,
    required this.method,
    required this.rel,
  });

  factory PlayHTLink.fromJson(Map<String, dynamic> json) {
    return PlayHTLink(
      contentType: json.getString('contentType'),
      description: json.getString('description'),
      href: json.getString('href'),
      method: json.getString('method'),
      rel: json.getString('rel'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contentType': contentType,
      'description': description,
      'href': href,
      'method': method,
      'rel': rel,
    };
  }

  @override
  String toString() {
    return 'PlayHTLink{contentType: $contentType, description: $description, href: $href, method: $method, rel: $rel}';
  }
}
