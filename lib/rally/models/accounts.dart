import 'dart:ui';

import 'package:meta/meta.dart';

@immutable
class AccountModel {
  const AccountModel(this.name, this.number, this.balance, this.color);

  final String name;
  final String number;
  final double balance;
  final Color color;

  String get formattedBalance => '\$${balance.toStringAsFixed(2)}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          number == other.number &&
          balance == other.balance;

  @override
  int get hashCode => name.hashCode ^ number.hashCode ^ balance.hashCode;
}

@immutable
class AccountSet {
  const AccountSet(List<AccountModel> accounts) : _accounts = accounts;

  final List<AccountModel> _accounts;

  AccountModel operator [](int index) => _accounts[index];

  int get length => _accounts.length;

  double get total => _accounts.fold(
      0.0, (double prev, AccountModel account) => prev + account.balance);

  String get formattedTotal => '\$${total.toStringAsFixed(2)}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountSet &&
          runtimeType == other.runtimeType &&
          _accounts == other._accounts;

  @override
  int get hashCode => _accounts.hashCode;
}
