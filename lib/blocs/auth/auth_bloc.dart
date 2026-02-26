import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(const AuthInitial()) {
    // Listen to auth state changes
    _authStateSubscription = _authService.authStateChanges.listen((user) {
      add(const AuthCheckRequested());
    });

    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<CheckVerificationStatusRequested>(_onCheckVerificationStatusRequested);
    on<ResendVerificationEmailRequested>(_onResendVerificationEmailRequested);
  }

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) {
    final user = _authService.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Creating account...'));

    try {
      final user = await _authService.signUp(
        email: event.email,
        password: event.password,
        name: event.name,
      );

      if (user != null) {
        emit(AuthSuccess(
          'Account created! Verification email sent to ${user.email}\n'
          'Please check your inbox AND spam folder.\n'
          'Click the link to verify your email.',
        ));
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Failed to create account'));
      }
    } catch (e) {
      emit(AuthError('Sign up failed: $e'));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Signing in...'));

    try {
      final user = await _authService.signIn(
        email: event.email,
        password: event.password,
      );

      if (user != null) {
        final isVerified = user.emailVerified;
        emit(AuthSuccess(
          isVerified
              ? 'Signed in successfully!\nUID: ${user.uid}'
              : 'Signed in, but email not verified.\nPlease check your inbox.',
        ));
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Failed to sign in'));
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Sign in failed: $e'));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Signing out...'));

    try {
      await _authService.signOut();
      emit(const AuthSuccess('Signed out successfully!'));
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Sign out failed: $e'));
    }
  }

  Future<void> _onCheckVerificationStatusRequested(
    CheckVerificationStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      emit(const AuthError('No user signed in'));
      return;
    }

    emit(const AuthLoading(message: 'Checking verification status...'));

    try {
      final isVerified = await _authService.isEmailVerified();
      emit(AuthSuccess(
        isVerified
            ? '✅ Email is verified! Firestore updated.'
            : '⚠️ Email not yet verified. Please check your inbox.',
      ));
      // Reload user to get updated emailVerified status
      await currentUser.reload();
      final updatedUser = _authService.currentUser;
      if (updatedUser != null) {
        emit(AuthAuthenticated(updatedUser));
      }
    } catch (e) {
      emit(AuthError('Failed to check verification status: $e'));
      emit(AuthAuthenticated(currentUser));
    }
  }

  Future<void> _onResendVerificationEmailRequested(
    ResendVerificationEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      emit(const AuthError('No user signed in'));
      return;
    }

    emit(const AuthLoading(message: 'Sending verification email...'));

    try {
      await _authService.sendEmailVerification();
      emit(const AuthSuccess(
        'Verification email sent! Check your inbox and spam folder.',
      ));
      emit(AuthAuthenticated(currentUser));
    } catch (e) {
      emit(AuthError('Failed to send verification email: $e'));
      emit(AuthAuthenticated(currentUser));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
