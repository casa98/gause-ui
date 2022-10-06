import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'arc_painter.dart';
import 'marker_painter.dart';

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
        Rect.fromPoints(
          Offset(size.width / 2 - 2, size.height / 1.175),
          Offset(size.width / 2 + 2, size.height * .945),
        ),
      )
      ..close();

    return path;
  }

  @override
  bool shouldReclip(GaugeNeedleClipper oldClipper) => false;
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

    for (var segment in segments.reversed) {
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
    }

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
      for (var segment in segments) {
        totalSegmentSize = totalSegmentSize + segment.segmentSize;
      }
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
          if (widget.showMarkers)
            CustomPaint(
              size: Size(widget.gaugeSize, widget.gaugeSize),
              painter: GaugeMarkerPainter(
                '${widget.minValue}%',
                Offset(widget.gaugeSize * -0.02, widget.gaugeSize * 0.45),
                const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
            ),
          if (widget.showMarkers)
            CustomPaint(
              size: Size(widget.gaugeSize, widget.gaugeSize),
              painter: GaugeMarkerPainter(
                '${widget.maxValue}%',
                Offset(widget.gaugeSize * 0.95, widget.gaugeSize * 0.45),
                const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
            ),
          if (widget.showBaselineMarker) markerWidget(localBaselineValue),
          if (widget.showBaselineMarker)
            legendWidget(label: 'Baseline', localValue: localBaselineValue),
          if (widget.showPreviousMarker) markerWidget(localPreviousValue),
          if (widget.showPreviousMarker)
            legendWidget(label: 'Previous', localValue: localPreviousValue),
          if (widget.showCurrentMarker) markerWidget(localCurrentValue),
          if (widget.showCurrentMarker)
            legendWidget(label: 'Current', localValue: localCurrentValue),
          Container(
            height: 260,
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
            right: 64,
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

  Container markerWidget(int? localValue) {
    return Container(
      height: widget.gaugeSize,
      width: widget.gaugeSize,
      alignment: Alignment.center,
      child: Transform.rotate(
        angle: (math.pi / 2) +
            ((localValue! - widget.minValue) /
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
    );
  }

  Container legendWidget({required String label, int? localValue}) {
    return Container(
      height: widget.gaugeSize,
      width: widget.gaugeSize,
      alignment: Alignment.center,
      child: Transform.rotate(
        angle: (3 * math.pi / 2) +
            ((localValue! - widget.minValue) /
                (widget.maxValue - widget.minValue) *
                math.pi),
        child: Column(
          children: [
            Text('$label: $localValue%'),
          ],
        ),
      ),
    );
  }
}
