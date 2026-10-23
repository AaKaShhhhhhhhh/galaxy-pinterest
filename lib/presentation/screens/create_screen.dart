import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/common.dart';
import '../../domain/entities/pin.dart';
import '../providers/providers.dart';
import '../widgets/board_sheet.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});
  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController(),
      description = TextEditingController(),
      link = TextEditingController();
  Uint8List? image;
  String? boardId;
  bool busy = false;
  @override
  void dispose() {
    title.dispose();
    description.dispose();
    link.dispose();
    super.dispose();
  }

  Future<void> pick() async {
    try {
      final bytes = await ref.read(fileServiceProvider).pickImage();
      if (mounted && bytes != null) {
        setState(() => image = bytes);
      }
    } catch (_) {
      if (mounted) {
        toast(context, 'Choose a photo smaller than 8 MB.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryProvider);
    final selected = library.boards.any((b) => b.id == boardId)
        ? boardId
        : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Pin'),
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: busy ? null : create,
              child: Text(
                busy ? 'Creating…' : 'Create',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    button: true,
                    label: 'Choose a photo',
                    onTap: busy ? null : pick,
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: busy ? null : pick,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        height: image == null ? 245 : 330,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: image == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 42,
                                  ),
                                  SizedBox(height: 14),
                                  Text(
                                    'Every idea starts somewhere',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Choose a photo to create your Pin',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            : Image.memory(image!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  if (image != null)
                    TextButton(
                      onPressed: busy ? null : pick,
                      child: const Text('Choose a different photo'),
                    ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: title,
                    maxLength: 100,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Give your Pin a title',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Add a title for your Pin'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: description,
                    maxLength: 500,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Tell the story behind your idea',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: link,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Link (optional)',
                      hintText: 'https://',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return null;
                      }
                      final uri = Uri.tryParse(v.trim());
                      return uri != null &&
                              ['http', 'https'].contains(uri.scheme) &&
                              uri.host.isNotEmpty
                          ? null
                          : 'Enter a valid https:// link';
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    key: ValueKey(selected),
                    initialValue: selected,
                    decoration: const InputDecoration(
                      labelText: 'Save to board',
                    ),
                    items: library.boards
                        .map(
                          (b) => DropdownMenuItem(
                            value: b.id,
                            child: Text(b.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => boardId = v),
                    validator: (v) => v == null ? 'Choose a board' : null,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        final id = await editBoard(context);
                        if (id != null && mounted) {
                          setState(() => boardId = id);
                        }
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Create a new board'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: busy ? null : create,
                    child: Text(busy ? 'Creating…' : 'Create Pin'),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Your created Pins are stored on this device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> create() async {
    if (!form.currentState!.validate()) {
      return;
    }
    if (image == null) {
      toast(context, 'Choose a photo for your Pin');
      return;
    }
    setState(() => busy = true);
    final success = await perform(context, () async {
      final codec = await ui.instantiateImageCodec(image!);
      final frame = await codec.getNextFrame();
      final pin = Pin(
        id: 'local_${DateTime.now().microsecondsSinceEpoch}',
        title: title.text.trim(),
        description: description.text.trim(),
        imageUrl: '',
        imageBase64: base64Encode(image!),
        creator: ref.read(libraryProvider).name,
        width: frame.image.width,
        height: frame.image.height,
        sourceUrl: link.text.trim(),
        category: 'Created',
        source: 'Your collection',
      );
      frame.image.dispose();
      codec.dispose();
      await ref.read(libraryProvider.notifier).createPin(pin, boardId!);
    }, success: 'Your Pin is ready');
    if (mounted) {
      if (success) {
        context.pop();
        context.go('/saved');
      } else {
        setState(() => busy = false);
      }
    }
  }
}
