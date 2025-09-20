import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? Colors.purple.shade700 : Colors.purple.shade50,
          foregroundColor: isSelected ? Colors.white : Colors.purple.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          elevation: isSelected ? 8 : 4,
          shadowColor: Colors.purple.withValues(alpha: 0.4),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          // Add performance optimizations
          animationDuration: Duration.zero,
          enableFeedback: false,
        ),
        child: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
    );
  }
}
