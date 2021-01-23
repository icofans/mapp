String listModelTemplate(
  String projectName,
  String name,
) {
  return '''
  import 'dart:async';
import 'package:demo_app/base/view_model/base_model.dart';

class TemplateModel extends ListModel {
  @override
  Stream loadData() {
    pageNo = 1;
    return Stream.fromFuture(_mockData()).map((event) {
      print(event);
      datas = event;
      return event;
    });
  }

  @override
  Stream loadMore() {
    pageNo++;
    return Stream.fromFuture(_mockData()).map((event) {
      datas.addAll(event);
      return event;
    });
  }

  Future _mockData() {
    Completer completer = Completer();
    Future.delayed(Duration(seconds: 2)).then((value) {
      count = 60;
      completer.complete(List.generate(pageNo * 20, (index) => index));
      // completer.completeError(RequestError(1, "error"));
    });
    return completer.future;
  }
}
  ''';
}
