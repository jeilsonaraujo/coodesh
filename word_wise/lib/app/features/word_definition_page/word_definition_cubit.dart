import 'package:bloc/bloc.dart';
import 'package:word_wise/app/features/word_definition_page/word_definition_state.dart';
import 'package:word_wise/core/logger.dart';
import 'package:word_wise/dto/user_dto.dart';
import 'package:word_wise/dto/word_detail_dto.dart';
import 'package:word_wise/repositories/word_repository.dart';
import 'package:word_wise/services/auth_service.dart';
import 'package:word_wise/services/cache_service.dart';

class WordDefinitionCubit extends Cubit<WordDefinitionState> {
  final WordRepository repository;
  final CacheService cacheService;
  final AuthService authService;

  WordDefinitionCubit({required this.authService, required this.repository, required this.cacheService}) : super(const WordDefinitionState.loading());
  WordDetailDto? wordDefinition;
  bool isFavorite = false;

  Future<void> load({required String word}) async {
    try {
      emit(const WordDefinitionState.loading());
      WWLogger.l(message: 'Loading history');
      wordDefinition = await getFirstFromCache(word: word);
      if (wordDefinition != null) {
        WWLogger.l(message: 'Fetched details of ${wordDefinition!.word}');
        registerHistory(word: word, userId: authService.applicationUser?.userId ?? '');
        if (authService.applicationUser.isNotNull) {
          isFavorite = await repository.isFavoriteWord(userId: authService.applicationUser?.userId ?? '', word: word);
        }
        emit(WordDefinitionState.content(wordDetail: wordDefinition!, isFavorite: isFavorite));
      }
    } catch (exception, stackTrace) {
      WWLogger.e(message: exception.toString(), exception: exception, stackTrace: stackTrace);
      emit(const WordDefinitionState.error());
    }
  }

  void registerHistory({required String word, required String userId}) {
    if (authService.applicationUser.isNull) return;

    repository.registerHistoryVisit(word: word, userId: userId);
  }

  Future<WordDetailDto> getFirstFromCache({required String word}) async {
    WordDetailDto? response;

    response = await cacheService.getFromCache(key: word);
    if (response != null) {
      WWLogger.i(message: '"$word" was found stored on cache');
      return response;
    }
    WWLogger.i(message: '"$word" not found stored on cache');
    response = await repository.getWordDefinition(word: word);
    await cacheService.putOnCache(key: word, value: response);
    WWLogger.i(message: 'Word: "$word" stored on cache');
    return response;
  }

  Future<void> toggleFavorite({required String word}) async {
    if (authService.applicationUser.isNull) return;
    isFavorite
        ? await repository.unFavoriteWord(userId: authService.applicationUser?.userId ?? '', word: word)
        : await repository.favoriteWord(userId: authService.applicationUser?.userId ?? '', word: word);
    isFavorite = await repository.isFavoriteWord(userId: authService.applicationUser?.userId ?? '', word: word);
    emit(WordDefinitionState.content(wordDetail: wordDefinition!, isFavorite: isFavorite));
  }
}
