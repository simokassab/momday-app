import 'dart:async';

import 'package:momday_app/bloc_provider.dart';

class MyListFilterBloc extends BlocBase {

  String selectedStatusId;

  StreamController<String> _listController = StreamController<String>();
  StreamSink<String> get _in => _listController.sink;
  Stream<String> get stream => _listController.stream;

  MyListFilterBloc({String selectedStatusId}) {
    this.selectedStatusId = selectedStatusId;
  }

  clearFilters() {
    this.selectedStatusId = null;
  }

  applyFilters(String statusId) {
    this.selectedStatusId = statusId;
    this._in.add(this.selectedStatusId);
  }

  @override
  dispose() {
    _listController.close();
    _in.close();
  }
}