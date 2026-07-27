import 'package:alkhair_app/core/constants/enums.dart';
import 'package:alkhair_app/core/errors/app_error_messages.dart';
import 'package:alkhair_app/core/router/app_router.dart';
import 'package:alkhair_app/features/donor/domain/report_validators.dart';
import 'package:alkhair_app/features/donor/presentation/controllers/report_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Screen 2 (Fig 5.2, FR2/FR3/FR4) — donor surplus report form. GPS is
/// captured automatically via `geolocator` when submitting (FR3); the
/// mandatory `safety_confirmed` checkbox blocks the submit button (FR4).
class DonorReportScreen extends ConsumerStatefulWidget {
  const DonorReportScreen({super.key});

  @override
  ConsumerState<DonorReportScreen> createState() => _DonorReportScreenState();
}

class _DonorReportScreenState extends ConsumerState<DonorReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  FoodCategory? _foodCategory;
  DateTime? _readinessTime;
  bool _safetyConfirmed = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickReadinessTime(FormFieldState<DateTime> field) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null) return;
    final combined =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() => _readinessTime = combined);
    field.didChange(combined);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_foodCategory == null || _readinessTime == null) return;

    ref.read(reportControllerProvider.notifier).submit(
          foodCategory: _foodCategory!,
          quantity: num.parse(_quantityController.text.trim()),
          readinessTime: _readinessTime!,
          safetyConfirmed: _safetyConfirmed,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(reportControllerProvider, (previous, next) {
      if (next.phase == ReportSubmitPhase.success &&
          previous?.phase != ReportSubmitPhase.success) {
        context.go(Routes.donorStatus);
      } else if (next.phase == ReportSubmitPhase.error && next.failure != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(arabicErrorMessage(next.failure!))));
      }
    });

    final submitState = ref.watch(reportControllerProvider);
    final isBusy = submitState.phase == ReportSubmitPhase.capturingLocation ||
        submitState.phase == ReportSubmitPhase.submitting;

    return Scaffold(
      appBar: AppBar(title: const Text('إبلاغ عن فائض غذائي')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                DropdownButtonFormField<FoodCategory>(
                  initialValue: _foodCategory,
                  decoration: const InputDecoration(
                    labelText: 'نوع الطعام',
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  items: [
                    for (final c in FoodCategory.values)
                      DropdownMenuItem(value: c, child: Text(_categoryLabel(c))),
                  ],
                  onChanged: (value) => setState(() => _foodCategory = value),
                  validator: (value) => value == null ? 'يرجى اختيار نوع الطعام' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'الكمية',
                    prefixIcon: Icon(Icons.scale),
                  ),
                  validator: (value) => _quantityErrorText(
                    validateQuantity(num.tryParse(value?.trim() ?? '')),
                  ),
                ),
                const SizedBox(height: 16),
                FormField<DateTime>(
                  initialValue: _readinessTime,
                  validator: (value) =>
                      _readinessErrorText(validateReadinessTime(value)),
                  builder: (field) => InkWell(
                    onTap: () => _pickReadinessTime(field),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'موعد جاهزية الطعام',
                        prefixIcon: const Icon(Icons.schedule),
                        errorText: field.errorText,
                      ),
                      child: Text(
                        _readinessTime == null
                            ? 'اختر التاريخ والوقت'
                            : DateFormat('yyyy/MM/dd HH:mm').format(_readinessTime!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: _safetyConfirmed,
                  onChanged: (value) =>
                      setState(() => _safetyConfirmed = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('أؤكد أن الطعام آمن للتوزيع والاستهلاك'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: (!_safetyConfirmed || isBusy) ? null : _submit,
                  child: isBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('إرسال البلاغ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _categoryLabel(FoodCategory c) => switch (c) {
      FoodCategory.mainMeals => 'وجبات رئيسية',
      FoodCategory.bakedGoods => 'مخبوزات',
      FoodCategory.fruitsAndVegetables => 'فواكه وخضروات',
      FoodCategory.canned => 'معلبات',
      FoodCategory.other => 'أخرى',
    };

String? _quantityErrorText(ReportValidationError? error) => switch (error) {
      null => null,
      ReportValidationError.required => 'يرجى إدخال الكمية',
      ReportValidationError.notPositive => 'يجب أن تكون الكمية أكبر من صفر',
      ReportValidationError.tooLarge => 'الكمية كبيرة جداً',
      ReportValidationError.notInFuture => null,
    };

String? _readinessErrorText(ReportValidationError? error) => switch (error) {
      null => null,
      ReportValidationError.required => 'يرجى اختيار موعد الجاهزية',
      ReportValidationError.notInFuture => 'يجب أن يكون الموعد في المستقبل',
      ReportValidationError.notPositive => null,
      ReportValidationError.tooLarge => null,
    };
