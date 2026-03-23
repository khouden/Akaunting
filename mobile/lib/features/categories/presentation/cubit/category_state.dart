import '../../../../data/models/category_model.dart';

abstract class CategoryState {
  const CategoryState();
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoriesLoaded extends CategoryState {
  final List<CategoryModel> categories;
  const CategoriesLoaded(this.categories);
}

class CategoryDetailLoaded extends CategoryState {
  final CategoryModel category;
  const CategoryDetailLoaded(this.category);
}

class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);
}

class CategoryOperationSuccess extends CategoryState {
  final String message;
  const CategoryOperationSuccess(this.message);
}
