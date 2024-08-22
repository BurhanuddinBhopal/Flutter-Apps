import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePage extends StatelessWidget {
  final String imageUrl;

  const ImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(62, 13, 59, 1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: imageUrl != null
            ? Container(
                constraints: const BoxConstraints.expand(),
                child: PhotoView(
                  imageProvider: NetworkImage(imageUrl),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2.5,
                ),
              )
            : const Text(
                "Image URL is null!",
                style: TextStyle(fontSize: 24),
              ),
      ),
    );
  }
}
