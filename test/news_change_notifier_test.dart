import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  // system under test
  late NewsChangeNotifier sut;
  late MockNewsService mockNewsService;

  // setup method runs before each and every test
  setUp(() {
    mockNewsService = MockNewsService();
    sut = NewsChangeNotifier(mockNewsService);
  });

  test(
    "initial values are correct",
    () {
      expect(sut.articles, []);
      expect(sut.isLoading, false);
    },
  );

  group('getArticles', () {
    final articlesFromService = [Article(title: 'Test 1', content: 'Test 1 content'),
      Article(title: 'Test 2', content: 'Test 2 content'),
      Article(title: 'Test 3', content: 'Test 3 content'),];

    void arrangeNewsServiceReturns3Articles() {
      when(() => mockNewsService.getArticles()).thenAnswer((_) async => articlesFromService);
    }

    test(
      "gets articles using the NewsService",
      () async {
        // when(() => mockNewsService.getArticles()).thenAnswer((_) async => []);
        arrangeNewsServiceReturns3Articles();

        await sut.getArticles();
        verify(() => mockNewsService.getArticles()).called(1);
      },
    );

    test(
      """indicates loading of data, 
      sets articles to the ones from the service,
      indicates that data is not being loaded anymore""",
          () async {
        arrangeNewsServiceReturns3Articles();
        final future = sut.getArticles(); // future here so that we are not awaiting and to see if isLoading below is correct
        expect(sut.isLoading, true);
        await future;
        expect(sut.articles, articlesFromService);
        expect(sut.isLoading, false);
      },
    );
  });
}
