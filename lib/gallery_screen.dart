import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker _picker = ImagePicker();

  List<XFile>? images;
  int _currentPage = 0;
  final _pagecontroller = PageController();

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    images = await _picker.pickMultiImage();

    if (images != null) {
      Timer.periodic(const Duration(seconds: 4), (timer) {
        _currentPage++;
        if (_currentPage > images!.length - 1) {
          _currentPage = 0;
        }
        _pagecontroller.animateToPage(_currentPage,
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전자액자'),
      ),
      body: images == null
          ? const Center(child: Text('No Data'))
          : PageView(
              controller: _pagecontroller,
              children: images!.map((image) {
                return FutureBuilder<Uint8List>(
                    future: image.readAsBytes(),
                    builder: (context, snapshot) {
                      final data = snapshot.data;

                      // data 가 null 이거나 데이터 연결 상태가 로딩 중이라면 --
                      if (data == null ||
                          snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return Image.memory(
                        data,
                        width: double.infinity,
                      );
                    });
              }).toList(),
            ),
    );
  }
}
