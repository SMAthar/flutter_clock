// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

enum _Element {
  background,
  text,
  circleFill,
}

final _lightTheme = {
  _Element.background: Colors.white,
  _Element.text: Colors.black,
  _Element.circleFill: Colors.green,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.circleFill: Colors.teal
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final day = DateFormat('EEEEEEEEEE').format(_dateTime);
    final month = DateFormat('MMMM').format(_dateTime);
    final date = DateFormat('dd').format(_dateTime);
    final ampm = DateFormat('a').format(_dateTime);

    final fontSize = MediaQuery.of(context).size.width / 15;
    final radius = MediaQuery.of(context).size.width * 0.40;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontSize: fontSize,
      fontFamily: "Roboto"
    );

    return Container(
      color: colors[_Element.background],
      child: Center(
        child: DefaultTextStyle(
          style: defaultStyle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    day,
                    style: TextStyle(
                        fontSize: fontSize * 0.85, fontWeight: FontWeight.w100),
                  ),
                  Text(
                    month + " " + date,
                  ),
                ],
              ),
              SizedBox(
                width: 20,
              ),
              CircularPercentIndicator(
                radius: radius,
                backgroundColor: colors[_Element.background],
                progressColor: colors[_Element.circleFill],
                percent:
                    int.parse(hour) / (widget.model.is24HourFormat ? 24 : 12),
                lineWidth: 2,
                circularStrokeCap: CircularStrokeCap.round,
                center: CircularPercentIndicator(
                  radius: radius * 0.9,
                  lineWidth: 10,
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: colors[_Element.background],
                  progressColor: colors[_Element.circleFill],
                  percent: int.parse(minute) / 60,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        hour + ":" + minute,
                        style: TextStyle(fontSize: fontSize * 1.5),
                      ),
                      widget.model.is24HourFormat
                          ? Container()
                          : Text(
                              ampm,
                              style: TextStyle(fontSize: fontSize * 0.30),
                            )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
