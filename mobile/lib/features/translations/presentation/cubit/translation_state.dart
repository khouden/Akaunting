abstract class TranslationState {
  const TranslationState();
}

class TranslationInitial extends TranslationState {}

class TranslationLoading extends TranslationState {}

class TranslationsLoaded extends TranslationState {
  final Map<String, dynamic> translations;
  const TranslationsLoaded(this.translations);
}

class TranslationError extends TranslationState {
  final String message;
  const TranslationError(this.message);
}
