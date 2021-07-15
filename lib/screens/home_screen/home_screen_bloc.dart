import 'dart:async';

import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/bloc_provider.dart';
import 'package:momday_app/models/models.dart';

enum HomeActionTypes {FetchData}

class Action {
  HomeActionTypes type;
  dynamic data;

  Action(this.type, this.data);
}

class HomeBloc extends BlocBase {

  HomeModel homeData;

  StreamController<HomeModel> _homeController = StreamController<HomeModel>();
  StreamSink<HomeModel> get _in => _homeController.sink;
  Stream<HomeModel> get dataStream => _homeController.stream;

  StreamController<Action> _actionController = StreamController<Action>.broadcast();
  StreamSink<Action> get _inAction => _actionController.sink;
  Stream<Action> get actionStream => _actionController.stream;

  HomeBloc();

  @override
  dispose() {
    _homeController.close();
    _in.close();
    _actionController.close();
    _inAction.close();
  }

  @override
  init() {
    this._getHome();
  }

  _getHome() async {
    final home = await MomdayBackend().getHome();
    this.homeData = HomeModel.fromDynamic(home);
    this._in.add(this.homeData);
    this._inAction.add(Action(HomeActionTypes.FetchData, this.homeData));
  }
}