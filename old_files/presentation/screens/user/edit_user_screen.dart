import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/core/current_user_session.dart';
import 'package:gestor_horas_extras/data/local/user_dao.dart';
import 'package:gestor_horas_extras/domain/entities/user_account.dart';
import 'package:gestor_horas_extras/data/local/service_location_dao.dart';
import 'package:gestor_horas_extras/domain/entities/service_location.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllerFullName = TextEditingController();
  final _controllerUsername = TextEditingController();
  final _controllerEmail = TextEditingController();

  UserAccount? _currentUser;
  List<ServiceLocation> _serviceLocations = [];
  ServiceLocation? _selectedServiceLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    final user = CurrentUserSession.instance.currentUser;
    if (user == null || user.id == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    _currentUser = user;
    _controllerFullName.text = user.fullName;
    _controllerUsername.text = user.username;
    _controllerEmail.text = user.email;
    _selectedServiceLocation = user.serviceLocation;

    _loadServiceLocations();
  }

  Future<void> _loadServiceLocations() async {
    final serviceLocations = await ServiceLocationDao.instance.findAll();

    if (!mounted) {
      return;
    }

    setState(() {
      _serviceLocations = serviceLocations;
      _selectedServiceLocation = serviceLocations.firstWhere(
        (location) =>
            location.id == _selectedServiceLocation?.id ||
            location.name == _selectedServiceLocation?.name,
        orElse: () => _selectedServiceLocation ?? serviceLocations.first,
      );
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controllerFullName.dispose();
    _controllerUsername.dispose();
    _controllerEmail.dispose();
    super.dispose();
  }

  String? _requiredField(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUser = _currentUser;
    final selectedServiceLocation = _selectedServiceLocation;
    if (currentUser == null || currentUser.id == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário logado não encontrado')),
      );
      return;
    }

    if (selectedServiceLocation == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o local de serviço')),
      );
      return;
    }

    final updatedUser = UserAccount(
      id: currentUser.id,
      fullName: _controllerFullName.text.trim(),
      username: _controllerUsername.text.trim(),
      email: _controllerEmail.text.trim(),
      serviceLocation: selectedServiceLocation,
      password: currentUser.password,
    );

    try {
      final existingUser = await UserDao.instance.findByUsername(
        updatedUser.username,
      );
      if (existingUser != null && existingUser.id != updatedUser.id) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Já existe um usuário com esse nome')),
        );
        return;
      }

      await UserDao.instance.update(updatedUser);
      CurrentUserSession.instance.setUser(updatedUser);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar as alterações')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar usuário'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar usuário'), centerTitle: true),
        body: const Center(
          child: Text('Não foi possível carregar o usuário logado'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar usuário'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Atualize seus dados cadastrais:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _controllerFullName,
                  validator: (value) {
                    return _requiredField(value, 'Insira seu nome completo');
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nome completo',
                    hintText: 'Insira seu nome completo',
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _controllerUsername,
                  validator: (value) {
                    return _requiredField(value, 'Insira seu nome de usuário');
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nome de usuário',
                    hintText: 'Insira seu nome de usuário',
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _controllerEmail,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final requiredMessage = _requiredField(
                      value,
                      'Insira seu email',
                    );

                    if (requiredMessage != null) {
                      return requiredMessage;
                    }

                    if (!value!.contains('@')) {
                      return 'Insira um email válido';
                    }

                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Insira seu email',
                  ),
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<ServiceLocation>(
                  value: _selectedServiceLocation,
                  items: _serviceLocations
                      .map(
                        (location) => DropdownMenuItem<ServiceLocation>(
                          value: location,
                          child: Text(
                            location.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedServiceLocation = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecione o local de serviço';
                    }

                    return null;
                  },
                  selectedItemBuilder: (context) {
                    return _serviceLocations
                        .map(
                          (location) => Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              location.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList();
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Local de serviço',
                    hintText: 'Selecione o local de serviço',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text('Realizar mudanças'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
