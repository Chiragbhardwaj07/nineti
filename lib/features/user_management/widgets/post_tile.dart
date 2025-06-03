import 'package:flutter/material.dart';
import 'package:nineti/features/user_management/domain/models/post.dart';

class PostTile extends StatelessWidget {
  final Post post;
  final Color backgroundColor;
  final Color? textColor;
  final Color borderColor;
  const PostTile({super.key, required this.post,required this.backgroundColor, this.textColor,required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),side: BorderSide(color: borderColor, width: 1)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Divider(
              color:  borderColor,
              height: 12,
            ),
            const SizedBox(height: 3),
            Text(
              post.body,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
