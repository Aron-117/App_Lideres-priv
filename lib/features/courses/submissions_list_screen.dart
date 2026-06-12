import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/models/resource_model.dart';
import '../../core/providers/teacher_submissions_provider.dart';
import 'widgets/submissions/grading_dialog_widget.dart';
import 'widgets/submissions/submission_card_widget.dart';

class SubmissionsListScreen extends StatefulWidget {
  final Resource task;

  const SubmissionsListScreen({super.key, required this.task});

  @override
  State<SubmissionsListScreen> createState() => _SubmissionsListScreenState();
}

class _SubmissionsListScreenState extends State<SubmissionsListScreen> {
  late TeacherSubmissionsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = TeacherSubmissionsProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.fetchSubmissions(widget.task.id);
    });
  }

  void _openGradingDialog(Map<String, dynamic> entrega, TeacherSubmissionsProvider provider) {
    showDialog(
      context: context,
      builder: (_) => GradingDialogWidget(
        entrega: entrega,
        provider: provider,
        maxScore: widget.task.maxScore ?? 100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryDark,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Entregas de alumnos',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<TeacherSubmissionsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        provider.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.fetchSubmissions(widget.task.id),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (provider.submissions.isEmpty) {
              return const Center(
                child: Text(
                  'Aún no hay entregas para esta tarea.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
 return RefreshIndicator(
              onRefresh: () => provider.fetchSubmissions(widget.task.id),
              child: ListView.builder(
                padding: const EdgeInsets.all(20.0),
                itemCount: provider.submissions.length,
                itemBuilder: (context, index) {
                  final entrega = provider.submissions[index];

                             return SubmissionCardWidget(
                    entrega: entrega,
                    maxScore: widget.task.maxScore ?? 100,
                    onTapGrade: () => _openGradingDialog(entrega, provider),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
