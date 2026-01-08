import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../penyedia/penyedia_auth.dart';
import 'halaman_daftar.dart';
import 'halaman_utama.dart';

class HalamanLogin extends StatefulWidget {
  @override
  _HalamanLoginState createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  final _kunciForm = GlobalKey<FormState>();
  final _pengendaliEmail = TextEditingController();
  final _pengendaliPassword = TextEditingController();
  bool _sembunyiPassword = true;
  bool _sedangMemuat = false;

  @override
  void dispose() {
    _pengendaliEmail.dispose();
    _pengendaliPassword.dispose();
    super.dispose();
  }

  Future<void> _prosesLogin() async {
    if (_kunciForm.currentState!.validate()) {
      setState(() => _sedangMemuat = true);
      
      final penyediaAuth = Provider.of<PenyediaAuth>(context, listen: false);
      final berhasil = await penyediaAuth.login(
        _pengendaliEmail.text,
        _pengendaliPassword.text,
      );
      
      setState(() => _sedangMemuat = false);
      
      if (berhasil) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HalamanUtama()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email atau password salah'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF00796B), Color(0xFF004D40)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Selamat Datang',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Masuk ke akun Anda',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 40),
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _kunciForm,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _pengendaliEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                            ),
                            validator: (nilai) {
                              if (nilai == null || nilai.isEmpty) {
                                return 'Email harus diisi';
                              }
                              if (!nilai.contains('@')) {
                                return 'Email tidak valid';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _pengendaliPassword,
                            obscureText: _sembunyiPassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _sembunyiPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _sembunyiPassword = !_sembunyiPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (nilai) {
                              if (nilai == null || nilai.isEmpty) {
                                return 'Password harus diisi';
                              }
                              if (nilai.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _sedangMemuat ? null : _prosesLogin,
                              child: _sedangMemuat
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text('Masuk', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Belum punya akun? '),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => HalamanDaftar(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Daftar Sekarang',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00796B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}