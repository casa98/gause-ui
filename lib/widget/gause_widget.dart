import 'dart:math' as math;
import 'package:flutter/material.dart';

/// taken from [pretty_gauge] package
///
///Class that holds the details of each segment on a CustomGauge
class CustomGaugeSegment {
  final String segmentName;

  ///Name of the segment
  final int segmentSize;

  ///The size of the segment
  final Color segmentColor;

  ///The color of the segment

  CustomGaugeSegment(this.segmentName, this.segmentSize, this.segmentColor);
}

class GaugeNeedleClipper extends CustomClipper<Path> {
  //Note that x,y coordinate system starts at the bottom right of the canvas
  //with x moving from right to left and y moving from bottm to top
  //Bottom right is 0,0 and top left is x,y
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.7);
    path.lineTo(1.1 * size.width * 0.5, size.height * 0.7);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(0.9 * size.width * 0.5, size.height * 0.7);
    path.close();
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

///Customizable Gauge widget for Flutter
class CustomGauge extends StatefulWidget {
  final double gaugeSize;
  final List<CustomGaugeSegment>? segments;

  final int minValue;

  final int maxValue;

  final int? currentValue;

  ///Custom color for the needle on the Gauge. Defaults to Colors.black
  final Color needleColor;

  ///Widget that is used to show the current value on the Gauge. Defaults to show the current value as a Decimal with 1 digit
  ///If value must not be shown, supply Container()
  final Widget? valueWidget;

  ///Specify if you want to display Min and Max value on the Gauge widget
  final bool showMarkers;

  @override
  _CustomGaugeState createState() => _CustomGaugeState();

  const CustomGauge({
    Key? key,
    this.gaugeSize = 200,
    this.segments,
    this.minValue = 0,
    this.maxValue = 100,
    this.currentValue,
    this.needleColor = Colors.black,
    this.valueWidget,
    this.showMarkers = true,
  }) : super(key: key);
}

class _CustomGaugeState extends State<CustomGauge> {
  //This method builds out multiple arcs that make up the Gauge
  //using data supplied in the segments property
  List<Widget> buildGauge(List<CustomGaugeSegment> segments) {
    List<CustomPaint> arcs = [];
    double cumulativeSegmentSize = 0.0;
    int gaugeSpread = widget.maxValue - widget.minValue;

    //Iterate through the segments collection in reverse order
    //First paint the arc with the last segment color, then paint multiple arcs in sequence until we reach the first segment

    //Because all these arcs will be painted inside of a Stack, it will overlay to represent the eventual gauge with
    //multiple segments
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
    int? currentValue = widget.currentValue;
    int currentValueDecimalPlaces = 0;

    if (widget.currentValue! < widget.minValue) {
      currentValue = widget.minValue;
    }
    if (widget.currentValue! > widget.maxValue) {
      currentValue = widget.maxValue;
    }
    // Make sure the decimal place if supplied meets Darts bounds (0-20)
    if (currentValueDecimalPlaces < 0) {
      currentValueDecimalPlaces = 0;
    }
    if (currentValueDecimalPlaces > 20) {
      currentValueDecimalPlaces = 20;
    }

    //If segments is supplied, validate that the sum of all segment sizes = (maxValue - minValue)
    if (segments != null) {
      double totalSegmentSize = 0;
      segments.forEach((segment) {
        totalSegmentSize = totalSegmentSize + segment.segmentSize;
      });
      if (totalSegmentSize != (widget.maxValue - widget.minValue)) {
        throw Exception('Total segment size must equal (Max Size - Min Size)');
      }
    } else {
      //If no segments are supplied, default to one segment with default color
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
          Container(
            height: widget.gaugeSize,
            width: widget.gaugeSize,
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: (math.pi / 2) +
                  ((currentValue! - widget.minValue) /
                      (widget.maxValue - widget.minValue) *
                      math.pi),
              child: ClipPath(
                clipper: GaugeNeedleClipper(),
                child: Container(
                  width: widget.gaugeSize * 0.75,
                  height: widget.gaugeSize * 0.75,
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
                          currentValue.toString(),
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
