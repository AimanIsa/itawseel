import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itawseel/themes/colors.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final _formKey = GlobalKey<FormState>();
  String? _editedName;
  String? _editedPhoneNumber;
  File? _profileImage;

  Card buildButton({
    required onTap,
    required title,
    required text,
  }) {
    return Card(
      shape: const StadiumBorder(),
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: ListTile(
        onTap: onTap,
        title: Text(title ?? ""),
        subtitle: Text(text ?? ""),
        trailing: const Icon(
          Icons.keyboard_arrow_right_rounded,
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_profileImage == null) return;
    final storageRef =
        FirebaseStorage.instance.ref().child('profile_images/${user.uid}');
    await storageRef.putFile(_profileImage!);
    final imageUrl = await storageRef.getDownloadURL();
    FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .update({'imageUrl': imageUrl});
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email)
          .update({
        'username': _editedName,
        'phonenumber': _editedPhoneNumber,
      });
      setState(() {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Profile Updated Successfully!',
          // autoCloseDuration: const Duration(seconds: 2),
          showConfirmBtn: true,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(user.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final userDoc = snapshot.data!;
                return Column(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 25),
                        CircleAvatar(
                          radius: 50.0,
                          backgroundColor: Colors.grey,
                          backgroundImage: userDoc['imageUrl'] != 'default' &&
                                  userDoc['imageUrl'].isNotEmpty
                              ? NetworkImage(userDoc['imageUrl'])
                              : NetworkImage(userDoc['imageUrl']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: _pickImage,
                        ),
                      ],
                    ),
                    Text(
                      userDoc['username'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    // Text(userDoc['email']),
                    // Text(userDoc['phonenumber'] ?? 'No phone number'),
                    const SizedBox(height: 20.0),
                    Card(
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("New username: "),
                              const SizedBox(height: 10),
                              TextFormField(
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor),
                                  borderRadius: BorderRadius.circular(8),
                                )),
                                initialValue: userDoc['username'],
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter your name'
                                    : null,
                                onSaved: (value) => _editedName = value,
                              ),
                              const SizedBox(height: 20.0),
                              const Text("New Phone Number: "),
                              const SizedBox(height: 10),
                              TextFormField(
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor),
                                  borderRadius: BorderRadius.circular(8),
                                )),
                                initialValue: userDoc['phonenumber'],
                                keyboardType: TextInputType.phone,
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter your phone number'
                                    : null,
                                onSaved: (value) => _editedPhoneNumber = value,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      onPressed: () => _updateUserData(),
                      child: const Text(
                        'Update Profile',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    if (_profileImage != null)
                      TextButton(
                          onPressed: _uploadImage,
                          child: const Text('Upload Profile Picture'))
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return const CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }
}
