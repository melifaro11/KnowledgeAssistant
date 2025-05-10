import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_assistant/bloc/auth_bloc.dart';
import 'package:knowledge_assistant/bloc/events/auth_event.dart';
import 'package:knowledge_assistant/bloc/states/auth_state.dart';
import 'package:knowledge_assistant/ui/widgets/elevated_icon_button.dart';
import 'package:knowledge_assistant/ui/widgets/textformfield_decorated.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        title: const Text('AI Knowledge Assistant'),
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
                      Center(
                        child: Image.asset(
                          "assets/images/login_icon.png",
                          width: 220,
                          opacity: const AlwaysStoppedAnimation(0.7),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormFieldDecorated(
                        controller: _emailController,
                        hintText: "Your email",
                        labelText: "Login",
                        width: 350,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter e-mail';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormFieldDecorated(
                        controller: _passwordController,
                        hintText: "Your password",
                        labelText: "Password",
                        obscureText: true,
                        width: 350,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter password';
                          }
                          return null;
                        },
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
                      const SizedBox(height: 34),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedIconButton(
                            width: 200,
                            onPressed: () {
                              _formKey.currentState!.save();

                              if (_formKey.currentState!.validate()) {
                                BlocProvider.of<AuthBloc>(context).add(
                                  LoginRequested(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Text('Login'),
                          ),
                          const SizedBox(width: 15),
                          ElevatedIconButton(
                            width: 200,
                            onPressed: () {
                              context.read<AuthBloc>().add(ClearAuthError());
                              GoRouter.of(context).push('/register');
                            },
                            child: const Text("Register"),
                          ),
                        ],
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
