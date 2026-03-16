import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A theme-aware, fully-featured text field widget.
///
/// Wraps Flutter's [TextFormField] and applies the design system's border
/// styling, typography, and color tokens consistently. All styling derives from
/// the ambient [Theme] so it adapts to both light and dark themes automatically.
///
/// **Basic usage**
/// ```dart
/// AppTextField(
///   label: 'Email address',
///   hint: 'you@example.com',
///   keyboardType: TextInputType.emailAddress,
///   onChanged: (v) => setState(() => _email = v),
/// )
/// ```
///
/// **Password field**
/// ```dart
/// AppTextField(
///   label: 'Password',
///   hint: '••••••••',
///   obscureText: true,
///   onChanged: (v) => setState(() => _password = v),
/// )
/// ```
class AppTextField extends StatefulWidget {
  /// Static label displayed above the input field.
  final String? label;

  /// Placeholder text shown when the field is empty.
  final String? hint;

  /// Helper text displayed below the field in normal state.
  final String? helperText;

  /// Error message displayed below the field. When non-null, the field
  /// renders in the error state and [helperText] is suppressed.
  final String? errorText;

  /// Widget placed inside the field prefix area.
  /// Accepts any widget: [Icon], [SvgPicture], or a fully custom widget.
  /// It is automatically sized (48×field-height) and centered.
  final Widget? prefixIcon;

  /// Widget placed inside the field suffix area.
  /// Accepts any widget: [Icon], [SvgPicture], or a fully custom widget.
  /// When [obscureText] is `true` this is replaced by the visibility toggle.
  final Widget? suffixIcon;

  /// When `true`, the field renders an eye-toggle suffix and hides the text.
  /// Providing a custom [suffixIcon] while this is `true` is not recommended.
  final bool obscureText;

  /// Keyboard type — defaults to [TextInputType.text].
  final TextInputType keyboardType;

  /// Horizontal alignment for the editable text.
  /// Use [TextAlign.right] for currency or numeric fields when needed.
  final TextAlign textAlign;

  /// Input action for the IME action button.
  final TextInputAction textInputAction;

  /// External [TextEditingController]. If omitted, an internal one is used.
  final TextEditingController? controller;

  /// Focus node. If omitted, an internal one is used.
  final FocusNode? focusNode;

  /// Called on every keystroke.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (presses the IME action).
  final ValueChanged<String>? onSubmitted;

  /// Called when focus leaves the field.
  final VoidCallback? onTapOutside;

  /// Validation callback used in a [Form] context.
  final FormFieldValidator<String>? validator;

  /// Input formatters applied to every character.
  final List<TextInputFormatter>? inputFormatters;

  /// Maximum number of lines. Defaults to 1. Pass `null` for unlimited.
  final int? maxLines;

  /// Minimum number of lines rendered in a multi-line field.
  final int? minLines;

  /// Maximum character length. Shows a counter when set.
  final int? maxLength;

  /// When `false`, the field ignores all interaction.
  final bool enabled;

  /// When `true`, the field is shown but prevents editing.
  final bool readOnly;

  /// Initial value — only used when [controller] is not provided.
  final String? initialValue;

  /// Auto-fill hints for password managers.
  final Iterable<String>? autofillHints;

  /// Whether to auto-focus this field.
  final bool autofocus;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textAlign = TextAlign.start,
    this.textInputAction = TextInputAction.next,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTapOutside,
    this.validator,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.initialValue,
    this.autofillHints,
    this.autofocus = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  // Tracks visibility when obscureText=true
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  void _toggleObscured() => setState(() => _obscured = !_obscured);

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscured = widget.obscureText;
    }
  }

  // ---------------------------------------------------------------------------
  // Adornment wrapper — normalises Icon / SVG / any Widget into a consistently
  // sized, centred prefix/suffix slot with the correct icon color.
  // ---------------------------------------------------------------------------

  Widget _wrapAdornment(BuildContext context, Widget child) {
    return SizedBox(
      width: 48,
      child: Center(
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
          child: child,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build suffix slot
  // ---------------------------------------------------------------------------

  Widget _buildSuffix(BuildContext context) {
    // Visibility toggle takes precedence when obscureText is true
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onPressed: _toggleObscured,
        tooltip: _obscured ? 'Show password' : 'Hide password',
      );
    }
    return _wrapAdornment(context, widget.suffixIcon!);
  }

  // ---------------------------------------------------------------------------
  // Decoration
  // ---------------------------------------------------------------------------

  InputDecoration _buildDecoration(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final fillColor = widget.enabled ? cs.surface : cs.onSurface.withValues(alpha: 0.12);
    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintText: widget.hint,
      hintStyle: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      errorText: hasError ? widget.errorText : null,
      errorStyle: tt.bodySmall?.copyWith(color: cs.error),
      prefixIcon: widget.prefixIcon != null ? _wrapAdornment(context, widget.prefixIcon!) : null,
      prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      suffixIcon: widget.obscureText || widget.suffixIcon != null ? _buildSuffix(context) : null,
      suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: hasError ? cs.error : cs.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: hasError ? cs.error : cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cs.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cs.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cs.onSurface.withValues(alpha: 0.12)),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final field = TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      initialValue: widget.controller == null ? widget.initialValue : null,
      keyboardType: widget.keyboardType,
      textAlign: widget.textAlign,
      textInputAction: widget.textInputAction,
      obscureText: _obscured,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.obscureText ? null : widget.minLines,
      maxLength: widget.maxLength,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      style: tt.bodySmall,
      cursorColor: cs.primary,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTapOutside: widget.onTapOutside != null
          ? (_) => widget.onTapOutside!()
          : (_) => FocusScope.of(context).unfocus(),
      decoration: _buildDecoration(context),
    );

    if (widget.label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: widget.label,
          child: Text(
            widget.label!,
            style: tt.titleSmall?.copyWith(
              color: widget.enabled ? cs.onSurface : cs.onSurface.withValues(alpha: 0.38),
            ),
          ),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 2),
          Text(widget.helperText!, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}
