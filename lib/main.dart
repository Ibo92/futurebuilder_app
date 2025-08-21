import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: FutureBuilderDemo());
  }
}

class FutureBuilderDemo extends StatefulWidget {
  const FutureBuilderDemo({super.key});

  @override
  State<FutureBuilderDemo> createState() => _FutureBuilderDemoState();
}

class _FutureBuilderDemoState extends State<FutureBuilderDemo> {
  late Future<int> _future;
  bool _fail = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _future = _load(fail: _fail);
    //timer
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        _future = _load(fail: _fail);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<int> _load({required bool fail}) async {
    await Future.delayed(const Duration(seconds: 1));
    if (fail) throw Exception("Fehler mit Absicht ausgelöst");
    return 42 + Random().nextInt(58);
  }

  void _reload() {
    setState(() {
      _future = _load(fail: _fail);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Future Nummer Test")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text("Fehler Simulieren"),
                Switch(
                  value: _fail,
                  onChanged: (v) => setState(() => _fail = v),
                ),
                const Spacer(),
                ElevatedButton(onPressed: _reload, child: Text("Reload")),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Center(
                  child: FutureBuilder<int>(
                    future: _future,
                    builder: (context, snapshot) {
                      // Lade Zustand
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text("Lädt..."),
                          ],
                        );
                      }
                      // Fehler Zustand
                      if (snapshot.hasError) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 32,
                            ),
                            SizedBox(height: 12),
                            Text("Fehler: ${snapshot.error}"),
                          ],
                        );
                      }

                      // Erfolgs Zustand
                      if (snapshot.hasData) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                              size: 32,
                            ),
                            SizedBox(height: 12),
                            Text("Ergebnis: ${snapshot.data}"),
                          ],
                        );
                      }

                      //Kein Ergebnis
                      return const Text("Kein Ergebnis");
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
