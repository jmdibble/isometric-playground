import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_isometric/custom_isometric_tile_map_component.dart';
import 'package:flame_isometric/flame_isometric.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isometric_playground/firebase_options.dart';
import 'package:isometric_playground/services/bloc_observer.dart';
import 'package:isometric_playground/theme/theme.dart';
import 'package:isometric_playground/utils/logger.dart';
import 'package:isometric_playground/services/get_it.dart';

void main() {
  bootstrap(() => const App(), DefaultFirebaseOptions.currentPlatform);
}

Future<void> bootstrap(
  FutureOr<Widget> Function() builder,
  FirebaseOptions currentPlatform,
) async {
  FlutterError.onError = (details) {};
  final logger = ZLogger(tag: 'bootstrap');

  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  await Firebase.initializeApp(
    options: currentPlatform,
  );

  await GetItService.setup();

  await runZonedGuarded(
    () async => runApp(
      await builder(),
    ),
    (error, stackTrace) {
      logger.e(error.toString(), error: error, stackTrace: stackTrace);
    },
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isometric Playground',
      theme: theme,
      home: SelectionArea(
        child: MultiBlocProvider(
          providers: [],
          child: MainGamePage(),
        ),
      ),
    );
  }
}

class MainGamePage extends StatefulWidget {
  const MainGamePage({Key? key}) : super(key: key);

  @override
  MainGameState createState() => MainGameState();
}

class MainGameState extends State<MainGamePage> {
  MainGame game = MainGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        GameWidget(game: game),
      ],
    ));
  }
}

class MainGame extends FlameGame with HasGameRef {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    final gameSize = gameRef.size;
    // single
    // final flameIsometric = await FlameIsometric.create(
    //     tileMap: 'tile_map.png', tmx: 'tiles/tile_map.tmx');
    //
    // for (var i = 0; i < flameIsometric.layerLength; i++) {
    //   add(
    //     IsometricTileMapComponent(
    //       flameIsometric.tileset,
    //       flameIsometric.renderMatrixList[i],
    //       destTileSize: flameIsometric.srcTileSize,
    //       position:
    //           Vector2(gameSize.x / 2, flameIsometric.tileHeight.toDouble()),
    //     ),
    //   );
    // }

    final flameIsometric =
        await FlameIsometric.create(tileMap: ['assets/images/Grass.png'], tmx: 'assets/tmx/base_grass.tmx');

    for (var renderLayer in flameIsometric.renderLayerList) {
      add(
        CustomIsometricTileMapComponent(
          renderLayer.spriteSheet,
          renderLayer.matrix,
          destTileSize: flameIsometric.srcTileSize,
          position: Vector2(gameSize.x / 2, flameIsometric.tileHeight.toDouble()),
        ),
      );
    }
  }
}
