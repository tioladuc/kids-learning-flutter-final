import 'package:flutter/material.dart';
import 'package:kids_learning_flutter_app/screens/introscreen/main_intro_screen_child.dart';
import 'package:provider/provider.dart';
import '../../core/constances.dart';
import '../../core/core_translator.dart';
import '../../core/notify_data.dart';
import '../../models/child.dart';
import '../../providers/session_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../audio/audio_list_screen.dart';
import 'parent/parent_child_screen.dart';

class MainIntroScreenParent extends StatefulWidget {
  const MainIntroScreenParent({super.key});

  @override
  State<MainIntroScreenParent> createState() => _MainIntroScreenParent();
}

class _MainIntroScreenParent extends State<MainIntroScreenParent> {
  Translator translator = Translator();

  void _navigateTo(Child? item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ParentChildScreen(child: item!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    SessionProvider session = context.watch<SessionProvider>();
    final notifyData = context.watch<NotifyData>();
    translator = Translator(
      status: StatusLangue.CONSTANCE_PARENT,
      lang: notifyData.currentLanguage,
    );

    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: Constant.getTitle1ButtonStyle(),
                child: Text(translator.getText('menuTitrePageIntroParent')),
              ),
            ),

            const SizedBox(height: 16),

            // Children list
            Expanded(
              child: SessionProvider.parent!.children.isEmpty
                  ? Center(
                      child: Text(translator.getText('menuNoChildRegister')),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: SessionProvider.parent?.children.length,
                      itemBuilder: (context, index) {
                        final item = SessionProvider.parent?.children[index];

                        return GestureDetector(
                          onTap: () => _navigateTo(item),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 16,
                            ),
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
                                Icon(
                                  Icons.person_3_outlined,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    item!.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        (SessionProvider.parent?.currentChild !=
                                                null &&
                                            item.id ==
                                                SessionProvider
                                                    .parent
                                                    ?.currentChild
                                                    ?.id)
                                        ? Colors.blue
                                        : Colors.grey, // The background color
                                    shape: BoxShape
                                        .circle, // The shape of the background
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.bluetooth_audio_outlined,
                                    ),
                                    color:
                                        (SessionProvider.parent?.currentChild !=
                                                null &&
                                            item.id ==
                                                SessionProvider
                                                    .parent
                                                    ?.currentChild
                                                    ?.id)
                                        ? Colors.white
                                        : Colors.black,
                                    onPressed: () {
                                      // Handle button press
                                      session.setCurrentChildAsParent(item);

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const MainIntroScreenChild(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 10),

            // Actions
            Center(
              child: ElevatedButton.icon(
                onPressed: () {_showAddChildDialog(context, notifyData); setState(() {});},
                icon: const Icon(Icons.person_add),
                label: Text(translator.getText('menuAddChild')),
                style: Constant.getTitle3ButtonStyle(),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: () =>
                    _showChangePasswordDialog(context, session, notifyData),
                icon: const Icon(Icons.lock),
                label: Text(translator.getText('menuChangeNameAndPwd')),
                style: Constant.getTitle3ButtonRedStyle(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // Add Child Dialog
  // -------------------------
  void _showAddChildDialog(BuildContext context, NotifyData notifyData) {
    final controllerLogin = TextEditingController();
    final controllerPassword = TextEditingController();
    final controllerName = TextEditingController();
    final levelController = TextEditingController();
    final Map<String, String> levels = SessionProvider.GetLevel();
    String currentLevel = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translator.getText('titleAddChild')),
        content: Column(
          children: [
          DropdownMenu<String>(
          controller: levelController,
          requestFocusOnTap: false,
          enableFilter: false,
          keyboardType: TextInputType.none,
          width: 250,
          label: Text(translator.getText('labelChildLevel')),
          dropdownMenuEntries: levels.entries.map((entry) {
            return DropdownMenuEntry<String>(
              value: entry.key,
              label: entry.value,
            );
          }).toList(),
          onSelected: (value) {
            print("Selected: $value");
            currentLevel = value!;
          },
        ),
        SizedBox(height: 10),
            TextField(
              controller: controllerName,
              decoration: InputDecoration(
                labelText: translator.getText('labelChildName'),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: controllerLogin,
              decoration: InputDecoration(
                labelText: translator.getText('labelChildLogin'),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: controllerPassword,
              decoration: InputDecoration(
                labelText: translator.getText('labelChildPwd'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translator.getText('labelChildCancelButton')),
          ),
          ElevatedButton(
            onPressed: () {
              if (controllerLogin.text.isNotEmpty &&
                  controllerName.text.isNotEmpty &&
                  controllerPassword.text.isNotEmpty) {
                context.read<SessionProvider>().addChild(
                  controllerLogin.text,
                  controllerName.text,
                  controllerPassword.text,
                  currentLevel
                );
                Navigator.pop(context);
              }
            },
            child: Text(translator.getText('labelChildSaveButton')),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // Change Password Dialog
  // -------------------------
  void _showChangePasswordDialog(
    BuildContext context,
    SessionProvider session,
    NotifyData notifyData,
  ) {
    final controllerFirstName = TextEditingController();
    final controllerLastName = TextEditingController();
    final controllerPassword = TextEditingController();
    controllerFirstName.text = SessionProvider.parent!.firstName ?? '';
    controllerLastName.text = SessionProvider.parent!.lastName ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translator.getText('labelTitleParentPwdChange')),
        content: Column(
          children: [
            TextField(
              controller: controllerFirstName,
              decoration: InputDecoration(
                labelText: translator.getText('labelFirstNameParentPwdChange'),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: controllerLastName,
              decoration: InputDecoration(
                labelText: translator.getText('labelLastNameParentPwdChange'),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: controllerPassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: translator.getText('labelNameParentPwdChange'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translator.getText('labelCancelButtonParentPwdChange')),
          ),
          ElevatedButton(
            onPressed: () {
              if (controllerFirstName.text.isNotEmpty &&
                  controllerLastName.text.isNotEmpty &&
                  controllerPassword.text.isNotEmpty) {
                context.read<SessionProvider>().changeParentPassword(
                  controllerFirstName.text,
                  controllerLastName.text,
                  controllerPassword.text,
                );
                Navigator.pop(context);
              }
            },
            child: Text(translator.getText('labelSaveButtonParentPwdChange')),
          ),
        ],
      ),
    );
  }
}
