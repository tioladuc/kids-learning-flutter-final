import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../providers/course_provider.dart';
import '../../../providers/session_provider.dart';
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
  BuildContext? contextOther;

  @override
  void deactivate() {
    CourseProvider.endWebUrlCourse(widget.code);
    print("Widget deactivated");
    SessionProvider.child!.name += '**deactivate';
    super.deactivate();
  }
  
  @override
  void dispose() {
    CourseProvider.endWebUrlCourse(widget.code);    
    SessionProvider.child!.name += '==dispose'; // Trigger a rebuild to update the UI
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SessionProvider.child!.name += '++init';
    CourseProvider.endWebUrlCourse(widget.code);
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    contextOther = context;
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