import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../services/auth_service.dart';
import 'account.dart';

final getIt = GetIt.I;

class MainPageDrawer extends StatefulWidget {

  const MainPageDrawer(
      {Key? key})
      : super(key: key);

  @override
  State<MainPageDrawer> createState() => _MainPageDrawerState();
}

class _MainPageDrawerState extends State<MainPageDrawer> {
  final authService = getIt<AuthService>();
  final TextStyle headerTextStyle = TextStyle(
    color: Colors.grey[300],
    fontWeight: FontWeight.w500,
  );

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.grey[900]),
      child: Drawer(
        child: StreamBuilder(
          stream: authService.signedInStream,
          builder:(context, signedIn)=>ListView(
            primary: true,
            padding: EdgeInsets.zero,
            children: [
              Container(
                color: Colors.grey[850],
                height: 80,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(top: 25, left: 25),
                    child: const Text(
                      "Money Tracker",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
              ),
              const AccountWidget(),
              Divider(
                color: Colors.grey[600],
                height: 5,
                thickness: 0.2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
