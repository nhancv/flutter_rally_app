import 'package:rally/rally/mock/mock.dart';
import 'package:rally/rally/models/accounts.dart';
import 'package:rally/rally/screens/account.dart';
import 'package:rally/rally/ui/layouts.dart';
import 'package:rally/rally/ui/widgets.dart';
import 'package:flutter/material.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AccountChartLayout(
      accountSet: mockAccounts, // TODO: replace with backend call.
      builder: (BuildContext context, int index) {
        final AccountModel account = mockAccounts[index];
        final String heroTag = 'accounts-page-item-$index';
        return AccountListTile(
          account: account,
          heroTag: heroTag,
          onPressed: (BuildContext context) {
            Navigator.of(context).push<void>(
              AccountScreen.route(context, account, heroTag),
            );
          },
        );
      },
    );
  }
}
