import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  /// Listens for speech input and returns the recognized text.
  /// [timeoutInSeconds] specifies the maximum duration to listen (default: 3 seconds).
  Future<String> listen({int timeoutInSeconds = 3}) async {
    // Check if speech recognition is available
    bool available = await _speech.initialize(
      onError: (error) => print("Speech recognition error: $error"),
      onStatus: (status) => print("Speech recognition status: $status"),
    );

    if (!available) {
      return "Speech recognition not available";
    }

    Completer<String> completer = Completer<String>();
    _isListening = true;

    // Start listening for speech input
    _speech.listen(onResult: (result) {
      if (!completer.isCompleted && result.finalResult) {
        _isListening = false;
        completer.complete(result.recognizedWords);
      }
    });

    // Stop listening after the specified timeout
    await Future.delayed(Duration(seconds: timeoutInSeconds));
    if (_isListening) {
      _speech.stop();
      if (!completer.isCompleted) {
        completer.complete("No speech detected");
      }
    }

    return completer.future;
  }

  /// Stops listening immediately and releases resources.
  void stop() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }

  /// Releases resources when the service is no longer needed.
  void dispose() {
    _speech.cancel();
    _isListening = false;
  }
}
