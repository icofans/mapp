String listPageTemplate(
  String projectName,
  String name,
) {
  return '''
import 'package:${projectName}/base/widget/widgets.dart';
import 'package:${projectName}/pages/demo/templates/template_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

class ${name}Page extends StatefulWidget {
  @override
  _${name}PageState createState() => _${name}PageState();
}

class _${name}PageState extends State<${name}Page> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("首页"),
      ),
      body: ProviderWidget(
        builder: (context, TemplateModel model, child) {
          print(model.pageStatus);
          if (model.isError) {
            return ErrorView(
              title: "出错了",
              message: "加载出错了",
              buttonText: "重试",
              onTap: model.initData,
              loadingView: LoadingView(message: "重试中"),
            );
          } else {
            return EasyRefresh(
              onLoad: model.datas.length == model.count ? null : model.onLoad,
              onRefresh: model.onRefresh,
              emptyWidget: model.isEmpty ? EmptyView(message: "空空如也") : null,
              firstRefresh: true,
              firstRefreshWidget: LoadingView(
                message: "加载中...",
              ),
              header: BallPulseHeader(),
              footer: BallPulseFooter(),
              child: ListView.builder(
                itemCount: model.datas.length,
                itemBuilder: (context, index) => _${name}PageListItem(index),
              ),
            );
          }
        },
        model: TemplateModel(),
        // onModelReady: (model) => model.initData(),
      ),
    );
  }
}

class _${name}PageListItem extends StatelessWidget {
  final int index;
  const _${name}PageListItem(this.index, {Key key}) : super(key: key);

  void onItemClick() {
    print(index);
  }

  @override
  Widget build(BuildContext context) {
    print(index);
    return ListTile(
      title: Text(context.watch<TemplateModel>().datas[index].toString()),
      onTap: onItemClick,
    );
  }
}
  ''';
}
