import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtccommunication/model/message.dart';
import 'package:webrtccommunication/model/user.dart';
import 'package:webrtccommunication/utils/signaling_constants.dart';
import 'package:webrtccommunication/utils/socket_configuration.dart' as socket_config;
import 'package:webrtccommunication/webrtccommunication.dart';

enum SignalingState {
  userAlreadyAdded,
  failedToJoinVideoCall
}

/*
 * callbacks for Signaling API.
 */
typedef SignalingStateCallback = void Function(SignalingState state, {String id});
typedef StreamStateCallback = void Function(MediaStream? stream, String id);
typedef OtherEventCallback = void Function(dynamic event);
typedef DataChannelMessageCallback = void Function(RTCDataChannel dc, RTCDataChannelMessage data);
typedef DataChannelCallback = void Function(RTCDataChannel dc);

class VideoSignaling {
  final JsonDecoder _decoder = const JsonDecoder();
  String? _selfId;
  String? _channelName;

  final _peerConnections = <String, RTCPeerConnection>{};
  final _dataChannels = <String, RTCDataChannel>{};
  final _remoteCandidates = [];

  MediaStream? _localStream;
  final List<MediaStream> _remoteStreams = [];
  SignalingStateCallback? onStateChange;
  StreamStateCallback? onLocalStream;
  StreamStateCallback? onAddRemoteStream;
  StreamStateCallback? onRemoveRemoteStream;
  OtherEventCallback? onPeersUpdate;
  DataChannelMessageCallback? onDataChannelMessage;
  DataChannelCallback? onDataChannel;
  String? roomId;
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'}
    ]
  };

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  final Map<String, dynamic> _constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  final Map<String, dynamic> dcConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };

  final Map<String, dynamic> mediaConstraints = {};

  close() {
    if (_localStream != null) {
      _localStream?.dispose();
      _localStream = null;
    }

    _peerConnections.forEach((key, pc) {
      pc.close();
    });
  }

  void switchCamera() {
    if (_localStream != null) {
      Helper.switchCamera(_localStream!.getVideoTracks()[0]);
    }
  }

  bool videoSwitch = true;

  void onOffVideo() {
    if (_localStream != null) {
      videoSwitch = !videoSwitch;
      _localStream?.getVideoTracks()[0].enabled = videoSwitch;
    }
  }

  void muteMic(bool mute) {
    if (_localStream != null) {
      // _localStream?.getAudioTracks()[0].setmutesetMicrophoneMute(mute);
      Helper.setMicrophoneMute(mute, _localStream!.getAudioTracks()[0]);
    }
  }

  void invite(String userId, useScreen) {
    _createPeerConnection(userId, useScreen).then((peerConnection) {
      _peerConnections[userId] = peerConnection;
      _createOffer(userId, peerConnection);
    });
  }

  void onMessage(message) async {
    Map<String, dynamic> mapData = message;
    var data = mapData['data'];

    switch (mapData['type']) {
      case SignalingConstants.userAllReadyAdded:
        if (onStateChange != null) {
          onStateChange!(SignalingState.userAlreadyAdded);
        }
        break;

      case SignalingConstants.failedToJoinVideoCall:
        if (onStateChange != null) {
          onStateChange!(SignalingState.failedToJoinVideoCall);
        }
        break;

      case SignalingConstants.videoCallStarted:
        String userId = data[SignalingConstants.userId];
        _selfId = userId;
        String channelName = data[SignalingConstants.channelName];
        _channelName = channelName;
        MediaStream stream;
        try {
          stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
        } catch (e) {
          return;
        }
        _localStream = stream;
        _localStream?.getAudioTracks()[0].enableSpeakerphone(true);
        if (onLocalStream != null) {
          onLocalStream!(stream, userId);
        }
        _send(Message(type: SignalingConstants.notifyUsers, data: User(userId: userId, channelName: channelName)));
        break;

      case SignalingConstants.newUserAdded:
        String userId = data[SignalingConstants.userId];
        debugPrint("users: " + userId);
        invite(userId, false);
        break;

      case SignalingConstants.offer:
        var id = data[SignalingConstants.fromUserId];
        var description = data[SignalingConstants.description];
        var pc = await _createPeerConnection(id, false);
        _peerConnections[id] = pc;
        await pc.setRemoteDescription(RTCSessionDescription(description['sdp'], description['type']));
        await _createAnswer(id, pc);
        if (_remoteCandidates.isNotEmpty) {
          for (var candidate in _remoteCandidates) {
            await pc.addCandidate(candidate);
          }
          _remoteCandidates.clear();
        }
        break;

      case SignalingConstants.answer:
        {
          var id = data[SignalingConstants.fromUserId];
          var description = data[SignalingConstants.description];

          var pc = _peerConnections[id];
          if (pc != null) {
            await pc.setRemoteDescription(RTCSessionDescription(description['sdp'], description['type']));
          }
        }
        break;

      case SignalingConstants.candidate:
        {
          var id = data[SignalingConstants.fromUserId];
          var candidateMap = data[SignalingConstants.candidate];
          var pc = _peerConnections[id];
          RTCIceCandidate candidate =
              RTCIceCandidate(candidateMap['candidate'], candidateMap['sdpMid'], candidateMap['sdpMLineIndex']);
          if (pc != null) {
            await pc.addCandidate(candidate);
          } else {
            _remoteCandidates.add(candidate);
          }
        }
        break;

      case SignalingConstants.removeUser:
        {
          var fromUserId = data[SignalingConstants.userId];

          var pc = _peerConnections[fromUserId];
          if (pc != null) {
            await pc.close();
            await pc.dispose();
            _peerConnections.remove(fromUserId);
          }

          var dc = _dataChannels[fromUserId];
          if (dc != null) {
            dc.close();
            _dataChannels.remove(fromUserId);
          }
          if (onRemoveRemoteStream != null) onRemoveRemoteStream!(null, fromUserId);
        }
        break;

      default:
        break;
    }
  }

  _createPeerConnection(id, userScreen) async {
    RTCPeerConnection pc = await createPeerConnection(_iceServers, _config);
    if (_localStream != null) {
      pc.addStream(_localStream!);
    }
    pc.onIceCandidate = (candidate) {
      _send(Message(type: SignalingConstants.candidate, data: {
        SignalingConstants.toUserId: id,
        SignalingConstants.fromUserId: _selfId,
        SignalingConstants.candidate: {
          'sdpMLineIndex': candidate.sdpMLineIndex,
          'sdpMid': candidate.sdpMid,
          'candidate': candidate.candidate,
        },
      }));
    };

    pc.onIceConnectionState = (state) {};

    pc.onAddStream = (stream) {
      if (onAddRemoteStream != null) onAddRemoteStream!(stream, id);
      _remoteStreams.add(stream);
    };

    pc.onRemoveStream = (stream) {
      if (onRemoveRemoteStream != null) onRemoveRemoteStream!(stream, id);
      _remoteStreams.removeWhere((it) {
        return (it.id == stream.id);
      });
    };

    pc.onDataChannel = (channel) {
      _addDataChannel(id, channel);
    };

    return pc;
  }

  _addDataChannel(id, RTCDataChannel channel) {
    channel.onDataChannelState = (e) {};
    channel.onMessage = (RTCDataChannelMessage data) {
      if (onDataChannelMessage != null) onDataChannelMessage!(channel, data);
    };
    _dataChannels[id] = channel;

    if (onDataChannel != null) onDataChannel!(channel);
  }

  /*_createDataChannel(id, RTCPeerConnection pc, {label: 'fileTransfer'}) async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit();
    RTCDataChannel channel = await pc.createDataChannel(label, dataChannelDict);
    _addDataChannel(id, channel);
  }*/

  _createOffer(String id, RTCPeerConnection pc) async {
    try {
      RTCSessionDescription s = await pc.createOffer(_constraints);
      pc.setLocalDescription(s);
      _send(Message(type: SignalingConstants.offer, data: {
        SignalingConstants.toUserId: id,
        SignalingConstants.fromUserId: _selfId,
        SignalingConstants.description: {'sdp': s.sdp, 'type': s.type},
      }));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _createAnswer(String id, RTCPeerConnection pc) async {
    try {
      RTCSessionDescription s = await pc.createAnswer(_constraints);
      pc.setLocalDescription(s);
      _send(Message(type: SignalingConstants.answer, data: {
        SignalingConstants.toUserId: id,
        SignalingConstants.fromUserId: _selfId,
        SignalingConstants.description: {'sdp': s.sdp, 'type': s.type},
      }));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _send(Message message) {
    WebRtcCommunication.instance.sendData(socket_config.MessageType.videoCall, message);
  }

  void bye() {
    _peerConnections.forEach((key, pc) async {
      await pc.close();
      await pc.dispose();
    });
    _dataChannels.forEach((key, pc) async {
      await _dataChannels[key]?.close();
      _dataChannels.remove(key);
    });

    if (_localStream != null) {
      _localStream?.dispose();
      _localStream = null;
    }
    _send(Message(
        type: SignalingConstants.bye,
        data: {SignalingConstants.fromUserId: _selfId, SignalingConstants.channelName: _channelName}));
  }

  void configureVideo() {
    mediaConstraints['video'] = {
      /*"frameRate": {
                "min": "15",
                "max": "60"
              },*/
      'mandatory': {
        'minWidth': '640', // Provide your own width, height and frame rate here
        'minHeight': '640',
        //'minFrameRate': '30',
      },
      'facingMode': 'user',
      'optional': [],
    };
  }

  void configureAudio() {
    mediaConstraints['audio'] = true;
    /*'audio': {
              'autoGainControl': false,
              'channelCount': 2,
              'echoCancellation': false,
              'latency': 0,
              'noiseSuppression': false,
              'sampleRate': 48000,
              'sampleSize': 16,
              'volume': 1.0
            },*/
  }
}
