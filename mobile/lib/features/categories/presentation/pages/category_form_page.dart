import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../data/models/category_model.dart';
import '../cubit/category_cubit.dart';
import '../cubit/category_state.dart';

class CategoryFormPage extends StatefulWidget {
  final CategoryModel? category;
  const CategoryFormPage({super.key, this.category});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _colorController;
  String _type = 'expense';
  late CategoryCubit _cubit;

  bool get isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I<CategoryCubit>();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _colorController = TextEditingController(text: widget.category?.color ?? '#6DA252');
    _type = widget.category?.type ?? 'expense';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<CategoryCubit, CategoryState>(
        listener: (context, state) {
          if (state is CategoryOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          } else if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? 'Edit Category' : 'New Category'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'expense', child: Text('Expense')),
                    DropdownMenuItem(value: 'income', child: Text('Income')),
                    DropdownMenuItem(value: 'item', child: Text('Item')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? 'expense'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _colorController,
                  decoration: const InputDecoration(labelText: 'Color (hex)', border: OutlineInputBorder(), hintText: '#6DA252'),
                ),
                const SizedBox(height: 24),
                BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, state) {
                    return FilledButton(
                      onPressed: state is CategoryLoading ? null : _submit,
                      child: state is CategoryLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(isEditing ? 'Update' : 'Create'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'name': _nameController.text,
      'type': _type,
      'color': _colorController.text,
    };
    if (isEditing) {
      _cubit.updateCategory(widget.category!.id, data);
    } else {
      _cubit.createCategory(data);
    }
  }
}
