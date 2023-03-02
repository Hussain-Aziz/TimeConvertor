import 'package:flutter/cupertino.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({Key? key}) : super(key: key);

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Placeholder(),
        Center(
          child: Text(
            "Comming soon",
            style:
                TextStyle(fontFamily: 'Fokus', fontSize: 48, letterSpacing: 3),
          ),
        ),
      ],
    );
  }
}
