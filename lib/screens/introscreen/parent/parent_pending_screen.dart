import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:kids_learning_flutter_app/core/notify_data.dart';
import 'package:provider/provider.dart';
import '../../../core/constances.dart';
import '../../../core/core_translator.dart';
import '../../../models/child.dart';
import '../../../models/course.dart';
import '../../../providers/course_provider.dart';
import '../../../widgets/app_scaffold.dart';

class ParentChildPendingScreen extends StatefulWidget {
  final Child child;
  final bool isResponsible;

  const ParentChildPendingScreen({
    super.key,
    required this.child,
    required this.isResponsible,
  });

  @override
  State<ParentChildPendingScreen> createState() =>
      _ParentChildPendingScreenState();
}

class _ParentChildPendingScreenState extends State<ParentChildPendingScreen> {
  Translator translator = Translator();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<CourseProvider>().loadChildPendingCourses(
        widget.child.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final notifyData = context.watch<NotifyData>();
    translator = Translator(
      status: StatusLangue.CONSTANCE_COURSE,
      lang: notifyData.currentLanguage,
    );

    return AppScaffold(body: _buildBody(provider, notifyData));
  }

  Widget _buildBody(CourseProvider provider, NotifyData notifyData) {
    if (provider.isLoadingPending) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.pendingCourses.isEmpty) {
      return Center(child: Text(translator.getText('NoPendingCourseMsg')));
    }

    return Column(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: Constant.getTitle1ButtonStyle(),
          child: Text(
            "${widget.child.name} - " +
                translator.getText('PendingCourseTitle'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.pendingCourses.length,
            itemBuilder: (context, index) {
              final course = provider.pendingCourses[index];
              return _courseCard(course, provider, notifyData);
            },
          ),
        ),
      ],
    );
  }

  Widget _courseCard(
    Course course,
    CourseProvider provider,
    NotifyData notifyData,
  ) {
    final isExpiringSoon =
        course.expiryDate != null &&
        course.expiryDate!.isBefore(
          DateTime.now().add(const Duration(days: 7)),
        );

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(course, notifyData),
            const SizedBox(height: 10),
            _infoRow(translator.getText('PendingCourseCode'), course.code),
            _infoRow(
              translator.getText('PendingCourseDescription'),
              course.description,
            ),
            _infoRow(
              translator.getText('PendingCourseAmount'),
              "\$${course.amount.toStringAsFixed(2)}",
            ),
            _infoRow(
              translator.getText('PendingCourseValidity'),
              course.validity,
            ),
            if (course.isRegistered && course.expiryDate != null)
              _infoRow(
                translator.getText('PendingCourseExpire'),
                _formatDate(course.expiryDate!),
                highlight: isExpiringSoon,
              ),
            if (true)//(widget.isResponsible)
              _paymentButton(course, provider, notifyData),
            _removeCourseButton(course, provider, notifyData),
          ],
        ),
      ),
    );
  }

  Widget _paymentButton(
    Course course,
    CourseProvider provider,
    NotifyData notifyData,
  ) {
    final isRenew = course.isRegistered;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: provider.isLoading
              ? null
              : () => _handlePayment(course, provider, notifyData),
          style: ElevatedButton.styleFrom(
            backgroundColor: isRenew ? Colors.orange : Colors.blue,
          ),
          child: provider.isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  isRenew
                      ? translator.getText('PendingCourseRenew')
                      : translator.getText('PendingCoursePurchase'),
                ),
        ),
      ),
    );
  }

  Widget _removeCourseButton(
    Course course,
    CourseProvider provider,
    NotifyData notifyData,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: provider.isLoading
              ? null
              : () => _handleRemoveCourse(course, provider, notifyData),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: provider.isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(translator.getText('PendingCourseRemoveCourse')),
        ),
      ),
    );
  }

  Future<void> _handlePayment(
    Course course,
    CourseProvider provider,
    NotifyData notifyData,
  ) async {
    final confirm = await _showConfirmationDialog(course, notifyData);

    if (confirm != true) return;
    if (!kIsWeb) { // if it is not web version
      print('before X 01');
      bool success = await provider.makePaymentStripe(
        (course.amount * 100).toInt(),
      );
      print('before X 02');
      if (success) {
        print('before X 03');
        success = await provider.payCourse(
          childId: widget.child.id,
          courseCode: course.code,
          amount: course.amount
        );
        print('before X 04');
      }

      print('before X 05');
      if (!mounted) return;

      print('before X 06');
      if (success) {
        print('before X 07');
        _showSuccessDialog(notifyData);
        setState(() {
          provider.pendingCourses.remove(course);
        });
        print('before X 08');
      } else {
        print('before X 09');
        _showError(
          provider.errorMessage ??
              translator.getText('PendingCoursePaymentFailed'),
        );
        print('before X 10');
      }
    }
    
  }

  Future<void> _handleRemoveCourse(
    Course course,
    CourseProvider provider,
    NotifyData notifyData,
  ) async {
    final confirm = await _showConfirmationCourseRemovalDialog(
      course,
      notifyData,
    );

    if (confirm != true) return;

    final success = await provider.removeCourse(
      childId: widget.child.id,
      courseCode: course.code,
    );

    if (!mounted) return;

    if (success) {
      _showSuccessCourseRemovalDialog(notifyData);
    } else {
      _showError(
        provider.errorMessage ??
            translator.getText('PendingCourseCourseRemovalFailed'),
      );
    }
  }

  Future<bool?> _showConfirmationDialog(Course course, NotifyData notifyData) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translator.getText('PendingCourseConfirmPaymentTitle')),
        content: Text(
          translator
              .getText('PendingCourseConfirmPaymentMsg')
              .replaceAll('{0}', course.amount.toStringAsFixed(2))
              .replaceAll('{1}', course.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(translator.getText('PendingCoursePaymentCancelBtn')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text((translator.getText('PendingCoursePaymentConfirmBtn'))),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmationCourseRemovalDialog(
    Course course,
    NotifyData notifyData,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translator.getText('PendingCourseRemovalTitle')),
        content: Text(
          translator
              .getText('PendingCourseRemovalMsg')
              .replaceAll('{0}', course.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(translator.getText('PendingCourseRemovalCancelBtn')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(translator.getText('PendingCourseRemovalConfirmBtn')),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(NotifyData notifyData) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translator.getText('PendingCoursePaymentSuccessTitle')),
        content: Text(translator.getText('PendingCoursePaymentSuccessMsg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translator.getText('PendingCoursePaymentSuccessOK')),
          ),
        ],
      ),
    );
  }

  void _showSuccessCourseRemovalDialog(NotifyData notifyData) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translator.getText('PendingCourseRemovalSuccessTitle')),
        content: Text(translator.getText('PendingCourseRemovalSuccessMsg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translator.getText('PendingCourseRemovalSuccessOK')),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _header(Course course, NotifyData notifyData) {
    final isExpiringSoon =
        course.expiryDate != null &&
        course.expiryDate!.isBefore(
          DateTime.now().add(const Duration(days: 7)),
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            course.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _statusBadge(course, isExpiringSoon, notifyData),
      ],
    );
  }

  Widget _statusBadge(
    Course course,
    bool isExpiringSoon,
    NotifyData notifyData,
  ) {
    String text;
    Color color;

    if (!course.isRegistered) {
      text = translator.getText('PendingCoursePaymentStatusPending');
      color = Colors.orange;
    } else if (isExpiringSoon) {
      text = translator.getText('PendingCoursePaymentStatusExpiringSoon');
      color = Colors.red;
    } else {
      text = translator.getText('PendingCoursePaymentStatusActive');
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: highlight ? Colors.red : Colors.black,
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
