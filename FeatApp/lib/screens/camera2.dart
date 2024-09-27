import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:feat/main.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key, required this.camera});

  final CameraDescription? camera;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  void initState() {
    super.initState();
    //_controller = CameraController(widget.camera, ResolutionPreset.high);
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
