import 'package:flutter/material.dart';

import '../services/hive_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool obscure = true;

  void register() async {
    if (formKey.currentState!.validate()) {
      final email = emailController.text.trim();

      // CHECK EMAIL ĐÃ TỒN TẠI
      final existingUser = HiveService.userBox.get(email);

      if (existingUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email đã tồn tại"),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      // LƯU USER
      await HiveService.userBox.put(email, {
        "name": nameController.text.trim(),
        "email": email,
        "password": passwordController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đăng ký thành công"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      resizeToAvoidBottomInset: true,

      appBar: AppBar(title: const Text("Đăng ký")),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: formKey,

            child: Column(
              children: [
                const SizedBox(height: 20),

                const Icon(Icons.pets, size: 80, color: Colors.teal),

                const SizedBox(height: 15),

                const Text(
                  "Tạo tài khoản",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),

                const SizedBox(height: 30),

                // HỌ TÊN
                TextFormField(
                  controller: nameController,

                  decoration: InputDecoration(
                    labelText: "Họ tên",

                    prefixIcon: const Icon(Icons.person),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Vui lòng nhập họ tên";
                    }

                    if (value.trim().length < 2) {
                      return "Họ tên quá ngắn";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // EMAIL
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,

                  decoration: InputDecoration(
                    labelText: "Email",

                    prefixIcon: const Icon(Icons.email),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Vui lòng nhập email";
                    }

                    if (!value.contains("@") || !value.contains(".")) {
                      return "Email không hợp lệ";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // PASSWORD
                TextFormField(
                  controller: passwordController,
                  obscureText: obscure,

                  decoration: InputDecoration(
                    labelText: "Mật khẩu",

                    prefixIcon: const Icon(Icons.lock),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscure = !obscure;
                        });
                      },

                      icon: Icon(
                        obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Vui lòng nhập mật khẩu";
                    }

                    if (value.length < 6) {
                      return "Mật khẩu tối thiểu 6 ký tự";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 35),

                // BUTTON
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: register,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,

                      padding: const EdgeInsets.symmetric(vertical: 16),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),

                    child: const Text(
                      "ĐĂNG KÝ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
