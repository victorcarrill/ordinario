import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formulario y Tabla de Becario',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _numeroCuentaController = TextEditingController();
  final _nombreCompletoController = TextEditingController();
  File? _imagenFoto;

  List<String> _becas = ['Inscripción', 'Coca Cola', 'Peña Colorada'];
  String _becaSeleccionada = 'Inscripción';
  final _nuevaBecaController = TextEditingController();

  List<Map<String, dynamic>> _becarios = [];

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagenFoto = File(pickedFile.path);
      });
    }
  }

  void _addBecario() {
    if (_numeroCuentaController.text.length == 8 &&
        _nombreCompletoController.text.isNotEmpty &&
        _becaSeleccionada.isNotEmpty) {
      setState(() {
        _becarios.add({
          'numeroCuenta': _numeroCuentaController.text,
          'nombreCompleto': _nombreCompletoController.text,
          'beca': _becaSeleccionada,
          'photo': _imagenFoto,
        });
      });

      _numeroCuentaController.clear();
      _nombreCompletoController.clear();
      setState(() {
        _becaSeleccionada = 'Inscripción';
        _imagenFoto = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, complete todos los campos correctamente')),
      );
    }
  }

  void _agregarNuevaBeca() {
    if (_nuevaBecaController.text.isNotEmpty) {
      setState(() {
        _becas.add(_nuevaBecaController.text);
        _nuevaBecaController.clear();
      });
    }
  }

  // Función para editar becarios
  void _editBecario(int index) {
    final becario = _becarios[index];
    final TextEditingController numeroCuentaController = TextEditingController(text: becario['numeroCuenta']);
    final TextEditingController nombreCompletoController = TextEditingController(text: becario['nombreCompleto']);
    String becaSeleccionada = becario['beca'];
    File? imagenFoto = becario['photo'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Editar Becario"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numeroCuentaController,
                decoration: InputDecoration(labelText: 'Número de cuenta'),
                keyboardType: TextInputType.number,
                maxLength: 8,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              TextField(
                controller: nombreCompletoController,
                decoration: InputDecoration(labelText: 'Nombre completo'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]')),
                ],
              ),
              // Dropdown para seleccionar la beca
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey),
                  color: Colors.grey[200],
                ),
                child: DropdownButton<String>(
                  value: becaSeleccionada,
                  onChanged: (String? newValue) {
                    becaSeleccionada = newValue!;
                  },
                  items: _becas.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  isExpanded: true,
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: _selectImage,
                child: Text('Seleccionar Foto'),
              ),
              if (imagenFoto != null)
                Image.file(imagenFoto, width: 100, height: 100),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _becarios[index] = {
                    'numeroCuenta': numeroCuentaController.text,
                    'nombreCompleto': nombreCompletoController.text,
                    'beca': becaSeleccionada,
                    'photo': imagenFoto,
                  };
                });
                Navigator.pop(context);
              },
              child: Text("Guardar Cambios"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancelar"),
            ),
          ],
        );
      },
    );
  }

  // Función para eliminar un becario con confirmación
  void _deleteBecario(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar eliminación"),
          content: Text("¿Estás seguro de eliminar este becario?"),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _becarios.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text("Sí"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulario de Becario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Título del formulario
            Text(
              'Agregar Becario',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Formulario para agregar becario
            TextField(
              controller: _numeroCuentaController,
              decoration: InputDecoration(labelText: 'Número de cuenta'),
              keyboardType: TextInputType.number,
              maxLength: 8,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            TextField(
              controller: _nombreCompletoController,
              decoration: InputDecoration(labelText: 'Nombre completo'),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]')),
              ],
            ),

            // Dropdown para seleccionar el tipo de beca
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey),
                color: Colors.grey[200],
              ),
              child: DropdownButton<String>(
                value: _becaSeleccionada,
                onChanged: (String? newValue) {
                  setState(() {
                    _becaSeleccionada = newValue!;
                  });
                },
                items: _becas.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                isExpanded: true,
                style: TextStyle(color: Colors.black),
              ),
            ),

            // Campo para agregar una nueva beca
            TextField(
              controller: _nuevaBecaController,
              decoration: InputDecoration(
                labelText: 'Agregar nueva beca (opcional)',
                hintText: 'Ej: Beca Deportiva',
              ),
            ),
            ElevatedButton(
              onPressed: _agregarNuevaBeca,
              child: Text('Agregar Beca'),
            ),

            // Opción para seleccionar la foto
            ElevatedButton(
              onPressed: _selectImage,
              child: Text('Seleccionar Foto'),
            ),
            if (_imagenFoto != null)
              Image.file(_imagenFoto!, width: 100, height: 100),
            SizedBox(height: 20),

            // Botón para agregar el becario
            ElevatedButton(
              onPressed: _addBecario,
              child: Text('Agregar a la tabla'),
            ),
            SizedBox(height: 20),

            // Tabla que muestra los becarios
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 20,
                  columns: [
                    DataColumn(label: Text('Número de Cuenta', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Nombre Completo', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Beca', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _becarios.map((becario) {
                    final index = _becarios.indexOf(becario);
                    return DataRow(cells: [
                      DataCell(Text(becario['numeroCuenta'])),
                      DataCell(Text(becario['nombreCompleto'])),
                      DataCell(Text(becario['beca'])),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editBecario(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteBecario(index),
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}