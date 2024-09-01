// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SpinWheelScreen(),
    );
  }
}

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  _SpinWheelScreenState createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen> {
  final player = AudioPlayer(); // For playing sound
  final StreamController<int> selected = StreamController<int>();
  final items = <String>[
    'Grogu',
    'Mace Windu',
    'Obi-Wan Kenobi',
    'Han Solo',
    'Luke Skywalker',
    'Darth Vader',
    'Yoda',
    'Ahsoka Tano',
  ];

  int selectedIndex = -1; // To store the selected index

  @override
  void initState() {
    _loadSound();
    super.initState();
  }

  // Load the spin sound
  Future<void> _loadSound() async {
    await player.setAsset('assets/audio/effect-wow.mp3');
  }

  @override
  void dispose() {
    selected.close();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spin the Wheel Fortune'),
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            selected.add(
              Fortune.randomInt(0, items.length),
            );
          });
        },
        child: Column(
          children: [
            Expanded(
              child: FortuneWheel(
                animateFirst: false,
                selected: selected.stream,
                onAnimationStart: () {
                  stopSound();
                },
                onAnimationEnd: () {
                  _playSound();

                  // Get the selected index from the stream and retrieve the item
                  selected.stream.first.then((index) {
                    setState(() {
                      selectedIndex = index;
                      _showSelectedItem(); // Display or use the selected item
                    });
                  });
                },
                items: [
                  for (var it in items) FortuneItem(child: Text(it)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Play the spin sound
  Future<void> _playSound() async {
    await player.seek(Duration.zero); // Reset to the beginning of the sound

    await player.play();
  }

  // Play the spin sound
  Future<void> stopSound() async {
    await player.stop();
  }

  // Show the selected item
  void _showSelectedItem() {
    if (selectedIndex != -1) {
      final selectedItem = items[selectedIndex];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected: $selectedItem')),
      );
    }
  }
}
