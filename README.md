> Flutter正式版出了,做为一个Android开发，是时候跟随大部队进坑了。在写一个登录页面的时候登录是写完了，突然发现不知道怎么搞一个加载中的动画效果，毕竟Android中有ProgressDialog可用，然而Flutter中不知道用啥，那就自己写一个出来。

### 目标
先上效果图：
![目标.gif](https://upload-images.jianshu.io/upload_images/10147880-33bbd66690cc486e.gif?imageMogr2/auto-orient/strip)

是不是感觉跟ProgressDialog创建出来的一毛一样！！！
### 实现思路

##### **使用对话框**
 首先想到的是用Flutter自带的SimpleDialog对话框，但是想到这玩意貌似要主动点击按钮关闭，这种方案不符合自己的要求。

##### **根据情况返回不同布局** 
在加载的时候返回加载的布局，不加载的时候返回登陆页面布局，代码如下:
```
import 'package:flutter/material.dart';
import 'package:flutter_loading/Toast.dart';

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
      body: _childLayout(),
    );
  }

  Widget _childLayout() {
    if (_loading) {
      return Center(
        child: Container(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Center(
        child: RaisedButton(
          onPressed: () => _onRefresh(),
          child: Text('显示加载动画'),
        ),
      );
    }
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

```
重点在_childLayout()方法，当加载中的时候返回环形进度条，加载完成，返回实际显示的布局，代码效果如下：

![GIF0.gif](https://upload-images.jianshu.io/upload_images/10147880-be9c13109b054c9f.gif?imageMogr2/auto-orient/strip)


看效果是好像实现，但是这种效果只适合普通数据列表页面的加载，要是登陆页面，你总不能这么搞吧，一点登录，页面布局都跑路了，只有一个圈圈有啥意思。这种方法也不行。

##### **使用Stack层叠布局**  
在原本布局上面叠加一层半透明背景，显示一个进度条。这个想法好像可以。重点来了开始撸一波
层叠布局至少有两个控件，按照Flutter思想，一切皆控件。我们自定义一个控件叫ProgressDialog，我们这个控件接收两个必传参数：子布局child，是否显示加载进度：loading，这两个参数是必须的，所以自定义控件如下
```
import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  final bool loading;
  final Widget child;

  ProgressDialog({Key key, @required this.loading, @required this.child})
      : assert(child != null),
        assert(loading != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return null;
  }
}
```
构造函数写好了，那么开始写控件，Stack层叠布局必须返回两个以上的控件，所以先定义一个List<Widget>,用来放层叠的控件组，首先要把child控件加进去，再加一个加载中的动画。上代码：
```
import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  final bool loading;
  final Widget child;

  ProgressDialog({Key key, @required this.loading, @required this.child})
      : assert(child != null),
        assert(loading != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    widgetList.add(child);
    //如果正在加载，则显示加载添加加载中布局
    if (loading) {
      widgetList.add(Center(
        child: CircularProgressIndicator(),
      ));
    }
    return Stack(
      children: widgetList,
    );
  }
}
```
是不是感觉好像很简单的样子，惯例上图：

![加载中1](https://upload-images.jianshu.io/upload_images/10147880-452d7869dc669338.gif?imageMogr2/auto-orient/strip)

看图效果好像很接近了，起码原先的布局没有被直接替换，但是感觉不美观，好吧加个透明背景效果，这里就用到控件Opacity，专门用来绘制透明效果。 上代码：
```
import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  final bool loading;
  final Widget child;

  ProgressDialog({Key key, @required this.loading, @required this.child})
      : assert(child != null),
        assert(loading != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    widgetList.add(child);
    //如果正在加载，则显示加载添加加载中布局
    if (loading) {
      //增加一层黑色背景透明度为0.8
      widgetList.add(
        Opacity(
            opacity: 0.8,
            child: ModalBarrier(
              color: Colors.black87,
            )),
      );
      //环形进度条
      widgetList.add(Center(
        child: CircularProgressIndicator(),
      ));
    }
    return Stack(
      children: widgetList,
    );
  }
}
```
老规矩，上图：
![增加透明度.gif](https://upload-images.jianshu.io/upload_images/10147880-adfd923347ec33f8.gif?imageMogr2/auto-orient/strip)


看着样子是不是差不多，一般进度都可以用了吧，但是如果我要想在进度条下方显示文字怎么办？并且我看那个toast样子蛮好看的，还想要搞成那样的。好吧，那样的话加载进度条和提示内容得是同一层，用个垂直布局显示一个进度一个Text()应该能搞定：
```
import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  final bool loading;
  final Widget child;

  ProgressDialog({Key key, @required this.loading, @required this.child})
      : assert(child != null),
        assert(loading != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    widgetList.add(child);
    //如果正在加载，则显示加载添加加载中布局
    if (loading) {
      //增加一层黑色背景透明度为0.8
      widgetList.add(
        Opacity(
            opacity: 0.8,
            child: ModalBarrier(
              color: Colors.black87,
            )),
      );
      //环形进度条
      widgetList.add(Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
              //黑色背景
              color: Colors.black87,
              //圆角边框
              borderRadius: BorderRadius.circular(10.0)),
          child: Column(
            //控件里面内容主轴负轴剧中显示
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            //主轴高度最小
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              Text(
                '加载中...',
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      ));
    }
    return Stack(
      children: widgetList,
    );
  }
}
```
用一个垂直布局Column包裹进度条和提示内容，完美解决，已经接近目标了，图来-->


![增加提醒内容.gif](https://upload-images.jianshu.io/upload_images/10147880-34543dd2cce2006d.gif?imageMogr2/auto-orient/strip)



目标完成，最后润色：提示字体要让用户自定义，加载动画也得可以自定义，那么最终代码如下：
```
import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  //子布局
  final Widget child;

  //加载中是否显示
  final bool loading;

  //进度提醒内容
  final String msg;

  //加载中动画
  final Widget progress;

  //背景透明度
  final double alpha;

  //字体颜色
  final Color textColor;

  ProgressDialog(
      {Key key,
      @required this.loading,
      this.msg,
      this.progress = const CircularProgressIndicator(),
      this.alpha = 0.6,
      this.textColor = Colors.white,
      @required this.child})
      : assert(child != null),
        assert(loading != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    widgetList.add(child);
    if (loading) {
      Widget layoutProgress;
      if (msg == null) {
        layoutProgress = Center(
          child: progress,
        );
      } else {
        layoutProgress = Center(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                progress,
                Container(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
                  child: Text(
                    msg,
                    style: TextStyle(color: textColor, fontSize: 16.0),
                  ),
                )
              ],
            ),
          ),
        );
      }
      widgetList.add(Opacity(
        opacity: alpha,
        child: new ModalBarrier(color: Colors.black87),
      ));
      widgetList.add(layoutProgress);
    }
    return Stack(
      children: widgetList,
    );
  }
}
```
最后附上在工程中调用的例子代码：
```
import 'package:flutter/material.dart';
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
        msg: '正在加载...',
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

```
对于加载动画，只要把progress属性改为自定义的属性即可，比如这位大佬写的加载动画：
[flutter自定义进度动画](https://www.jianshu.com/p/acd3734310aa)，我们用他的加载中动画：
只需在上述代码中加一行(当然前提是你得去[github](https://github.com/While1true/flutter_refresh)上git到他自定义的代码)：
```
loading: _loading,
//自定义动画
progress: MyProgress(size: new Size(100.0, 20.0),color: Colors.white,),
msg: '正在加载...',
```
效果如下：

![自定义动画.gif](https://upload-images.jianshu.io/upload_images/10147880-9a40f6eb03491029.gif?imageMogr2/auto-orient/strip)

- 参考项目：
[https://github.com/While1true/flutter_refresh](https://github.com/While1true/flutter_refresh)
[https://pub.dartlang.org/packages/modal_progress_hud](https://pub.dartlang.org/packages/modal_progress_hud)






