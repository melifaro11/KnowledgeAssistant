import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_assistant/bloc/auth_bloc.dart';
import 'package:knowledge_assistant/bloc/events/auth_event.dart';
import 'package:knowledge_assistant/bloc/states/auth_state.dart';
import 'package:knowledge_assistant/ui/widgets/elevated_icon_button.dart';
import 'package:knowledge_assistant/ui/widgets/textformfield_decorated.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        title: const Text('New user registration'),
        leading: BackButton(
          onPressed: () {
            context.read<AuthBloc>().add(ClearAuthError());
            GoRouter.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is Authenticated) {
                  GoRouter.of(context).go('/dashboard');
                }
              },
              builder: (context, state) {
                final String? errorText =
                    state is AuthError ? state.message : null;

                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Registration",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 26),
                      TextFormFieldDecorated(
                        controller: _nameController,
                        width: 350,
                        labelText: "Name",
                        hintText: "Your name",
                      ),
                      const SizedBox(height: 16),
                      TextFormFieldDecorated(
                        controller: _emailController,
                        width: 350,
                        labelText: "Email",
                        hintText: "Your email",
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter email'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormFieldDecorated(
                        controller: _passwordController,
                        obscureText: true,
                        width: 350,
                        labelText: "Password",
                        hintText: "Your password",
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter password'
                                    : null,
                      ),
                      if (errorText != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          errorText,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedIconButton(
                          width: 200,
                          onPressed: () {
                            _formKey.currentState!.save();

                            if (_formKey.currentState!.validate()) {
                              BlocProvider.of<AuthBloc>(context).add(
                                RegisterRequested(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                  name: _nameController.text.trim(),
                                ),
                              );
                            }
                          },
                          child:
                              state is AuthLoading
                                  ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Text('Register'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
