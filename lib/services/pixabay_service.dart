import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';

class PixabayService {
  final String _apiKey = '46383086-94e49e812d3b2b7bed5c14583';  // Replace with your API Key
  final String _baseUrl = 'https://pixabay.com/api/';

  Future<List<PixabayImage>> fetchImages(int page) async {
    final response = await http.get(Uri.parse(
        '$_baseUrl?key=$_apiKey&image_type=photo&per_page=20&page=$page'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List images = data['hits'];
      return images.map((image) => PixabayImage.fromJson(image)).toList();
    } else {
      throw Exception('Failed to load images');
    }
  }
}
