import 'package:rally/rally/mock/mock.dart';
import 'package:rally/rally/models/accounts.dart';
import 'package:rally/rally/screens/account.dart';
import 'package:rally/rally/ui/layouts.dart';
import 'package:rally/rally/ui/widgets.dart';
import 'package:flutter/material.dart';


class BillsPage extends StatelessWidget {
	const BillsPage({
		Key key
	}) : super(key: key);


	@override
	Widget build(BuildContext context) {
		return AccountChartLayout(
			accountSet: mockBills, // TODO: replace with backend call.
			builder: (BuildContext context, int index) {
				final AccountModel bill = mockBills[index];
				final String heroTag = 'bills-page-item-$index';
				return AccountListTile(
					account: bill,
					heroTag: heroTag,
					onPressed: (BuildContext context) {
						Navigator.of(context).push<void>(
							AccountScreen.route(context, bill, heroTag),
						);
					},
				);
			},
		);
	}
}
