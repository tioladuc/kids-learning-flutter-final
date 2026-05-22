import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:kids_learning_flutter_app/widgets/app_scaffold.dart';

import '../../../providers/course_provider.dart';

class ApplicationViewHtml extends StatefulWidget {
  final String url;
  final String code;

  const ApplicationViewHtml({
    super.key,
    required this.url,
    required this.code,
  });

  @override
  State<ApplicationViewHtml> createState() => _ApplicationViewHtmlState();
}

class _ApplicationViewHtmlState extends State<ApplicationViewHtml> {
  late final String viewType;

  @override
  void deactivate() {
    CourseProvider.endWebUrlCourse(widget.code);
    print("Widget deactivated");

    super.deactivate();
  }

  @override
  void initState() {
    super.initState();

    print('sssssssssssssssss START======= '+widget.code+' ======= dddddddddddddddddddd');
    CourseProvider.startWebUrlCourse(widget.code);

    viewType = 'iframe-${widget.code}-${DateTime.now().millisecondsSinceEpoch}';

    ui.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = widget.url
          ..style.border = 'none'
          ..width = '100%'
          ..height = '100%';

        return iframe;
      },
    );
  }

  @override
  void dispose() {
    CourseProvider.endWebUrlCourse(widget.code);
    print('sssssssssssssssss END======= '+widget.code+' ======= dddddddddddddddddddd');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: HtmlElementView(
          viewType: viewType,
        ),
      ),
    );
  }
}