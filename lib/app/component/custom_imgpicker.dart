import 'dart:io';
import 'package:devconnect_app/style/server_path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomImagePicker extends StatefulWidget {
  final void Function(XFile)? onImageSelected;
  final String? dprofile;

  const CustomImagePicker({
    this.onImageSelected,
    this.dprofile,
  });

  @override
  _CustomImagePicker createState(){
    return _CustomImagePicker();
  }
}

class _CustomImagePicker extends State< CustomImagePicker > {
  final ImagePicker picker = ImagePicker();
  XFile? selectedImage;

  void onSelectImage() async {
    try {
      final XFile? pickedFile = await picker.pickImage( source: ImageSource.gallery );
      if (pickedFile != null) {
        setState(() {
          selectedImage = pickedFile;
        });
        if (widget.onImageSelected != null) {
          widget.onImageSelected!(pickedFile);
        }
      }
    } catch (e) { print("에러 발생"); }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 원형 이미지
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[200],
          backgroundImage: selectedImage != null
              ? FileImage(File(selectedImage!.path))
              : NetworkImage("${widget.dprofile ?? "default.jpg"}") as ImageProvider,
        ),

        Transform.translate(
          offset: Offset(40, 40),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: CircleBorder(),
              padding: EdgeInsets.all(6),
            ),
            onPressed: onSelectImage,
            child: Icon(Icons.add_a_photo, size: 28),
          ),
        ),
      ],
    );
  }
}
