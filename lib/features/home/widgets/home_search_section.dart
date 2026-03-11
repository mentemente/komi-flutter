import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';

const List<String> _suggestions = [
  'Sopa de casa',
  'Aji de gallina',
  'Arroz con pollo',
  'Tallarines verdes',
  'Papa a la huancaina',
];

const int _minLength = 3;
const int _maxLength = 50;

final _lettersAndSpacesFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\s]'),
);

class HomeSearchSection extends StatefulWidget {
  const HomeSearchSection({super.key, this.onSearch});

  final void Function(String query)? onSearch;

  @override
  State<HomeSearchSection> createState() => _HomeSearchSectionState();
}

class _HomeSearchSectionState extends State<HomeSearchSection> {
  late final TextEditingController _controller;
  String? _selectedSuggestion;
  String? _errorText;

  bool get _canSearch {
    final text = _controller.text.trim();
    return text.isNotEmpty && text.length >= _minLength;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text.trim();
    if (_selectedSuggestion != null && text != _selectedSuggestion) {
      _selectedSuggestion = null;
    }
    if (_errorText != null) {
      setState(() => _errorText = null);
    } else {
      setState(() {});
    }
  }

  void _onSuggestionTap(String text) {
    setState(() {
      _selectedSuggestion = text;
      _errorText = null;
    });
    _controller.text = text;
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: text.length,
    );
  }

  void _onSearchPressed() {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      setState(() => _errorText = 'Ingresa un término para buscar');
      return;
    }
    if (text.length < _minLength) {
      setState(
        () => _errorText = 'Escribe al menos $_minLength letras para buscar',
      );
      return;
    }

    setState(() => _errorText = null);
    widget.onSearch?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          inputFormatters: [
            _lettersAndSpacesFormatter,
            LengthLimitingTextInputFormatter(_maxLength),
          ],
          decoration: InputDecoration(
            hintText: 'Buscar',
            prefixIcon: const Icon(Icons.search),
            errorText: _errorText,
            counterText: _controller.text.isNotEmpty
                ? '${_controller.text.length}/$_maxLength'
                : null,
          ),
          style: AppTextStyles.body,
          onSubmitted: (_) => _onSearchPressed(),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._suggestions.map(
              (label) => _SuggestionChip(
                label: label,
                isSelected: _selectedSuggestion == label,
                onTap: () => _onSuggestionTap(label),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: _canSearch ? _onSearchPressed : null,
            child: const Text('Buscar'),
          ),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.2)
          : AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textGray.withValues(alpha: 0.35),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textDark,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
