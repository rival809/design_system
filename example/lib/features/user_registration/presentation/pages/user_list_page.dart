import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/user_entity.dart';
import '../cubit/user_list_cubit.dart';
import '../cubit/user_list_state.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UserListCubit>()..loadUsers(),
      child: const _UserListView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _UserListView extends StatefulWidget {
  const _UserListView();

  @override
  State<_UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<_UserListView> {
  late final ScrollController _scrollController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      context.read<UserListCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
        actions: [
          BlocBuilder<UserListCubit, UserListState>(
            buildWhen: (p, c) => p.status != c.status,
            builder: (context, state) => IconButton(
              icon: const Icon(Icons.refresh_outlined),
              tooltip: 'Refresh',
              onPressed: state.isLoading
                  ? null
                  : () {
                      _searchController.clear();
                      context.read<UserListCubit>().loadUsers();
                    },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(controller: _searchController),
          Expanded(
            child: BlocConsumer<UserListCubit, UserListState>(
              // Show snackbar only when a loadMore fails (users already visible)
              listenWhen: (p, c) => c.isError && c.users.isNotEmpty && p.status != c.status,
              listener: (context, state) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: const Text('Gagal memuat halaman berikutnya'),
                      action: SnackBarAction(
                        label: 'Coba lagi',
                        onPressed: () => context.read<UserListCubit>().loadMore(),
                      ),
                    ),
                  );
              },
              builder: (context, state) {
                // First-page loading
                if (state.isLoading || state.isInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Full-page error (no data at all)
                if (state.isError && state.users.isEmpty) {
                  return _ErrorView(
                    message: state.errorMessage ?? 'Terjadi kesalahan',
                    onRetry: () => context.read<UserListCubit>().refresh(),
                  );
                }

                // Empty result (after load or search)
                if (state.users.isEmpty) {
                  return _EmptyView(query: state.query);
                }

                final hasExtra = state.isLoadingMore || state.hasReachedEnd;
                final itemCount = state.users.length + (hasExtra ? 1 : 0);

                return RefreshIndicator(
                  onRefresh: () {
                    _searchController.clear();
                    return context.read<UserListCubit>().loadUsers();
                  },
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: itemCount,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index < state.users.length) {
                        return _UserCard(user: state.users[index]);
                      }
                      if (state.isLoadingMore) {
                        return const _LoadingMoreTile();
                      }
                      return _EndOfListTile(count: state.users.length);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: cs.surface,
      child: TextField(
        controller: controller,
        style: tt.bodyMedium,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari nama, email, departemen...',
          hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant, size: 20),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) => value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      controller.clear();
                      context.read<UserListCubit>().search('');
                    },
                  )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: cs.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (q) => context.read<UserListCubit>().search(q),
      ),
    );
  }
}

// ── Lazy-load indicators ──────────────────────────────────────────────────────

class _LoadingMoreTile extends StatelessWidget {
  const _LoadingMoreTile();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _EndOfListTile extends StatelessWidget {
  const _EndOfListTile({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            'Semua $count pengguna ditampilkan',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              query.isEmpty ? Icons.group_off_outlined : Icons.search_off_rounded,
              size: 64,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              query.isEmpty ? 'Belum ada pengguna' : 'Tidak ada hasil',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (query.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Tidak ditemukan pengguna untuk "$query"',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── User card ─────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: cs.primaryContainer,
          backgroundImage: user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
          child: user.avatar.isEmpty
              ? Text(
                  user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                  style: tt.titleMedium?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(user.fullName, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.mail_outline, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    user.email,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (user.department.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.business_outlined, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(user.department, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ],
          ],
        ),
        trailing: _GenderBadge(gender: user.gender),
      ),
    );
  }
}

class _GenderBadge extends StatelessWidget {
  const _GenderBadge({required this.gender});
  final String gender;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMale = gender.toLowerCase() == 'male';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isMale ? cs.primaryContainer : cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isMale ? 'Pria' : 'Wanita',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isMale ? cs.onPrimaryContainer : cs.onTertiaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: cs.error),
            const SizedBox(height: 16),
            Text('Gagal memuat data', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              message,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
