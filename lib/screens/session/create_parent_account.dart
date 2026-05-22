import 'package:flutter/material.dart';
import 'package:kids_learning_flutter_app/screens/session/login_screen.dart';
import 'package:provider/provider.dart';
import '../../core/constances.dart';
import '../../core/core_translator.dart';
import '../../core/notify_data.dart';
import '../../providers/session_provider.dart';
import '../../widgets/app_scaffold.dart';
import 'activate_parent_account.dart';

class CreateParentAccount extends StatefulWidget {
  const CreateParentAccount({super.key});

  @override
  State<CreateParentAccount> createState() => _CreateParentAccountState();
}

class _CreateParentAccountState extends State<CreateParentAccount> {
  final _formKey = GlobalKey<FormState>();
  Translator translator = Translator();

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final loginCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final codeCtrl = TextEditingController( text: SessionProvider.getRadom(6));

  Future<void> _submit(NotifyData notifyData) async {
    if (!_formKey.currentState!.validate()) return;

    final session = context.read<SessionProvider>();

    final success = await session.createParentAccount(
      firstName: firstNameCtrl.text,
      lastName: lastNameCtrl.text,
      login: loginCtrl.text,
      password: passwordCtrl.text,
      email: emailCtrl.text,
      codeParent: codeCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(),
                ), 
                (Route<dynamic> route) => false,
              );//==duclair==
      //==duclair==_showSuccessDialog(notifyData);
    } else {
      _showError(
        session.errorMessage ??
            translator.getText('CreateParentAccountErrorMessage'),
      );
    }
  }

  void _showSuccessDialog(NotifyData notifyData) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translator.getText('CreateParentAccountCreated')),
        content: Text(translator.getText('CreateParentAccountValidationMsg')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ActivateParentAccount(email: emailCtrl.text),
                ),
              );
            },
            child: Text(translator.getText('CreateParentAccountActivate')),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    loginCtrl.dispose();
    passwordCtrl.dispose();
    emailCtrl.dispose();
    codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final NotifyData notifyData = context.watch<NotifyData>();
    translator = Translator(
      status: StatusLangue.CONSTANCE_SESSION,
      lang: notifyData.currentLanguage,
    );

    return AppScaffold(
      //appBar: AppBar(title: const Text("Create Parent Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: Constant.getTitle1ButtonStyle(),
                child: Text(
                  translator.getText('CreateParentAccountCreateParentAccount'),
                ),
              ),
              const SizedBox(height: 24),
              _field(
                notifyData,
                firstNameCtrl,
                translator.getText('CreateParentAccountFirstName'),
              ),
              _field(
                notifyData,
                lastNameCtrl,
                translator.getText('CreateParentAccountLastName'),
              ),
              _field(
                notifyData,
                codeCtrl,
                'Code',
              ),
              _field(
                notifyData,
                loginCtrl,
                translator.getText('CreateParentAccountLogin'),
              ),
              _field(
                notifyData,
                emailCtrl,
                translator.getText('CreateParentAccountEmail'),
                keyboardType: TextInputType.emailAddress,
              ),
              _field(
                notifyData,
                passwordCtrl,
                translator.getText('CreateParentAccountPassword'),
                obscure: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: Constant.getTitle3ButtonStyle(),
                  onPressed: () {
                    session.isLoading ? null : _submit(notifyData);
                  },
                  child: session.isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          translator.getText(
                            'CreateParentAccountCreateAccount',
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    NotifyData notifyData,
    TextEditingController ctrl,
    String label, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: (v) => v == null || v.isEmpty
            ? translator.getText('CreateParentAccountRequired')
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
