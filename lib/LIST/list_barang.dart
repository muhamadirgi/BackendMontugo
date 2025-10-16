import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ListBarang extends StatelessWidget {
  const ListBarang({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Barang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddEditDialog(context);
            },
          ),
        ],
      ),
      body: const BarangList(),
    );
  }
}

class BarangList extends StatelessWidget {
  const BarangList({super.key});

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
      stream: FirebaseFirestore.instance.collection('barang').snapshots(),
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
                leading: CircleAvatar(
                  backgroundImage: _getImageProvider(data['image']),
                  child:
                      (data['image'] == null || data['image'].isEmpty) &&
                          (data['nama'] != null && data['nama'].isNotEmpty)
                      ? Text(data['nama'][0])
                      : null,
                ),
                title: Text(
                  data['nama'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(data['kategori'] ?? ''),
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
                      onPressed: () => _deleteBarang(context, document.id),
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
            title: Text(document == null ? 'Tambah Barang' : 'Edit Barang'),
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
                          decoration: const InputDecoration(
                            labelText: 'Nama Barang',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama barang tidak boleh kosong';
                            }
                            return null;
                          },
                          onSaved: (v) => formData['nama'] = v,
                        ),
                        TextFormField(
                          initialValue: formData['kategori'] ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Kategori tidak boleh kosong';
                            }
                            return null;
                          },
                          onSaved: (v) => formData['kategori'] = v,
                        ),
                        TextFormField(
                          initialValue: formData['berat'] ?? '',
                          decoration: const InputDecoration(labelText: 'Berat'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Berat tidak boleh kosong';
                            }
                            return null;
                          },
                          onSaved: (v) => formData['berat'] = v,
                        ),
                        DropdownButtonFormField<String>(
                          value: formData['jenis'],
                          decoration: const InputDecoration(labelText: 'Jenis'),
                          items: ['Logistik', 'Peralatan']
                              .map((label) => DropdownMenuItem(
                                    child: Text(label),
                                    value: label,
                                  ))
                              .toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Pilih jenis barang';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              formData['jenis'] = value;
                            });
                          },
                          onSaved: (v) => formData['jenis'] = v,
                        ),
                        TextFormField(
                          initialValue: formData['harga']?.toString() ?? '',
                          decoration: const InputDecoration(labelText: 'Harga'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Harga tidak boleh kosong';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Masukkan angka yang valid';
                            }
                            return null;
                          },
                          onSaved: (v) =>
                              formData['harga'] = int.tryParse(v ?? '0'),
                        ),
                        TextFormField(
                          initialValue: formData['bahan'] ?? '',
                          decoration: const InputDecoration(labelText: 'Bahan'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bahan tidak boleh kosong';
                            }
                            return null;
                          },
                          onSaved: (v) => formData['bahan'] = v,
                        ),
                        TextFormField(
                          initialValue: formData['deskripsi'] ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi',
                          ),
                           validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Deskripsi tidak boleh kosong';
                            }
                            return null;
                          },
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
                   if (document == null && pickedImageBytes == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pilih gambar terlebih dahulu.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    if (pickedImageBytes != null) {
                      formData['image'] = base64Encode(pickedImageBytes!);
                    }

                    if (document == null) {
                      FirebaseFirestore.instance
                          .collection('barang')
                          .add(formData);
                    } else {
                      FirebaseFirestore.instance
                          .collection('barang')
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

void _deleteBarang(BuildContext context, String docId) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus Barang'),
      content: const Text('Apakah Anda yakin ingin menghapus data barang ini?'),
      actions: [
        TextButton(
          child: const Text('Batal'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Hapus'),
          onPressed: () {
            FirebaseFirestore.instance.collection('barang').doc(docId).delete();
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}
