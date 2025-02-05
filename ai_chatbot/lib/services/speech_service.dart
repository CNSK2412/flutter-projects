import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextService {
  final stt.SpeechToText speech = stt.SpeechToText();

  Future<String> listen() async {
    bool available = await speech.initialize();
    if (!available) return "Speech recognition not available";

    Completer<String> completer = Completer<String>();
    speech.listen(onResult: (result) {
      if (!completer.isCompleted) {
        completer.complete(result.recognizedWords);
      }
    });

    await Future.delayed(Duration(seconds: 3));
    speech.stop();
    return completer.future;
  }
}
