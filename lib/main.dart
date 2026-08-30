import 'package:choira_music_player/Providers/player_Provider.dart';
import 'package:choira_music_player/Screens/home_screen.dart';
import 'package:choira_music_player/Providers/track_provider.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FastCachedImageConfig.init();
  await dotenv.load(fileName: 'secret.env');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrackProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Choira Music Player',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}
