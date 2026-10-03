import 'package:flutter/material.dart';

void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hồ Sơ Cá Nhân',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const PortfolioScreen(),
    );
  }
}

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Hồ Sơ Cá Nhân'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. HEADER / AVATAR & TÊN
                const Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.indigo,
                          child: CircleAvatar(
                            radius: 52,
                            backgroundImage: NetworkImage(
                              'https://picsum.photos/200',
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Đặng Xuân Minh',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. THÔNG TIN CÁ NHÂN & LIÊN HỆ
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin cá nhân & Liên hệ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.cake, color: Colors.indigo),
                          title: const Text('Ngày sinh'),
                          subtitle: const Text('25/09/2004'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_on, color: Colors.indigo),
                          title: const Text('Quê quán'),
                          subtitle: const Text('Hà Nội'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.phone, color: Colors.indigo),
                          title: const Text('Số điện thoại'),
                          subtitle: const Text('0123456789'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.email, color: Colors.indigo),
                          title: const Text('Email'),
                          subtitle: const Text('minh@123.321.com'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}