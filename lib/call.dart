import 'dart:async';
import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';

import 'package:native_screenshot/native_screenshot.dart';

class CallPage extends StatefulWidget {
  String channelName;
  final ClientRole role = ClientRole.Broadcaster;
  final String APP_ID;
  bool camera;

  CallPage({Key key, this.channelName, this.APP_ID, this.camera}) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = true;
  RtcEngine _engine;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    if(_engine != null){
      _engine.leaveChannel();
      _engine.destroy();
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
  }

  Future<void> initialize() async {
    if (widget.APP_ID.isEmpty && mounted) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    //await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(1920, 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(null, widget.channelName, null, 0);
    _engine.muteLocalAudioStream(muted);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(widget.APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    if(mounted)
      _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
        });
      }, joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
      }, leaveChannel: (stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      }, userJoined: (uid, elapsed) {
        setState(() {
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          _users.add(uid);
        });
      }, userOffline: (uid, elapsed) {
        setState(() {
          final info = 'userOffline: $uid';
          _infoStrings.add(info);
          _users.remove(uid);
        });
      }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
        setState(() {
          final info = 'firstRemoteVideo: $uid ${width}x $height';
          _infoStrings.add(info);
        });
      }));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }


  /// Video layout wrapper
  Widget _viewRows(bool myCam) {
    final views = _getRenderViews();
    if(views.length == 1){
      return Container(
          child: Column(
            children: <Widget>[_videoView(views[0])],
          ));
    }
    else if(myCam){
      return Container(
          child: Column(
            children: <Widget>[_videoView(views[0])],
          ));
    }
    else{
      return Container(
          child: Column(
            children: <Widget>[_videoView(views[1])],
          ));
    }
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }


  @override
  Widget build(BuildContext context) {
    print("channel : ${widget.channelName}, myCam : ${widget.camera}");
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(widget.camera),
          ],
        ),
      ),
    );
  }
}
