import 'package:flutter/material.dart';
import 'package:mvvm_flutter/view/home_page.dart';
import 'di/app_module.dart';


void main() async{
  // wait init
  await init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'MVVM',
        theme: ThemeData(
            primarySwatch: Colors.lime,
            splashColor: Colors.transparent,
            brightness: Brightness.light
        ),
        home: HomePage('MVVM'));
    }
}



/*
基本概念
    顾名思义，Stream 就是流的意思，表示发出的一系列的异步数据。可以简单地认为 Stream 是一个异步数据源。它是 Dart 中处理异步事件流的统一 API。

集合与Stream
    Dart 中，集合（Iterable或Collection）表示一系列的对象。而 Stream （也就是“流”）也表示一系列的对象，但区别在于 Stream 是异步的事件流。比如文件、套接字这种 IO 数据的非阻塞输入流（input data），或者用户界面上用户触发的动作（UI事件）。

    集合可以理解为“拉”模式，比如你有一个 List ，你可以主动地通过迭代获得其中的每个元素，想要就能拿出来。而 Stream 可以理解为“推”模式，这些异步产生的事件或数据会推送给你（并不是你想要就能立刻拿到）。这种模式下，你要做的是用一个 listener （即callback）做好数据接收的准备，数据可用时就通知你。

    推和拉就是别人给你还是你自己去拿的区别。但是不管如何获取数据，二者的本质都可以认为是数据的集合（数据可能无限多）。所以，二者有很多相同的方法，稍后介绍。

    怎么理解 Stream 中的数据？
    数据（data）是个非常抽象的概念，可以认为一切皆数据。在程序的世界里，其实只有两种东西：数据和对数据的操作。对数据的操作就是对输入的数据经过一些计算，之后输出一些新数据。事件（event，如UI上的事件）、计算结果（value，如函数/方法的返回值）以及从文件或网络获得的纯数据都可以认为是数据（data）。另外，Dart 中的所有事物都是对象，所以数据也一定是某种对象（object）。在本文中，可以认为事件、结果、数据、对象都是一样的，不用特意区分。

Stream 与 Future
    Stream 和 Future 是 Dart 异步处理的核心 API。Future 表示稍后获得的一个数据，所有异步的操作的返回值都用 Future 来表示。但是 Future 只能表示一次异步获得的数据。而 Stream 表示多次异步获得的数据。比如界面上的按钮可能会被用户点击多次，所以按钮上的点击事件（onClick）就是一个 Stream 。简单地说，Future将返回一个值，而Stream将返回多次值。

    另外一点， Stream 是流式处理，比如 IO 处理的时候，一般情况是每次只会读取一部分数据（具体取决于实现）。和一次性读取整个文件的内容相比，Stream 的好处是处理过程中内存占用较小。而 File 的 readAsString（异步读，返回 Future）或 readAsStringSync（同步读，返回 String）等方法都是一次性读取整个文件的内容进来，虽然获得完整内容处理起来比较方便，但是如果文件很大的话就会导致内存占用过大的问题。



获取 Stream 的方式
    将集合（Iterable）包装为 Stream 
    Stream 有3个工厂构造函数：fromFuture、fromIterable 和 periodic，分别可以通过一个 Future、Iterable或定时触发动作作为 Stream 的事件源构造 Stream。下面的代码就是通过一个 List 构造的 Stream。
    var data = [1, 2, 3, 4]; 
    var stream = new Stream.fromIterable(data); 
    对集合的包装只是简单地模拟异步，定时触发、IO输入、UI事件等现实情况才是真正的异步事件。

    使用 Stream 读文件    var stream = new File(new Options().script).openRead();

订阅 Stream

    你有了一个 Stream 时，最常用的功能就是通过 listen() 方法订阅 Stream 上发出的数据（即事件）。有事件发出时就会通知订阅者。如果在发出事件的同时添加订阅者，那么要在订阅者在该事件发出后才会生效。如果订阅者取消了订阅，那么它会立即停止接收事件。

    我们在接收一个输入流的时候要面临几种不同的情况和状态，最基本的是处理收到数据，此外上游还可能出现错误，以及出现错误时是否继续后续数据的处理，最后在输入完成的时候还有一个结束状态。所以 listen 方法的几个参数分别对应这些情况和状态： 
    onData，处理收到的数据的 callback 
    onError，处理遇到错误时的 callback 
    onDone，结束时的通知 callback 
    unsubscribeOnError，遇到第一个错误时是否停止（也就是取消订阅），默认为false 
    onData 是唯一必填参数，也是用的最多的，后面3个是可选的命名参数。


高级订阅管理

    前面的示例代码会处理 Stream 发出的所有数据，直到 Stream 结束。如果想提前取消处理怎么办？listen() 方法会返回一个 StreamSubscription 对象，用于提供对订阅的管理控制。onData、onError和onDone 这3个方法分别用于设置（如果listen方法中的参数为null）或覆盖对应的 callback。cancel、pause和resume分别用于取消订阅、暂停和继续。比如，可以在 listen 方法中参数置为 null，接着通过 subscription 对象设置 callback 。此外，cancel 方法也重要，要么一直处理数据直到 stream 结束，要么提前取消订阅结束处理。比如使用 Stream 读文件，为了使资源得到释放，要么读完整个文件，要么使用 subscription 的 cancel 方法取消订阅（即终止后续数据的读取）。可以看出，这里的 cancel 相当于传统意义上的 close 方法。最后，pause和resume方法是尝试向数据源发出暂停和继续的请求，其意义取决于实际情况，并且不保证一定能生效。比如数据源能够支持，或者是带缓冲实现的 stream 才能做到暂停。




Stream 两种订阅模式
    Stream有两种订阅模式：单订阅(single)和多订阅（broadcast）。单订阅就是只能有一个订阅者，而广播是可以有多个订阅者。这就有点类似于消息服务（Message Service）的处理模式。单订阅类似于点对点，在订阅者出现之前会持有数据，在订阅者出现之后就才转交给它。而广播类似于发布订阅模式，可以同时有多个订阅者，当有数据时就会传递给所有的订阅者，而不管当前是否已有订阅者存在。

    Stream 默认处于单订阅模式，所以同一个 stream 上的 listen 和其它大多数方法只能调用一次，调用第二次就会报错。但 Stream 可以通过 transform() 方法（返回另一个 Stream）进行连续调用。通过 Stream.asBroadcastStream() 可以将一个单订阅模式的 Stream 转换成一个多订阅模式的 Stream，isBroadcast 属性可以判断当前 Stream 所处的模式。


Stream 的集合特性
    Stream 和一般的集合类似，都是一组数据，只不过一个是异步推送，一个是同步拉取

通用数据收敛方法
    集合中有很多方法只返回一个值，多个数据作为输入、一个数据作为输出的方法就是数据收敛的方法。Stream 有一个更通用的收敛方法 pipe() 。pipe() 方法的参数要求是一个 StreamConsumer 接口的实现，该接口只有一个方法： Future consume(Stream stream)




abstract class StreamConsumer<S>       //  dart


abstract class Sink<T>       //  dart:core

abstract class EventSink<T> implements Sink<T>       //  dart

abstract class StreamSink<S> implements EventSink<S>, StreamConsumer<S>       //  dart

abstract class StreamController<T> implements StreamSink<T>        //  dart

abstract class Stream<T>       //  dart

class Observable<T> extends Stream<T>      //  rxdart

abstract class Subject<T> extends Observable<T> implements StreamController<T>     //  rxdart

class PublishSubject<T> extends Subject<T>     //  rxdart


abstract class ValueObservable<T> implements Observable<T>

class BehaviorSubject<T> extends Subject<T> implements ValueObservable<T> 


abstract class ReplayObservable<T> implements Observable<T>

class ReplaySubject<T> extends Subject<T> implements ReplayObservable<T>


Stream 
    constructor:   empty  fromFuture   fromFutures   fromIterable   periodicss  eventTransformed
    属性:   first last  length  single   isEmpty  isBroadcast
    方法:   any where  transform  take  takeWhile  skip  skipWhile  timeout  reduce  pipe   map  listen  join  firstWhile  lastWhile   forEach   fold   expand(展开数组)   every  drain   distinct(过滤相同数据)  contains   cast   asyncMap  asyncExpand   asBroadcastStream  toSet  toList


StreamController
    constructor:   broadcast
    属性:  hasListener  isClosed  isPaused  onCancel  onListen  onPause  onResume  sink  stream
    方法:  add   addStream   addError   close


StreamSubscription
    属性:  isPaused
    方法:  asFuture   cancel  onDate  onDone  onError  pause  resume


StreamIterator
    属性:  current
    方法:  cancel  moveNext

StreamConsumer
    方法:  addStream   close

StreamSink
    属性:  done
    方法:  close  add  addError   addStream


使用 Subject 控制 Observable, 即可实现对 Stream 的控制
rxdart 通过使用可观察序列来编写异步和基于事件的程序
Subject实现并扩展了StreamController,它符合StreamController的所有规范,  假如您之前使用的StreamController,那么你可以直接替换为Subjec
Observable 实现并扩展了 Stream 它将常用的 stream 和 streamTransformer 组合成了非常好用的api。你可以把它想像成stream
*/