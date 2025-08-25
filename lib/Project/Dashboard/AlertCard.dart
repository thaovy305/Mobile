import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'Dashboard.dart';

// class AlertCard extends StatelessWidget {
//   final double spi;
//   final double cpi;
//   final VoidCallback onShowAIRecommendations;
//   final bool showRecommendations;
//   final bool isRecLoading;
//
//   const AlertCard({
//     Key? key,
//     required this.spi,
//     required this.cpi,
//     required this.onShowAIRecommendations,
//     required this.showRecommendations,
//     required this.isRecLoading,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isSPIBad = spi < 1;
//     final bool isCPIBad = cpi < 1;
//
//     if (!isSPIBad && !isCPIBad) return const SizedBox.shrink();
//
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.red[100],
//         border: Border.all(color: Colors.red.shade400),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(
//                 LucideIcons.alertTriangle,
//                 color: Colors.red,
//                 size: 24,
//               ),
//               const SizedBox(width: 8),
//               const Text(
//                 'Warning:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           if (isSPIBad)
//             const Text('• Schedule Performance Index (SPI) is below 1.'),
//           if (isCPIBad)
//             const Text('• Cost Performance Index (CPI) is below 1.'),
//           const Text('• Please review suggested actions from AI below.'),
//           if (!showRecommendations)
//             Container(
//               margin: const EdgeInsets.only(top: 12),
//               child: ElevatedButton.icon(
//                 onPressed: isRecLoading ? null : onShowAIRecommendations,
//                 icon: const Icon(Icons.download),
//                 label: isRecLoading
//                     ? const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 8.0),
//                   child: SizedBox(
//                     height: 16,
//                     width: 16,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2.0,
//                       color: Colors.white,
//                     ),
//                   ),
//                 )
//                     : const Text("View AI suggestion"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue.shade600,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 12,
//                     horizontal: 16,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'Dashboard.dart';

class AlertCard extends StatelessWidget {
  final double spi;
  final double cpi;
  final bool showRecommendations;
  final VoidCallback onShowAIRecommendations;
  final bool isRecLoading;
  final List<AIRecommendationDTO> aiRecommendations;

  const AlertCard({
    Key? key,
    required this.spi,
    required this.cpi,
    required this.showRecommendations,
    required this.onShowAIRecommendations,
    required this.isRecLoading,
    required this.aiRecommendations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSPIBad = spi < 1;
    final bool isCPIBad = cpi < 1;
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠️ Project Alerts',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (isSPIBad)
              const Text('• Schedule Performance Index (SPI) is below 1.'),
            if (isCPIBad)
              const Text('• Cost Performance Index (CPI) is below 1.'),
            const Text('• Please review suggested actions from AI below.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isRecLoading ? null : onShowAIRecommendations,
              child: const Text('Show AI Recommendations'),
            ),
            if (isRecLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}

