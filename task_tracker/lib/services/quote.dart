import 'package:http/http.dart';
import 'dart:convert';

class Quote {
  String quote = "";
  String author = "";

  Future<void> getQuote() async {
    Response response =
        await get(Uri.parse('https://zenquotes.io/api/random/')); // API
    List data = jsonDecode(response.body);
    quote = data[0]['q'];
    author = data[0]['a'];
  }
}
