import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/common.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/pin.dart';
import '../providers/providers.dart';
import 'pin_image.dart';

Future<void> chooseBoard(BuildContext context, Pin pin) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _SaveSheet(pin: pin),
    );
Future<String?> editBoard(BuildContext context, {Board? board}) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _BoardForm(board: board),
    );

class _SaveSheet extends ConsumerStatefulWidget {
  const _SaveSheet({required this.pin});
  final Pin pin;
  @override
  ConsumerState<_SaveSheet> createState() => _SaveSheetState();
}

class _SaveSheetState extends ConsumerState<_SaveSheet> {
  bool busy = false;
  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Save to board',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: library.boards.map((board) {
                  final pins = library.pinsFor(board.id);
                  final saved = (library.saved[board.id] ?? []).contains(
                    widget.pin.id,
                  );
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 5),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 58,
                        height: 58,
                        child: pins.isEmpty
                            ? ColoredBox(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.dashboard_outlined),
                              )
                            : PinImage(pin: pins.first),
                      ),
                    ),
                    title: Text(
                      board.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${pins.length} ${pins.length == 1 ? 'Pin' : 'Pins'}${board.isSecret ? ' · Secret' : ''}',
                    ),
                    trailing: saved
                        ? const Icon(Icons.check_circle)
                        : const Icon(Icons.chevron_right),
                    onTap: busy
                        ? null
                        : () async {
                            setState(() => busy = true);
                            final messenger = ScaffoldMessenger.of(context);
                            final success = await perform(context, () async {
                              if (saved) {
                                await ref
                                    .read(libraryProvider.notifier)
                                    .removePin(widget.pin.id, board.id);
                              } else {
                                await ref
                                    .read(repositoryProvider)
                                    .registerDownload(widget.pin);
                                await ref
                                    .read(libraryProvider.notifier)
                                    .savePin(widget.pin, board.id);
                              }
                            });
                            if (!context.mounted) {
                              return;
                            }
                            if (success) {
                              haptic();
                              Navigator.pop(context);
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    saved
                                        ? 'Removed from ${board.name}'
                                        : 'Saved to ${board.name}',
                                  ),
                                ),
                              );
                            } else {
                              setState(() => busy = false);
                            }
                          },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xffefefef),
                child: Icon(Icons.add, color: Colors.black),
              ),
              title: const Text(
                'Create board',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              onTap: busy
                  ? null
                  : () async {
                      await editBoard(context);
                    },
            ),
            if (busy) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class _BoardForm extends ConsumerStatefulWidget {
  const _BoardForm({this.board});
  final Board? board;
  @override
  ConsumerState<_BoardForm> createState() => _BoardFormState();
}

class _BoardFormState extends ConsumerState<_BoardForm> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.board?.name);
  late final description = TextEditingController(
    text: widget.board?.description,
  );
  late bool secret = widget.board?.isSecret ?? false;
  bool busy = false;
  @override
  void dispose() {
    name.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.board == null ? 'Create board' : 'Edit board',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: name,
              autofocus: true,
              maxLength: 60,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Board name',
                hintText: 'Like “Places I want to go”',
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Give your board a name'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: description,
              maxLength: 200,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Keep this board secret',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Only visible in your personal collection'),
              value: secret,
              onChanged: (v) => setState(() => secret = v),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      if (!form.currentState!.validate()) {
                        return;
                      }
                      setState(() => busy = true);
                      String? id;
                      final success = await perform(context, () async {
                        final controller = ref.read(libraryProvider.notifier);
                        if (widget.board case final board?) {
                          await controller.updateBoard(
                            Board(
                              id: board.id,
                              name: name.text.trim(),
                              description: description.text.trim(),
                              isSecret: secret,
                            ),
                          );
                          id = board.id;
                        } else {
                          id = await controller.createBoard(
                            name.text,
                            description: description.text,
                            secret: secret,
                          );
                        }
                      });
                      if (context.mounted) {
                        if (success) {
                          Navigator.pop(context, id);
                        } else {
                          setState(() => busy = false);
                        }
                      }
                    },
              child: Text(
                busy
                    ? 'Saving…'
                    : widget.board == null
                    ? 'Create'
                    : 'Save changes',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
