import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'services/pixabay_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixabay Gallery',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ImageGalleryScreen(),
    );
  }
}

class ImageGalleryScreen extends StatefulWidget {
  @override
  _ImageGalleryScreenState createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  final PixabayService _pixabayService = PixabayService();
  final ScrollController _scrollController = ScrollController();
  List<PixabayImage> _images = [];
  int _page = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreImages();
    }
  }

  Future<void> _loadImages() async {
    setState(() {
      _isLoading = true;
    });

    final newImages = await _pixabayService.fetchImages(_page);
    setState(() {
      _images.addAll(newImages);
      _isLoading = false;
    });
  }

  Future<void> _loadMoreImages() async {
    _page++;
    _loadImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pixabay Gallery'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    double height = (kIsWeb)?380:200;

    double width = ((MediaQuery.of(context).size.width -
                (_calculateCrossAxisCount(context) * 10)) /
            _calculateCrossAxisCount(context));

    if (_isLoading && _images.isEmpty) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: width / height,
                crossAxisCount: _calculateCrossAxisCount(context),
                controller: _scrollController,
                children: List.generate(_images.length, (index) {
                  final image = _images[index];
                  return _buildImageCard(image);
                }),
              ),
            ),
          ),
          if (_isLoading) CircularProgressIndicator(),
        ],
      );
    }
  }

  int _calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return 5;
    } else if (screenWidth > 800) {
      return 3;
    } else {
      return 2;
    }
  }

  Widget _buildImageCard(PixabayImage image) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              height: (kIsWeb)
                  ? MediaQuery.of(context).size.height / 3.5
                  : MediaQuery.of(context).size.height / 6.8,
              child: Image.network(image.imageUrl, fit: BoxFit.fill)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Likes: ${image.likes}, \nViews: ${image.views}'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// model/pixabay_image.dart
class PixabayImage {
  final String imageUrl;
  final int likes;
  final int views;

  PixabayImage({
    required this.imageUrl,
    required this.likes,
    required this.views,
  });

  factory PixabayImage.fromJson(Map<String, dynamic> json) {
    return PixabayImage(
      imageUrl: json['webformatURL'],
      likes: json['likes'],
      views: json['views'],
    );
  }
}
