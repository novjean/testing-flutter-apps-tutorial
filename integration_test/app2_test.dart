import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_page.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
  });

  final articlesFromService = [
    Article(title: 'Test 1', content: 'Test 1 content'),
    Article(title: 'Test 2', content: 'Test 2 content'),
    Article(title: 'Test 3', content: 'Test 3 content'),
  ];

  void arrangeNewsServiceReturns3Articles() {
    when(() => mockNewsService.getArticles()).thenAnswer(
          (_) async => articlesFromService,
    );
  }

  Widget createWidgetUnderTest() {
    // this can be added if we are using flutter binding in the app
    // IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: NewsPage(),
      ),
    );
  }

  testWidgets(
    """Testing out form and checkbox """,
        (WidgetTester tester) async {
      arrangeNewsServiceReturns3Articles();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      //finding an email form field and entering the value
      final emailFormField = find.byKey(Key("email"));
      await tester.enterText(emailFormField, "something@gmail.com");
      await tester.pumpAndSettle();

      // find checkbox
      final firstCheckBox = find.byType(Checkbox).first;
      expect(
        tester.getSemantics(firstCheckBox),
        matchesSemantics(
            hasTapAction: true,
            hasCheckedState: true,
            isChecked: false,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true),
      );
      await tester.tap(firstCheckBox);
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(firstCheckBox),
        matchesSemantics(
            hasTapAction: true,
            hasCheckedState: true,
            isChecked: true,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true),
      );
    },
  );
}
