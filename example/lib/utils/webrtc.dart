import 'dart:convert';

import 'package:example/store/webSocket.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../models/error/error.dart';

class WebRTC {
  static final WebRTC _webrtc = WebRTC._init();
  late RTCPeerConnection rtcPeerConnection;
  MSocket mSocket = MSocket();
  MediaStream? _localStream;
  static final configuration = {
    "iceServers": [
      {"urls": 'stun:stun.l.google.com:19302'},
      {
        "urls": 'turn:chenrong.vip:3478', // TURN 服务器地址
        "username": 'chenrong', // TURN 用户名
        "credential": '130561' // TURN 密码
      }
    ]
  };

  WebRTC._init() {
    print("WebRTC initialized");
  }

  factory WebRTC() {
    return _webrtc;
  }

  // 获取一个peer链接
  Future<Error?> createPeer() async {
    try {
      rtcPeerConnection = await createPeerConnection(configuration);
      rtcPeerConnection.addStream(_localStream!);
      rtcPeerConnection.onAddStream = (stream) {
        // 监听远程流
        // _remoteRenderer.srcObject = stream;
      };
      // 处理ICE候选
      rtcPeerConnection.onIceCandidate = (candidate) {
        // 接收到candidate之后发送candidate 到对端
        mSocket.send({
          "type": "audio",
          "data": {"candidate": candidate, "type": 'candidate'}
        });
        // _sendSignalingMessage({'type': 'candidate', 'candidate': candidate.toJson()});
      };
      return null;
    } catch (err) {
      return CustomError("初始化失败");
    }
  }

  // 获取本地媒体流
  void getAudioMedia() async {
    MediaStream localStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'echoCancellation': true, // 启用回声消除
        'noiseSuppression': true, // 启用噪声抑制
        'autoGainControl': true, // 启用自动增益控制
      },
    });
    _localStream = localStream;
    // 本地流
    // _localRenderer.srcObject = localStream;
  }

  void close() {
    rtcPeerConnection.close();
  }

  void handlerMessage(String message) async {
    Map<String, dynamic> msg = jsonDecode(message);
    switch (msg['type']) {
      case 'offer':
        await _handleOffer(msg['offer']);
        break;
      case 'answer':
        await _handleAnswer(msg['answer']);
        break;
      case 'candidate':
        await _handleCandidate(msg['candidate']);
        break;
    }
  }

  Future<void> _handleOffer(String offer) async {
    await rtcPeerConnection
        .setRemoteDescription(RTCSessionDescription(offer, 'offer'));
    var answer = await rtcPeerConnection.createAnswer();
    await rtcPeerConnection.setLocalDescription(answer);
    // 此处应该发送消息到另一端，answer
    mSocket.send({
      "type": "audio",
      "data": {"answer": answer.sdp, "type": 'answer'}
    });
  }

  Future<void> _handleAnswer(String answer) async {
    await rtcPeerConnection
        .setRemoteDescription(RTCSessionDescription(answer, 'answer'));
  }

  Future<void> _handleCandidate(Map<String, dynamic> candidate) async {
    await rtcPeerConnection.addCandidate(RTCIceCandidate(candidate['candidate'],
        candidate['sdpMid'], candidate['sdpMLineIndex']));
  }
}
