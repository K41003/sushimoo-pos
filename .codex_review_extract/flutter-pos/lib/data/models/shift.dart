import 'num_util.dart';
import 'user.dart';

class Shift {
  final int idShift;
  final int idUser;
  final String? openTime;
  final String? closeTime;
  final double pettyCash;
  final String status;
  final User? user;

  const Shift({
    required this.idShift,
    required this.idUser,
    this.openTime,
    this.closeTime,
    required this.pettyCash,
    required this.status,
    this.user,
  });

  factory Shift.fromJson(Map<String, dynamic> json) => Shift(
        idShift: json['id_shift'] as int,
        idUser: json['id_user'] as int,
        openTime: json['open_time'] as String?,
        closeTime: json['close_time'] as String?,
        pettyCash: parseDouble(json['petty_cash']),
        status: json['status'] as String,
        user: json['user'] != null
            ? User.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );
}
