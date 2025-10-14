
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ListGunung extends StatelessWidget {
  const ListGunung({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Gunung'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddEditDialog(context);
            },
          ),
        ],
      ),
      body: const MountainList(),
    );
  }
}

class MountainList extends StatelessWidget {
  const MountainList({super.key});

  ImageProvider _getImageProvider(String? base64String) {
    if (base64String != null && base64String.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(base64String));
      } catch (e) {
        return const AssetImage('assets/placeholder.png'); 
      }
    } else {
      return const AssetImage('assets/placeholder.png'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('gunung').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(8.0),
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            return Card(
              elevation: 4.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                leading: CircleAvatar(
                  backgroundImage: _getImageProvider(data['image']),
                  child: (data['image'] == null || data['image'].isEmpty) && (data['nama'] != null && data['nama'].isNotEmpty)
                      ? Text(data['nama'][0])
                      : null,
                ),
                title: Text(data['nama'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(data['lokasi'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showAddEditDialog(context, document: document),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteMountain(context, document.id),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

void _showAddEditDialog(BuildContext context, {DocumentSnapshot? document}) {
  final formKey = GlobalKey<FormState>();
  Map<String, dynamic> formData = document != null ? document.data() as Map<String, dynamic> : {};
  Uint8List? pickedImageBytes;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickImage() async {
            final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 800);
            if (pickedFile != null) {
              final bytes = await pickedFile.readAsBytes();
              setState(() {
                pickedImageBytes = bytes;
                formData['image'] = null; 
              });
            }
          }

          Widget imagePreview() {
            if (pickedImageBytes != null) {
              return Image.memory(pickedImageBytes!, fit: BoxFit.cover, width: double.infinity);
            } else if (formData['image'] != null && formData['image'].isNotEmpty) {
               try {
                return Image.memory(base64Decode(formData['image']), fit: BoxFit.cover, width: double.infinity);
              } catch(e) {
                return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
              }
            } else {
              return const Icon(Icons.photo, size: 50, color: Colors.grey);
            }
          }

          return AlertDialog(
            title: Text(document == null ? 'Tambah Gunung' : 'Edit Gunung'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12.0)),
                            child: Center(child: imagePreview()),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text('Pilih Gambar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...[
                        TextFormField(initialValue: formData['nama'] ?? '', decoration: const InputDecoration(labelText: 'Nama Gunung'), onSaved: (v) => formData['nama'] = v),
                        TextFormField(initialValue: formData['deskripsi'] ?? '', decoration: const InputDecoration(labelText: 'Deskripsi'), onSaved: (v) => formData['deskripsi'] = v),
                        TextFormField(initialValue: formData['jalur'] ?? '', decoration: const InputDecoration(labelText: 'Jalur'), onSaved: (v) => formData['jalur'] = v),
                        TextFormField(initialValue: formData['kesulitan'] ?? '', decoration: const InputDecoration(labelText: 'Kesulitan'), onSaved: (v) => formData['kesulitan'] = v),
                        TextFormField(initialValue: formData['ketinggian'] ?? '', decoration: const InputDecoration(labelText: 'Ketinggian'), onSaved: (v) => formData['ketinggian'] = v),
                        TextFormField(initialValue: formData['lokasi'] ?? '', decoration: const InputDecoration(labelText: 'Lokasi'), onSaved: (v) => formData['lokasi'] = v),
                        TextFormField(initialValue: formData['latitude']?.toString() ?? '', decoration: const InputDecoration(labelText: 'Latitude'), keyboardType: TextInputType.number, onSaved: (v) => formData['latitude'] = double.tryParse(v ?? '0')),
                        TextFormField(initialValue: formData['longitude']?.toString() ?? '', decoration: const InputDecoration(labelText: 'Longitude'), keyboardType: TextInputType.number, onSaved: (v) => formData['longitude'] = double.tryParse(v ?? '0')),
                        TextFormField(initialValue: formData['provinsi'] ?? '', decoration: const InputDecoration(labelText: 'Provinsi'), onSaved: (v) => formData['provinsi'] = v),
                        TextFormField(initialValue: formData['status'] ?? '', decoration: const InputDecoration(labelText: 'Status'), onSaved: (v) => formData['status'] = v),
                        TextFormField(initialValue: formData['tiket'] ?? '', decoration: const InputDecoration(labelText: 'Tiket'), onSaved: (v) => formData['tiket'] = v),
                        TextFormField(initialValue: formData['waktu'] ?? '', decoration: const InputDecoration(labelText: 'Waktu'), onSaved: (v) => formData['waktu'] = v),
                      ].map((widget) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: widget)),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(child: const Text('Batal'), onPressed: () => Navigator.of(context).pop()),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Simpan'),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    if (pickedImageBytes != null) {
                      formData['image'] = base64Encode(pickedImageBytes!);
                    }
                    if (document == null) {
                      FirebaseFirestore.instance.collection('gunung').add(formData);
                    } else {
                      FirebaseFirestore.instance.collection('gunung').doc(document.id).update(formData);
                    }
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}

void _deleteMountain(BuildContext context, String docId) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus Gunung'),
      content: const Text('Apakah Anda yakin ingin menghapus data gunung ini?'),
      actions: [
        TextButton(child: const Text('Batal'), onPressed: () => Navigator.of(context).pop()),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Hapus'),
          onPressed: () {
            FirebaseFirestore.instance.collection('gunung').doc(docId).delete();
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}
