import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itawseel/Components/mybutton.dart';
import 'package:itawseel/Components/navigationR.dart';
import 'package:itawseel/pages/Customer/edit_profile.dart';
import 'package:itawseel/themes/colors.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class ProfileR extends StatefulWidget {
  const ProfileR({super.key});

  @override
  State<ProfileR> createState() => _ProfileRState();
}

class _ProfileRState extends State<ProfileR> {
  XFile? _pickedImage;
  String _imageUrl = ''; // Initialize with empty string

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
      _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_pickedImage != null) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('Qrcode_images')
            .child(FirebaseAuth.instance.currentUser!.uid + '.jpg');
        final uploadTask = ref.putFile(File(_pickedImage!.path));
        final url = await (await uploadTask).ref.getDownloadURL();
        setState(() {
          _imageUrl = url;
        });
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .update({'QrCode': url});
      } catch (error) {
        print('Error uploading image: $error');
      }
    }
  }

  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(user.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userDoc = snapshot.data!;
            final imageUrl = userDoc['QrCode'];
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Card(
                          color: primaryColor,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Container(
                                  child: CircleAvatar(
                                    radius: 50.0,
                                    backgroundColor: Colors.grey,
                                    backgroundImage:
                                        userDoc['imageUrl'] != 'default' &&
                                                userDoc['imageUrl'].isNotEmpty
                                            ? NetworkImage(userDoc['imageUrl'])
                                            : NetworkImage(userDoc['imageUrl']),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    Text(
                                      userDoc['username'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white),
                                    ),
                                    SingleChildScrollView(
                                      child: Text(
                                        userDoc['email'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.white),
                                      ),
                                    ),
                                    Text(
                                      userDoc['location'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      userDoc['phonenumber'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.white),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                            "                                "),
                                        TextButton(
                                            onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const EditProfilePage())),
                                            child: const Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "Edit",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            )),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Divider(),
                        SizedBox(height: 8),
                        Text("Qr Code",
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          child: imageUrl.isEmpty
                              ? ElevatedButton(
                                  onPressed: _pickImage,
                                  child: const Text('Upload Your Qr code Here'),
                                )
                              : Card(
                                  color: primaryColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Image.network(
                                      imageUrl,
                                      width: 400,
                                      height: 400,
                                    ),
                                  ),
                                ),
                        ),
                        TextButton(
                          onPressed: () {
                            _pickImage();
                          },
                          child: const Text('Update Qr code'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
