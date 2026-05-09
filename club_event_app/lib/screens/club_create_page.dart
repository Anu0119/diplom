import 'package:flutter/material.dart';

class ClubCreatePage extends StatefulWidget {
  const ClubCreatePage({super.key});

  @override
  State<ClubCreatePage> createState() => _ClubCreatePageState();
}

class _ClubCreatePageState extends State<ClubCreatePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Өнгөний тогтмол утгууд
  final Color themeColor = const Color(0xFF2D265B); // Гүн хөх
  final Color accentColor = const Color(0xFFFFB6B6); // Зөөлөн ягаан
  final Color inputFillColor = const Color(0xFFF3F3F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Шинэ клуб", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                ),
              ),
              child: const Text(
                "Клубын үндсэн\nмэдээллийг оруулна уу",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// IMAGE PICKER
                  _buildInputLabel("Клубын зураг"),
                  GestureDetector(
                    onTap: () {
                      // Image picker logic
                    },
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: inputFillColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 40, color: themeColor),
                          const SizedBox(height: 10),
                          Text(
                            "Cover зураг сонгох",
                            style: TextStyle(color: themeColor.withOpacity(0.6), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// CLUB NAME
                  _buildInputLabel("Клубын нэр"),
                  _buildTextField(
                    controller: nameController,
                    hint: "Жишээ: Coding Club, Art Club...",
                    icon: Icons.groups_outlined,
                  ),

                  const SizedBox(height: 20),

                  /// DESCRIPTION
                  _buildInputLabel("Тайлбар"),
                  _buildTextField(
                    controller: descriptionController,
                    hint: "Клубын зорилго, үйл ажиллагааны чиглэл...",
                    icon: Icons.info_outline,
                    maxLines: 5,
                  ),

                  const SizedBox(height: 40),

                  /// CREATE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        String name = nameController.text;
                        String description = descriptionController.text;
                        // Save logic here
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        shadowColor: themeColor.withOpacity(0.4),
                      ),
                      child: const Text(
                        "КЛУБ ҮҮСГЭХ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Label widget
  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          color: themeColor,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  // Custom TextField widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: themeColor, size: 22),
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
      ),
    );
  }
}