// // import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class ViewCvButton extends StatelessWidget {
//   const ViewCvButton({super.key});

//   Future<void> _openPdf(BuildContext context) async {
//     // Hidden actual link — not shown in UI
//     const _pdfUrl = 'https://qrr.to/bf04e34f';
//     final uri = Uri.parse(_pdfUrl);

//     if (await canLaunchUrl(uri)) {
//       await launchUrl(
//         uri,
//         mode: LaunchMode.externalApplication, // opens in browser
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Could not open CV'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton.icon(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.blueAccent,
//         foregroundColor: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       ),
//       onPressed: () => _openPdf(context),
//       icon: const Icon(Icons.picture_as_pdf),
//       label: const Text(
//         'View CV',
//         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//       ),
//     );
//   }
// }