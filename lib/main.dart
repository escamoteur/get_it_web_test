import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

Future<void> main() async {
  await initApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder(
          future: Env().ready,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.done) {
              return Container(
                child: Text('We made it!!!'),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

Future<void> initApp({bool testMode = false}) async {
  WidgetsFlutterBinding.ensureInitialized();
  Env().setup();
}

class Env {
  Env._({
    required this.sl,
  });

  factory Env({
    GetIt? sl,
  }) {
    return _instance ??= Env._(
      sl: sl ?? GetIt.instance,
    );
  }

  Future<void> get ready => _readyCompleter.future;

  /// If you make sl nullable this works, if not or you declare it
  /// late it crashes in release only in FlutterWeb
  GetIt sl;

  Future<void> setup() async {
    _setupDependencies();
    await sl.allReady();

    _readyCompleter.complete();
  }

  static Env? _instance;

  final _readyCompleter = Completer<void>();

  void _setupDependencies() {
    final dependency = Dependency();

    sl
      ..registerSingleton<Dependency>(dependency)
      ..registerSingletonAsync<AppModel>(_setupAppModel);
  }

  Future<AppModel> _setupAppModel() async {
    final dependency = sl<Dependency>();

    print('before fetchValue');
    final value = await dependency.fetchValue();
    print('after fetchValue');
    return AppModel.withDependency(value);
  }
}

class AppModel {
  AppModel._(this.dependency);

  final String? dependency;

  factory AppModel.withDependency(String? dependency) {
    return AppModel._(dependency);
  }
}

class Dependency {
  Future<String> fetchValue() async => "value";
}
