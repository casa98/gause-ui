import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gauge_ui/widget/custom_text_field.dart';

import '../widget/gause_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController baselineController;
  late final TextEditingController currentController;
  late final TextEditingController previousController;

  @override
  void initState() {
    super.initState();
    baselineController = TextEditingController();
    currentController = TextEditingController();
    previousController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: GestureDetector(
        onTap: () {
          final currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
        },
        child: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PercentGause',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  const SizedBox(height: 32.0),
                  CustomGauge(
                    gaugeSize: 310,
                    segments: [
                      CustomGaugeSegment('Low', 33, Colors.red),
                      CustomGaugeSegment('Medium', 34, Colors.orange),
                      CustomGaugeSegment('High', 33, Colors.green),
                    ],
                    baselineValue: baselineController.text.isEmpty
                        ? 0
                        : int.parse(baselineController.text),
                    showBaselineMarker: baselineController.text.isNotEmpty,
                    previousValue: previousController.text.isEmpty
                        ? 0
                        : int.parse(previousController.text),
                    showPreviousMarker: previousController.text.isNotEmpty,
                    currentValue: currentController.text.isEmpty
                        ? 0
                        : int.parse(currentController.text),
                    showCurrentMarker: currentController.text.isNotEmpty,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            helperText: 'Baseline',
                            controller: baselineController,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: CustomTextField(
                            helperText: 'Previous',
                            controller: previousController,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: CustomTextField(
                            helperText: 'Current',
                            controller: currentController,
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
