import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widget/custom_text_field.dart';
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

  int baselineValue = 0;
  int currentValue = 0;
  int previousValue = 0;
  bool usingTextfields = false;
  bool visible = false;

  @override
  void initState() {
    super.initState();
    baselineController = TextEditingController();
    currentController = TextEditingController();
    previousController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('Soft animation...'),
          duration: Duration(milliseconds: 2000),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // await Future.delayed(const Duration(milliseconds: 500));
      setState(() => visible = true);
    });
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
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0.0,
            // actions: [
            //   TextButton(
            //     onPressed: () {
            //       baselineController.clear();
            //       baselineValue = 0;
            //       previousController.clear();
            //       previousValue = 0;
            //       currentController.clear();
            //       currentValue = 0;
            //       selectedLabel = '';
            //       selectedValue = 0;

            //       setState(() => usingTextfields = !usingTextfields);
            //     },
            //     child: const Text('Switch Mode'),
            //   ),
            // ],
          ),
          body: AnimatedOpacity(
            opacity: visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 2000),
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
                    gaugeSize: 334,
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
                    usingTextfields: usingTextfields,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: usingTextfields
                        ? Row(
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
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Baseline',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              Slider.adaptive(
                                value: baselineValue.toDouble(),
                                onChanged: (value) {
                                  setState(() => baselineValue = value.toInt());
                                  baselineController.text =
                                      value.toInt().toString();
                                },
                                min: 0,
                                max: 100,
                                divisions: 101,
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Previous',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              Slider.adaptive(
                                value: previousValue.toDouble(),
                                onChanged: (value) {
                                  setState(() => previousValue = value.toInt());
                                  previousController.text =
                                      value.toInt().toString();
                                },
                                min: 0,
                                max: 100,
                                divisions: 101,
                              ),
                              const SizedBox(height: 8.0),
                              subtitleWidget(context),
                              Slider.adaptive(
                                value: currentValue.toDouble(),
                                onChanged: (value) {
                                  setState(() => currentValue = value.toInt());
                                  currentController.text =
                                      value.toInt().toString();
                                },
                                min: 0,
                                max: 100,
                                divisions: 101,
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

  Text subtitleWidget(BuildContext context) {
    return Text(
      'Current',
      style: Theme.of(context).textTheme.subtitle1,
    );
  }
}
