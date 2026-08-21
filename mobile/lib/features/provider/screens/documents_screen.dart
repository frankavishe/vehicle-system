import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/autoserve_api.dart';
import '../../../shared/models/provider_document.dart';

final myDocumentsProvider = FutureProvider.autoDispose<List<ProviderDocumentDto>>((ref) {
  return ref.watch(autoserveApiProvider).myDocuments();
});

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  bool _uploading = false;

  Future<void> _upload() async {
    // image_picker, not file_picker (PLAN's original choice) — see
    // pubspec.yaml's version comment for why: a reproducible Android
    // build-toolchain incompatibility with file_picker in this Flutter
    // release. **Flagged scope trim**: gallery/camera images only, no
    // PDF — a certification document that's a scanned PDF can't be
    // uploaded through this screen this phase.
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      await ref.read(autoserveApiProvider).uploadDocument(filePath: picked.path, docType: 'LICENSE');
      ref.invalidate(myDocumentsProvider);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final documents = ref.watch(myDocumentsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myDocumentsProvider),
        child: documents.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(myDocumentsProvider),
              child: const Text('Could not load documents — tap to retry'),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No documents uploaded yet.')),
                  ),
                ],
              );
            }
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final d = items[i];
                return ListTile(
                  leading: Icon(d.verified ? Icons.verified : Icons.hourglass_top),
                  title: Text(d.docType ?? 'Document'),
                  subtitle: Text(d.verified ? 'Verified' : 'Pending review'),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploading ? null : _upload,
        icon: _uploading
            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.upload_file),
        label: const Text('Upload'),
      ),
    );
  }
}
