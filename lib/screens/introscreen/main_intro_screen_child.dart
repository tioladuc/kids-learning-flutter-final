import 'package:flutter/material.dart';
import 'package:kids_learning_flutter_app/core/constances.dart';
import 'package:kids_learning_flutter_app/providers/course_provider.dart';
import 'package:kids_learning_flutter_app/providers/session_provider.dart';
import 'package:kids_learning_flutter_app/screens/introscreen/main_intro_screen_parent.dart';
import 'package:provider/provider.dart';
import '../../core/core_translator.dart';
import '../../core/notify_data.dart';
import '../../models/course.dart';
import '../../widgets/app_scaffold.dart';
import '../audio/audio_list_screen.dart';
import 'child/application_view_html.dart';
import 'logout_screen.dart';
import 'child/child_pending_screen.dart';
import 'child/child_pick_course.dart';
import 'statistics/intro_statistics.dart';

class MainIntroScreenChild extends StatefulWidget {
  const MainIntroScreenChild({super.key});

  @override
  State<MainIntroScreenChild> createState() => _MainIntroScreenChild();
}

class _MainIntroScreenChild extends State<MainIntroScreenChild> {
  List<Map<String, dynamic>> menuItems = [];
  Translator translator = Translator();
  List<Course> courses = [];
  CourseProvider courseProvider = CourseProvider();
  bool isLoadingAvailable = false;

  List<Map<String, dynamic>> produceMenuItemsFromCoursesNotUrlAndStaticMenus(
    String langue,
    SessionProvider session,
  ) {
    String logoutDisplay = '';

    if (SessionProvider.parent != null) {
      logoutDisplay = translator.getText('menuLogoutChildParent');
    } else {
      logoutDisplay = translator.getText('menuLogout');
    }

    return [
      //all url menu
      for(var item in courses.where((x)=>x.url !=null && x.url!=''))
        {
          "title": item.name,
          "icon": Icons.mic,
          "key": item.code,

          "url": item.url,
          "description": item.description,
          "amount": item.amount,
          "level": item.level,

        },
      //Menu for dictation
      if (courses.any((elt) => elt.code == 'C000'))
        {
          "title": translator.getText('menuDictation'),
          "icon": Icons.mic,
          "key": 'C000',

          "url": Null,
          "description": Null,
          "amount": Null,
          "level": Null,

        },
        //Menus for statics operations
      {
        "title": translator.getText('menuPickCourse'),
        "icon": Icons.menu_book,
        "key": 'PickACourse',

          "url": Null,
          "description": Null,
          "amount": Null,
          "level": Null,
      },
      {
        "title": translator.getText('menuCoursesValidationPending'),
        "icon": Icons.hourglass_top,
        "key": 'CourseValidationPending',

          "url": Null,
          "description": Null,
          "amount": Null,
          "level": Null,
      },
      {
        "title": translator.getText('menuStatistics'),
        "icon": Icons.bar_chart,
        "key": 'Statistics',

          "url": Null,
          "description": Null,
          "amount": Null,
          "level": Null,
      },
      {"title": logoutDisplay, "icon": Icons.logout, "key": 'Logout'},
    ];
  }

  void _navigateToFromCoursesNotUrlAndStaticMenus(Map<String, dynamic> item, SessionProvider session) {
    if (item['url'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ApplicationViewHtml(url:item['url'])),
      );
    }
    //Custom navigation for dictation
    if (item['key'] == 'C000') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AudioListScreen()),
      );
    }
    //Navigation for specific courses
    if (item['key'] == 'PickACourse') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChildPickCourse(child: SessionProvider.child!),
        ),
      );
    }

    if (item['key'] == 'CourseValidationPending') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChildPendingScreen(child: SessionProvider.child!),
        ),
      );
    }

    if (item['key'] == 'Statistics') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => IntroStatistics(
            child: SessionProvider.child!,
            isResponsible: false,
            isViewParent: false,
          ),
        ),
      );
    }

    if (item['key'] == 'Logout') {
      if (SessionProvider.parent == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LogoutScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainIntroScreenParent()),
          (route) => false,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final courseProvider = context.read<CourseProvider>();
      await courseProvider.loadChildAvailableCourses(SessionProvider.child!.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifyData = context.watch<NotifyData>();
    final session = context.watch<SessionProvider>();
    final courseProvider = context.watch<CourseProvider>();

    translator = Translator(
      status: StatusLangue.CONSTANCE_CHILD,
      lang: notifyData.currentLanguage,
    );

    courses = courseProvider.availableCourses;
    menuItems = produceMenuItemsFromCoursesNotUrlAndStaticMenus(notifyData.currentLanguage, session);

    return AppScaffold(
      body: courseProvider.isLoadingAvailable
          ? const Center(child: CircularProgressIndicator())
          : produceInterface(session),
    );
  }

  Widget produceInterface(SessionProvider session) {
    courses = courseProvider.availableCourses;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];

        return GestureDetector(
          onTap: () => _navigateToFromCoursesNotUrlAndStaticMenus(item, session),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(item['icon'], color: Colors.blue),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
