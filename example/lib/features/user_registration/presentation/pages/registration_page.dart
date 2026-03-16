import 'package:design_system/design_system.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_paths.dart';
import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_inputs.dart';
import '../bloc/registration_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const _departments = [
  'Engineering',
  'Product',
  'Design',
  'Marketing',
  'Sales',
  'Finance',
  'HR',
  'Operations',
  'Legal',
  'Customer Support',
];

// ─────────────────────────────────────────────────────────────────────────────
// Page entry point
// ─────────────────────────────────────────────────────────────────────────────

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi Pengguna')),
      body: BlocProvider(create: (_) => sl<RegistrationBloc>(), child: const _RegistrationView()),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// View — listens for state changes (success / error banners, navigation)
// ─────────────────────────────────────────────────────────────────────────────

class _RegistrationView extends StatelessWidget {
  const _RegistrationView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegistrationBloc, RegistrationState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == RegistrationStatus.success && state.createdUser != null) {
          _showSuccessDialog(context, state);
        } else if (state.status == RegistrationStatus.failure && state.errorMessage != null) {
          AppSnackbar.show(context, message: state.errorMessage!, type: SnackbarType.error);
        }
      },
      child: const _RegistrationForm(),
    );
  }

  void _showSuccessDialog(BuildContext context, RegistrationState state) {
    final user = state.createdUser!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cs.primaryContainer, shape: BoxShape.circle),
              child: Icon(Icons.check_rounded, size: 40, color: cs.onPrimaryContainer),
            ),
            const SizedBox(height: 16),
            Text(
              'Registrasi Berhasil!',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Data pengguna berhasil disimpan.',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _InfoRow(label: 'ID', value: '#${user.id}'),
            _InfoRow(label: 'Nama', value: user.fullName),
            _InfoRow(label: 'Email', value: user.email),
            _InfoRow(label: 'Gender', value: user.gender),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<RegistrationBloc>().add(const RegistrationReset());
                    },
                    child: const Text('Isi Lagi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go(RoutePaths.users);
                    },
                    child: const Text('Lihat Daftar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          Text(value, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form Widget
// ─────────────────────────────────────────────────────────────────────────────

class _RegistrationForm extends StatefulWidget {
  const _RegistrationForm();

  @override
  State<_RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<_RegistrationForm> {
  // Controllers that need explicit lifecycle management
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '+62 ###-####-####',
    filter: {'#': RegExp(r'\d')},
  );

  // Cache untuk departments — API hanya di-hit sekali, selanjutnya filter lokal
  List<String>? _cachedDepartments;

  Future<List<String>> _fetchDepartments(String query) async {
    if (_cachedDepartments == null || _cachedDepartments!.isEmpty) {
      try {
        // Simulasi network request (ganti dengan repository call di produksi)
        await Future.delayed(const Duration(milliseconds: 600));
        final result = _departments;
        // Hanya cache kalau ada data — kosong atau error → retry saat buka lagi
        if (result.isNotEmpty) _cachedDepartments = result;
      } catch (_) {
        // Biarkan null → dropdown akan retry saat dibuka lagi
      }
    }
    final data = _cachedDepartments ?? [];
    if (data.isEmpty || query.isEmpty) return data;
    final q = query.toLowerCase();
    return data.where((d) => d.toLowerCase().contains(q)).toList();
  }

  final _salaryFormatter = CurrencyTextInputFormatter.currency(
    locale: 'id',
    decimalDigits: 0,
    symbol: 'Rp',
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        final isLoading = state.status == RegistrationStatus.loading;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.person_add_outlined, color: cs.onPrimaryContainer, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registrasi Pengguna',
                        style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'API: dummyjson.com  ·  BLoC + Formz',
                        style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Section: Data Pribadi ────────────────────────────────────────
              _SectionHeader(icon: Icons.badge_outlined, label: 'Data Pribadi'),
              const SizedBox(height: 16),

              // Full Name
              AppTextField(
                label: 'Nama Lengkap *',
                hint: 'Budi Santoso',
                helperText: 'Minimal 3 karakter',
                errorText: _fullNameError(state.fullName.displayError),
                prefixIcon: const Icon(Icons.person_outline),
                textInputAction: TextInputAction.next,
                onChanged: (v) =>
                    context.read<RegistrationBloc>().add(RegistrationFullNameChanged(v)),
                validator: (_) => _fullNameError(state.fullName.displayError),
              ),
              const SizedBox(height: 16),

              // Email
              AppTextField(
                label: 'Email *',
                hint: 'budi@contoh.com',
                errorText: _emailError(state.email.displayError),
                prefixIcon: const Icon(Icons.mail_outline),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: (v) => context.read<RegistrationBloc>().add(RegistrationEmailChanged(v)),
                validator: (_) => _emailError(state.email.displayError),
              ),
              const SizedBox(height: 16),

              // Phone
              AppTextField(
                label: 'Nomor HP *',
                hint: '+62 812-3456-7890',
                helperText: 'Format: +62 8xx-xxxx-xxxx',
                errorText: _phoneError(state.phone.displayError),
                prefixIcon: const Icon(Icons.phone_outlined),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [_phoneFormatter],
                onChanged: (v) => context.read<RegistrationBloc>().add(RegistrationPhoneChanged(v)),
                validator: (_) => _phoneError(state.phone.displayError),
              ),
              const SizedBox(height: 16),

              // Date of Birth
              AppDatePicker(
                label: 'Tanggal Lahir *',
                hint: 'Pilih tanggal lahir',
                value: state.dateOfBirth,
                firstDate: DateTime(1940),
                lastDate: DateTime.now().subtract(const Duration(days: 365 * 17)),
                pickerHelpText: 'Pilih Tanggal Lahir',
                errorText: state.dateOfBirth == null && !state.fullName.isPure
                    ? 'Tanggal lahir wajib diisi'
                    : null,
                onChanged: (date) =>
                    context.read<RegistrationBloc>().add(RegistrationDateOfBirthChanged(date)),
              ),
              const SizedBox(height: 16),

              // Gender
              _SectionLabel(label: 'Jenis Kelamin *'),
              const SizedBox(height: 8),
              _GenderSelector(
                selected: state.gender,
                onChanged: (v) =>
                    context.read<RegistrationBloc>().add(RegistrationGenderChanged(v)),
              ),
              const SizedBox(height: 24),

              // ── Section: Pekerjaan ───────────────────────────────────────────
              _SectionHeader(icon: Icons.work_outline, label: 'Informasi Pekerjaan'),
              const SizedBox(height: 16),

              // Job Title
              AppTextField(
                label: 'Jabatan / Posisi *',
                hint: 'Software Engineer',
                errorText: _jobTitleError(state.jobTitle.displayError),
                prefixIcon: const Icon(Icons.work_outline),
                textInputAction: TextInputAction.next,
                onChanged: (v) =>
                    context.read<RegistrationBloc>().add(RegistrationJobTitleChanged(v)),
                validator: (_) => _jobTitleError(state.jobTitle.displayError),
              ),
              const SizedBox(height: 16),

              // Department Dropdown
              AppSearchableDropdown<String>(
                label: 'Departemen *',
                hint: 'Pilih departemen',
                prefixIcon: const Icon(Icons.business_outlined),
                asyncItems: _fetchDepartments,
                selectedItem: state.department.value.isEmpty ? null : state.department.value,
                errorText: _departmentError(state.department.displayError),
                onChanged: (v) {
                  if (v == null) return;
                  context.read<RegistrationBloc>().add(RegistrationDepartmentChanged(v));
                },
              ),
              const SizedBox(height: 16),

              // Salary
              AppTextField(
                label: 'Gaji Per Bulan',
                helperText: 'Opsional',
                prefixIcon: const Icon(Icons.payments_outlined),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [_salaryFormatter],
                onChanged: (v) =>
                    context.read<RegistrationBloc>().add(RegistrationSalaryChanged(v)),
              ),
              const SizedBox(height: 24),

              // ── Section: Tentang Saya ────────────────────────────────────────
              _SectionHeader(icon: Icons.info_outline, label: 'Tentang Saya'),
              const SizedBox(height: 16),

              // Bio
              _BioTextField(
                error: _bioError(state.bio.displayError),
                onChanged: (v) => context.read<RegistrationBloc>().add(RegistrationBioChanged(v)),
              ),
              const SizedBox(height: 24),

              // ── Section: Keamanan Akun ───────────────────────────────────────
              _SectionHeader(icon: Icons.lock_outline, label: 'Keamanan Akun'),
              const SizedBox(height: 16),

              // Password
              AppTextField(
                label: 'Password *',
                hint: 'Min 8 karakter, 1 huruf besar, 1 angka',
                errorText: _passwordError(state.password.displayError),
                obscureText: true,
                textInputAction: TextInputAction.next,
                onChanged: (v) =>
                    context.read<RegistrationBloc>().add(RegistrationPasswordChanged(v)),
                validator: (_) => _passwordError(state.password.displayError),
              ),
              const SizedBox(height: 8),

              // Password strength indicator
              if (state.password.value.isNotEmpty)
                _PasswordStrengthBar(strength: state.passwordStrength),
              const SizedBox(height: 16),

              // Confirm Password
              AppTextField(
                label: 'Konfirmasi Password *',
                hint: 'Ulangi password',
                errorText: _confirmPasswordError(state.confirmPassword.displayError),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onChanged: (v) =>
                    context.read<RegistrationBloc>().add(RegistrationConfirmPasswordChanged(v)),
                validator: (_) => _confirmPasswordError(state.confirmPassword.displayError),
              ),
              const SizedBox(height: 24),

              // ── Persetujuan ──────────────────────────────────────────────────
              _AgreementSection(
                termsAccepted: state.termsAccepted,
                newsletterSubscribed: state.newsletterSubscribed,
                showTermsError: !state.termsAccepted && state.status == RegistrationStatus.failure,
                onTermsChanged: (v) =>
                    context.read<RegistrationBloc>().add(RegistrationTermsChanged(value: v)),
                onNewsletterChanged: (v) =>
                    context.read<RegistrationBloc>().add(RegistrationNewsletterChanged(value: v)),
              ),
              const SizedBox(height: 32),

              // ── Submit ───────────────────────────────────────────────────────
              PrimaryButton(
                label: 'Daftar Sekarang',
                expand: true,
                isLoading: isLoading,
                onPressed: isLoading
                    ? null
                    : () => context.read<RegistrationBloc>().add(const RegistrationSubmitted()),
              ),
              const SizedBox(height: 16),

              // View users shortcut
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.group_outlined),
                label: const Text('Lihat Daftar Pengguna dari API'),
                onPressed: () => context.go(RoutePaths.users),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Error helpers ────────────────────────────────────────────────────────────

  String? _fullNameError(FullNameError? e) => switch (e) {
    FullNameError.empty => 'Nama tidak boleh kosong',
    FullNameError.tooShort => 'Nama minimal 3 karakter',
    null => null,
  };

  String? _emailError(EmailError? e) => switch (e) {
    EmailError.empty => 'Email tidak boleh kosong',
    EmailError.invalid => 'Format email tidak valid',
    null => null,
  };

  String? _phoneError(PhoneError? e) => switch (e) {
    PhoneError.empty => 'Nomor HP tidak boleh kosong',
    PhoneError.invalid => 'Nomor HP minimal 10 digit',
    null => null,
  };

  String? _jobTitleError(JobTitleError? e) => switch (e) {
    JobTitleError.empty => 'Jabatan tidak boleh kosong',
    null => null,
  };

  String? _departmentError(DepartmentError? e) => switch (e) {
    DepartmentError.empty => 'Pilih departemen',
    null => null,
  };

  String? _bioError(BioError? e) => switch (e) {
    BioError.tooLong => 'Bio maksimal ${BioInput.maxLength} karakter',
    null => null,
  };

  String? _passwordError(PasswordError? e) => switch (e) {
    PasswordError.empty => 'Password tidak boleh kosong',
    PasswordError.tooShort => 'Password minimal 8 karakter',
    PasswordError.noUpperCase => 'Tambahkan minimal 1 huruf kapital',
    PasswordError.noDigit => 'Tambahkan minimal 1 angka',
    null => null,
  };

  String? _confirmPasswordError(ConfirmPasswordError? e) => switch (e) {
    ConfirmPasswordError.empty => 'Konfirmasi password tidak boleh kosong',
    ConfirmPasswordError.mismatch => 'Password tidak sama',
    null => null,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: cs.outlineVariant)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Text(
      label,
      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
    );
  }
}

// ── Gender Selector ───────────────────────────────────────────────────────────

// ── Gender Selector ───────────────────────────────────────────────────────────

class _GenderSelector extends StatelessWidget {
  const _GenderSelector({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GenderOption(
            label: 'Pria',
            value: 'male',
            icon: Icons.male,
            selected: selected == 'male',
            onTap: () => onChanged('male'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GenderOption(
            label: 'Wanita',
            value: 'female',
            icon: Icons.female,
            selected: selected == 'female',
            onTap: () => onChanged('female'),
          ),
        ),
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.value,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
          border: Border.all(color: selected ? cs.primary : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: selected ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: tt.bodyMedium?.copyWith(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bio Text Field ────────────────────────────────────────────────────────────

class _BioTextField extends StatelessWidget {
  const _BioTextField({required this.error, required this.onChanged});

  final String? error;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'Bio',
      helperText: 'Opsional',
      hint: 'Ceritakan sedikit tentang diri Anda...',
      errorText: error,
      maxLines: 4,
      minLines: 4,
      maxLength: BioInput.maxLength,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      onChanged: onChanged,
    );
  }
}

// ── Password Strength Bar ─────────────────────────────────────────────────────

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.strength});

  final int strength; // 0-4

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (label, color) = switch (strength) {
      1 => ('Sangat Lemah', cs.error),
      2 => ('Lemah', Colors.orange),
      3 => ('Sedang', Colors.amber),
      4 => ('Kuat', Colors.green),
      _ => ('', cs.outline),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: i < strength ? color : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        if (label.isNotEmpty)
          Text('Kekuatan: $label', style: tt.labelSmall?.copyWith(color: color)),
      ],
    );
  }
}

// ── Agreement Section ─────────────────────────────────────────────────────────

class _AgreementSection extends StatelessWidget {
  const _AgreementSection({
    required this.termsAccepted,
    required this.newsletterSubscribed,
    required this.showTermsError,
    required this.onTermsChanged,
    required this.onNewsletterChanged,
  });

  final bool termsAccepted;
  final bool newsletterSubscribed;
  final bool showTermsError;
  final ValueChanged<bool> onTermsChanged;
  final ValueChanged<bool> onNewsletterChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Terms & Conditions
        InkWell(
          onTap: () => onTermsChanged(!termsAccepted),
          borderRadius: BorderRadius.circular(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: termsAccepted,
                onChanged: (v) => onTermsChanged(v ?? false),
                activeColor: cs.primary,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 11),
                  child: RichText(
                    text: TextSpan(
                      style: tt.bodyMedium,
                      children: [
                        const TextSpan(text: 'Saya menyetujui '),
                        TextSpan(
                          text: 'Syarat & Ketentuan',
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: ' serta '),
                        TextSpan(
                          text: 'Kebijakan Privasi',
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: ' yang berlaku *'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showTermsError)
          Padding(
            padding: const EdgeInsets.only(left: 48, bottom: 4),
            child: Text(
              'Anda harus menyetujui syarat dan ketentuan',
              style: tt.bodySmall?.copyWith(color: cs.error),
            ),
          ),

        // Newsletter
        InkWell(
          onTap: () => onNewsletterChanged(!newsletterSubscribed),
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Switch(value: newsletterSubscribed, onChanged: onNewsletterChanged),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Saya ingin menerima informasi & penawaran terbaru',
                  style: tt.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
