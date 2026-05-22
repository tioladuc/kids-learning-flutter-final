import 'package:flutter/material.dart';
import 'package:kids_learning_flutter_app/screens/session/login_screen.dart';
import 'package:provider/provider.dart';
import '../core/constances.dart';
import '../core/core_translator.dart';
import '../core/notify_data.dart';
import '../providers/session_provider.dart';

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeader();

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class _AppHeader extends State<AppHeader> with ChangeNotifier {
  String currentLanguage = Constant.currentLanguage;
  Translator translator = Translator();

  @override
  void dispose() {
    // your cleanup code here

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final notifyData = context.watch<NotifyData>();
    translator = Translator(
      status: StatusLangue.CONSTANCE_CONSTANCE,
      lang: notifyData.currentLanguage,
    );

    return AppBar(
      centerTitle: true,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 3, 54, 241),
              Color.fromARGB(255, 235, 243, 236),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      title: Text(
        translator.getText('AppName'),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        ElevatedButton(
          style: Constant.getTitle3ButtonStyle(),
          child: Text(notifyData.displayLanguageChanger()),
          onPressed: () => {
            setState(() {
              currentLanguage = currentLanguage == NotifyData.languageEN
                  ? NotifyData.languageFR
                  : NotifyData.languageEN;
              ;
              Constant.currentLanguage = currentLanguage;
              notifyData.changeLanguage(currentLanguage);
            }),
          },
        ),

        IconButton(
          icon: Icon(session.isLoggedIn ? Icons.logout : Icons.login),
          onPressed: () {
            if (session.isLoggedIn) {
              session.setRole(null);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
