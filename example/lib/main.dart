import 'dart:developer';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:hprt_label/hprt_label.dart';
import 'package:hprt_label/model/hprt_image_to_print.dart';
import 'package:hprt_label/model/hprt_ip_address.dart';
import 'package:hprt_label/model/hprt_paper_size.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HPRT Label Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LabelExampleHome(),
    );
  }
}

class DraggableTextElement {
  String id;
  String text;
  Offset position;
  double fontSize;
  bool isBold;

  DraggableTextElement({
    required this.id,
    required this.text,
    this.position = Offset.zero,
    this.fontSize = 20,
    this.isBold = false,
  });
}

class LabelExampleHome extends StatefulWidget {
  const LabelExampleHome({super.key});

  @override
  State<LabelExampleHome> createState() => _LabelExampleHomeState();
}

class _LabelExampleHomeState extends State<LabelExampleHome> {
  final _hprtLabelPlugin = HprtLabel();
  final GlobalKey _repaintKey = GlobalKey();

  final TextEditingController _ipController = TextEditingController(text: '192.168.1.100');
  final TextEditingController _widthController = TextEditingController(text: '52');
  final TextEditingController _heightController = TextEditingController(text: '23');
  
  final TextEditingController _textEditorController = TextEditingController();

  final List<DraggableTextElement> _elements = List.empty(growable: true);
  String? _selectedElementId;

  String _paperUnit = 'mm';
  double _paperWidthPx = 416; // 52 * 8
  double _paperHeightPx = 184; // 23 * 8

  @override
  void dispose() {
    _ipController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _textEditorController.dispose();
    super.dispose();
  }

  Future<void> _connectIp() async {
    try {
      final res = await _hprtLabelPlugin.connectIp(HPRTIpAddress(ipAddress: _ipController.text));
      _showSnack('Connect IP Result: $res');
    } catch (e) {
      _showSnack('Error: $e');
    }
  }

  Future<void> _connectUsb() async {
    try {
      await _hprtLabelPlugin.requestUsbPermission();
      final res = await _hprtLabelPlugin.connectUsb();
      _showSnack('Connect USB Result: $res');
    } catch (e) {
      _showSnack('Error: $e');
    }
  }

  Future<void> _setPaperSize() async {
    final wVal = double.tryParse(_widthController.text) ?? 52;
    final hVal = double.tryParse(_heightController.text) ?? 23;
    
    double physicalW = wVal;
    double physicalH = hVal;
    double pixelW = wVal;
    double pixelH = hVal;

    if (_paperUnit == 'mm') {
      physicalW = wVal;
      physicalH = hVal;
      pixelW = wVal * 8;
      pixelH = hVal * 8;
    } else if (_paperUnit == 'cm') {
      physicalW = wVal * 10;
      physicalH = hVal * 10;
      pixelW = wVal * 80;
      pixelH = hVal * 80;
    } else if (_paperUnit == 'px') {
      physicalW = wVal / 8;
      physicalH = hVal / 8;
      pixelW = wVal;
      pixelH = hVal;
    }
    
    setState(() {
      _paperWidthPx = pixelW;
      _paperHeightPx = pixelH;
    });
    
    try {
      // Plugin needs the physical dimensions (in mm)
      final res = await _hprtLabelPlugin.setPaperSize(
        HPRTPaperSize(size: Size(physicalW, physicalH)),
      );
      _showSnack('Set Paper Size Result: $res');
    } catch (e) {
      _showSnack('Error: $e');
    }
  }

  void _addTextElement() {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _elements.add(DraggableTextElement(
        id: newId,
        text: 'New Text',
        position: const Offset(10, 10),
      ));
      _selectedElementId = newId;
      _textEditorController.text = 'New Text';
    });
  }

  void _deleteSelected() {
    if (_selectedElementId != null) {
      setState(() {
        _elements.removeWhere((e) => e.id == _selectedElementId);
        _selectedElementId = null;
        _textEditorController.text = '';
      });
    }
  }

  DraggableTextElement? get _selectedElement {
    try {
      return _elements.firstWhere((e) => e.id == _selectedElementId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _printLabel() async {
    // Deselect to hide borders during capture
    setState(() {
      _selectedElementId = null;
    });
    // Wait a frame for UI to update (border gone)
    await Future.delayed(const Duration(milliseconds: 50));
    
    try {
      // Capture RepaintBoundary
      RenderRepaintBoundary boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final res = await _hprtLabelPlugin.printImage(HPRTImageToPrint(image: byteData));
        _showSnack('Print Result: $res');
      } else {
        _showSnack('Failed to capture image.');
      }
    } catch (e) {
      _showSnack('Print Error: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HPRT Label Example'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection Section
              const Text('Connection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ipController,
                      decoration: const InputDecoration(labelText: 'IP Address'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _connectIp, child: const Text('Connect IP')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _connectUsb, child: const Text('Connect USB')),
                ],
              ),
              const Divider(height: 32),

              // Settings Section
              const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _widthController,
                      decoration: const InputDecoration(labelText: 'Paper Width'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      decoration: const InputDecoration(labelText: 'Paper Height'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _paperUnit,
                    items: const [
                      DropdownMenuItem(value: 'px', child: Text('px')),
                      DropdownMenuItem(value: 'mm', child: Text('mm')),
                      DropdownMenuItem(value: 'cm', child: Text('cm')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _paperUnit = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _setPaperSize, child: const Text('Set Size')),
                ],
              ),
              const Divider(height: 32),

              // Canvas Tools Section
              const Text('Canvas Tools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  ElevatedButton(onPressed: _addTextElement, child: const Text('Add Text')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _selectedElementId == null ? null : _deleteSelected,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Delete Selected', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              if (_selectedElement != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textEditorController,
                        decoration: const InputDecoration(labelText: 'Edit Text'),
                        onChanged: (val) {
                          setState(() {
                            _selectedElement!.text = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Checkbox(
                      value: _selectedElement!.isBold,
                      onChanged: (val) {
                        setState(() {
                          _selectedElement!.isBold = val ?? false;
                        });
                      },
                    ),
                    const Text('Bold'),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        initialValue: _selectedElement!.fontSize.toString(),
                        decoration: const InputDecoration(labelText: 'Size'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() {
                            _selectedElement!.fontSize = double.tryParse(val) ?? 20;
                          });
                        },
                      ),
                    )
                  ],
                ),
              ],
              const Divider(height: 32),

              // Canvas and Print
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Label Canvas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: _printLabel,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Print Label', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // The Canvas Container
              Center(
                child: Container(
                  width: _paperWidthPx,
                  height: _paperHeightPx,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 2)
                    ],
                  ),
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: Container(
                      width: _paperWidthPx,
                      height: _paperHeightPx,
                      color: Colors.white, // Ensure white background for print
                      child: Stack(
                        children: _elements.map((e) {
                          final isSelected = e.id == _selectedElementId;
                          return Positioned(
                            left: e.position.dx,
                            top: e.position.dy,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedElementId = e.id;
                                  _textEditorController.text = e.text;
                                });
                              },
                              onPanUpdate: (details) {
                                setState(() {
                                  e.position += details.delta;
                                  // Select on drag
                                  if (!isSelected) {
                                    _selectedElementId = e.id;
                                    _textEditorController.text = e.text;
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: isSelected ? Border.all(color: Colors.blue, width: 1, style: BorderStyle.solid) : null,
                                ),
                                padding: const EdgeInsets.all(2),
                                child: Text(
                                  e.text,
                                  style: TextStyle(
                                    fontSize: e.fontSize,
                                    fontWeight: e.isBold ? FontWeight.bold : FontWeight.normal,
                                    color: Colors.black, // Print should be black
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
