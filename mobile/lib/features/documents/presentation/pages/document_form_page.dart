import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/document_model.dart';
import '../../../../logic/cubits/document_cubit.dart';
import '../../../../logic/cubits/contact_cubit.dart';
import '../../../../features/currencies/presentation/cubit/currency_cubit.dart';
import '../../../../features/currencies/presentation/cubit/currency_state.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/ui/components/base_alert.dart';
import '../../../../core/ui/components/base_button.dart';

class DocumentFormPage extends StatelessWidget {
  final DocumentModel? document;

  const DocumentFormPage({super.key, this.document});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DocumentCubit>(
          create: (context) => sl<DocumentCubit>(),
        ),
        BlocProvider<ContactCubit>(
          create: (context) => sl<ContactCubit>()..loadContacts(search: 'type:customer'),
        ),
        BlocProvider<CurrencyCubit>(
          create: (context) => sl<CurrencyCubit>()..fetchCurrencies(query: {'enabled': 1}),
        ),
      ],
      child: _DocumentFormView(document: document),
    );
  }
}

class _DocumentFormView extends StatefulWidget {
  final DocumentModel? document;

  const _DocumentFormView({this.document});

  @override
  State<_DocumentFormView> createState() => _DocumentFormViewState();
}

class _DocumentFormViewState extends State<_DocumentFormView> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _numberController;
  late TextEditingController _amountController;
  
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  
  int? _selectedContactId;
  String? _selectedContactName;
  String _status = 'draft';
  String? _currencyCode;
  
  final List<String> _statuses = ['draft', 'sent', 'received', 'viewed', 'partial', 'paid', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(text: widget.document?.documentNumber ?? 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
    _amountController = TextEditingController(text: widget.document != null ? widget.document!.amount.toString() : '');
    _status = widget.document?.status ?? 'draft';
    _selectedContactId = widget.document?.contactId;
    _selectedContactName = widget.document?.contactName;
    _currencyCode = widget.document?.currencyCode;
    
    if (widget.document?.issueDate != null) {
      _issueDate = DateTime.tryParse(widget.document!.issueDate!) ?? DateTime.now();
    }
    if (widget.document?.dueDate != null) {
      _dueDate = DateTime.tryParse(widget.document!.dueDate!) ?? DateTime.now().add(const Duration(days: 30));
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedContactId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a contact')));
        return;
      }
      if (_currencyCode == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a currency')));
        return;
      }
      
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final data = {
        'type': widget.document?.type ?? 'invoice',
        'document_number': _numberController.text,
        'status': _status,
        'amount': amount,
        'contact_id': _selectedContactId,
        'contact_name': _selectedContactName,
        'issued_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(_issueDate),
        'due_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(_dueDate),
        'currency_code': _currencyCode,
        'currency_rate': 1,
        'category_id': 1,
        'items': [
          {
            'name': 'Custom Service',
            'description': '',
            'price': amount,
            'quantity': 1,
            'currency': _currencyCode,
          }
        ]
      };

      if (widget.document != null) {
        context.read<DocumentCubit>().updateDocument(widget.document!.id, data);
      } else {
        context.read<DocumentCubit>().createDocument(data);
      }
    }
  }
  
  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isIssueDate ? _issueDate : _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = picked;
          if (_dueDate.isBefore(_issueDate)) {
            _dueDate = _issueDate.add(const Duration(days: 1));
          }
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document != null ? 'Edit Document' : 'New Document'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<DocumentCubit, DocumentState>(
        listener: (context, state) {
          if (state is DocumentSaved) {
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(widget.document != null ? 'Document updated successfully' : 'Document created successfully')),
            );
          } else if (state is DocumentError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'Document Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a document number' : null,
              ),
              const SizedBox(height: 16),
              
              BlocBuilder<ContactCubit, ContactState>(
                builder: (context, state) {
                  if (state is ContactLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ContactsLoaded) {
                    final contacts = state.contacts;
                    return DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Contact (Customer)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      value: _selectedContactId,
                      items: contacts.map((contact) {
                        return DropdownMenuItem<int>(
                          value: contact.id,
                          child: Text(contact.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedContactId = value;
                          if (value != null) {
                            _selectedContactName = contacts.firstWhere((c) => c.id == value).name;
                          }
                        });
                      },
                      validator: (value) => value == null ? 'Please select a contact' : null,
                    );
                  }
                  return const Text('Error loading contacts');
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter an amount' : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                value: _status,
                items: _statuses.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              const SizedBox(height: 16),
              
              BlocBuilder<CurrencyCubit, CurrencyState>(
                builder: (context, state) {
                  if (state is CurrencyLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CurrenciesLoaded) {
                    final currencies = state.currencies;
                    
                    if (_currencyCode == null && currencies.isNotEmpty) {
                       WidgetsBinding.instance.addPostFrameCallback((_) {
                         setState(() {
                           _currencyCode = widget.document?.currencyCode ?? currencies.first.code;
                         });
                       });
                    }
                    
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.money),
                      ),
                      value: currencies.any((c) => c.code == _currencyCode) ? _currencyCode : (currencies.isNotEmpty ? currencies.first.code : null),
                      items: currencies.map((currency) {
                        return DropdownMenuItem<String>(
                          value: currency.code,
                          child: Text('${currency.code} - ${currency.name}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _currencyCode = value);
                      },
                      validator: (value) => value == null ? 'Please select a currency' : null,
                    );
                  }
                  return const Text('Error loading currencies');
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Issue Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('yyyy-MM-dd').format(_issueDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.event),
                        ),
                        child: Text(DateFormat('yyyy-MM-dd').format(_dueDate)),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              BlocBuilder<DocumentCubit, DocumentState>(
                builder: (context, state) {
                  return BaseButton(
                    onPressed: state is DocumentLoading ? null : _submitForm,
                    loading: state is DocumentLoading,
                    block: true,
                    type: ButtonType.primary,
                    child: Text(widget.document != null ? 'Update Document' : 'Save Document'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
