import 'package:flutter/material.dart';
import 'package:kids_learning_flutter_app/screens/introscreen/main_intro_screen_parent.dart';
import 'package:provider/provider.dart';
import '../../../core/constances.dart';
import '../../../core/core_translator.dart';
import '../../../core/notify_data.dart';
import '../../../models/child.dart';
import '../../../providers/session_provider.dart';
import '../../../widgets/app_scaffold.dart';
import '../main_intro_screen_child.dart';
import '../statistics/intro_statistics.dart';
import 'parent_pending_screen.dart';

class ParentChildScreen extends StatefulWidget {
  final Child child;

  const ParentChildScreen({super.key, required this.child});

  @override
  State<ParentChildScreen> createState() => _ParentChildScreenState();
}

class _ParentChildScreenState extends State<ParentChildScreen> {
  late TextEditingController _nameController;
  late TextEditingController _loginController;
  TextEditingController _levelController = TextEditingController();
  late TextEditingController _passwordController;
  Translator translator = Translator();
  final Map<String, String> levels = SessionProvider.GetLevel();

  late Child _editableChild;

  @override
  void initState() {
    super.initState();

    // Create a copy to avoid modifying original directly
    _editableChild = Child.copy(widget.child);
    print('***********************=='+ _editableChild.password +'==***111111*******************');
    _nameController = TextEditingController(text: _editableChild.name);
    print('***********************=='+ _editableChild.password +'==***2222222*******************');
    _passwordController = TextEditingController(text: _editableChild.password);
    print('***********************=='+ _editableChild.password +'==***33333333*******************');
    _levelController = TextEditingController( text: _editableChild.level );
    print('***********************=='+ _editableChild.password +'==****4444444******************');
    _loginController = TextEditingController(text: _editableChild.login);
    print('***********************=='+ _editableChild.password +'==**5555555********************');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _loginController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  // -------------------------
  // SAVE CHANGES
  // -------------------------
  void _saveChanges(NotifyData notifyData) {
    final session = context.read<SessionProvider>();

    _editableChild.name = _nameController.text;
    _editableChild.password = _passwordController.text;

    // TODO: implement update in provider / API
    setState(() {
      session.changePasswordParentChild(
        _nameController.text,
        _passwordController.text,
        _levelController.text,
        _loginController.text,
        widget.child
        

      );
    });
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainIntroScreenParent()),
      (Route<dynamic> route) => false, // Removes all routes below the new one
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translator.getText('detailedChildPageChildUpdate')),
      ),
    );
  }

  // -------------------------
  // DELETE CHILD
  // -------------------------

  void _deleteChild(NotifyData notifyData) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translator.getText('childDeleteTitle')),
        content: Text(translator.getText('childDeleteContain')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translator.getText('childDeleteCancelButton')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<SessionProvider>().deleteChild(widget.child.id);

              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(translator.getText('childDeleteAlertMessage')),
                ),
              );
            },
            child: Text(translator.getText('childDeleteDeleteButton')),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // VIEW STATISTICS
  // -------------------------
  void _viewStatistics() {
    // TODO: navigate to statistics screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IntroStatistics(
          child: widget.child,
          isViewParent: true,
          isResponsible: widget.child.parentResponsible!,
        ),
      ),
    );
  }

  // -------------------------
  // VIEW PENDING COURSES
  // -------------------------
  void _viewPendingCourses() {
    // TODO: navigate to statistics screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParentChildPendingScreen(
          child: widget.child,
          isResponsible: widget.child.parentResponsible!,
        ),
      ),
    );
  }

  // -------------------------
  // SETTING THE RESPONSIBLE OF THE CHILD
  // -------------------------
  void setParentAsResponsible(SessionProvider session) {
    session.setParentAsReponsibleOfChild(
      isResponsible: !widget.child.parentResponsible!,
      child: widget.child,
    );
  }

  // -------------------------
  // WORK AS CHILD
  // -------------------------
  void _workAsChild(NotifyData notifyData) {
    final session = context.read<SessionProvider>();

    // TODO: implement child login
    session.setCurrentChildAsParent(widget.child);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainIntroScreenChild()),
      (Route<dynamic> route) => false, // Removes all routes below the new one
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(translator.getText('childParentWorkAsChild'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww');
    final notifyData = context.watch<NotifyData>();
    final session = context.watch<SessionProvider>();
    String currentLevel = widget.child.level;
    print('tttttttttttttttttttttttttttttttttttt');
    print(session);
    print(widget.child.parentResponsible!);
    print('tttttttttttttttttttttttttttttttttttt');
    translator = Translator(
      status: StatusLangue.CONSTANCE_PARENT,
      lang: notifyData.currentLanguage,
    );
    print('7777777777777777777777777777777777777777777777777');
    _levelController.text = SessionProvider.GetLevel()[widget.child.level]! ;
    print('55555555555555555555555555555555555555555');
    print(widget.child.id);
    print(SessionProvider.parent!.codeparent);
    print('55555555555555555555555555555555555555555');

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {},
              style: Constant.getTitle1ButtonStyle(),
              child: Text(translator.getText('labelTitleChildIdDetail')),
            ),
            // -------------------------
            // CHILD INFO CARD
            // -------------------------
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.child_care, size: 60, color: Colors.blue),
                    const SizedBox(height: 10),

                    Text(
                      translator.getText('labelChildParentCode') +
                          ": ${SessionProvider.parent!.codeparent}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      translator.getText('labelChildId') +
                          ": ${widget.child.id}",
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 20),

                    DropdownMenu<String>(
                      controller: _levelController,
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

                    const SizedBox(height: 20),

                    // Name
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: translator.getText('labelChildNameDetail'),
                        border: const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Login (readonly)
                    TextField(
                      controller: _loginController,
                      readOnly: false,
                      decoration: InputDecoration(
                        labelText: translator.getText('labelChildLoginDetail'),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Password
                    TextField(
                      controller: _passwordController,
                      obscureText: false,
                      decoration: InputDecoration(
                        labelText: translator.getText(
                          'labelChildPasswordDetail',
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Save button
                    ElevatedButton.icon(
                      onPressed: () {
                        _saveChanges(notifyData);
                      },
                      icon: const Icon(Icons.save),
                      label: Text(
                        translator.getText('labelChildSaveChangesDetail'),
                      ),
                      style: Constant.getTitle3ButtonStyle(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // -------------------------
            // ACTIONS
            // -------------------------
            //=================================================================
            //=================================================================
            //=================================================================
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.timer),
                    title: Text(
                      translator.getText('labelChildPendingCourseDetail'),
                    ),
                    onTap: _viewPendingCourses,
                  ),
                  if (widget.child.parentResponsible!)
                    ListTile(
                      leading: const Icon(Icons.money_off_csred_outlined),
                      title: Text(
                        translator.getText(
                          'labelChildRemoveFinancialAuthority',
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          session.setParentAsReponsibleOfChild(
                            isResponsible: false,
                            child: widget.child,
                          );
                        });
                      },
                    ),
                  if (!widget.child.parentResponsible!)
                    ListTile(
                      leading: const Icon(Icons.monetization_on_outlined),
                      title: Text(
                        translator.getText(
                          'labelChildAcquisitionFinancialAuthority',
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          session.setParentAsReponsibleOfChild(
                            isResponsible: false,
                            child: widget.child,
                          );
                        });
                      },
                    ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: Text(
                      translator.getText('labelChildViewStatsDetail'),
                    ),
                    onTap: _viewStatistics,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.play_circle_fill),
                    title: Text(translator.getText('labelChildWorkAsDetail')),
                    onTap: () {
                      _workAsChild(notifyData);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: Text(
                      translator.getText('labelChildDeleteChildDetail'),
                    ),
                    onTap: () {
                      _deleteChild(notifyData);
                    },
                  ),
                ],
              ),
            ),
          
          //=================================================================
            //=================================================================
            //=================================================================
          ],
        ),
      ),
    );
  }
}
