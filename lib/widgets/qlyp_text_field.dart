import 'package:flutter/material.dart';

import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';

/// Champ de saisie QLYP — PRD 3.3 et 3.6.
///
/// Border-radius 10px. Compact au repos, elargi au focus via
/// [AnimatedContainer] en [kQlypSpring] sur [kDurFocus] (300ms), avec un
/// overlay de suggestions ancre sous le champ.
class QlypTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Suggestions proposees dans l'overlay quand le champ a le focus.
  final List<String> suggestions;

  /// Appele quand une suggestion est choisie.
  final ValueChanged<String>? onSuggestionSelected;

  /// Nombre maximum de suggestions affichees.
  final int maxSuggestions;

  const QlypTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.suggestions = const [],
    this.onSuggestionSelected,
    this.maxSuggestions = 5,
  });

  @override
  State<QlypTextField> createState() => _QlypTextFieldState();
}

class _QlypTextFieldState extends State<QlypTextField> {
  static const double _radius = 10;
  static const double _restHeight = 48;
  static const double _focusHeight = 56;

  final LayerLink _link = LayerLink();

  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;

  OverlayEntry? _overlay;
  bool _focused = false;
  double _fieldWidth = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _ownsController = widget.controller == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _removeOverlay();
    if (_ownsFocusNode) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    final query = _controller.text.trim().toLowerCase();
    final matches = query.isEmpty
        ? widget.suggestions
        : widget.suggestions
            .where((s) => s.toLowerCase().contains(query))
            .toList();
    return matches.take(widget.maxSuggestions).toList();
  }

  void _handleFocusChange() {
    final hasFocus = _focusNode.hasFocus;
    if (hasFocus == _focused) return;
    setState(() => _focused = hasFocus);
    if (hasFocus) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    if (_overlay != null || _filtered.isEmpty) return;
    _overlay = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context).insert(_overlay!);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _handleChanged(String value) {
    widget.onChanged?.call(value);
    if (!_focused) return;
    if (_filtered.isEmpty) {
      _removeOverlay();
    } else if (_overlay == null) {
      _showOverlay();
    } else {
      _overlay!.markNeedsBuild();
    }
  }

  void _selectSuggestion(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    widget.onSuggestionSelected?.call(value);
    _focusNode.unfocus();
  }

  Widget _buildOverlay(BuildContext context) {
    final suggestions = _filtered;
    final textTheme = Theme.of(context).textTheme;

    return Positioned(
      width: _fieldWidth,
      child: CompositedTransformFollower(
        link: _link,
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.topLeft,
        offset: const Offset(0, 8),
        child: Material(
          color: QlypColors.white,
          elevation: 8,
          shadowColor: QlypColors.midnightQlyp.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(_radius),
          clipBehavior: Clip.antiAlias,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: suggestions.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 1,
              color: QlypColors.grayVeryLight,
            ),
            itemBuilder: (_, index) {
              final suggestion = suggestions[index];
              return InkWell(
                onTap: () => _selectSuggestion(suggestion),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 18,
                        color: QlypColors.gray,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          suggestion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: QlypColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final borderColor = _hasError
        ? QlypColors.red
        : (_focused ? QlypColors.emerald : QlypColors.grayLight);

    return CompositedTransformTarget(
      link: _link,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _fieldWidth = constraints.maxWidth;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.labelText != null) ...[
                Text(
                  widget.labelText!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: QlypColors.gray,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              AnimatedContainer(
                duration: kDurFocus,
                curve: kQlypSpring,
                height: _focused ? _focusHeight : _restHeight,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: widget.enabled
                      ? QlypColors.white
                      : QlypColors.grayVeryLight,
                  borderRadius: BorderRadius.circular(_radius),
                  border: Border.all(
                    color: borderColor,
                    width: _focused || _hasError ? 1.5 : 1,
                  ),
                  boxShadow: _focused && !_hasError
                      ? [
                          BoxShadow(
                            color: QlypColors.emerald.withValues(alpha: 0.14),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    if (widget.prefixIcon != null) ...[
                      Icon(
                        widget.prefixIcon,
                        size: 20,
                        color: _focused
                            ? QlypColors.emerald
                            : QlypColors.gray,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: widget.enabled,
                        obscureText: widget.obscureText,
                        keyboardType: widget.keyboardType,
                        textInputAction: widget.textInputAction,
                        onChanged: _handleChanged,
                        onSubmitted: widget.onSubmitted,
                        cursorColor: QlypColors.emerald,
                        style: textTheme.bodyLarge?.copyWith(
                          color: QlypColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: widget.hintText,
                          hintStyle: textTheme.bodyLarge?.copyWith(
                            color: QlypColors.gray,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_hasError) ...[
                const SizedBox(height: 6),
                Text(
                  widget.errorText!,
                  style: textTheme.bodySmall?.copyWith(color: QlypColors.red),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

typedef QlypInput = QlypTextField;
