import 'package:flutter/material.dart';

class PermissionToggle extends StatefulWidget {
  final Function(String) onChanged;
  final String initialValue;

  const PermissionToggle({
    super.key,
    required this.onChanged,
    this.initialValue = 'read',
  });

  @override
  State<PermissionToggle> createState() => _PermissionToggleState();
}

class _PermissionToggleState extends State<PermissionToggle> {
  late bool isWrite;

  @override
  void initState() {
    super.initState();
    isWrite = widget.initialValue == 'write';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isWrite = !isWrite;
        });
        widget.onChanged(isWrite ? 'write' : 'read');
      },
      child: Container(
        width: 110,
        height: 35,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 1, color: Colors.grey),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        'READ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: !isWrite ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'WRITE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isWrite ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AnimatedAlign(
              alignment: isWrite ? Alignment.centerRight : Alignment.centerLeft,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              child: Container(
                width: 55,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
