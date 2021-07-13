/**
 *   日期          修改人              修改目的
 * 20210708       zhang qiao
 *
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'timeline_util.dart';

class VideoNetworkPageBuilder extends StatefulWidget {
  // final double height;
  final String url;//可以传视频或者音频
  final bool isLoopPlay;//是否循环播放
  final bool initPlay;//是否初始化完成的时候就播放

  // ignore: sort_constructors_first
  const VideoNetworkPageBuilder({ required this.url, this.isLoopPlay = false, this.initPlay = false});

  @override
  State<StatefulWidget> createState() {
    return VideoNetworkPageBuilderState();
  }
}

class VideoNetworkPageBuilderState extends State<VideoNetworkPageBuilder> {
  late VideoPlayerController _controller;
  int position = 0;
  // double height = 0;
  bool fullScreen = false;
  bool hideAppBar = true;
  bool hideControllBar = false;
  String tips = '缓冲中...';
  late IconData _icons;// = Icons.pause_circle_outline;
  double dy = 0;

  @override
  void initState() {
    super.initState();
    // print("widget.url==${widget.url}");
    _controller = VideoPlayerController.network(widget.url
//        "http://ipms.ujiaku.com/download/linshi/yunhujiao.mp4");
//        "http://server.ujiaku.com/upload/2021/03/29/02c5766fd8ac7641.wav"
    );
    _controller.addListener(() {
      if (_controller.value.hasError) {
        print(_controller.value.errorDescription);
        setState(() {
          tips = '播放出错';
        });
      } else if (_controller.value.isInitialized) {
        setState(() {
          position = _controller.value.position.inSeconds;
          tips = '';
        });
      } else if (_controller.value.isBuffering) {
        setState(() {
          tips = '缓冲中...';
        });
      }
    });
    _controller.initialize().then((_) {
      if(widget.initPlay){
        setState(() {
          _controller.play();
          _controller.setVolume(1);
        });
      }

    });
    _controller.setLooping(widget.isLoopPlay);
//    height = 200;
//     height = widget.height;
    _icons = widget.initPlay?Icons.pause_circle_outline: Icons.play_circle_outline;
  }

  @override
  Widget build(BuildContext context) {

    return Positioned.fill(
      child: Center(
        child: Container(
          color: Colors.black,
          child: _controller.value.isInitialized
              ? Stack(
            alignment: Alignment.center,
            children: <Widget>[
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: InkWell(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      // 滑动控制音量、亮度、进度等操作
                      GestureDetector(
                        onVerticalDragStart: (details) {
                          dy = 0;
                        },
                        onVerticalDragUpdate: (details) {
                          dy += details.delta.dy;
                          print('${details.delta.dy}  :  $dy');
                          print(dy /
                              MediaQuery.of(context).size.height);
                          _controller.setVolume(1);
                        },
                        onVerticalDragEnd: (details) {},
                        child: VideoPlayer(_controller),
                      ),
                      Text(
                        tips,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.white),
                      )
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      hideControllBar = !hideControllBar;
                    });
                  },
                ),
              ),
              // 播放器底部控制栏
              Align(
                alignment: Alignment.bottomCenter,
                child: Offstage(
                  offstage: hideControllBar,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    color: Colors.black54,
                    child: Row(children: <Widget>[
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                              _icons = Icons.play_circle_outline;
                            } else {
                              _controller.play();
                              _icons = Icons.pause_circle_outline;
                            }
                          });
                        },
                        child: Icon(
                          _icons,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(
                        TimelineUtil.getCurrentPosition(position),
                        style: const TextStyle(color: Colors.white),
                      ),),

                      // 进度条
                      Expanded(
                          child: LinearProgressIndicator(
                            value: TimelineUtil.getProgress(position,
                                _controller.value.duration.inSeconds),
                            backgroundColor: Colors.black87,
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        TimelineUtil.getCurrentPosition(
                            _controller.value.duration.inSeconds),
                        style: TextStyle(color: Colors.white),
                      ),
//                          SizedBox(
//                            width: 10,
//                          ),
//                          InkWell(
//                            child: Icon(
//                              Icons.fullscreen,
//                              color: Colors.white,
//                              size: 30,
//                            ),
//                            onTap: () {
//                              fullOrMin();
//                            },
//                          ),
                    ]),
                  ),
                ),
              ),
            ],
          )
              : Container(
            alignment: Alignment.center,
            child: Text(
              tips,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget getAppBar() {
    return PreferredSize(
      // Offstage来控制AppBar的显示与隐藏
        child: Offstage(
          offstage: hideAppBar,
          child: AppBar(
            title: Text('VideoPlayer'),
            primary: true,
          ),
        ),
        preferredSize:
        Size.fromHeight(MediaQuery.of(context).size.height * 0.07));
  }

  // 返回键拦截执行方法
  Future<bool> _onWillPop() {
    if (fullScreen) {
      setState(() {
        // height = 200;
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitUp,
        ]);
        SystemChrome.setEnabledSystemUIOverlays(
            [SystemUiOverlay.top, SystemUiOverlay.bottom]);
        hideAppBar = false;
        fullScreen = !fullScreen;
      });
      return Future.value(false); //不退出
    } else {
      return Future.value(true); //退出
    }
  }

  void fullOrMin() {
    setState(() {
      if (fullScreen) {
        // height = 200;
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitUp,
        ]);
        SystemChrome.setEnabledSystemUIOverlays(
            [SystemUiOverlay.top, SystemUiOverlay.bottom]);
        hideAppBar = false;
      } else {
        hideAppBar = true;
        // height = MediaQuery.of(context).size.height;
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeLeft,
        ]);
        SystemChrome.setEnabledSystemUIOverlays([]);
      }
      fullScreen = !fullScreen;
    });
  }

  @override
  void dispose() {
    // print("摧毁video》》》》》");
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }
}