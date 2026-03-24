import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/user_action_cubit.dart';
import '../cubit/user_action_state.dart';
import '../../data/models/user_model.dart';
import '../../../companies/presentation/cubit/company_cubit.dart';
import '../../../companies/presentation/cubit/company_state.dart';
import '../../../companies/data/models/company_model.dart';

class UserFormPage extends StatefulWidget {
  final UserModel? user;

  const UserFormPage({super.key, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _passwordConfirmController;
  late TextEditingController _landingPageController;
  late String _selectedRole;
  late bool _enabled;
  List<int> _selectedCompanyIds = [];

  bool get isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _passwordConfirmController = TextEditingController();
    _landingPageController = TextEditingController(
      text: widget.user?.landingPage ?? '/',
    );
    _selectedRole = '1';
    _enabled = widget.user?.enabled ?? true;

    // Load companies list
    context.read<CompanyCubit>().getCompanies();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _landingPageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCompanyIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one company.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final data = <String, dynamic>{
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'landing_page': _landingPageController.text.trim(),
        'roles': _selectedRole,
        'companies': _selectedCompanyIds,
        'enabled': _enabled ? 1 : 0,
      };

      // Only send password fields when creating or explicitly changing
      if (!isEditing || _passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
        data['password_confirmation'] = _passwordConfirmController.text;
      }

      if (isEditing) {
        context.read<UserActionCubit>().updateUser(widget.user!.id, data);
      } else {
        context.read<UserActionCubit>().createUser(data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<UserActionCubit, UserActionState>(
      listener: (context, state) {
        if (state is UserActionSaved) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'User updated!' : 'User created!'),
              backgroundColor: const Color(0xFF00D084),
            ),
          );
        } else if (state is UserActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.only(bottom: bottomInset),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    isEditing ? 'Edit User' : 'New User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 14),

                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Email is required';
                      if (!val.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  _buildTextField(
                    controller: _passwordController,
                    label: isEditing ? 'New Password (optional)' : 'Password',
                    icon: Icons.lock_outline,
                    obscure: true,
                    validator: isEditing
                        ? null
                        : (val) => val == null || val.isEmpty
                            ? 'Password is required'
                            : null,
                  ),
                  const SizedBox(height: 14),

                  _buildTextField(
                    controller: _passwordConfirmController,
                    label: 'Confirm Password',
                    icon: Icons.lock_outline,
                    obscure: true,
                    validator: (val) {
                      if (_passwordController.text.isNotEmpty &&
                          val != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Role dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      prefixIcon: const Icon(Icons.admin_panel_settings_outlined,
                          size: 20),
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF00D084)),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: '1', child: Text('Admin')),
                      DropdownMenuItem(value: '2', child: Text('Manager')),
                      DropdownMenuItem(value: '3', child: Text('Accountant')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRole = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Companies selector
                  _buildCompanySelector(),
                  const SizedBox(height: 14),

                  _buildTextField(
                    controller: _landingPageController,
                    label: 'Landing Page',
                    icon: Icons.home_outlined,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),

                  // Enabled toggle
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Enabled',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        Switch(
                          value: _enabled,
                          activeColor: const Color(0xFF00D084),
                          onChanged: (val) => setState(() => _enabled = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  BlocBuilder<UserActionCubit, UserActionState>(
                    builder: (context, actionState) {
                      final isLoading = actionState is UserActionLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00D084),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  isEditing ? 'Update User' : 'Create User',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanySelector() {
    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) {
        List<CompanyModel> companies = [];
        if (state is CompanyLoaded) {
          companies = state.companies;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.business_outlined, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Companies *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (state is CompanyLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF00D084),
                      ),
                    ),
                  ),
                )
              else if (companies.isEmpty)
                Text(
                  'No companies available.',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: companies.map((company) {
                    final isSelected = _selectedCompanyIds.contains(company.id);
                    return FilterChip(
                      label: Text(company.name),
                      selected: isSelected,
                      selectedColor: const Color(0xFF00D084).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF00D084),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF00D084)
                            : Colors.grey[300]!,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCompanyIds.add(company.id);
                          } else {
                            _selectedCompanyIds.remove(company.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        labelStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF00D084)),
        ),
      ),
    );
  }
}
