import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ApplicationViewHtml extends StatefulWidget {
  final String url;

  const ApplicationViewHtml({
    super.key,
    required this.url,
  });

  @override
  State<ApplicationViewHtml> createState() => _ApplicationViewHtmlState();
}

class _ApplicationViewHtmlState extends State<ApplicationViewHtml> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}