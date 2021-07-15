import 'dart:async';

import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/bloc_provider.dart';
import 'package:momday_app/models/models.dart';

enum ActivityActionTypes {FetchData}

class Action {
  ActivityActionTypes type;
  dynamic data;

  Action(this.type, this.data);
}

class ActivityBloc extends BlocBase {

  String activityId;

  ActivityModel activityData;

  StreamController<ActivityModel> _activityController = StreamController<ActivityModel>();
  StreamSink<ActivityModel> get _in => _activityController.sink;
  Stream<ActivityModel> get dataStream => _activityController.stream;

  StreamController<Action> _actionController = StreamController<Action>.broadcast();
  StreamSink<Action> get _inAction => _actionController.sink;
  Stream<Action> get actionStream => _actionController.stream;

  ActivityBloc({this.activityId});

  @override
  dispose() {
    _activityController.close();
    _in.close();
    _actionController.close();
    _inAction.close();
  }

  @override
  init() {
    this._getActivity(this.activityId);
  }

  _getActivity(activityId) async {

    final post = await MomdayBackend().getActivity(
        activityId: activityId
    );

    if (post != null) {
      this.activityData = ActivityModel.fromDynamic(post);
      this._in.add(this.activityData);
      this._inAction.add(Action(ActivityActionTypes.FetchData, this.activityData));
    }
  }
}