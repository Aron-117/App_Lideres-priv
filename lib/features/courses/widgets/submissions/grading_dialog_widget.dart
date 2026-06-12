import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/teacher_submissions_provider.dart';

class GradingDialogWidget extends StatefulWidget {
  final Map<String, dynamic> entrega;
  final TeacherSubmissionsProvider provider;
  final int maxScore;

  const GradingDialogWidget({
    Key? key,
    required this.entrega,
    required this.provider,
    required this.maxScore,
  }) : super(key: key);

  @override
  State<GradingDialogWidget> createState() => _GradingDialogWidgetState();
}

class _GradingDialogWidgetState extends State<GradingDialogWidget> {
  late TextEditingController notaController;
  late TextEditingController comentarioController;
  final formKey = GlobalKey<FormState>();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    notaController = TextEditingController(
      text: widget.entrega['calificacion']?.toString() ?? '',
    );
    comentarioController = TextEditingController(
      text: widget.entrega['comentario_profesor'] ?? '',
    );
  }

  @override
  void dispose() {
    notaController.dispose();
    comentarioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (formKey.currentState!.validate()) {
      setState(() => isSaving = true);
      try {
        await widget.provider.gradeSubmission(
          widget.entrega['id_entrega'],
          int.parse(notaController.text),
          comentarioController.text.trim(),
          widget.maxScore,
        );
        if (mounted) Navigator.pop(context);
      } catch (e) {
        setState(() => isSaving = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Calificar entrega',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: notaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nota (Máx: ${widget.maxScore})',
                prefixIcon: const Icon(Icons.military_tech),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                final n = int.tryParse(value ?? '');
                if (n == null) return 'Ingresa un número';
                if (n > widget.maxScore) {
                  return 'No supera los ${widget.maxScore} pts';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: comentarioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Feedback (Opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: isSaving ? null : _save,
          child: isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
