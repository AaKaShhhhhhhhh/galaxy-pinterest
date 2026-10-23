import 'package:galaxy_pinterest/data/repositories/local_library_repository.dart';
import 'package:flutter/services.dart';
import 'package:galaxy_pinterest/core/services/file_service.dart';
import 'package:galaxy_pinterest/presentation/providers/library_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galaxy_pinterest/app.dart';
import 'package:galaxy_pinterest/core/services/cache_service.dart';
import 'package:galaxy_pinterest/presentation/providers/providers.dart';
import 'package:galaxy_pinterest/data/datasources/demo_data_source.dart';
import 'package:galaxy_pinterest/data/datasources/pexels_data_source.dart';
import 'package:galaxy_pinterest/data/datasources/unsplash_data_source.dart';
import 'package:galaxy_pinterest/data/repositories/pin_repository_impl.dart';
import 'package:galaxy_pinterest/core/services/network_service.dart';
import 'package:galaxy_pinterest/presentation/widgets/pin_card.dart';

void main() {
  testWidgets(
    'Feed renders, opens a Pin, saves it, and exposes the saved board',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cache = CacheService(prefs);
      final demo = DemoDataSource();
      await tester.runAsync(demo.load);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cacheProvider.overrideWithValue(cache),
            repositoryProvider.overrideWithValue(
              PinRepositoryImpl(
                demo,
                PexelsDataSource(NetworkService()),
                cache,
                UnsplashDataSource(),
              ),
            ),
          ],
          child: const GalaxyApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('For you'), findsWidgets);
      expect(find.byTooltip('Your profile'), findsOneWidget);
      await tester.tap(find.byType(PinCard).first);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Back'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, 'Save'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(find.text('Save to board'), findsOneWidget);
      await tester.tap(find.text('My inspiration'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, 'Saved'), findsOneWidget);
      expect(prefs.getString('library_v1_guest'), contains('1571460'));
      await tester.drag(find.byType(Scrollable).last, const Offset(0, 600));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saved').last);
      await tester.pumpAndSettle();
      expect(find.text('Your saved ideas'), findsOneWidget);
      expect(find.text('1 Pin'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Search filters demo content and displays empty state', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final cache = CacheService(prefs);
    final demo = DemoDataSource();
    await tester.runAsync(demo.load);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cacheProvider.overrideWithValue(cache),
          repositoryProvider.overrideWithValue(
            PinRepositoryImpl(
              demo,
              PexelsDataSource(NetworkService()),
              cache,
              UnsplashDataSource(),
            ),
          ),
        ],
        child: const GalaxyApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Search').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'nothing-matches-this');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('A fresh start for your ideas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Create Pin persists selected image bytes and appears in its board',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final cache = CacheService(await SharedPreferences.getInstance());
      final demo = DemoDataSource();
      await tester.runAsync(demo.load);
      final image = await tester.runAsync(
        () async => (await rootBundle.load(
          'assets/images/1571460.jpg',
        )).buffer.asUint8List(),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cacheProvider.overrideWithValue(cache),
            fileServiceProvider.overrideWithValue(_SelectedPhoto(image!)),
            repositoryProvider.overrideWithValue(
              PinRepositoryImpl(
                demo,
                PexelsDataSource(NetworkService()),
                cache,
                UnsplashDataSource(),
              ),
            ),
          ],
          child: const GalaxyApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create').last);
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Choose a photo'));
      await tester.pumpAndSettle();
      expect(find.text('Choose a different photo'), findsOneWidget);
      final title = find.byType(TextFormField).first;
      await tester.ensureVisible(title);
      await tester.enterText(title, 'Sunday at home');
      final board = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(board);
      await tester.tap(board);
      await tester.pumpAndSettle();
      await tester.tap(find.text('My inspiration').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Create'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Your saved ideas'), findsOneWidget);
      final restored = LibraryController(
        LocalLibraryRepository(cache),
        'guest',
      );
      final pin = restored.state.pinsFor('inspiration').single;
      expect(pin.title, 'Sunday at home');
      expect(pin.isCreated, isTrue);
      expect(pin.imageBase64, isNotEmpty);
      expect(pin.assetPath, isNull);
      restored.dispose();
      expect(tester.takeException(), isNull);
    },
  );
}

class _SelectedPhoto extends FileService {
  _SelectedPhoto(this.bytes);
  final Uint8List bytes;
  @override
  Future<Uint8List?> pickImage() async => bytes;
}
