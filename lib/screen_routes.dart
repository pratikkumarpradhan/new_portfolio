import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/home_screen.dart';
import 'package:portfolio/login/login_screen.dart';
import 'package:portfolio/login/register_screen.dart';

/// Central place for all web URL routes (deep links).
///
/// Examples (localhost):
/// - `/home`
/// - `/projects`
/// - `/about` (alias: `/contact`)
final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: <RouteBase>[
    GoRoute(path: '/', redirect: (_, __) => '/home'),

    // Main website-style pages (render inside HomeScreen's PageView).
    GoRoute(
      path: '/home',
      pageBuilder:
          (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const HomeScreen(initialScreenType: 'home'),
          ),
    ),
    GoRoute(
      path: '/projects',
      pageBuilder:
          (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const HomeScreen(initialScreenType: 'projects'),
          ),
    ),
    GoRoute(
      path: '/skills',
      pageBuilder:
          (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const HomeScreen(initialScreenType: 'skills'),
          ),
    ),
    GoRoute(
      path: '/experience',
      pageBuilder:
          (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const HomeScreen(initialScreenType: 'experience'),
          ),
    ),
    GoRoute(
      path: '/github',
      pageBuilder:
          (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const HomeScreen(initialScreenType: 'github'),
          ),
    ),
    GoRoute(
      path: '/leetcode',
      pageBuilder:
          (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const HomeScreen(initialScreenType: 'leetcode'),
          ),
    ),
    GoRoute(
      path: '/about',
      pageBuilder:
          (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const HomeScreen(initialScreenType: 'about'),
          ),
    ),
    GoRoute(path: '/contact', redirect: (_, __) => '/about'),
    GoRoute(
      path: '/blog',
      pageBuilder:
          (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const HomeScreen(initialScreenType: 'blog'),
          ),
    ),

    // Auth screens (separate pages).
    GoRoute(
      path: '/login',
      pageBuilder:
          (context, state) =>
              MaterialPage<void>(key: state.pageKey, child: const LoginPage()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder:
          (context, state) => MaterialPage<void>(
            key: state.pageKey,
            child: const RegisterPage(),
          ),
    ),
  ],
  errorPageBuilder:
      (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: _NotFoundScreen(error: state.error),
      ),
);

class _NotFoundScreen extends StatelessWidget {
  final Exception? error;
  const _NotFoundScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '404 - Page not found',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'The page you requested does not exist.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error.toString(),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
