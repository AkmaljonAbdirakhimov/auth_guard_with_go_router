import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import '../../domain/entities/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthStatus checkAuthStatus;
  final SendOtp sendOtp;
  final VerifyOtp verifyOtp;
  final Logout logout;

  AuthBloc({
    required this.checkAuthStatus,
    required this.sendOtp,
    required this.verifyOtp,
    required this.logout,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<LogoutEvent>(_onLogout);

    // Check initial auth status when bloc is created
    add(CheckAuthStatusEvent());
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    // First check initial status
    final initialStatus = await checkAuthStatus.checkInitial();

    initialStatus.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) async {
        if (user != null && user.isAuthenticated) {
          emit(AuthSuccess());
        } else {
          emit(AuthInitial());
        }
      },
    );

    // Then start watching for changes
    await emit.onEach<User?>(
      checkAuthStatus.watch(),
      onData: (user) {
        if (user != null && user.isAuthenticated) {
          emit(AuthSuccess());
        } else {
          emit(AuthInitial());
        }
      },
    );
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await sendOtp(SendOtpParams(phoneNumber: event.phoneNumber));

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(OtpSent()),
    );
  }

  Future<void> _onVerifyOtp(
      VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await verifyOtp(
      VerifyOtpParams(
        phoneNumber: event.phoneNumber,
        otp: event.otp,
      ),
    );

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess()),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    final result = await logout(NoParams());

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthInitial()),
    );
  }
}
