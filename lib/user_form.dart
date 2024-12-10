import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: UserForm(),
    );
  }
}

class UserForm extends StatefulWidget {
  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<Map<String, String>> _users = [];

  // Function to encrypt password using SHA256
  String _encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Function to validate email
  bool _isValidEmail(String email) {
    String pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}\b';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  // Function to edit an existing user
  void _editUser(int index) {
    _usernameController.text = _users[index]['username']!;
    _fullnameController.text = _users[index]['fullname']!;
    _emailController.text = _users[index]['email']!;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Usuario'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_usernameController, 'Username', Icons.person, false, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un username';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                    return 'El username solo puede contener letras y números';
                  }
                  return null;
                }),
                _buildTextField(_fullnameController, 'Nombre Completo', Icons.account_circle, false, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese su nombre completo';
                  }
                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                    return 'El nombre solo puede contener letras';
                  }
                  return null;
                }),
                _buildTextField(_emailController, 'Correo Electrónico', Icons.email, false, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un correo electrónico';
                  }
                  if (!_isValidEmail(value)) {
                    return 'Correo electrónico inválido';
                  }
                  return null;
                }),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _users[index] = {
                          'username': _usernameController.text,
                          'password': _users[index]['password']!,  // Keep the same password
                          'fullname': _fullnameController.text,
                          'email': _emailController.text,
                        };
                      });

                      // Clear the form fields and close the dialog
                      _usernameController.clear();
                      _fullnameController.clear();
                      _emailController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Actualizar Usuario'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to delete an existing user with confirmation
  void _deleteUser(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar este usuario?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _users.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text('Sí'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_usernameController, 'Username', Icons.person, false, (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese un username';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                      return 'El username solo puede contener letras y números';
                    }
                    return null;
                  }),
                  _buildTextField(_passwordController, 'Contraseña', Icons.lock, true, (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese una contraseña';
                    }
                    return null;
                  }),
                  _buildTextField(_fullnameController, 'Nombre Completo', Icons.account_circle, false, (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese su nombre completo';
                    }
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                      return 'El nombre solo puede contener letras';
                    }
                    return null;
                  }),
                  _buildTextField(_emailController, 'Correo Electrónico', Icons.email, false, (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese un correo electrónico';
                    }
                    if (!_isValidEmail(value)) {
                      return 'Correo electrónico inválido';
                    }
                    return null;
                  }),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _users.add({
                            'username': _usernameController.text,
                            'password': _encryptPassword(_passwordController.text),
                            'fullname': _fullnameController.text,
                            'email': _emailController.text,
                          });

                          // Clear the form fields
                          _usernameController.clear();
                          _passwordController.clear();
                          _fullnameController.clear();
                          _emailController.clear();
                        });
                      }
                    },
                    child: Text('Agregar a la Tabla', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text('Usuarios Agregados:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 20,
                  columns: [
                    DataColumn(label: Text('Username', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Contraseña', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Nombre Completo', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Correo Electrónico', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _users.map((user) {
                    int index = _users.indexOf(user);
                    return DataRow(cells: [
                      DataCell(Text(user['username']!)),
                      DataCell(Text(user['password']!)),
                      DataCell(Text(user['fullname']!)),
                      DataCell(Text(user['email']!)),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editUser(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteUser(index),
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

  // Helper method for creating text fields with icons
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool obscureText, String? Function(String?)? validator) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        obscureText: obscureText,
        validator: validator,
      ),
    );
  }
}
