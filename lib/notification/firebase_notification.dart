import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class NotificationApiHitting {
  Future<bool> callOnFcmApiSendPushNotifications({
    required String message,
    required String topic,
    required String type,
    required String title,
  }) async {
    const String postUrl = 'https://fcm.googleapis.com/fcm/send';
    const String authorization =
        'key=AAAADE-eIxo:APA91bEbrLxQ8KizBsbxdD-0vbDjivBRAxmZfP_EZ2nU2NvUOIvu_c5itybd3yOtB14Clg631UohZXM2vOyfnTFYJdGfVqJbz3cZG_t3p4VNcZ7v95sgmfA1v3IzV63FVpKlybfv2u5j';

    final data = {
      "to": "/topics/$topic", // Use the topic to send notifications to all users
      "collapse_key": "type_a",
      "notification": {
        "title": title,
        "body": message,
      },
      "priority": "high",
      "data": {
        "type": type,
        "jwm_message": message,
      }
    };

    Map<String, String> headers = {
      'content-type': 'application/json',
      'Authorization': authorization,
    };

    try {
      final response = await http.post(
        Uri.parse(postUrl),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // On success
        log(response.body.toString());
        return true;
      } else {
        // On failure
        log('<=============CFM error=============>');
        log(response.body.toString());
        return false;
      }
    } catch (ex) {
      log("Inside Catch Statement");
      log("Exception caught ${ex}");
      return false;
    }
  }
}