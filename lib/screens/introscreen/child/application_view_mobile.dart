import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../providers/course_provider.dart';
import '../../../widgets/app_scaffold.dart';

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
  late final WebViewController controller;

  @override
  void deactivate() {
    CourseProvider.endWebUrlCourse(widget.code);
    print("Widget deactivated");

    super.deactivate();
  }
  
  @override
  void dispose() {
    CourseProvider.endWebUrlCourse(widget.code);    
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    CourseProvider.endWebUrlCourse(widget.code);
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}