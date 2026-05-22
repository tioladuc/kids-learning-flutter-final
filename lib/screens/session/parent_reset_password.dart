import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constances.dart';
import '../../core/core_translator.dart';
import '../../core/notify_data.dart';
import '../../providers/session_provider.dart';
import '../../widgets/app_scaffold.dart';

class ParentResetPassword extends StatefulWidget {
  final String email;

  const ParentResetPassword({super.key, required this.email});

  @override
  State<ParentResetPassword> createState() => _ParentResetPasswordState();
}

class _ParentResetPasswordState extends State<ParentResetPassword> {
  final _formKey = GlobalKey<FormState>();
  Translator translator = Translator();

  late TextEditingController emailCtrl;
  final codeCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailCtrl = TextEditingController(text: widget.email);
  }

  Future<void> _resetPassword(NotifyData notifyData, BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordCtrl.text != confirmCtrl.text) {
      _showError(translator.getText('ParentResetPasswordPasswordsNotMatch'), context);
      return;
    }

    final session = context.read<SessionProvider>();

    final success = await session.resetPassword(
      email: emailCtrl.text,
      code: codeCtrl.text,
      newPassword: passwordCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      _showSuccess(notifyData, context);
    } else {
      _showError(
        session.errorMessage ?? translator.getText('ParentResetPasswordError'), context
      );
    }
  }

  void _showSuccess(NotifyData notifyData, BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translator.getText('ParentResetPasswordSuccess')),
        content: Text(
          translator.getText('ParentResetPasswordPasswordResetSuccessfully'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              // Back to login or root
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(translator.getText('ParentResetPasswordContinue')),
          ),
        ],
      ),
    );
  }

  void _showError(String msg, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    codeCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final notifyData = context.watch<NotifyData>();
    translator = Translator(
      status: StatusLangue.CONSTANCE_SESSION,
      lang: notifyData.currentLanguage,
    );

    return AppScaffold(
      //appBar: AppBar(title: const Text("Reset Password")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ElevatedButton(
                onPressed:
                    () {}, //context.read<SessionProvider>().login('child'),
                style: Constant.getTitle1ButtonStyle(),
                child: Text(
                  translator.getText('ParentResetPasswordResetPassword'),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                translator.getText('ParentResetPasswordEnterYourEmail'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _field(
                notifyData,
                emailCtrl,
                translator.getText('ParentResetPasswordEmail'),
                keyboardType: TextInputType.emailAddress,
              ),
              _field(
                notifyData,
                codeCtrl,
                translator.getText('ParentResetPasswordResetCode'),
              ),
              _field(
                notifyData,
                passwordCtrl,
                translator.getText('ParentResetPasswordNewPassword'),
                obscure: true,
              ),
              _field(
                notifyData,
                confirmCtrl,
                translator.getText('ParentResetPasswordConfirmPassword'),
                obscure: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: Constant.getTitle3ButtonStyle(),
                  onPressed: () {
                    session.isLoading ? null : _resetPassword(notifyData, context);
                  },
                  child: session.isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          translator.getText(
                            'ParentResetPasswordResetPasswordBtn',
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
            ? translator.getText('ParentResetPasswordRequired')
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
