import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'package:flutter/material.dart';

class ApplicationViewHtml extends StatelessWidget {
  final String url;

  const ApplicationViewHtml({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final String viewType = 'iframe-$url';

    ui.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = url
          ..style.border = 'none'
          ..width = '100%'
          ..height = '100%';

        return iframe;
      },
    );

    return HtmlElementView(viewType: viewType);
  }
}