import 'package:dartin/dartin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mvvm_flutter/helper/dialog.dart';
import 'package:mvvm_flutter/helper/toast.dart';
import 'package:mvvm_flutter/helper/widget_utils.dart';
import 'package:mvvm_flutter/view/base.dart';
import 'package:mvvm_flutter/viewmodel/home_provide.dart';
import 'package:provide/provide.dart';

import 'dart:async';
import 'package:rxdart/rxdart.dart';

/// Page ：HomePage
///
/// 获取其它页面传递来的参数
/// 构造出各个 Provide 对象，放入到 [mProviders]里
class HomePage extends PageProvideNode {
    /// 页面标题
    final String title;

    /// 提供
    ///
    /// 获取参数 [title] 并生成一个[HomeProvide]对象
    /// 然后放入 [mProviders]中
    HomePage(this.title) {
        final provide = inject<HomeProvide>(params: [title]);
        mProviders.provideValue(provide);
    }

    @override
    Widget buildContent(BuildContext context) {
        return _HomeContentPage();
    }
}

/// View : 登录页面
///
/// 展示UI (ps:如果有UI地址，最好附上相应的链接)
/// 与用户进行交互
class _HomeContentPage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() {
        return _HomeContentState();
    }
}

class _HomeContentState extends State<_HomeContentPage> with SingleTickerProviderStateMixin<_HomeContentPage>
    implements Presenter {

    HomeProvide mProvide;

    /// 处理动画
    AnimationController _controller;
    Animation<double> _animation;


    static const ACTION_LOGIN = "login";

    final LoadingDialog loadingDialog = LoadingDialog();


    CustomSubject subject;

    @override
    void initState() {
        super.initState();
        _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
        _animation = Tween(begin: 295.0, end: 48.0).animate(_controller)
        ..addListener(() {
            mProvide.btnWidth = _animation.value;
        });
    }

    @override
    void dispose() {
        print('-------dispose-------');
        _controller.dispose();
        subject.close();
        super.dispose();
    }

    @override
    void onClick(String action) {
        if (action == ACTION_LOGIN) {
            login();
        }
    }

    /// 登录
    ///
    /// 调用 [mProvide] 的 login 方法并进行订阅
    /// 请求开始时：启动动画 [AnimationStatus.forward]
    /// 请求结束时：反转动画 [AnimationStatus.reverse]
    /// 成功 ：弹出 'login success'
    /// 失败 ：[dispatchFailure] 显示错误原因
    void login() {
        subjects();
        return null;
        final s = mProvide.login().doOnListen(() {
            _controller.forward();
        }).doOnDone(() {
            _controller.reverse();
        }).doOnCancel(() {
            print("======cancel======");
        }).listen((_) {
            //success
            Toast.show("login success", context, type: Toast.SUCCESS);
        }, onError: (e) {
            //error
            dispatchFailure(context, e);
        });
        mProvide.addSubscription(s);
    }

    subjects(){
        subject = CustomSubject<int>(sync: false);
/*
        subject.listen((v) {
            print('A....${v}');
        });
        subject.add(1111);
        subject.add(2222);
        subject.listen((v) {
            print('B....${v}');
        });
        subject.add(3333);
        subject.add(4444);
        print(subject.stream.length);

        var ob = Observable(Stream.fromIterable([1,2,3,4]).map((v){
            return v * 2;
        }).asBroadcastStream());

        print(ob.isBroadcast);
        ob.first.then((v){
            print('first...$v');
        });

        ob.listen((v){
            print('listen...$v');
        }, onDone: (){
            print('over...');
        });
        Timer(Duration(seconds: 3), () => ob.listen(print));
        Timer(Duration(seconds: 4), () => ob.listen(print));
*/

        var c = new StreamController<int>.broadcast();

        final transform = StreamTransformer<int, String>.fromHandlers(
            handleData: (value, sink) {
                sink.add('transform $value');   // 在初始流的基础上更新
            }
        );
        c.stream.transform(transform).map((v){
            return '$v map';
        }).listen((v){
            print(v);
        });
        c.sink.add(1111);


        c.stream.pipe(CustomConsumer())
        ..then((v){
            print('custom consumer $v');
        });
        // equivalent below
        // stream.reduce(0, (p, c) => p + c).then(print);

        c.sink.add(5656);
        c.sink.add(6767);
        //c.close();

        Observable.fromFuture(Future.value('5555'))
        ..listen((v){
            print(v);
        });
        Observable<String> observable = Observable.periodic(Duration(seconds: 2));
        observable.listen((v){
            //print(6666);
        }); 
    }

    @override
    Widget build(BuildContext context) {
        mProvide = Provide.value<HomeProvide>(context);
        FocusNode password = FocusNode(); 
        password.addListener(() {
            print(password.hasFocus);
        });
        
        print("--------build--------");
        return Material(
            child: Scaffold(
                appBar: AppBar(
                    title: Text(mProvide.title),
                    elevation: 0.0,
                ),
                body: SafeArea(
                    child: DefaultTextStyle(
                    style: TextStyle(color: Colors.grey),
                    child: Column(
                    children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(top: 10.0),
                            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                            child: TextField(
                                obscureText: false,
                                cursorColor: Colors.red,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(15.0),
                                    hintText: 'Account',
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey[300], width: 0.5 )
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey[300], width: 0.5 )
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey[350], width: 0.5 )
                                    )
                                ),
                                autofocus: false,
                                onChanged: (str) => mProvide.username = str,
                                onEditingComplete: () => FocusScope.of(context).requestFocus(password),
                            ),
                        ),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                            child: TextField(
                                obscureText: true,
                                focusNode: password,
                                cursorColor: Colors.red,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(15.0),
                                    hintText: 'Password',
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey[300], width: 0.5 )
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey[350], width: 0.5 )
                                    ),
                                ),
                                autofocus: false,
                                onChanged: (str) => mProvide.password = str,
                            ),
                        ),
                        buildLoginBtnProvide(),
                        const Text(
                            "Response:",
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.start,
                        ),
                        
                        Expanded(
                            child: Container(
                                constraints: BoxConstraints(minWidth: double.infinity),
                                margin: EdgeInsets.fromLTRB(12, 12, 12, 12),
                                padding: EdgeInsets.all(5.0),
                                child: Provide<HomeProvide>(
                                    builder: (BuildContext context, Widget child, HomeProvide value) {
                                        if(value.response.isEmpty) {
                                            return Text(value.response); 
                                        }else {
                                            var result = json.decode(value.response);
                                            print(result);
                                            if(result['message'] != null){
                                                return Text(result['message']); 
                                            }
                                            return ListTile(
                                                title: Text(result['name'], style: TextStyle(color: Colors.grey),),
                                                subtitle: Text('${result['id']}', style: TextStyle(color: Colors.grey),),
                                                leading: CircleAvatar( 
                                                    radius: 30.0,
                                                    backgroundImage: NetworkImage(result['avatar_url']),
                                                )
                                            );
                                        }
                                    }
                                ),
                            ),
                        )
                        ],
                    ),
                ),
                )
            ),
        );
    }

    /// 登录按钮
    ///
    /// 按钮宽度根据是否进行请求由[_controller]控制
    /// 当 [mProvide.loading] 为true 时 ，点击事件不生效
    Provide<HomeProvide> buildLoginBtnProvide() {
        return Provide<HomeProvide>(
            builder: (BuildContext context, Widget child, HomeProvide value) {
                return CupertinoButton(
                    onPressed: value.loading ? null : () => onClick(ACTION_LOGIN),
                    pressedOpacity: 0.8,
                    child: Container(
                        alignment: Alignment.center,
                        width: value.btnWidth,
                        height: 48,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)),
                            gradient: LinearGradient(colors: [
                                Color(0xFFffff00),
                                Color(0xFFff4f40),
                            ]),
                            boxShadow: [
                                BoxShadow(color: Color(0x3D5E56FF), offset: Offset(0.0, 2.0), blurRadius: 5.0)
                            ]),
                        child: buildLoginChild(value),
                    ),
                );
            },
        );
    }

    /// 登录按钮内部的 child
    ///
    /// 当请求进行时 [value.loading] 为 true 时,显示 [CircularProgressIndicator]
    /// 否则显示普通文本
    Widget buildLoginChild(HomeProvide value) {
        if (value.loading) {
            return const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white));
        } else {
            return const FittedBox(
                fit: BoxFit.scaleDown,
                child: const Text(
                    'Login With Github Account',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white),
                ),
            );
        }
    }
}



class User {
    final String name;

    User({this.name});

    factory User.fromJson(Map<String, dynamic> json) {
        return new User(
            name: json['name'] as String
        );
    }
    List<User> parseJson(String response) {
        List<User> users = new List<User>();
        List result = json.decode(response.toString());
        for (int i = 0; i < result.length; i++) {
            users.add(new User.fromJson(result[i]));
        }
        return users;
    }
 }


class CustomSubject<T> extends Subject<T> {
    CustomSubject._(StreamController<T> controller, Observable<T> observable)
        : super(controller, observable);

    factory CustomSubject({void onListen(), void onCancel(), bool sync = false}) {
        // ignore: close_sinks
        final controller = StreamController<T>.broadcast(
            onListen: onListen,
            onCancel: onCancel,
            sync: sync,
        );
        return CustomSubject<T>._(
            controller,
            Observable<T>(controller.stream),
        );
    }
}


class CustomConsumer<M> implements StreamConsumer<M> {

    @override
    Future addStream(Stream<M> stream) {
        return stream.forEach((v) {
            print('>>>>> $v');
            return v;
        });
    }

    @override
    Future close() {
        return null;
    }
}