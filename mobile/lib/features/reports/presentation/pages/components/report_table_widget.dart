import 'package:flutter/material.dart';

class ReportTableWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const ReportTableWidget({super.key, required this.data});

  Map<String, dynamic> _safeMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  @override
  Widget build(BuildContext context) {
    if (data['tables'] == null || data['dates'] == null) {
      return const SizedBox.shrink();
    }

    final tables = _safeMap(data['tables']);
    final dates = List<String>.from(data['dates'] ?? []);
    final rowNames = _safeMap(data['row_names']);
    final rowValues = _safeMap(data['row_values']);
    final footerTotals = _safeMap(data['footer_totals']);

    if (dates.isEmpty || tables.isEmpty) {
      return const Center(child: Text('No data found for this period.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: tables.keys.map((tableKey) {
        final tableName = tables[tableKey] ?? '';

        final currentNames = _safeMap(rowNames[tableKey]);
        final currentValues = _safeMap(rowValues[tableKey]);
        final currentTotals = _safeMap(footerTotals[tableKey]);

        return Card(
          margin: const EdgeInsets.only(bottom: 24),
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (tableName.toString().isNotEmpty)
                Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    tableName.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                  columns: [
                    const DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    ...dates.map((d) => DataColumn(
                          label: Text(d, style: const TextStyle(fontWeight: FontWeight.bold)),
                          numeric: true,
                        )),
                  ],
                  rows: [
                    ...currentNames.keys.map((key) {
                      final name = currentNames[key];
                      final values = currentValues[key] as List<dynamic>? ?? [];
                      return DataRow(
                        cells: [
                          DataCell(Text(name.toString())),
                           for (var i = 0; i < dates.length; i++)
                            DataCell(Text(
                              i < values.length ? values[i].toString() : '0',
                            )),
                        ],
                      );
                    }),
                    if (currentTotals.isNotEmpty)
                      DataRow(
                        color: MaterialStateProperty.all(Theme.of(context).primaryColor.withOpacity(0.05)),
                        cells: [
                          const DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                          for (var d in dates)
                            DataCell(Text(
                              currentTotals[d]?.toString() ?? '0',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
