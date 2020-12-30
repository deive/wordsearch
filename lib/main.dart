import 'package:flutter/widgets.dart';
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';

import 'app/App.dart';
import 'app/AppState.dart';
import 'app/game/GameState.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final persistor = Persistor<AppState>(
    storage: FlutterStorage(location: FlutterSaveLocation.sharedPreferences),
    serializer: JsonSerializer<AppState>(AppState.fromJson),
    throttleDuration: Duration(seconds: 2),
  );

  final initialState = await persistor.load();

  final Store<AppState> store = Store<AppState>(
    appReducer, /* Function defined in the reducers file */
    initialState: initialState ?? AppState.initial(),
    middleware: [persistor.createMiddleware(), loadGameMiddleware],
  );

  runApp(App(store));
}