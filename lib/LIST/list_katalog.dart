import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ListKatalog extends StatelessWidget {
  const ListKatalog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Katalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddEditDialog(context);
            },
          ),
        ],
      ),
      body: const KatalogList(),
    );
  }
}

class KatalogList extends StatelessWidget {
  const KatalogList({super.key});

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
      stream: FirebaseFirestore.instance.collection('katalog').snapshots(),
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
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            return Card(
              elevation: 4.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                leading: SizedBox(
                  width: 50,
                  height: 50,
                  child: Image(
                    image: _getImageProvider(data['image']),
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  data['nama'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Kategori: ${data['kategori'] ?? ''}\nHarga: Rp ${data['harga'] ?? 0}",
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          _showAddEditDialog(context, document: document),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteKatalog(context, document.id),
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
  Map<String, dynamic> formData = document != null
      ? document.data() as Map<String, dynamic>
      : {};
  Uint8List? pickedImageBytes;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickImage() async {
            final pickedFile = await ImagePicker().pickImage(
              source: ImageSource.gallery,
              imageQuality: 50,
              maxWidth: 800,
            );
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
              return Image.memory(
                pickedImageBytes!,
                fit: BoxFit.cover,
                width: double.infinity,
              );
            } else if (formData['image'] != null &&
                formData['image'].isNotEmpty) {
              try {
                return Image.memory(
                  base64Decode(formData['image']),
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              } catch (e) {
                return const Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                );
              }
            } else {
              return const Icon(Icons.photo, size: 50, color: Colors.grey);
            }
          }

          return AlertDialog(
            title: Text(document == null ? 'Tambah Katalog' : 'Edit Katalog'),
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
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
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
                        TextFormField(
                          initialValue: formData['nama'] ?? '',
                          decoration: const InputDecoration(labelText: 'Nama'),
                          onSaved: (v) => formData['nama'] = v,
                        ),
                        TextFormField(
                          initialValue: formData['link'] ?? '',
                          decoration: const InputDecoration(labelText: 'Link'),
                          onSaved: (v) => formData['link'] = v,
                        ),
                        TextFormField(
                          initialValue: formData['kategori'] ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                          ),
                          onSaved: (v) => formData['kategori'] = v,
                        ),
                        TextFormField(
                          initialValue: formData['harga']?.toInt() ?? '',
                          decoration: const InputDecoration(labelText: 'Harga'),
                          keyboardType: TextInputType.number,
                          onSaved: (v) =>
                              formData['harga'] = int.tryParse(v ?? '0'),
                        ),
                        TextFormField(
                          initialValue: formData['deskripsi'] ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi',
                          ),
                          onSaved: (v) => formData['deskripsi'] = v,
                        ),
                      ].map(
                        (widget) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: widget,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.of(context).pop(),
              ),
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
                      FirebaseFirestore.instance
                          .collection('katalog')
                          .add(formData);
                    } else {
                      FirebaseFirestore.instance
                          .collection('katalog')
                          .doc(document.id)
                          .update(formData);
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

void _deleteKatalog(BuildContext context, String docId) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus Katalog'),
      content: const Text(
        'Apakah Anda yakin ingin menghapus data katalog ini?',
      ),
      actions: [
        TextButton(
          child: const Text('Batal'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Hapus'),
          onPressed: () {
            FirebaseFirestore.instance
                .collection('katalog')
                .doc(docId)
                .delete();
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}
