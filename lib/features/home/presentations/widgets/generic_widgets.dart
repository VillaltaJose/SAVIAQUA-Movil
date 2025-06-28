import 'package:flutter/material.dart';

Widget buildSectionCard({
  required String title,
  required IconData icon,
  required List<Widget> children,
}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    ),
  );
}

Widget buildAnimatedField({required int delay, required Widget child}) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: Duration(milliseconds: 300 + delay),
    builder: (context, value, child) {
      return Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      );
    },
    child: child,
  );
}

Widget inputField(
  TextEditingController controller,
  String label,
  String hint,
  IconData? icon, {
  bool validator = false,
  bool isNumber = false,
  bool readOnly = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: inputDecoration(hint, icon).copyWith(
          filled: readOnly,
          fillColor: readOnly ? Colors.grey.shade100 : null,
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        cursorColor: Colors.black38,
        validator:
            validator
                ? (val) =>
                    val == null || val.isEmpty
                        ? 'Este campo es requerido'
                        : null
                : null,
        style: TextStyle(color: readOnly ? Colors.grey.shade700 : Colors.black),
      ),
    ],
  );
}

InputDecoration inputDecoration(String hint, IconData? icon) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: icon != null ? Icon(icon, color: Colors.black38) : null,
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(
      horizontal: icon != null ? 1 : 20,
      vertical: 8,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.blue, width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
  );
}

Widget buildDropdown({
  required bool isLoading,
  required int? value,
  required List<DropdownMenuItem<int>> items,
  required String hintLoading,
  required String label,
  required IconData icon,
  required ValueChanged<int?> onChanged,
  required String? Function(int?) validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<int>(
        value: value,
        decoration: inputDecoration('Seleccione una opción', icon),
        items:
            isLoading
                ? [
                  DropdownMenuItem(
                    value: null,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(hintLoading),
                      ],
                    ),
                  ),
                ]
                : items,
        onChanged: isLoading ? null : onChanged,
        validator: validator,
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black87),
      ),
    ],
  );
}
