import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camerascreen.dart'; // Added import for CameraScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fetch available cameras
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Extractor',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MainPage(camera: camera),
    );
  }
}

class MainPage extends StatelessWidget {
  final CameraDescription camera;

  const MainPage({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Extractor'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade400, Colors.teal.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, size: 100, color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Welcome to Text Extractor!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'This app lets you extract text from images captured using your camera. '
                'You can also copy the extracted text to your clipboard.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor:
                      Colors.white, // Set background color to white
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraScreen(camera: camera),
                    ),
                  );
                },
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.teal, // Set text color to red
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
