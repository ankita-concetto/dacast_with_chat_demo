import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class StreamingView extends StatefulWidget {
  /// Stream which found from WebRTC or Local Stream
  final MediaStream? stream;

  /// Duration when widget size changes
  final Duration duration;

  /// Width of the Streaming View
  final double width;

  /// Height of the Streaming View
  final double height;

  /// Text while your Stream is Loading
  final String waitingText;

  final TextStyle waitingTextStyle;

  const StreamingView(
      {Key? key,
      this.stream,
      this.duration = const Duration(milliseconds: 200),
      this.width = 300,
      this.height = 300,
      this.waitingText = "Joining...",
      this.waitingTextStyle =
          const TextStyle(fontSize: 14, color: Colors.white)})
      : assert(stream != null),
        super(key: key);

  @override
  _StreamingViewState createState() => _StreamingViewState();
}

class _StreamingViewState extends State<StreamingView> {
  RTCVideoRenderer? _renderer;

  @override
  void initState() {
    _initialiseRender();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildStreamingView();
  }

  _buildStreamingView() {
    return AnimatedContainer(
        duration: widget.duration,
        width: widget.width,
        height: widget.height,
        color: Colors.black,
        child: _renderer == null
            ? Center(
                child: Text(widget.waitingText, style: widget.waitingTextStyle))
            : RTCVideoView(_renderer!,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain));
  }

  void _initialiseRender() async {
    if (widget.stream != null) {
      _renderer = RTCVideoRenderer();
      await _renderer?.initialize();
      _renderer?.srcObject = widget.stream;
    }
  }
}
