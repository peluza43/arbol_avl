import 'package:flutter/material.dart';

void main() {
  runApp(AVLTreeApp());
}

// Clase principal que configura la aplicación Flutter
class AVLTreeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AVL',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AVLTreeScreen(),
    );
  }
}

// Pantalla principal que muestra el árbol AVL y las opciones de interacción
class AVLTreeScreen extends StatefulWidget {
  @override
  _AVLTreeScreenState createState() => _AVLTreeScreenState();
}

class _AVLTreeScreenState extends State<AVLTreeScreen> {
  TextEditingController _controller = TextEditingController();
  String _input = '';
  AVLNode? _root;
  TreePainter? _treePainter;
  List<int>? _traversalResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arbol AVL'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20.0),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Visualización del árbol',
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20.0),
                  CustomPaint(
                    size: Size(300, 300),
                    painter: _treePainter ?? TreePainter(null),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Ingresar datos',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _input = value;
                });
              },
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _buildAVLTree,
                      child: Text('Ingresar'),
                    ),
                    SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: _root != null ? () => _updateTreeTraversal(_root!.postOrderTraversal) : null,
                      child: Text('Post-order'),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _root != null ? () => _updateTreeTraversal(_root!.inOrderTraversal) : null,
                  child: Text('In-order'),
                ),
                ElevatedButton(
                  onPressed: _root != null ? () => _updateTreeTraversal(_root!.preOrderTraversal) : null,
                  child: Text('Pre-order'),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _deleteValue,
                  child: Text('Eliminar Valor'),
                ),
                ElevatedButton(
                  onPressed: _modifyValue,
                  child: Text('Modificar Valor'),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Text(
              'Para modificar un valor (valor actual, valor nuevo) y luego toque el botón "Modificar Valor".',
              style: TextStyle(fontSize: 14.0),
            ),
            SizedBox(height: 20.0),
            if (_traversalResult != null) ...[
              Text(
                'Resultado del recorrido: ${_traversalResult!.join(", ")}',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Construye el árbol AVL a partir de los valores ingresados
  void _buildAVLTree() {
    if (_input.isEmpty) return;

    List<int> values = _input.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList();
    for (int value in values) {
      if (_root == null) {
        _root = AVLNode(value);
      } else {
        _root = _root!.insert(value);
      }
    }
    setState(() {
      _treePainter = TreePainter(_root);
      _traversalResult = null;
    });
  }

  // Actualiza la visualización del recorrido del árbol
  void _updateTreeTraversal(List<int> Function() traversal) {
    if (_root != null) {
      setState(() {
        _traversalResult = traversal();
      });
    }
  }

  // Elimina un valor del árbol
  void _deleteValue() {
    if (_input.isEmpty) return;

    int valueToDelete = int.tryParse(_input.trim()) ?? 0;

    if (_root != null) {
      setState(() {
        _root = _deleteNode(_root, valueToDelete);
        _treePainter = TreePainter(_root);
        _traversalResult = null;
      });
    }
  }

  // Función auxiliar para eliminar un nodo del árbol
  AVLNode? _deleteNode(AVLNode? root, int valueToDelete) {
    if (root == null) return root;

    if (valueToDelete < root.value) {
      root.leftChild = _deleteNode(root.leftChild, valueToDelete);
    } else if (valueToDelete > root.value) {
      root.rightChild = _deleteNode(root.rightChild, valueToDelete);
    } else {
      if (root.leftChild == null) {
        return root.rightChild;
      } else if (root.rightChild == null) {
        return root.leftChild;
      }

      root.value = _minValue(root.rightChild!);
      root.rightChild = _deleteNode(root.rightChild, root.value);
    }

    root.height = 1 + _max(_getHeight(root.leftChild), _getHeight(root.rightChild));

    int balance = _getBalance(root);

    if (balance > 1 && _getBalance(root.leftChild) >= 0) {
      return _rotateRight(root)!;
    }

    if (balance > 1 && _getBalance(root.leftChild) < 0) {
      if (root.leftChild != null) {
        root.leftChild = _rotateLeft(root.leftChild!);
      }
      return _rotateRight(root)!;
    }

    if (balance < -1 && _getBalance(root.rightChild) <= 0) {
      return _rotateLeft(root)!;
    }

    if (balance < -1 && _getBalance(root.rightChild) > 0) {
      if (root.rightChild != null) {
        root.rightChild = _rotateRight(root.rightChild!);
      }
      return _rotateLeft(root)!;
    }

    return root;
  }

  // Encuentra el valor mínimo en el subárbol
  int _minValue(AVLNode node) {
    int minValue = node.value;
    while (node.leftChild != null) {
      minValue = node.leftChild!.value;
      node = node.leftChild!;
    }
    return minValue;
  }

  // Modifica un valor en el árbol
  void _modifyValue() {
    if (_input.isEmpty) return;

    List<int> values = _input.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList();
    if (values.length != 2) return;

    int oldValue = values[0];
    int newValue = values[1];

    if (_root != null) {
      setState(() {
        _root = _deleteNode(_root, oldValue);
        _root = _root!.insert(newValue);
        _treePainter = TreePainter(_root);
        _traversalResult = null;
      });
    }
  }

  int _max(int a, int b) {
    return (a > b) ? a : b;
  }

  int _getHeight(AVLNode? node) {
    if (node == null) return 0;
    return node.height;
  }

  int _getBalance(AVLNode? node) {
    if (node == null) return 0;
    return _getHeight(node.leftChild) - _getHeight(node.rightChild);
  }

  AVLNode? _rotateRight(AVLNode y) {
    if (y.leftChild == null) return null;

    AVLNode x = y.leftChild!;
    AVLNode? T2 = x.rightChild;

    x.rightChild = y;
    y.leftChild = T2;

    y.height = 1 + _max(_getHeight(y.leftChild), _getHeight(y.rightChild));
    x.height = 1 + _max(_getHeight(x.leftChild), _getHeight(x.rightChild));

    return x;
  }

  AVLNode? _rotateLeft(AVLNode x) {
    if (x.rightChild == null) return null;

    AVLNode y = x.rightChild!;
    AVLNode? T2 = y.leftChild;

    y.leftChild = x;
    x.rightChild = T2;

    x.height = 1 + _max(_getHeight(x.leftChild), _getHeight(x.rightChild));
    y.height = 1 + _max(_getHeight(y.leftChild), _getHeight(y.rightChild));

    return y;
  }
}

// Clase que representa un nodo en el árbol AVL
class AVLNode {
  int value;
  int height;
  AVLNode? leftChild;
  AVLNode? rightChild;

  AVLNode(this.value) : height = 1 {
    leftChild = null;
    rightChild = null;
  }

  AVLNode insert(int value) {
    if (value < this.value) {
      if (leftChild == null) {
        leftChild = AVLNode(value);
      } else {
        leftChild = leftChild!.insert(value);
      }
    } else if (value > this.value) {
      if (rightChild == null) {
        rightChild = AVLNode(value);
      } else {
        rightChild = rightChild!.insert(value);
      }
    } else {
      return this;
    }

    height = 1 + _max(_getHeight(leftChild), _getHeight(rightChild));

    int balance = _getBalance(this);

    if (balance > 1 && value < leftChild!.value) {
      return _rotateRight(this)!;
    }

    if (balance < -1 && value > rightChild!.value) {
      return _rotateLeft(this)!;
    }

    if (balance > 1 && value > leftChild!.value) {
      leftChild = leftChild!._rotateLeft(leftChild!);
      return _rotateRight(this)!;
    }

    if (balance < -1 && value < rightChild!.value) {
      rightChild = rightChild!._rotateRight(rightChild!);
      return _rotateLeft(this)!;
    }

    return this;
  }

  List<int> inOrderTraversal() {
    List<int> result = [];
    if (leftChild != null) {
      result.addAll(leftChild!.inOrderTraversal());
    }
    result.add(value);
    if (rightChild != null) {
      result.addAll(rightChild!.inOrderTraversal());
    }
    return result;
  }

  List<int> preOrderTraversal() {
    List<int> result = [];
    result.add(value);
    if (leftChild != null) {
      result.addAll(leftChild!.preOrderTraversal());
    }
    if (rightChild != null) {
      result.addAll(rightChild!.preOrderTraversal());
    }
    return result;
  }

  List<int> postOrderTraversal() {
    List<int> result = [];
    if (leftChild != null) {
      result.addAll(leftChild!.postOrderTraversal());
    }
    if (rightChild != null) {
      result.addAll(rightChild!.postOrderTraversal());
    }
    result.add(value);
    return result;
  }

  int _max(int a, int b) {
    return (a > b) ? a : b;
  }

  int _getHeight(AVLNode? node) {
    if (node == null) return 0;
    return node.height;
  }

  int _getBalance(AVLNode? node) {
    if (node == null) return 0;
    return _getHeight(node.leftChild) - _getHeight(node.rightChild);
  }

  AVLNode? _rotateRight(AVLNode y) {
    if (y.leftChild == null) return null;

    AVLNode x = y.leftChild!;
    AVLNode? T2 = x.rightChild;

    x.rightChild = y;
    y.leftChild = T2;

    y.height = 1 + _max(_getHeight(y.leftChild), _getHeight(y.rightChild));
    x.height = 1 + _max(_getHeight(x.leftChild), _getHeight(x.rightChild));

    return x;
  }

  AVLNode? _rotateLeft(AVLNode x) {
    if (x.rightChild == null) return null;

    AVLNode y = x.rightChild!;
    AVLNode? T2 = y.leftChild;

    y.leftChild = x;
    x.rightChild = T2;

    x.height = 1 + _max(_getHeight(x.leftChild), _getHeight(x.rightChild));
    y.height = 1 + _max(_getHeight(y.leftChild), _getHeight(y.rightChild));

    return y;
  }
}

// Clase para pintar el árbol en la pantalla
class TreePainter extends CustomPainter {
  AVLNode? _root;

  TreePainter(this._root);

  @override
  void paint(Canvas canvas, Size size) {
    if (_root != null) {
      _drawNode(canvas, _root!, size.width / 2, 50, size.width / 4);
    }
  }

  void _drawNode(Canvas canvas, AVLNode node, double x, double y, double offsetX) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(x, y), 20, paint);
    TextSpan span = TextSpan(
      style: TextStyle(color: Colors.black, fontSize: 14),
      text: node.value.toString(),
    );
    TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x - 10, y - 10));

    if (node.leftChild != null) {
      canvas.drawLine(Offset(x, y + 20), Offset(x - offsetX, y + 50), paint);
      _drawNode(canvas, node.leftChild!, x - offsetX, y + 50, offsetX / 2);
    }
    if (node.rightChild != null) {
      canvas.drawLine(Offset(x, y + 20), Offset(x + offsetX, y + 50), paint);
      _drawNode(canvas, node.rightChild!, x + offsetX, y + 50, offsetX / 2);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
