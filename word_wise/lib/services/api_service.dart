import 'package:dio/dio.dart';
import 'package:word_wise/core/logger.dart';
import 'package:word_wise/dto/word_detail_dto.dart';

class APIService {
  final Dio dio;

  APIService({required this.dio});

  Future<WordDetailDto> getDefinition({required String word}) async {
    WWLogger.i(message: 'Fetching word:"$word" from API');

    final result = await dio.get(word);
    final data = WordDetailDto.fromJson(result.data[0]);

    return data;
  }
}