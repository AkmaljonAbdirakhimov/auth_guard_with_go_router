import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String phoneNumber;
  final bool isAuthenticated;

  const User({
    required this.phoneNumber,
    required this.isAuthenticated,
  });

  @override
  List<Object?> get props => [phoneNumber, isAuthenticated];
}
