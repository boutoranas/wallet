import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget inputData({
  TextEditingController? controller,
  required String label,
  required bool text,
  Function? onTap,
  Function? onChanged,
  TextInputType? keyBoardType,
  List<TextInputFormatter>? inputFormatters,
  Widget? suffix,
  Widget? prefixIcon,
  Color? backgcolor,
  TextStyle? style,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ),
      SizedBox(
        height: 5,
      ),
      TextField(
        style: style,
        controller: controller,
        onTap: text == false
            ? () {
                onTap != null ? onTap() : null;
              }
            : null,
        onChanged: (value) {
          onChanged != null ? onChanged() : null;
        },
        readOnly: text == true ? false : true,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          filled: true,
          fillColor: backgcolor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          suffix: suffix,
          suffixIcon: text == false
              ? Icon(
                  Icons.arrow_drop_down,
                  color: backgcolor != null ? Colors.white : null,
                )
              : null,
        ),
        keyboardType: keyBoardType,
        inputFormatters: inputFormatters,
      ),
    ],
  );
}

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      dismissDirection: DismissDirection.endToStart,
      showCloseIcon: true,
      closeIconColor: Theme.of(context).colorScheme.primary,
      content: Text(text),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
