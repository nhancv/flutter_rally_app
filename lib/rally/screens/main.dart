import 'package:rally/rally/pages/accounts_page.dart';
import 'package:rally/rally/pages/bills_page.dart';
import 'package:rally/rally/pages/overview_page.dart';
import 'package:rally/rally/pages/settings_page.dart';
import 'package:rally/rally/pages/stats_page.dart';
import 'package:rally/rally/ui/widgets.dart';
import 'package:flutter/material.dart';


typedef MainTabJumper = void Function(MainTab tab);


class MainScreen extends StatefulWidget {

	static Route<dynamic> route() {
		return MaterialPageRoute<dynamic>(
			builder: (BuildContext context) {
				return MainScreen();
			},
		);
	}

	@override
	_MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {

	TabController _tabController;

	@override
	void initState() {
		super.initState();
		_tabController = TabController(
			length: 5,
			vsync: this,
		);
	}

	@override
	void dispose() {
		_tabController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return BackgroundWidget(
			child: SafeArea(
				child: Column(
					children: <Widget>[
						Row(
							children: MainTab.values.map<Widget>((MainTab tab) =>
								_Tab(
									controller: _tabController,
									tab: tab,
								),
							).toList(growable: false),
						),
						Expanded(
							child: TabBarView(
								controller: _tabController,
								children: <Widget>[
									OverviewPage(
										jumpToMainTab: _jumpToTab,
									),
									const AccountsPage(),
									const BillsPage(),
									const StatsPage(),
									const SettingsPage(),
								],
							),
						),
					],
				),
			),
		);
	}

	void _jumpToTab(MainTab tab) {
		_tabController.animateTo(tab.index);
	}
}

class _Tab extends StatefulWidget {

	const _Tab({
		Key key,
		@required this.controller,
		this.tab,
	}) : super(key: key);

	final TabController controller;
	final MainTab tab;

	@override
	_TabState createState() => _TabState();
}

class _TabState extends State<_Tab> {

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			behavior: HitTestBehavior.opaque,
			onTap: _onTap,
			child: Container(
				height: 48.0,
				child: Row(
					mainAxisSize: MainAxisSize.min,
					children: <Widget>[
						AspectRatio(
							aspectRatio: 1.0,
							child: Center(
								child: Icon(widget.tab.icon),
							),
						),
						//SizedBox(height: 8.0),
						AnimatedBuilder(
							animation: widget.controller.animation,
							builder: (BuildContext context, Widget child) {
								final int pageIndex = widget.tab.index;
								final double pageOffset = widget.controller.animation.value;

								double tabVisibility;
								if (pageOffset >= pageIndex && pageOffset < (pageIndex + 1.0)) {
									tabVisibility = 1.0 - (pageOffset % 1.0);
								} else if ((pageOffset + 1.0) >= pageIndex && (pageOffset + 1.0) < (pageIndex + 1.0)) {
									tabVisibility = pageOffset % 1.0;
								} else {
									tabVisibility = 0.0;
								}

								return Opacity(
									opacity: tabVisibility,
									child: ClipRect(
										child: Align(
											alignment: Alignment.centerLeft,
											heightFactor: 1.0,
											widthFactor: tabVisibility,
											child: child,
										)
									),
								);
							},
							child: Text(widget.tab.label),
						),
					],
				),
			),
		);
	}

	void _onTap() {
		widget.controller.animateTo(widget.tab.index,
			duration: const Duration(milliseconds: 450), curve: Curves.fastOutSlowIn);
	}
}

class MainTab {
	const MainTab(this.icon, this.label);

	static const MainTab Overview = MainTab(Icons.pie_chart, 'OVERVIEW');
	static const MainTab Accounts = MainTab(Icons.attach_money, 'ACCOUNTS');
	static const MainTab Bills = MainTab(Icons.money_off, 'BILLS');
	static const MainTab Stats = MainTab(Icons.equalizer, 'STATS');
	static const MainTab Settings = MainTab(Icons.settings, 'SETTINGS');

	static const List<MainTab> values = <MainTab>[
		Overview, Accounts, Bills, Stats, Settings,
	];

	int get index => values.indexOf(this);


	final IconData icon;
	final String label;
}
