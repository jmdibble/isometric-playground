import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
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
        child: MainGamePage(),
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
  int numberOfRows = 3;

  @override
  Widget build(BuildContext context) {
    IsometricTileMapExample isoExample = IsometricTileMapExample(numberOfRows);

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          GameWidget(
            game: isoExample,
            loadingBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                    backgroundColor: Colors.redAccent,
                    onPressed: () {
                      setState(() {
                        if (numberOfRows > 1) numberOfRows--;
                      });
                    },
                    child: const Icon(Icons.remove),
                  ),
                  FloatingActionButton(
                    backgroundColor: Colors.greenAccent,
                    onPressed: () {
                      setState(() {
                        if (numberOfRows < 10) numberOfRows++;
                      });
                    },
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IsometricTileMapExample extends FlameGame {
  IsometricTileMapExample(this.numberOfRows);

  final int numberOfRows;

  late IsometricTileMapComponent base;

  @override
  Future<void> onLoad() async {
    // Creates a tileset, the block ids are automatically assigned sequentially
    // starting at 0, from left to right and then top to bottom.
    final tilesetImage = await images.load('grass.png');
    final tileset = SpriteSheet(
      image: tilesetImage,
      srcSize: Vector2(64, 64),
    );

    final treeImage = await images.load('tree_64.png');
    final tree = Sprite(treeImage);

    ///
    /// [0, 0, 0]
    /// [0, 0, 0]
    /// [0, 0, 0]
    ///
    final matrix = [
      ...List.generate(
        numberOfRows,
        (i) => List.generate(
          numberOfRows,
          (j) => 0,
        ),
      ),
    ];

    final middle = size / 2;

    addAll([
      base = IsometricTileMapComponent(
        tileset,
        matrix,
        position: middle,
        anchor: Anchor.center,
      ),
      DraggableTree(
        numberOfRows.isEven ? middle : Vector2(middle.x, middle.y - 16),
        tree,
        numberOfRows,
        snapToGrid: (Vector2 position) {
          print('position: $position');
          final block = base.getBlock(position);
          print('block: $block');
          if ((block.x + 1).abs() <= numberOfRows && (block.y + 1).abs() <= numberOfRows) {
            final vector = base.getBlockCenterPosition(block);
            print('vector: $vector');
            return Vector2(middle.x + vector.x, middle.y + vector.y - 16);
          } else {
            return numberOfRows.isEven ? middle : Vector2(middle.x, middle.y - 16);
          }
        },
      ),
      // DraggableTree(
      //   numberOfRows.isEven ? middle : Vector2(middle.x, middle.y - 16),
      //   tree,
      //   numberOfRows,
      //   snapToGrid: (Vector2 position) {
      //     print('position: $position');
      //     final block = base.getBlock(position);
      //     print('block: $block');
      //     final vector = base.getBlockCenterPosition(block);
      //     print('vector: $vector');
      //     return vector;
      //   },
      //   snapToCenterTile: () {
      //     return numberOfRows.isEven ? middle : Vector2(middle.x, middle.y - 16);
      //   },
      // ),
    ]);
  }
}

class DraggableTree extends SpriteComponent with DragCallbacks {
  DraggableTree(
    Vector2 position,
    Sprite sprite,
    this.numberOfRows, {
    required this.snapToGrid,
  }) : super(
          sprite: sprite,
          position: position,
          anchor: Anchor.bottomCenter,
        );

  final int numberOfRows;
  final Function(Vector2) snapToGrid;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    priority = 10;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    print('onDragEnd');
    super.onDragEnd(event);
    priority = 0;

    final nearestTile = snapToGrid(position);

    position = nearestTile;
  }
}
