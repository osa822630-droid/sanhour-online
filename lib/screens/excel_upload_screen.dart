// lib/screens/excel_upload_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
// تم حذف import provider لأنه غير مستخدم
import '../services/api_service.dart';
import '../utils/logger.dart';

class ExcelUploadScreen extends StatefulWidget {
  const ExcelUploadScreen({super.key});

  @override
  State<ExcelUploadScreen> createState() => _ExcelUploadScreenState();
}

class _ExcelUploadScreenState extends State<ExcelUploadScreen> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _selectedFileName;
  PlatformFile? _selectedFile;
  Map<String, dynamic>? _uploadResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رفع ملف Excel'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة التعليمات
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'تعليمات رفع الملف',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionItem('1', 'قم بتحميل نموذج Excel من الزر أدناه'),
                    _buildInstructionItem('2', 'املأ البيانات في الملف المحمل'),
                    _buildInstructionItem('3', 'اختر الملف المكتمل من جهازك'),
                    _buildInstructionItem('4', 'انقر على رفع الملف للمعالجة'),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('تحميل النموذج'),
                      onPressed: _downloadTemplate,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // منطقة رفع الملف
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'رفع ملف Excel',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedFileName != null ? Colors.green : Colors.grey,
                          // تم التصحيح: BorderStyle.dashed غير موجود، استبدل بـ solid
                          style: BorderStyle.solid, 
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[50],
                      ),
                      child: _selectedFileName != null
                          ? _buildFileSelected()
                          : _buildUploadArea(),
                    ),
                    const SizedBox(height: 16),
                    if (_isUploading) _buildProgressIndicator(),
                    if (_uploadResult != null) _buildUploadResult(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // معلومات التنسيق
            _buildFormatInfo(),
          ],
        ),
      ),
      floatingActionButton: _selectedFileName != null && !_isUploading
          ? FloatingActionButton.extended(
              onPressed: _uploadFile,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('رفع الملف'),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    return InkWell(
      onTap: _pickFile,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          const Text(
            'انقر لاختيار ملف Excel',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            'امتدادات الملفات المسموحة: .xlsx, .xls, .csv',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSelected() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.description,
          size: 48,
          color: Colors.green,
        ),
        const SizedBox(height: 8),
        Text(
          _selectedFileName!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _pickFile,
          child: const Text('تغيير الملف'),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          'جاري معالجة الملف...',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _uploadProgress,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
        ),
        const SizedBox(height: 8),
        Text(
          '${(_uploadProgress * 100).toStringAsFixed(0)}%',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildUploadResult() {
    final success = _uploadResult?['success'] ?? false;
    final processedItems = _uploadResult?['processedItems'] ?? 0;
    final failedItems = _uploadResult?['failedItems'] ?? 0;

    return Column(
      children: [
        const SizedBox(height: 16),
        Icon(
          success ? Icons.check_circle : Icons.error,
          size: 48,
          color: success ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 8),
        Text(
          _uploadResult?['message'] ?? '',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: success ? Colors.green : Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'تمت معالجة: $processedItems عنصر',
          style: const TextStyle(fontSize: 14),
        ),
        if (failedItems > 0)
          Text(
            'فشل في: $failedItems عنصر',
            style: const TextStyle(fontSize: 14, color: Colors.red),
          ),
        const SizedBox(height: 16),
        if (_uploadResult?['results'] != null)
          _buildResultsDetails(),
      ],
    );
  }

  Widget _buildResultsDetails() {
    final results = _uploadResult?['results'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تفاصيل المعالجة:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...results.map((result) => ListTile(
          leading: Icon(
            result['status'] == 'success' ? Icons.check : Icons.error,
            color: result['status'] == 'success' ? Colors.green : Colors.red,
          ),
          title: Text(result['name'] ?? 'غير معروف'),
          subtitle: result['status'] == 'success'
              ? Text('السعر: ${result['price']} جنيه')
              : Text('خطأ: ${result['error']}'),
        )),
      ],
    );
  }

  Widget _buildFormatInfo() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تنسيق الملف المطلوب',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('الحقل')),
                DataColumn(label: Text('النوع')),
                DataColumn(label: Text('مطلوب')),
                DataColumn(label: Text('وصف')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('name')),
                  DataCell(Text('نص')),
                  DataCell(Text('نعم')),
                  DataCell(Text('اسم المنتج')),
                ]),
                DataRow(cells: [
                  DataCell(Text('price')),
                  DataCell(Text('رقم')),
                  DataCell(Text('نعم')),
                  DataCell(Text('سعر المنتج')),
                ]),
                DataRow(cells: [
                  DataCell(Text('category')),
                  DataCell(Text('نص')),
                  DataCell(Text('نعم')),
                  DataCell(Text('الفئة')),
                ]),
                DataRow(cells: [
                  DataCell(Text('description')),
                  DataCell(Text('نص')),
                  DataCell(Text('لا')),
                  DataCell(Text('وصف المنتج')),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _selectedFileName = _selectedFile!.name;
          _uploadResult = null;
        });
      }
    } catch (e) {
      AppLogger.e('خطأ في اختيار الملف', e);
      if (!mounted) return; // تم إضافة التحقق من mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في اختيار الملف: $e')),
      );
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // محاكاة التقدم
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return; // تم إضافة التحقق من mounted أثناء الحلقة
        setState(() {
          _uploadProgress = i / 100.0;
        });
      }

      // معالجة الملف
      final result = await ApiService.processExcelFile(_selectedFile!.path!);
      
      if (!mounted) return; // تم إضافة التحقق من mounted قبل استخدام setState
      
      setState(() {
        _uploadResult = result;
        _isUploading = false;
      });

      AppLogger.i('تم معالجة الملف بنجاح: ${result['processedItems']} عنصر');
    } catch (e) {
      AppLogger.e('خطأ في معالجة الملف', e);
      if (!mounted) return; // تم إضافة التحقق من mounted
      setState(() {
        _uploadResult = {
          'success': false,
          'message': 'فشل في معالجة الملف: $e',
        };
        _isUploading = false;
      });
    }
  }

  Future<void> _downloadTemplate() async {
    // محاكاة تحميل النموذج
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تحميل نموذج Excel...'),
        backgroundColor: Colors.blue,
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return; // تم إضافة التحقق من mounted

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحميل النموذج بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
