import 'package:flutter/material.dart';
import 'package:kids_learning_flutter_app/core/notify_data.dart';
import 'package:kids_learning_flutter_app/screens/introscreen/main_intro_screen_child.dart';
import 'package:provider/provider.dart';
import '../../core/constances.dart';
import '../../core/core_translator.dart';
import '../../providers/course_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../introscreen/main_intro_screen_parent.dart';
import 'create_parent_account.dart';
import 'parent_reset.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final controllerLogin = TextEditingController();
  final controllerCode = TextEditingController();
  final controllerPwd = TextEditingController();
  SessionProvider session = SessionProvider();
  Translator translator = Translator();

  String selectedProfile = "";

  void chooseLoginChoice(String choice) {
    setState(() {
      selectedProfile = choice;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    final notifyData = context.watch<NotifyData>();
    translator = Translator(
      status: StatusLangue.CONSTANCE_SESSION,
      lang: notifyData.currentLanguage,
    );
    session = context.watch<SessionProvider>();

    return AppScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedProfile != '')
              ElevatedButton(
                onPressed: () => chooseLoginChoice(''),
                style: Constant.getTitle1ButtonStyle(),
                child: Text(translator.getText('ReturnLoginChoices')),
              ),
            if (selectedProfile != '') const SizedBox(height: 24),
            if (selectedProfile == '' ||
                selectedProfile == NotifyData.ChoiceChild)
              ElevatedButton(
                onPressed: () => chooseLoginChoice(NotifyData.ChoiceChild),
                style: selectedProfile == NotifyData.ChoiceChild
                    ? Constant.getTitle1ButtonStyleWhite()
                    : Constant.getTitle1ButtonStyleBlack(),
                child: Text(translator.getText('LoginAsChild')),
              ),
            if (selectedProfile == '' ||
                selectedProfile == NotifyData.ChoiceChild)
              const SizedBox(height: 24),
            if (selectedProfile == '' ||
                selectedProfile == NotifyData.ChoiceParent)
              ElevatedButton(
                onPressed: () => chooseLoginChoice(NotifyData.ChoiceParent),
                style: selectedProfile == NotifyData.ChoiceParent
                    ? Constant.getTitle1ButtonStyleWhite()
                    : Constant.getTitle1ButtonStyleBlack(),
                child: Text(translator.getText('LoginAsParent')),
              ),
            /*if (selectedProfile == '' ||
                selectedProfile == NotifyData.ChoiceParent)
              const SizedBox(height: 24),
            if (selectedProfile == NotifyData.ChoiceParent ||
                selectedProfile == NotifyData.ChoiceChild)
              TextField(
                controller: controllerLogin,
                decoration: InputDecoration(
                  labelText: translator.getText('LoginText'),
                ),
              ),*/



            if (selectedProfile == '' ||
                selectedProfile == NotifyData.ChoiceParent)
              const SizedBox(height: 24),
            if (selectedProfile == NotifyData.ChoiceParent ||
                selectedProfile == NotifyData.ChoiceChild)
              TextField(
                controller: controllerCode,
                decoration: InputDecoration(
                  labelText: translator.getText('CodeParent'),
                ),
              ),

              if (selectedProfile == '' ||
                selectedProfile == NotifyData.ChoiceParent)
              const SizedBox(height: 24),
            if (selectedProfile == NotifyData.ChoiceParent ||
                selectedProfile == NotifyData.ChoiceChild)
              TextField(
                controller: controllerLogin,
                decoration: InputDecoration(
                  labelText: translator.getText('LoginText'),
                ),
              ),






            if (selectedProfile == NotifyData.ChoiceParent ||
                selectedProfile == NotifyData.ChoiceChild)
              const SizedBox(height: 24),
            if (selectedProfile == NotifyData.ChoiceParent ||
                selectedProfile == NotifyData.ChoiceChild)
              TextField(
                controller: controllerPwd,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: translator.getText('PasswordText'),
                ),
              ),
            if (selectedProfile == NotifyData.ChoiceParent ||
                selectedProfile == NotifyData.ChoiceChild)
              const SizedBox(height: 24),
            if (selectedProfile == NotifyData.ChoiceParent ||
                selectedProfile == NotifyData.ChoiceChild)
              ElevatedButton(
                style: Constant.getTitle3ButtonStyle(),
                onPressed: () async {
                  bool success = await session.login(
                    selectedProfile,
                    controllerLogin.text,
                    controllerPwd.text,
                    controllerCode.text
                  );

                  if (success) {
                    session.setRole(selectedProfile);

                    notifyData.setCurrentBottomPosition(1);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => session.role == NotifyData.ChoiceChild
                            ? const MainIntroScreenChild()
                            : const MainIntroScreenParent(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(session.errorMessage ?? "Error")),
                    );
                  }
                },
                child: session.isLoginLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(translator.getText('LoginButton')),
              ),

            if (selectedProfile == '' ||
                selectedProfile == NotifyData.ChoiceParent)
              FractionallySizedBox(
                widthFactor: 0.5, // 50% of the parent width
                child: Divider(
                  color: Colors.blue,
                  thickness: 5.0,
                  indent: 20.0,
                  endIndent: 20.0,
                  height: 30.0,
                ),
              ),
            if (selectedProfile == '' ||
                selectedProfile == NotifyData.ChoiceParent)
              const SizedBox(height: 24),
            if (selectedProfile == '' ||
                selectedProfile == NotifyData.ChoiceParent)
              ElevatedButton(
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CreateParentAccount()),
                  ),
                },
                style: selectedProfile == NotifyData.ChoiceParent
                    ? Constant.getTitle1ButtonStyleForResetCreate()
                    : Constant.getTitle1ButtonStyleForResetCreate(),
                child: Text(translator.getText('CreateParentAccount')),
              ),
            if (selectedProfile == '' ||
                selectedProfile == NotifyData.ChoiceParent)
              const SizedBox(height: 24),
            /*if (selectedProfile == '' ||
                selectedProfile == NotifyData.ChoiceParent)*/
                if(selectedProfile == NotifyData.ChoiceParent)//==duclair==
              ElevatedButton(
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ParentReset()),
                  ),
                },
                style: selectedProfile == NotifyData.ChoiceParent
                    ? Constant.getTitle1ButtonStyleForResetCreate()
                    : Constant.getTitle1ButtonStyleForResetCreate(),
                child: Text(translator.getText('ResetParentAccount')),
              ),
            if (selectedProfile == '' ||
                selectedProfile == NotifyData.ChoiceParent)
              const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
