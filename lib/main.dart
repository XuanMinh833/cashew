import 'package:flutter/material.dart';

// ============================================================================
// LỚP 1: DOMAIN LAYER
// ============================================================================

class DocumentEntity {
  final String id;
  final String title;
  final String category;
  final String fileUrl;
  final DateTime createdAt;

  DocumentEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.fileUrl,
    required this.createdAt,
  });
}

abstract class DocumentRepository {
  Future<List<DocumentEntity>> getDocuments();
  Future<void> addDocument(DocumentEntity doc);
  Future<void> deleteDocument(String id);
}

class GetDocumentsUseCase {
  final DocumentRepository repository;
  GetDocumentsUseCase(this.repository);

  Future<List<DocumentEntity>> call() async {
    return await repository.getDocuments();
  }
}

class AddDocumentUseCase {
  final DocumentRepository repository;
  AddDocumentUseCase(this.repository);

  Future<void> call(DocumentEntity doc) async {
    if (doc.title.trim().isEmpty) {
      throw Exception('Tên tài liệu không được để trống');
    }
    await repository.addDocument(doc);
  }
}

class DeleteDocumentUseCase {
  final DocumentRepository repository;
  DeleteDocumentUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteDocument(id);
  }
}

// ============================================================================
// LỚP 2: DATA LAYER
// ============================================================================

class DocumentLocalDataSource {
  final List<DocumentEntity> _storage = [
    DocumentEntity(
      id: '1',
      title: 'Bài giảng Kiến trúc Phần mềm - Chương 1',
      category: 'Bài giảng',
      fileUrl: 'https://example.com/chuong1.pdf',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    DocumentEntity(
      id: '2',
      title: 'Bài tập Thực hành Flutter Clean Architecture',
      category: 'Bài tập',
      fileUrl: 'https://example.com/baitap.docx',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<List<DocumentEntity>> fetchDocuments() async {
    return List.from(_storage);
  }

  Future<void> saveDocument(DocumentEntity doc) async {
    _storage.add(doc);
  }

  Future<void> removeDocument(String id) async {
    _storage.removeWhere((item) => item.id == id);
  }
}

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentLocalDataSource localDataSource;

  DocumentRepositoryImpl(this.localDataSource);

  @override
  Future<List<DocumentEntity>> getDocuments() async {
    return await localDataSource.fetchDocuments();
  }

  @override
  Future<void> addDocument(DocumentEntity doc) async {
    await localDataSource.saveDocument(doc);
  }

  @override
  Future<void> deleteDocument(String id) async {
    await localDataSource.removeDocument(id);
  }
}

// ============================================================================
// LỚP 3: PRESENTATION LAYER
// ============================================================================

void main() {
  runApp(const CashewDocumentApp());
}

class CashewDocumentApp extends StatelessWidget {
  const CashewDocumentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý Tài liệu Cashew',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DocumentListScreen(),
    );
  }
}

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  late final DocumentLocalDataSource _dataSource;
  late final DocumentRepository _repository;
  late final GetDocumentsUseCase _getDocumentsUseCase;
  late final AddDocumentUseCase _addDocumentUseCase;
  late final DeleteDocumentUseCase _deleteDocumentUseCase;

  List<DocumentEntity> _allDocuments = [];
  List<DocumentEntity> _filteredDocuments = [];
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  final List<String> _categories = [
    'Tất cả',
    'Bài giảng',
    'Bài tập',
    'Tài liệu tham khảo'
  ];

  @override
  void initState() {
    super.initState();
    _dataSource = DocumentLocalDataSource();
    _repository = DocumentRepositoryImpl(_dataSource);
    _getDocumentsUseCase = GetDocumentsUseCase(_repository);
    _addDocumentUseCase = AddDocumentUseCase(_repository);
    _deleteDocumentUseCase = DeleteDocumentUseCase(_repository);

    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final docs = await _getDocumentsUseCase.call();
    setState(() {
      _allDocuments = docs;
      _applyFilter();
    });
  }

  void _applyFilter() {
    setState(() {
      _filteredDocuments = _allDocuments.where((doc) {
        final matchesQuery =
            doc.title.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCategory = _selectedCategory == 'Tất cả' ||
            doc.category == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  Future<void> _addDocument(String title, String category, String url) async {
    final newDoc = DocumentEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      fileUrl: url,
      createdAt: DateTime.now(),
    );

    try {
      await _addDocumentUseCase.call(newDoc);
      await _loadDocuments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm tài liệu thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _deleteDocument(String id) async {
    await _deleteDocumentUseCase.call(id);
    await _loadDocuments();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa tài liệu!')),
      );
    }
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    String category = 'Bài giảng';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm tài liệu học tập mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration:
                    const InputDecoration(labelText: 'Tên tài liệu (*)'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: category,
                items: ['Bài giảng', 'Bài tập', 'Tài liệu tham khảo']
                    .map((cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => category = val!,
                decoration: const InputDecoration(labelText: 'Loại tài liệu'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                    labelText: 'Link file/Đường dẫn tài liệu'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                _addDocument(
                  titleController.text.trim(),
                  category,
                  urlController.text.trim(),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Tài liệu Học tập'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    _searchQuery = value;
                    _applyFilter();
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm tài liệu...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = cat;
                                _applyFilter();
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredDocuments.isEmpty
                ? const Center(child: Text('Không tìm thấy tài liệu nào.'))
                : ListView.builder(
                    itemCount: _filteredDocuments.length,
                    itemBuilder: (ctx, index) {
                      final doc = _filteredDocuments[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(
                              doc.category == 'Bài giảng'
                                  ? Icons.book
                                  : doc.category == 'Bài tập'
                                      ? Icons.assignment
                                      : Icons.folder,
                            ),
                          ),
                          title: Text(
                            doc.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${doc.category} • ${doc.createdAt.day}/${doc.createdAt.month}/${doc.createdAt.year}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteDocument(doc.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}