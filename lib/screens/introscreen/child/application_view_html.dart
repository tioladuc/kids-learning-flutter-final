import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Web-only imports
import 'dart:ui_web' as ui;
import 'dart:html' as html;

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
  WebViewController? controller;
  late final String viewType;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      viewType = 'html-view-${widget.url.hashCode}';

      ui.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) {
          final iframe = html.IFrameElement()
            ..src = widget.url
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allowFullscreen = true;

          return iframe;
        },
      );
    } else {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return HtmlElementView(viewType: viewType);
    }

    return WebViewWidget(controller: controller!);
  }
}