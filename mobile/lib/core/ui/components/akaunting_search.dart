import 'package:flutter/material.dart';

class AkauntingSearch extends StatefulWidget {
  final String placeholder;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onClear;

  const AkauntingSearch({
    super.key,
    this.placeholder = 'Search or filter results...',
    this.onSearch,
    this.onClear,
  });

  @override
  State<AkauntingSearch> createState() => _AkauntingSearchState();
}

class _AkauntingSearchState extends State<AkauntingSearch> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    if (widget.onSearch != null) {
      widget.onSearch!(_controller.text);
    }
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {});
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _controller,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _triggerSearch(),
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: widget.placeholder,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  onPressed: _clearSearch,
                ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: _controller.text.isNotEmpty
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  size: 20,
                ),
                onPressed: _triggerSearch,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
