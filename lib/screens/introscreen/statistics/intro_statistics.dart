import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constances.dart';
import '../../../core/core_translator.dart';
import '../../../core/notify_data.dart';
import '../../../models/child.dart';
import '../../../providers/statistics_provider.dart';
import '../../../widgets/app_scaffold.dart';
import 'statistics_course.dart';

class IntroStatistics extends StatefulWidget {
  final Child child;
  final bool isViewParent;
  final bool isResponsible;

  const IntroStatistics({
    super.key,
    required this.child,
    this.isViewParent = false,
    this.isResponsible = false,
  });

  @override
  State<IntroStatistics> createState() => _IntroStatisticsState();
}

class _IntroStatisticsState extends State<IntroStatistics> {
  Child? child;
  Translator translator = Translator();

  @override
  void initState() {
    super.initState();
    print('5555555555556666666666666644444444444777777777777788888888888899999999999999444444444444');

    Future.microtask(() async {
      print('wwwwwwwwwwwwwwwwwwwwweeeeeeeeeeeeeeeeeeeeeeeeetttttttttttttttttttttttttt');
      child = widget.child;
      print('00000000000000044444444444444444000000000000000000000000');
      
      await context.read<StatisticsProvider>().loadStatistics(widget.child);
      print('rrrrrrrrrrrrrrrrrkkkkkkkkkkkkkkkkkkkmmmmmmmmmmmmmmmmmmmm');
      
    });
  }

  @override
  Widget build(BuildContext context) {
    print('dddddddddddddddddddddddddddd 01');
    final provider = context.watch<StatisticsProvider>();
    print('dddddddddddddddddddddddddddd 02');
    final notifyData = context.watch<NotifyData>();
    print('dddddddddddddddddddddddddddd 03');
    translator = Translator(
      status: StatusLangue.CONSTANCE_STATISTICS,
      lang: notifyData.currentLanguage,
    );
      print('dddddddddddddddddddddddddddd 04');

    return AppScaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(provider, notifyData),
    );
  }

  Widget _buildBody(StatisticsProvider provider, NotifyData notifyData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: Constant.getTitle1ButtonStyle(),
              child: Text(translator.getText('ChildStatTitle')),
            ),
          ),
          _childHeader(notifyData),
          const SizedBox(height: 16),
          _sectionTitle(translator.getText('IntroStatTitleBasicInformation')),
          _basicInfo(notifyData),
          const SizedBox(height: 16),
          _sectionTitle(translator.getText('IntroStatTitleLastConnection')),
          _connectionInfo(provider, notifyData),
          const SizedBox(height: 16),
          _sectionTitle(translator.getText('IntroStatTitleCoursesVisited')),
          _coursesVisited(provider, notifyData),
          /*const SizedBox(height: 16),
          _sectionTitle(translator.getText('IntroStatTitleCoursesCompleted')),
          _coursesCompleted(provider, notifyData),*/
          const SizedBox(height: 16),
          _sectionTitle(translator.getText('IntroStatTitleCoursesNeverDone')),
          _coursesNeverDone(provider, notifyData),
        ],
      ),
    );
  }

  /// HEADER
  Widget _childHeader(NotifyData notifyData) {
    print('**************+++++++++======== '+ child!.login +' ===========+++++++++++************');
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            widget.child.name.isNotEmpty ? widget.child.name[0] : "?",
          ),
        ),
        title: Text(widget.child.name),
        subtitle: Text(
          translator.getText('IntroStatLogin').replaceAll('{0}', child!.login),
        ),
        trailing: widget.isResponsible
            ? const Icon(Icons.star, color: Colors.orange)
            : null,
      ),
    );
  }

  /// BASIC INFO
  Widget _basicInfo(NotifyData notifyData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            /*_infoRow(
              translator.getText('IntroStatAge'),
              "${child!.age ?? '-'}",
            ),*/
            _infoRow(
              translator.getText('IntroStatCompletedTasks'),
              "${child!.completedTasks ?? 0}",
            ),
            _infoRow(
              translator.getText('IntroStatTotalTasks'),
              "${child!.totalTasks ?? 0}",
            ),
            _infoRow(
              translator.getText('IntroStatTotalTime'),
              translator
                  .getText('IntroStatMinute')
                  .replaceAll('{0}', (child!.totalTimeMinutes ?? 0).toString()),
            ),
            _infoRow(
              translator.getText('IntroStatStreakDays'),
              translator
                  .getText('IntroStatDays')
                  .replaceAll('{0}', (child!.streakDays ?? 0).toString()),
            ),
          ],
        ),
      ),
    );
  }

  /// CONNECTION INFO
  Widget _connectionInfo(StatisticsProvider provider, NotifyData notifyData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _infoRow(
              translator.getText('IntroStatLastConnection'),
              provider.lastConnectionTime ?? "-",
            ),
            _infoRow(
              translator.getText('IntroStatDuration'),
              provider.lastConnectionDuration ?? "-",
            ),
          ],
        ),
      ),
    );
  }

  /// COURSES VISITED
  Widget _coursesVisited(StatisticsProvider provider, NotifyData notifyData) {
    if (provider.visitedCourses.isEmpty) {
      return Text(translator.getText('IntroStatNoCoursesVisited'));
    }

    return Column(
      children: provider.visitedCourses.map((item) {
        final course = item.course;
        final duration = item.timeSpent;
        final lastDateConnection = item.lastDateConnection;

        return Card(
          child: ListTile(
            title: Text(course.name),
            subtitle: Text(
              translator
                  .getText('IntroStatTimeSpent')
                  .replaceAll('{0}', duration.toString())
                  .replaceAll('{1}', _formatDate(lastDateConnection)),
            ),
            leading: const Icon(Icons.visibility),
            onTap: () {
              setState(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        StatisticsCourse(child: child!, course: item.course),
                  ),
                );
              });
            },
          ),
        );
      }).toList(),
    );
  }

  /// COURSES COMPLETED
  Widget _coursesCompleted(StatisticsProvider provider, NotifyData notifyData) {
    if (provider.completedCourses.isEmpty) {
      return Text(translator.getText('IntroStatNoCompletedCourses'));
    }

    return Column(
      children: provider.completedCourses.map((course) {
        return Card(
          child: ListTile(
            title: Text(course.name),
            leading: const Icon(Icons.check_circle, color: Colors.green),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      StatisticsCourse(child: widget.child, course: course),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  /// COURSES NEVER DONE
  Widget _coursesNeverDone(StatisticsProvider provider, NotifyData notifyData) {
    if (provider.neverDoneCourses.isEmpty) {
      return Text(translator.getText('IntroStatNoPendingCourses'));
    }

    return Column(
      children: provider.neverDoneCourses.map((item) {
        final course = item.course;
        final date = item.pickedDate;

        return Card(
          child: ListTile(
            title: Text(course.name),
            subtitle: Text(
              translator
                  .getText('IntroStatPickedOn')
                  .replaceAll('{0}', _formatDate(date)),
            ),
            leading: const Icon(Icons.schedule, color: Colors.orange),
          ),
        );
      }).toList(),
    );
  }

  /// UTIL
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
