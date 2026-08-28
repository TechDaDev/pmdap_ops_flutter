import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pmdap_operations/core/widgets.dart';
import 'package:pmdap_operations/providers.dart';

class PrivateImageScreen extends ConsumerStatefulWidget {
  const PrivateImageScreen({
    super.key,
    required this.documentId,
    required this.initialSide,
  });
  final String documentId;
  final String initialSide;

  @override
  ConsumerState<PrivateImageScreen> createState() => _PrivateImageScreenState();
}

class _PrivateImageScreenState extends ConsumerState<PrivateImageScreen> {
  Uint8List? _bytes;
  MemoryImage? _provider;
  Object? _error;
  bool _loading = true;
  late String _side;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _side = widget.initialSide == 'back' ? 'back' : 'front';
    _load();
  }

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    final side = _side;
    _clearBytes();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(opsRepositoryProvider)
          .identityImage(widget.documentId, side);
      if (!mounted || generation != _loadGeneration) {
        result.bytes.fillRange(0, result.bytes.length, 0);
        return;
      }
      setState(() {
        _bytes = result.bytes;
        _provider = MemoryImage(result.bytes);
        _loading = false;
      });
    } catch (error) {
      if (mounted && generation == _loadGeneration) {
        setState(() {
          _error = error;
          _loading = false;
        });
      }
    }
  }

  void _clearBytes() {
    final provider = _provider;
    if (provider != null) provider.evict();
    _bytes?.fillRange(0, _bytes!.length, 0);
    _bytes = null;
    _provider = null;
  }

  @override
  void dispose() {
    _loadGeneration++;
    _clearBytes();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_side == 'front' ? context.l10n.front : context.l10n.back),
      actions: [
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'front', label: Text(context.l10n.front)),
            ButtonSegment(value: 'back', label: Text(context.l10n.back)),
          ],
          selected: {_side},
          onSelectionChanged: (value) {
            _side = value.first;
            _load();
          },
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? ErrorPane(onRetry: _load)
        : Semantics(
            label: context.l10n.imageSemantics(
              _side == 'front' ? context.l10n.front : context.l10n.back,
            ),
            image: true,
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 5,
              boundaryMargin: const EdgeInsets.all(80),
              child: Center(
                child: Image(
                  image: _provider!,
                  fit: BoxFit.contain,
                  gaplessPlayback: false,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
  );
}
