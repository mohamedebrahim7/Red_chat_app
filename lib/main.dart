import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_chat/screens/login_screen.dart';
import 'package:red_chat/screens/message_list_screen.dart';
import '../data/message_dao.dart';
import 'data/user_dao.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserDao>(
          lazy: false,
          create: (_) => UserDao(),
        ),
        Provider<MessageDao>(
          lazy: false,
          create: (_) => MessageDao(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Red Chat',
        theme: ThemeData(
          primarySwatch: Colors.red
        ),
        home: Consumer<UserDao>(
          builder: (context, userDao, child) {
            if (userDao.isLoggedIn()) {
              return const MessageListScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}