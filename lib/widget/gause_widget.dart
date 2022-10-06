import 'dart:math' as math;
import 'package:flutter/material.dart';

class CustomGaugeSegment {
  final String segmentName;
  final int segmentSize;
  final Color segmentColor;

  CustomGaugeSegment(this.segmentName, this.segmentSize, this.segmentColor);
}

class GaugeNeedleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(
        Rect.fromPoints(Offset(size.width / 2 - 2, size.height / 1.21),
            Offset(size.width / 2 + 2, size.height * .97)),
      )
      ..close();

    return path;
  }

  @override
  bool shouldReclip(GaugeNeedleClipper oldClipper) => false;
}

class ArcPainter extends CustomPainter {
  ArcPainter(
      {this.startAngle = 0, this.sweepAngle = 0, this.color = Colors.grey});

  final double startAngle;

  final double sweepAngle;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(size.width * 0.1, size.height * 0.1,
        size.width * 0.9, size.height * 0.9);

    const useCenter = false;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08;

    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class GaugeMarkerPainter extends CustomPainter {
  GaugeMarkerPainter(this.text, this.position, this.textStyle);

  final String text;
  final TextStyle textStyle;
  final Offset position;

  @override
  void paint(Canvas canvas, Size size) {
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class CustomGauge extends StatefulWidget {
  final double gaugeSize;
  final List<CustomGaugeSegment>? segments;

  final int minValue;
  final int maxValue;

  final int? baselineValue;
  final int? previousValue;
  final int? currentValue;

  final Color needleColor;

  final Widget? valueWidget;

  final bool showBaselineMarker;
  final bool showPreviousMarker;
  final bool showCurrentMarker;
  final bool showMarkers;

  @override
  _CustomGaugeState createState() => _CustomGaugeState();

  const CustomGauge({
    Key? key,
    this.gaugeSize = 200,
    this.segments,
    this.minValue = 0,
    this.maxValue = 100,
    this.baselineValue,
    this.previousValue,
    this.currentValue,
    this.needleColor = Colors.black,
    this.valueWidget,
    this.showBaselineMarker = false,
    this.showPreviousMarker = false,
    this.showCurrentMarker = false,
    this.showMarkers = true,
  }) : super(key: key);
}

class _CustomGaugeState extends State<CustomGauge> {
  List<Widget> buildGauge(List<CustomGaugeSegment> segments) {
    List<CustomPaint> arcs = [];
    double cumulativeSegmentSize = 0.0;
    int gaugeSpread = widget.maxValue - widget.minValue;

    segments.reversed.forEach((segment) {
      arcs.add(
        CustomPaint(
          size: Size(widget.gaugeSize, widget.gaugeSize),
          painter: ArcPainter(
            startAngle: math.pi,
            sweepAngle:
                ((gaugeSpread - cumulativeSegmentSize) / gaugeSpread) * math.pi,
            color: segment.segmentColor,
          ),
        ),
      );
      cumulativeSegmentSize = cumulativeSegmentSize + segment.segmentSize;
    });

    return arcs;
  }

  @override
  Widget build(BuildContext context) {
    List<CustomGaugeSegment>? segments = widget.segments;
    int? localBaselineValue = widget.baselineValue;

    if (widget.baselineValue! < widget.minValue) {
      localBaselineValue = widget.minValue;
    }
    if (widget.baselineValue! > widget.maxValue) {
      localBaselineValue = widget.maxValue;
    }

    int? localPreviousValue = widget.previousValue;

    if (widget.previousValue! < widget.minValue) {
      localPreviousValue = widget.minValue;
    }
    if (widget.previousValue! > widget.maxValue) {
      localPreviousValue = widget.maxValue;
    }

    int? localCurrentValue = widget.currentValue;

    if (widget.currentValue! < widget.minValue) {
      localCurrentValue = widget.minValue;
    }
    if (widget.currentValue! > widget.maxValue) {
      localCurrentValue = widget.maxValue;
    }

    if (segments != null) {
      double totalSegmentSize = 0;
      segments.forEach((segment) {
        totalSegmentSize = totalSegmentSize + segment.segmentSize;
      });
      if (totalSegmentSize != (widget.maxValue - widget.minValue)) {
        throw Exception('Total segment size must equal (Max Size - Min Size)');
      }
    } else {
      segments = [
        CustomGaugeSegment('', (widget.maxValue - widget.minValue), Colors.grey)
      ];
    }

    return SizedBox(
      height: widget.gaugeSize,
      width: widget.gaugeSize,
      child: Stack(
        children: <Widget>[
          ...buildGauge(segments),
          widget.showMarkers
              ? CustomPaint(
                  size: Size(widget.gaugeSize, widget.gaugeSize),
                  painter: GaugeMarkerPainter(
                    '${widget.minValue}%',
                    Offset(widget.gaugeSize * -0.05, widget.gaugeSize * 0.45),
                    const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          widget.showMarkers
              ? CustomPaint(
                  size: Size(widget.gaugeSize, widget.gaugeSize),
                  painter: GaugeMarkerPainter(
                    '${widget.maxValue}%',
                    Offset(widget.gaugeSize * 0.97, widget.gaugeSize * 0.45),
                    const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          if (widget.showBaselineMarker)
            Container(
              height: widget.gaugeSize,
              width: widget.gaugeSize,
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: (math.pi / 2) +
                    ((localBaselineValue! - widget.minValue) /
                        (widget.maxValue - widget.minValue) *
                        math.pi),
                child: ClipPath(
                  clipper: GaugeNeedleClipper(),
                  child: Container(
                    width: widget.gaugeSize * 0.3,
                    height: widget.gaugeSize,
                    color: widget.needleColor,
                  ),
                ),
              ),
            ),
          if (widget.showPreviousMarker)
            Container(
              height: widget.gaugeSize,
              width: widget.gaugeSize,
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: (math.pi / 2) +
                    ((localPreviousValue! - widget.minValue) /
                        (widget.maxValue - widget.minValue) *
                        math.pi),
                child: ClipPath(
                  clipper: GaugeNeedleClipper(),
                  child: Container(
                    width: widget.gaugeSize * 0.3,
                    height: widget.gaugeSize,
                    color: widget.needleColor,
                  ),
                ),
              ),
            ),
          if (widget.showCurrentMarker)
            Container(
              height: widget.gaugeSize,
              width: widget.gaugeSize,
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: (math.pi / 2) +
                    ((localCurrentValue! - widget.minValue) /
                        (widget.maxValue - widget.minValue) *
                        math.pi),
                child: ClipPath(
                  clipper: GaugeNeedleClipper(),
                  child: Container(
                    width: widget.gaugeSize * 0.3,
                    height: widget.gaugeSize,
                    color: widget.needleColor,
                  ),
                ),
              ),
            ),
          Container(
            height: 240,
            width: widget.gaugeSize,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    widget.valueWidget ??
                        Text(
                          localBaselineValue.toString(),
                          style: Theme.of(context).textTheme.headline3,
                        ),
                    Column(
                      children: [
                        Text(
                          '%',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        const SizedBox(height: 8.0),
                      ],
                    ),
                  ],
                ),
                Text(
                  'x from previous',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            ),
          ),
          Positioned(
            top: 260,
            width: 200,
            right: 54,
            child: Center(
              child: Text(
                'Enter fields below',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
