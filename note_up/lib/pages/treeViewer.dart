import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:saver_gallery/saver_gallery.dart';

class TreeViewer extends StatefulWidget {
  const TreeViewer({super.key});

  @override
  State<TreeViewer> createState() => _TreeViewerState();
}

class Node {
  Node? parent;
  String? nodeData;
  List<Node> children;
  bool isExpanded;
  Color branchColor;
  int depth; // Track node depth in the tree

  Node({
    this.parent,
    this.nodeData,
    List<Node>? children,
    this.isExpanded = true,
    Color? branchColor,
    int? depth,
  }) :
        children = children ?? [],
        branchColor = branchColor ?? Colors.blue,
        depth = depth ?? 0;
}

class _TreeViewerState extends State<TreeViewer> {
  late Node rootNode;
  final GlobalKey _globalKey = GlobalKey();
  Color backgroundColor = Colors.white;
  Color textColor = Colors.black87;
  int colorIndex = 0;

  // Branch colors
  final List<Color> branchColors = [
    const Color(0xFF4285F4), // Blue
    const Color(0xFFDB4437), // Red
    const Color(0xFFF4B400), // Yellow
    const Color(0xFF0F9D58), // Green
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFFF9800), // Orange
    const Color(0xFF795548), // Brown
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFE91E63), // Pink
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFF8BC34A), // Light Green
    const Color(0xFF9E9E9E), // Grey
  ];

  // Get a new color from the palette
  Color _getNextColor() {
    Color color = branchColors[colorIndex % branchColors.length];
    colorIndex++;
    return color;
  }

  @override
  void initState() {
    super.initState();
    rootNode = Node(nodeData: "Root Topic", branchColor: branchColors[0], depth: 0);
    _createSampleTree();
  }

  void _createSampleTree() {
    // Create sample branches with different colors based on their depth level
    for (int i = 0; i < 4; i++) {
      final mainBranch = Node(
          nodeData: "Main Branch ${i+1}",
          parent: rootNode,
          branchColor: branchColors[1], // Level 1 color
          depth: 1
      );
      rootNode.children.add(mainBranch);

      // Add sub-branches
      for (int j = 0; j < 2 + i % 3; j++) {
        final subBranch = Node(
            nodeData: "Sub-topic ${i+1}.${j+1}",
            parent: mainBranch,
            branchColor: branchColors[2], // Level 2 color
            depth: 2
        );
        mainBranch.children.add(subBranch);

        // Add leaf nodes to some sub-branches
        if (j % 2 == 0 || i % 2 == 1) {
          for (int k = 0; k < 1 + j % 3; k++) {
            subBranch.children.add(Node(
                nodeData: "Detail ${i+1}.${j+1}.${k+1}",
                parent: subBranch,
                branchColor: branchColors[3], // Level 3 color
                depth: 3
            ));
          }
        }
      }
    }
  }

  void _showEditDialog(
      BuildContext context,
      String initialValue,
      Function(String) onSave,
      ) {
    final TextEditingController controller = TextEditingController(
      text: initialValue,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Edit Topic',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter topic name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  void _addChildTo(Node node) {
    // Set color based on the depth level of the node
    int childDepth = node.depth + 1;
    Color childColor = branchColors[childDepth % branchColors.length];

    final newNode = Node(
        nodeData: "New Topic",
        parent: node,
        branchColor: childColor,
        depth: childDepth
    );

    node.children.add(newNode);
    if (!node.isExpanded) {
      node.isExpanded = true; // Auto-expand when adding child
    }
    setState(() {});
  }

  void _deleteNode(Node node) {
    if (node == rootNode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete the root topic'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Node? parent = node.parent;
    if (parent != null) {
      parent.children.remove(node);
      setState(() {});
    }
  }

  void _toggleExpand(Node node) {
    setState(() {
      node.isExpanded = !node.isExpanded;
    });
  }

  Future<void> _captureAndSaveImage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Capturing mind map...'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      RenderRepaintBoundary boundary =
      _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        await SaverGallery.saveImage(
          pngBytes,
          fileName: 'mind_map_${DateTime.now().millisecondsSinceEpoch}',
          skipIfExists: false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mind map saved to gallery'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildFlowingMindMap(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Root node
          _buildRootNode(rootNode),

          // Space between root and branches
          const SizedBox(width: 30),

          // Main branches flowing from root
          _buildBranches(rootNode),
        ],
      ),
    );
  }

  Widget _buildRootNode(Node node) {
    return GestureDetector(
      onTap: () {
        _showEditDialog(
          context,
          node.nodeData ?? '',
              (newValue) => setState(() => node.nodeData = newValue),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: node.branchColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              node.nodeData ?? 'Root Topic',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.add_circle, color: Colors.white),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 24, minHeight: 24),
              iconSize: 20,
              onPressed: () => _addChildTo(node),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranches(Node parentNode) {
    if (parentNode.children.isEmpty || !parentNode.isExpanded) {
      return const SizedBox();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < parentNode.children.length; i++)
          _buildBranchConnection(parentNode.children[i],
              isFirst: i == 0,
              isLast: i == parentNode.children.length - 1,
              totalBranches: parentNode.children.length),
      ],
    );
  }

  Widget _buildBranchConnection(Node node, {required bool isFirst, required bool isLast, required int totalBranches}) {
    // Calculate curve parameters
    final double verticalPadding = 25.0;
    final double curveHeight = 80.0 * (isFirst || isLast ? 1.2 : 1.0);

    // Calculate vertical spacing based on position
    double topPadding = isFirst ? 0 : verticalPadding / 2;
    double bottomPadding = isLast ? 0 : verticalPadding / 2;

    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Curved connector line - improved to connect perfectly
            CustomPaint(
              size: Size(60, curveHeight),
              painter: ImprovedCurvedLinePainter(
                color: node.branchColor,
                isFirst: isFirst,
                isLast: isLast,
                totalBranches: totalBranches,
              ),
            ),

            // Branch node
            _buildBranchNode(node),

            // Sub-branches if any
            if (node.children.isNotEmpty && node.isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: _buildBranches(node),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchNode(Node node) {
    return GestureDetector(
      onTap: () {
        if (node.children.isNotEmpty) {
          _toggleExpand(node);
        } else {
          _showEditDialog(
            context,
            node.nodeData ?? '',
                (newValue) => setState(() => node.nodeData = newValue),
          );
        }
      },
      onLongPress: () {
        _showEditDialog(
          context,
          node.nodeData ?? '',
              (newValue) => setState(() => node.nodeData = newValue),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          minWidth: 100,
          maxWidth: 200,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: node.branchColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (node.children.isNotEmpty)
              GestureDetector(
                onTap: () => _toggleExpand(node),
                child: Icon(
                  node.isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                  color: node.branchColor,
                  size: 20,
                ),
              ),

            Flexible(
              child: Text(
                node.nodeData ?? 'Topic',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add button
                InkWell(
                  onTap: () => _addChildTo(node),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: node.branchColor,
                    ),
                  ),
                ),

                // Delete button (not for root)
                if (node != rootNode)
                  InkWell(
                    onTap: () => _deleteNode(node),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.red.shade300,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Mind Map Flow"),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Choose Color Theme', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ListTile(
                          title: Text('Classic Theme'),
                          leading: Icon(Icons.palette, color: branchColors[0]),
                          onTap: () {
                            setState(() {
                              branchColors[0] = const Color(0xFF4285F4); // Blue
                              branchColors[1] = const Color(0xFFDB4437); // Red
                              branchColors[2] = const Color(0xFFF4B400); // Yellow
                              branchColors[3] = const Color(0xFF0F9D58); // Green
                              _updateNodeColors(rootNode);
                            });
                            Navigator.of(ctx).pop();
                          },
                        ),
                        ListTile(
                          title: Text('Ocean Theme'),
                          leading: Icon(Icons.palette, color: Colors.blue),
                          onTap: () {
                            setState(() {
                              branchColors[0] = const Color(0xFF01579B); // Dark Blue
                              branchColors[1] = const Color(0xFF0288D1); // Medium Blue
                              branchColors[2] = const Color(0xFF4FC3F7); // Light Blue
                              branchColors[3] = const Color(0xFF80DEEA); // Cyan
                              _updateNodeColors(rootNode);
                            });
                            Navigator.of(ctx).pop();
                          },
                        ),
                        ListTile(
                          title: Text('Forest Theme'),
                          leading: Icon(Icons.palette, color: Colors.green),
                          onTap: () {
                            setState(() {
                              branchColors[0] = const Color(0xFF1B5E20); // Dark Green
                              branchColors[1] = const Color(0xFF388E3C); // Medium Green
                              branchColors[2] = const Color(0xFF81C784); // Light Green
                              branchColors[3] = const Color(0xFFC5E1A5); // Lime
                              _updateNodeColors(rootNode);
                            });
                            Navigator.of(ctx).pop();
                          },
                        ),
                        ListTile(
                          title: Text('Sunset Theme'),
                          leading: Icon(Icons.palette, color: Colors.orange),
                          onTap: () {
                            setState(() {
                              branchColors[0] = const Color(0xFFE65100); // Orange
                              branchColors[1] = const Color(0xFFF57C00); // Light Orange
                              branchColors[2] = const Color(0xFFFFB74D); // Amber
                              branchColors[3] = const Color(0xFFFFE082); // Light Amber
                              _updateNodeColors(rootNode);
                            });
                            Navigator.of(ctx).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('Cancel'),
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            tooltip: 'Change color theme',
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('How to use', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• Tap on a topic to edit or toggle expand'),
                      SizedBox(height: 6),
                      Text('• Long press on topic to edit directly'),
                      SizedBox(height: 6),
                      Text('• Use + to add new branches'),
                      SizedBox(height: 6),
                      Text('• Use × to delete topics'),
                      SizedBox(height: 6),
                      Text('• Colors are based on node levels'),
                      SizedBox(height: 6),
                      Text('• Use color palette to change theme'),
                      SizedBox(height: 6),
                      Text('• Use camera button to save the diagram'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('Got it'),
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: RepaintBoundary(
            key: _globalKey,
            child: Container(
              color: backgroundColor,
              padding: const EdgeInsets.all(20),
              child: _buildFlowingMindMap(context),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureAndSaveImage,
        backgroundColor: Colors.indigo,
        elevation: 4,
        child: const Icon(Icons.camera_alt),
        tooltip: 'Save mind map as image',
      ),
    );
  }

  // Helper method to update node colors based on their depth
  void _updateNodeColors(Node node) {
    node.branchColor = branchColors[node.depth % branchColors.length];
    for (var child in node.children) {
      _updateNodeColors(child);
    }
  }
}

// Improved curved line painter that connects perfectly with nodes
class ImprovedCurvedLinePainter extends CustomPainter {
  final Color color;
  final bool isFirst;
  final bool isLast;
  final int totalBranches;

  ImprovedCurvedLinePainter({
    required this.color,
    required this.isFirst,
    required this.isLast,
    required this.totalBranches,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Calculate curve parameters
    final double startX = 0;
    final double endX = size.width;
    final double midX = size.width * 0.5;

    // Calculate centerY - this is the point where nodes connect
    final double centerY = size.height / 2;

    // Adjust vertical position based on branch position
    double startY, endY;
    if (totalBranches == 1) {
      // Single branch - straight horizontal line
      startY = centerY;
      endY = centerY;
    } else if (isFirst) {
      // First branch curves up
      startY = centerY - size.height * 0.2;
      endY = centerY;
    } else if (isLast) {
      // Last branch curves down
      startY = centerY + size.height * 0.2;
      endY = centerY;
    } else {
      // Middle branches - slight curve based on position
      double position = (totalBranches > 2) ?
      0.4 + (0.2 / (totalBranches - 2)) : 0.5;
      startY = centerY;
      endY = centerY;
    }

    // Draw the curved path - make sure it starts and ends exactly at centerY
    path.moveTo(startX, centerY);

    // Use quadratic bezier for smoother curves that connect precisely
    path.quadraticBezierTo(
        midX, startY,
        endX, centerY
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ImprovedCurvedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isFirst != isFirst ||
        oldDelegate.isLast != isLast ||
        oldDelegate.totalBranches != totalBranches;
  }
}