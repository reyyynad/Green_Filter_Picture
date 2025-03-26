import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker_web/image_picker_web.dart';

void main() {
  runApp(ProfileFilterApp());
}

class ProfileFilterApp extends StatelessWidget {
  const ProfileFilterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '3alaf Picture',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const ProfileFilterHomePage(),
    );
  }
}

class ProfileFilterHomePage extends StatefulWidget {
  const ProfileFilterHomePage({super.key});

  @override
  State<ProfileFilterHomePage> createState() => _ProfileFilterHomePageState();
}

class _ProfileFilterHomePageState extends State<ProfileFilterHomePage> {
  Uint8List? originalBytes;
  Uint8List? greenFilteredBytes;

  Future<void> pickImage() async {
    final imageBytes = await ImagePickerWeb.getImageAsBytes();
    if (imageBytes != null) {
      setState(() {
        originalBytes = imageBytes;
        greenFilteredBytes = applyGreenFilter(imageBytes);
      });
    }
  }

  Uint8List applyGreenFilter(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes)!;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        final a = pixel.a;

        image.setPixelRgba(
          x,
          y,
          (r * 0.4).toInt(),
          g,
          (b * 0.4).toInt(),
          a,
        );
      }
    }

    return Uint8List.fromList(img.encodePng(image));
  }

  void downloadFilteredImage() {
    if (greenFilteredBytes != null) {
      final blob = html.Blob([greenFilteredBytes!]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "green_profile.png")
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 64, 118, 80),
      appBar: AppBar(
        title: const Text(
          '3alaf Picture ',
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (greenFilteredBytes != null)
              Image.memory(greenFilteredBytes!, width: 200, height: 200)
            else
              const Text('No image selected.'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text(
                'Upload Profile Picture',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: pickImage,
              style: ElevatedButton.styleFrom(
                iconColor: Colors.black,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            if (greenFilteredBytes != null)
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text(
                  'Download Green Image',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: downloadFilteredImage,
                style: ElevatedButton.styleFrom(
                  iconColor: Colors.black,
                  backgroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
