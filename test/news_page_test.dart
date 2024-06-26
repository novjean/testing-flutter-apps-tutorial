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
    when(() => mockNewsService.getArticles())
        .thenAnswer((_) async => articlesFromService);
  }

  void arrangeNewsServiceReturns3ArticlesAfter2SecondWait() {
    when(() => mockNewsService.getArticles()).thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 2));
      return articlesFromService;
    });
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: NewsPage(),
      ),
    );
  }

  testWidgets(
    'title is displayed',
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3Articles();

      //build the page into the invisible UI
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('News'), findsOneWidget);
    },
  );

  testWidgets(
    'loading indicator is displayed while waiting for articles',
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3ArticlesAfter2SecondWait();

      //build the page into the invisible UI
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 500));

      // expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(Key('progress-indicator')), findsOneWidget);

      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'articles are displayed',
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3Articles();

      //build the page into the invisible UI
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      for (final article in articlesFromService) {
        expect(find.text(article.title), findsOneWidget);
        expect(find.text(article.content), findsOneWidget);
      }
    },
  );

  testWidgets(
    'articles are scrolled with n number of items',
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3Articles();

      //build the page into the invisible UI
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      expect(find.text("Test 1"), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));
    },
  );

  testWidgets('should show only 2 item on small screen size',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = Size(720, 720);

    arrangeNewsServiceReturns3Articles();

    //build the page into the invisible UI
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('should throw error if empty list is provided',
          (WidgetTester tester) async {
        // arrangeNewsServiceReturns3Articles();

        //build the page into the invisible UI
        await tester.pumpWidget(createWidgetUnderTest());
        // await tester.pump();

        expect(tester.takeException(), isAssertionError);
      });
}
