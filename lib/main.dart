import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:money_tracker/services/auth_service.dart';
import 'package:money_tracker/services/config_service.dart';
import 'package:money_tracker/services/firebase_service.dart';
import 'package:money_tracker/util/components.dart';

import 'drawer/drawer.dart';
import 'firebase_options.dart';
import '../theme.dart' as globalTheme;
final getIt = GetIt.I;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await ConfigService.ensureInitialized();

  final authService = AuthService();
  getIt.registerSingleton(authService);

  final firebaseService = FirebaseService();
  getIt.registerSingleton(firebaseService);

  await authService.ensureInitialized();
  await firebaseService.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var primary = Colors.indigo;
    var accent = Colors.indigoAccent;

    var theme = ThemeData(
      dividerTheme: const DividerThemeData(thickness: 0.3, space: 1),
      iconTheme: IconThemeData(
        color: Colors.grey[350],
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) =>
        states.contains(MaterialState.selected) ? accent : null),
        trackColor: MaterialStateProperty.resolveWith((states) =>
        states.contains(MaterialState.selected) ? primary[500] : null),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary[700],
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(
              accent
          ),
          textStyle: MaterialStateProperty.all(
            TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.grey.shade900,
        contentTextStyle: TextStyle(color: Colors.grey[200]),
        actionTextColor: accent,
      ),
      checkboxTheme:
      CheckboxThemeData(fillColor: MaterialStateProperty.all(accent)),
      primarySwatch: primary,
      brightness: Brightness.dark,
    );
    theme = theme.copyWith(
      textTheme: theme.textTheme.apply(
        bodyColor: Colors.grey[200],

        // displayColor: Colors.black
      ),
      colorScheme: theme.colorScheme.copyWith(secondary: primary[700]),
    );
    globalTheme.theme = theme;

    return MaterialApp(
      title: 'Money Tracker',
      theme: theme,
      initialRoute: "/",
      // routes: {
      //   "/": (context) => MainPage(initialLink: initialLink),
      // },
      // home: MainPage(
      //   initialLink: initialLink,
      // ),
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context)=>const MainPage(),
        );

        // return MainPage(initialLink: initialLink);
        // return NavigatorRoute.route(settings.name);
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final authService = getIt<AuthService>();
  final firebaseService = getIt<FirebaseService>();

  @override
  void initState(){
    super.initState();


  }

  void _signInTaped() async {
    _key.currentState!.openDrawer();
    await Future.delayed(const Duration(milliseconds: 500));
    await authService.signInWithGoogle();
  }

  /// Builds the body or a sign in prompt
  Widget _buildBody(){

    return StreamBuilder(
      stream: authService.signedInStream,
      builder: (context, snapshot){
        bool signedIn = snapshot.data ?? false;

        if(!signedIn){
          return Center(
            child: InfoActionWidget(
              onTap: _signInTaped,
              buttonText: "SIGN IN",
              label: "You need to be signed in to user this app.",
            ),
          );
        }else{
          return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(

        title: const Text("Money Tracker"),
      ),
      body: _buildBody(),
      drawer: const MainPageDrawer(),
    );
  }
}
