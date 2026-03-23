import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../domain/repositories/category_repository.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repository = GetIt.I<CategoryRepository>();

  CategoryCubit() : super(CategoryInitial());

  Future<void> fetchCategories({Map<String, dynamic>? query}) async {
    emit(CategoryLoading());
    try {
      final categories = await _repository.getCategories(query: query);
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> fetchCategory(int id) async {
    emit(CategoryLoading());
    try {
      final category = await _repository.getCategory(id);
      emit(CategoryDetailLoaded(category));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> createCategory(Map<String, dynamic> data) async {
    emit(CategoryLoading());
    try {
      await _repository.createCategory(data);
      emit(const CategoryOperationSuccess('Category created successfully'));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> updateCategory(int id, Map<String, dynamic> data) async {
    emit(CategoryLoading());
    try {
      await _repository.updateCategory(id, data);
      emit(const CategoryOperationSuccess('Category updated successfully'));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> deleteCategory(int id) async {
    emit(CategoryLoading());
    try {
      await _repository.deleteCategory(id);
      emit(const CategoryOperationSuccess('Category deleted successfully'));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> enableCategory(int id) async {
    try {
      await _repository.enableCategory(id);
      emit(const CategoryOperationSuccess('Category enabled'));
      fetchCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> disableCategory(int id) async {
    try {
      await _repository.disableCategory(id);
      emit(const CategoryOperationSuccess('Category disabled'));
      fetchCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
