import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'shop_directory.dart';
import 'product_page.dart';
import 'aboutus.dart';
import 'messages.dart';
import 'main.dart';
import 'notification.dart';

const darkBlue = Color(0xFF1E2B6D);
const orange = Color(0xFFF65A06);

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late Timer _timer;
  DateTime _dateTime = DateTime.now();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _dateTime = DateTime.now();
      });
    });

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _timer.cancel();
    _animController.dispose();
    super.dispose();
  }

  String get formattedDate {
    final months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return '${_dateTime.day} ${months[_dateTime.month - 1]} ${_dateTime.year}';
  }

  String get formattedTime {
    int hour = _dateTime.hour;
    final minute = _dateTime.minute.toString().padLeft(2, '0');
    final second = _dateTime.second.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute:$second $ampm';
  }

  Widget _navIcon(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onTap,
      tooltip: icon.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,

      // ✅ Top App Bar with back navigation
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(
                color: orange,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formattedTime,
              style: const TextStyle(
                color: orange,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: AnalogClockPainter(_dateTime),
              ),
            ),
            const SizedBox(height: 20),
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Card(
                  color: Colors.white10,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome to IT Shopee',
                          style: TextStyle(
                            color: orange,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'An AKIDTA Initiative',
                          style: TextStyle(
                            color: orange,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.deepOrange,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          // child: Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     _navIcon(Icons.home, () {
          //       Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
          //     }),
          //     _navIcon(Icons.menu, () {
          //       Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsPage()));
          //     }),
          //     _navIcon(Icons.store, () {
          //       Navigator.push(context, MaterialPageRoute(builder: (context) => const ShopDirectoryPage()));
          //     }),
          //     _navIcon(Icons.notifications, () {
          //       Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationPage()));
          //     }),
          //     _navIcon(Icons.message, () {
          //       Navigator.push(context, MaterialPageRoute(builder: (context) => const MessagesPage()));
          //     }),
          //     _navIcon(Icons.logout, () {
          //       Navigator.of(context).pushAndRemoveUntil(
          //         MaterialPageRoute(builder: (context) => const LoginPage()),
          //             (route) => false,
          //       );
          //     }),
          //   ],
          // ),
        ),
      ),
    );
  }
}

class AnalogClockPainter extends CustomPainter {
  final DateTime datetime;

  AnalogClockPainter(this.datetime);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final fillBrush = Paint()..color = Colors.black12;
    final outlineBrush = Paint()
      ..color = orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final centerFillBrush = Paint()..color = orange;

    final secHandBrush = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final minHandBrush = Paint()
      ..color = orange
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final hourHandBrush = Paint()
      ..color = orange
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 10, fillBrush);
    canvas.drawCircle(center, radius - 10, outlineBrush);

    final hourAngle = ((datetime.hour % 12) + datetime.minute / 60) * 30 * pi / 180 - pi / 2;
    final hourHandX = center.dx + 0.5 * radius * cos(hourAngle);
    final hourHandY = center.dy + 0.5 * radius * sin(hourAngle);
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandBrush);

    final minAngle = datetime.minute * 6 * pi / 180 - pi / 2;
    final minHandX = center.dx + 0.7 * radius * cos(minAngle);
    final minHandY = center.dy + 0.7 * radius * sin(minAngle);
    canvas.drawLine(center, Offset(minHandX, minHandY), minHandBrush);

    final secAngle = datetime.second * 6 * pi / 180 - pi / 2;
    final secHandX = center.dx + 0.9 * radius * cos(secAngle);
    final secHandY = center.dy + 0.9 * radius * sin(secAngle);
    canvas.drawLine(center, Offset(secHandX, secHandY), secHandBrush);

    canvas.drawCircle(center, 8, centerFillBrush);

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final textStyle = TextStyle(
      color: orange,
      fontSize: radius * 0.12,
      fontWeight: FontWeight.bold,
    );

    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      final x = center.dx + (radius * 0.75) * cos(angle);
      final y = center.dy + (radius * 0.75) * sin(angle);

      textPainter.text = TextSpan(text: '$i', style: textStyle);
      textPainter.layout();
      final offset = Offset(x - textPainter.width / 2, y - textPainter.height / 2);
      textPainter.paint(canvas, offset);
    }

    final labelTextPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    labelTextPainter.text = TextSpan(
      text: 'IT Shopee',
      style: TextStyle(
        color: orange,
        fontSize: radius * 0.12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );

    labelTextPainter.layout();

    final labelOffset = Offset(
      center.dx - labelTextPainter.width / 2,
      center.dy + radius * 0.3,
    );

    labelTextPainter.paint(canvas, labelOffset);
  }

  @override
  bool shouldRepaint(covariant AnalogClockPainter oldDelegate) {
    return oldDelegate.datetime.second != datetime.second;
  }
}
