import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../data/models/document_model.dart';
import '../../../../../logic/cubits/document_cubit.dart';
import '../../../../../logic/cubits/document_transaction_cubit.dart';
import 'document_form_page.dart';
import 'document_transaction_form_page.dart';

class DocumentDetailPage extends StatelessWidget {
  final DocumentModel document;

  const DocumentDetailPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DocumentCubit>(create: (context) => sl<DocumentCubit>()),
        BlocProvider<DocumentTransactionCubit>(
          create: (context) => sl<DocumentTransactionCubit>()..loadDocumentTransactions(document.id),
        ),
      ],
      child: _DocumentDetailView(initialDocument: document),
    );
  }
}

class _DocumentDetailView extends StatefulWidget {
  final DocumentModel initialDocument;

  const _DocumentDetailView({required this.initialDocument});

  @override
  State<_DocumentDetailView> createState() => _DocumentDetailViewState();
}

class _DocumentDetailViewState extends State<_DocumentDetailView> {
  late DocumentModel _currentDoc;

  @override
  void initState() {
    super.initState();
    _currentDoc = widget.initialDocument;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DocumentCubit, DocumentState>(
      listener: (context, state) {
        if (state is DocumentError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        } else if (state is DocumentSaved) {
          setState(() {
            _currentDoc = state.document;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document updated successfully'), backgroundColor: Colors.green));
        } else if (state is DocumentLoaded) {
          setState(() {
            _currentDoc = state.document;
          });
        } else if (state is DocumentDeleted) {
          Navigator.of(context).pop(true); // Pop the detail page and indicate success
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document deleted'), backgroundColor: Colors.green));
        }
      },
      builder: (context, state) {
        final isLoading = state is DocumentLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F8),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Text(
              _currentDoc.documentNumber,
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DocumentFormPage(document: _currentDoc),
                    ),
                  ).then((res) {
                    if (res == true) {
                      // If the form was saved, reload the document to get updated data
                      context.read<DocumentCubit>().loadDocument(_currentDoc.id);
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context),
              )
            ],
          ),
          body: isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _DetailRow(label: 'Type', value: _currentDoc.type.toUpperCase()),
                        const Divider(),
                        _DetailRow(label: 'Status', value: _currentDoc.status.toUpperCase()),
                        const Divider(),
                        _DetailRow(label: 'Amount', value: _currentDoc.amount.toStringAsFixed(2)),
                        const Divider(),
                        _DetailRow(label: 'Contact', value: _currentDoc.contactName ?? 'N/A'),
                        if (_currentDoc.issueDate != null) ...[
                          const Divider(),
                          _DetailRow(label: 'Issue Date', value: _currentDoc.issueDate!),
                        ],
                        if (_currentDoc.dueDate != null) ...[
                          const Divider(),
                          _DetailRow(label: 'Due Date', value: _currentDoc.dueDate!),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.blue),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DocumentTransactionFormPage(
                              documentId: _currentDoc.id,
                            ),
                          ),
                        ).then((res) {
                          if (res == true) {
                            context.read<DocumentTransactionCubit>().loadDocumentTransactions(_currentDoc.id);
                            context.read<DocumentCubit>().loadDocument(_currentDoc.id);
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                BlocConsumer<DocumentTransactionCubit, DocumentTransactionState>(
                  listener: (context, txState) {
                    if (txState is DocumentTransactionDeleted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction deleted', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
                      context.read<DocumentTransactionCubit>().loadDocumentTransactions(_currentDoc.id);
                      context.read<DocumentCubit>().loadDocument(_currentDoc.id);
                    }
                  },
                  builder: (context, txState) {
                    if (txState is DocumentTransactionLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (txState is DocumentTransactionsLoaded) {
                      if (txState.transactions.isEmpty) {
                        return const Center(child: Text('No transactions found.'));
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: txState.transactions.length,
                        itemBuilder: (context, index) {
                          final tx = txState.transactions[index];
                          return Dismissible(
                            key: ValueKey(tx.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20.0),
                              color: Colors.red,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Transaction'),
                                  content: const Text('Are you sure you want to delete this transaction?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text('CANCEL'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) {
                              context.read<DocumentTransactionCubit>().deleteDocumentTransaction(_currentDoc.id, tx.id);
                            },
                            child: Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => DocumentTransactionFormPage(
                                        documentId: _currentDoc.id,
                                        transaction: tx,
                                      ),
                                    ),
                                  ).then((res) {
                                    if (res == true) {
                                      context.read<DocumentTransactionCubit>().loadDocumentTransactions(_currentDoc.id);
                                      context.read<DocumentCubit>().loadDocument(_currentDoc.id);
                                    }
                                  });
                                },
                                leading: CircleAvatar(
                                  backgroundColor: tx.type == 'income' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  child: Icon(
                                    tx.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: tx.type == 'income' ? Colors.green : Colors.red,
                                  ),
                                ),
                                title: Text(tx.description ?? tx.type.toUpperCase()),
                                subtitle: Text(tx.paidAt),
                                trailing: Text(
                                  tx.amountFormatted ?? tx.amount.toStringAsFixed(2),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (txState is DocumentTransactionError) {
                      return Center(child: Text(txState.message, style: const TextStyle(color: Colors.red)));
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 24),
                if (_currentDoc.status != 'received')
                  ElevatedButton(
                    onPressed: () {
                      context.read<DocumentCubit>().markAsReceived(_currentDoc.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Mark as Received', style: TextStyle(color: Colors.white)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('This document is received.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
              context.read<DocumentCubit>().deleteDocument(_currentDoc.id);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
