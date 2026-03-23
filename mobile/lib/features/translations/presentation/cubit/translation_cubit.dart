import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../domain/repositories/translation_repository.dart';
import 'translation_state.dart';

class TranslationCubit extends Cubit<TranslationState> {
  final TranslationRepository _repository = GetIt.I<TranslationRepository>();

  TranslationCubit() : super(TranslationInitial());

  Future<void> fetchAll(String locale) async {
    emit(TranslationLoading());
    try {
      final translations = await _repository.getAll(locale);
      emit(TranslationsLoaded(translations));
    } catch (e) {
      emit(TranslationError(e.toString()));
    }
  }

  Future<void> fetchFile(String locale, String file) async {
    emit(TranslationLoading());
    try {
      final translations = await _repository.getFile(locale, file);
      emit(TranslationsLoaded(translations));
    } catch (e) {
      emit(TranslationError(e.toString()));
    }
  }
}
