import 'package:design_system/design_system.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// =============================================================================
// Formz validation models
// =============================================================================

enum _NameError { empty }

class _NameInput extends FormzInput<String, _NameError> {
  const _NameInput.pure() : super.pure('');
  const _NameInput.dirty([super.value = '']) : super.dirty();

  @override
  _NameError? validator(String value) => value.trim().isEmpty ? _NameError.empty : null;
}

enum _EmailError { empty, invalid }

class _EmailInput extends FormzInput<String, _EmailError> {
  const _EmailInput.pure() : super.pure('');
  const _EmailInput.dirty([super.value = '']) : super.dirty();

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  _EmailError? validator(String value) {
    if (value.trim().isEmpty) return _EmailError.empty;
    if (!_emailRegex.hasMatch(value)) return _EmailError.invalid;
    return null;
  }
}

enum _PhoneError { empty, invalid }

class _PhoneInput extends FormzInput<String, _PhoneError> {
  const _PhoneInput.pure() : super.pure('');
  const _PhoneInput.dirty([super.value = '']) : super.dirty();

  // Minimal 10 digit digit setelah strip mask
  @override
  _PhoneError? validator(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return _PhoneError.empty;
    if (digits.length < 10) return _PhoneError.invalid;
    return null;
  }
}

enum _PasswordError { empty, tooShort }

class _PasswordInput extends FormzInput<String, _PasswordError> {
  const _PasswordInput.pure() : super.pure('');
  const _PasswordInput.dirty([super.value = '']) : super.dirty();

  @override
  _PasswordError? validator(String value) {
    if (value.isEmpty) return _PasswordError.empty;
    if (value.length < 8) return _PasswordError.tooShort;
    return null;
  }
}

enum _AmountError { empty, belowMinimum }

class _AmountInput extends FormzInput<String, _AmountError> {
  const _AmountInput.pure() : super.pure('');
  const _AmountInput.dirty([super.value = '']) : super.dirty();

  static const minAmount = 10000;

  @override
  _AmountError? validator(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return _AmountError.empty;
    final amount = int.tryParse(digits) ?? 0;
    if (amount < minAmount) return _AmountError.belowMinimum;
    return null;
  }
}

// =============================================================================
// Page
// =============================================================================

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();

  // Formz inputs
  var _name = const _NameInput.pure();
  var _email = const _EmailInput.pure();
  var _phone = const _PhoneInput.pure();
  var _password = const _PasswordInput.pure();
  var _amount = const _AmountInput.pure();

  final _currencyFormatter = CurrencyTextInputFormatter.currency(
    enableNegative: false,
    minValue: 0,
    locale: 'id',
    decimalDigits: 0,
    symbol: '',
  );

  // Phone mask formatter
  final _phoneMask = MaskTextInputFormatter(
    mask: '+62 ###-####-####',
    filter: {'#': RegExp(r'\d')},
  );

  FormzSubmissionStatus _status = FormzSubmissionStatus.initial;

  bool get _isValid => Formz.validate([_name, _email, _phone, _password, _amount]);

  String? _nameError() => switch (_name.displayError) {
    _NameError.empty => 'Nama tidak boleh kosong',
    null => null,
  };

  String? _emailError() => switch (_email.displayError) {
    _EmailError.empty => 'Email tidak boleh kosong',
    _EmailError.invalid => 'Format email tidak valid',
    null => null,
  };

  String? _phoneError() => switch (_phone.displayError) {
    _PhoneError.empty => 'Nomor HP tidak boleh kosong',
    _PhoneError.invalid => 'Nomor HP minimal 10 digit',
    null => null,
  };

  String? _passwordError() => switch (_password.displayError) {
    _PasswordError.empty => 'Password tidak boleh kosong',
    _PasswordError.tooShort => 'Password minimal 8 karakter',
    null => null,
  };

  String? _amountError() => switch (_amount.displayError) {
    _AmountError.empty => 'Nominal tidak boleh kosong',
    _AmountError.belowMinimum => 'Nominal minimal Rp 10.000',
    null => null,
  };

  Future<void> _submit() async {
    // Mark all dirty to trigger validation display
    setState(() {
      _name = _NameInput.dirty(_name.value);
      _email = _EmailInput.dirty(_email.value);
      _phone = _PhoneInput.dirty(_phone.value);
      _password = _PasswordInput.dirty(_password.value);
      _amount = _AmountInput.dirty(_amount.value);
    });

    if (!_isValid) return;

    setState(() => _status = FormzSubmissionStatus.inProgress);

    // Simulate API call
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _status = FormzSubmissionStatus.success);

    AppSnackbar.show(context, message: 'Form berhasil dikirim!', type: SnackbarType.success);

    setState(() => _status = FormzSubmissionStatus.initial);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final isLoading = _status == FormzSubmissionStatus.inProgress;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contoh Formulir', style: tt.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Validasi menggunakan formz · Mask menggunakan mask_text_input_formatter · '
              'Currency menggunakan currency_text_input_formatter',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 28),

            // ── Nama ──────────────────────────────────────────────────────────
            AppTextField(
              label: 'Nama Lengkap',
              hint: 'John Doe',
              helperText: 'Sesuai KTP',
              errorText: _nameError(),
              prefixIcon: const Icon(Icons.person_outline),
              textInputAction: TextInputAction.next,
              onChanged: (v) => setState(() => _name = _NameInput.dirty(v)),
              validator: (_) => _nameError(),
            ),
            const SizedBox(height: 20),

            // ── Email ─────────────────────────────────────────────────────────
            AppTextField(
              label: 'Email',
              hint: 'nama@contoh.com',
              errorText: _emailError(),
              prefixIcon: const Icon(Icons.mail_outline),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (v) => setState(() => _email = _EmailInput.dirty(v)),
              validator: (_) => _emailError(),
            ),
            const SizedBox(height: 20),

            // ── No HP (masked) ────────────────────────────────────────────────
            AppTextField(
              label: 'Nomor HP',
              hint: '+62 812-3456-7890',
              helperText: 'Format: +62 8xx-xxxx-xxxx',
              errorText: _phoneError(),
              prefixIcon: const Icon(Icons.phone_outlined),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [_phoneMask],
              onChanged: (v) => setState(() => _phone = _PhoneInput.dirty(v)),
              validator: (_) => _phoneError(),
            ),
            const SizedBox(height: 20),

            // ── Currency ──────────────────────────────────────────────────────
            AppTextField(
              label: 'Nominal Transfer',
              helperText: 'Minimal Rp 10.000',
              errorText: _amountError(),
              prefixIcon: const Icon(Icons.payments_outlined),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [_currencyFormatter],
              onChanged: (v) => setState(() => _amount = _AmountInput.dirty(v)),
              validator: (_) => _amountError(),
            ),
            const SizedBox(height: 20),

            // ── Password ──────────────────────────────────────────────────────
            AppTextField(
              label: 'Password',
              hint: 'Minimal 8 karakter',
              errorText: _passwordError(),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onChanged: (v) => setState(() => _password = _PasswordInput.dirty(v)),
              validator: (_) => _passwordError(),
            ),
            const SizedBox(height: 32),

            // ── Submit ────────────────────────────────────────────────────────
            PrimaryButton(
              label: 'Kirim',
              expand: true,
              isLoading: isLoading,
              onPressed: isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
