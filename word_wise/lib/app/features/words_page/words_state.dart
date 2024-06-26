import 'package:freezed_annotation/freezed_annotation.dart';

part 'words_state.freezed.dart';

@freezed
class WordsState with _$WordsState {
  const factory WordsState.loading() = _Loading;

  const factory WordsState.error() = _Error;

  const factory WordsState.empty() = _Empty;

  const factory WordsState.paginating({required List<String> words}) = _Paginating;

  const factory WordsState.content({required List<String> words}) = _Content;
}

extension WordsStateExt on WordsState {
  bool get isContentOrPaginating => this is _Loading || this is _Paginating;
  bool get isLoading => this is _Loading;
  bool get isPaginating => this is _Paginating;
  bool get isContent => this is _Content;
  bool get isError => this is _Error;
  bool get isEmpty => this is _Empty;

  List get getWords => this is _Content
      ? (this as _Content).words
      : this is _Paginating
          ? (this as _Paginating).words
          : [];
}
