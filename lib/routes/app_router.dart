import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injection_container.dart';
import '../core/guards/auth_guard.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/otp_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  static final authBloc = sl<AuthBloc>();

  // Public routes
  static final List<RouteBase> _publicRoutes = [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
      redirect: _handleInitialRedirect,
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
      redirect: _handleAuthRedirect,
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final phoneNumber = state.extra as String;
        return OtpPage(phoneNumber: phoneNumber);
      },
    ),
  ];

  // Protected routes
  static final List<RouteBase> _protectedRoutes = [
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ];

  static String? _handleInitialRedirect(
      BuildContext context, GoRouterState state) {
    final authState = authBloc.state;

    // Keep showing splash while loading
    if (authState is AuthLoading) {
      return null;
    }

    // Redirect based on auth status
    if (authState is AuthSuccess) {
      return '/home';
    }

    if (authState is AuthInitial || authState is AuthFailure) {
      return '/login';
    }

    return null;
  }

  static String? _handleAuthRedirect(
      BuildContext context, GoRouterState state) {
    final authState = authBloc.state;

    if (authState is AuthSuccess) {
      return '/home';
    }

    return null;
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // Add this for debugging
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    routes: [
      ..._publicRoutes,
      ShellRoute(
        builder: (context, state, child) {
          return AuthGuard(child: child);
        },
        routes: _protectedRoutes,
      ),
    ],
  );
}

// Helper class to convert Stream to Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.listen(
      (AuthState state) => notifyListeners(),
    );
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
