import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {


  const WebViewScreen(
      {super.key, required double latitude, required double longitude});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  final String googleMapsApiKey = 'AIzaSyCbOmTCOveIbJ-tPP_0eN8UTMmTBUtglzs';    


  @override
  void initState() {
    super.initState();

   const location = '40.749933,-73.98633'; // A location in New York
 
    _controller = WebViewController()
      ..loadRequest(Uri.parse(
          'https://www.google.com/maps/embed/v1/streetview?key=$googleMapsApiKey&location=$location'));
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}