import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({required this.camera});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final TextRecognizer textRecognizer = GoogleMlKit.vision.textRecognizer();
  final ImagePicker _picker = ImagePicker();
  String extractedText = '';
  bool isTextExtracted = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    textRecognizer.close();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';

      // Capture the image and save it
      await _controller.takePicture().then((XFile file) async {
        await file.saveTo(filePath);
        print('Picture saved to $filePath');

        // Extract text from the image
        await _extractTextFromImage(File(filePath));
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        print('Image selected: ${pickedFile.path}');
        await _extractTextFromImage(File(pickedFile.path));
      }
    } catch (e) {
      print('Error selecting image: $e');
    }
  }

  Future<void> _extractTextFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);

    // Process the image using the TextRecognizer
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    setState(() {
      extractedText = recognizedText.text;
      isTextExtracted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Extract Text'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: isTextExtracted
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      extractedText.isNotEmpty
                          ? extractedText
                          : 'No text detected!',
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: extractedText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Text copied to clipboard!')),
                        );
                      },
                      icon: Icon(Icons.copy),
                      label: Text('Copy Text'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isTextExtracted = false;
                        });
                      },
                      child: Text('Process Another Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      CameraPreview(_controller),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: _selectFromGallery,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.all(15),
                                  backgroundColor: Colors.teal.shade700,
                                  shape: CircleBorder(),
                                ),
                                child: Icon(
                                  Icons.image,
                                  size: 30, // Make the icon smaller
                                  color:
                                      Colors.white, // Set icon color to white
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _takePicture,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.all(15),
                                  backgroundColor: Colors.teal.shade700,
                                  shape: CircleBorder(),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 30, // Make the icon smaller
                                  color:
                                      Colors.white, // Set icon color to white
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }
}
