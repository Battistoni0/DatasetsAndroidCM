import 'package:flutter/material.dart';
import 'pages/choose_photo_page.dart';
import 'pages/subfolders_page.dart';
import 'pages/view_photo_page.dart';
import 'pages/images_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChoosePhotoPage(),
      routes: {
        ChoosePhotoPage.routeName: (context) => const ChoosePhotoPage(),
        ViewPhotoPage.routeName: (context) =>
            ViewPhotoPage(imageFile: null), // Default argument for null
      },
      onGenerateRoute: (settings) {
        if (settings.name == SubfoldersPage.routeName) {
          final folderName = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) {
              return SubfoldersPage(folderName: folderName);
            },
          );
        }
        if (settings.name == ImagesPage.routeName) {
          final args = settings.arguments as Map<String, String>;
          final folderName = args['folderName']!;
          final subfolderName = args['subfolderName']!;
          return MaterialPageRoute(
            builder: (context) {
              return ImagesPage(
                  folderName: folderName, subfolderName: subfolderName);
            },
          );
        }
        return null;
      },
    );
  }
}
