import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BarkRecorder(),
    );
  }
}

class BarkRecorder extends StatefulWidget {
  @override
  _BarkRecorderState createState() => _BarkRecorderState();
}

class _BarkRecorderState extends State<BarkRecorder> {
  FlutterSoundRecorder? _recorder;
  bool isRecording = false;
  late String audioFilePath;

  @override
  void initState() {
    super.initState();
    initializeRecorder();
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    super.dispose();
  }

  Future<void> initializeRecorder() async {
    if (Platform.isIOS || Platform.isAndroid) {
      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();

      // Get a valid file path to save the audio
      Directory tempDir = await getTemporaryDirectory();
      audioFilePath = '${tempDir.path}/bark_audio.aac';
    } else {
      print("Audio recording is not supported on this platform.");
    }
  }

  Future<void> startRecording() async {
    if (_recorder == null) {
      print("Recorder not initialized.");
      return;
    }

    await _recorder!.startRecorder(toFile: audioFilePath);
    setState(() {
      isRecording = true;
    });
    print("Recording started...");
  }

  Future<void> stopRecordingAndSend() async {
    if (_recorder == null) {
      print("Recorder not initialized.");
      return;
    }

    await _recorder!.stopRecorder();
    setState(() {
      isRecording = false;
    });
    print("Recording stopped. File saved at: $audioFilePath");

    await sendAudioToApi(audioFilePath);
  }

  Future<void> sendAudioToApi(String filePath) async {
    final url = Uri.parse('https://your-api-endpoint.com/upload');
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();

    if (response.statusCode == 200) {
      print('Upload successful!');
    } else {
      print('Upload failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dog Bark Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isRecording ? null : startRecording,
              child: Text('Start Recording'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isRecording ? stopRecordingAndSend : null,
              child: Text('Stop & Send'),
            ),
          ],
        ),
      ),
    );
  }
}
