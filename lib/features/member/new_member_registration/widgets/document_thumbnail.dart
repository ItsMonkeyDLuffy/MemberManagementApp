import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DocumentThumbnail extends StatelessWidget {
  final String title;
  final File? file;
  final String? url; // ✅ Renamed to 'url' to match parent screens
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DocumentThumbnail({
    super.key,
    required this.title,
    this.file,
    this.url, // ✅ Renamed
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Check for EITHER File OR URL
    final bool hasImage = file != null || (url != null && url!.isNotEmpty);

    return GestureDetector(
      onTap: onTap, // Tapping the box triggers the "Pick Image" action
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: hasImage ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            // ✅ Use withOpacity for broader compatibility
            color: hasImage
                ? Colors.green.withOpacity(0.5)
                : Colors.grey.shade300,
          ),
        ),
        child: hasImage
            ? Stack(
                fit: StackFit.expand, // ✅ Ensure children fill the box
                children: [
                  // 1. THE IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: file != null
                        ? Image.file(
                            file!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            url!, // ✅ Updated to use 'url'
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                          ),
                  ),

                  // 2. DELETE BUTTON (X)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: onDelete, // ✅ Only triggers delete
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),

                  // 3. TITLE OVERLAY
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_a_photo_outlined,
                    size: 24,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
