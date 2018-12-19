import 'package:flutter/material.dart';
import 'package:flutter_loading/Progress.dart';
import 'package:flutter_loading/Toast.dart';
import 'package:flutter_loading/view_loading.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '加载动画'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ProgressDialog(
        loading: _loading,
        progress: MyProgress(size: new Size(100.0, 20.0),color: Colors.white,),
        msg: '正在加载...',
        alpha: 0.5,
        child: Center(
          child: RaisedButton(
            onPressed: () => _onRefresh(),
            child: Text('显示加载动画'),
          ),
        ),
      ),
    );
  }

  Future<Null> _onRefresh() async {
    setState(() {
      _loading = !_loading;
    });
    await Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _loading = !_loading;
        Toast.show(context, "加载完成");
      });
    });
  }
}
