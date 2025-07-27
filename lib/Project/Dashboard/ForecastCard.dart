// import 'package:flutter/material.dart';
//
// class ForecastCard extends StatelessWidget {
//   const ForecastCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Đây là dữ liệu mẫu, bạn nên fetch từ API bằng FutureBuilder
//     final eac = 150000;
//     final etc = 50000;
//     final vac = -10000;
//     final edac = 6;
//
//     return Card(
//       color: Colors.blue[50],
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('📊 Project Forecast', style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             Text('EAC: \$${eac.toString()}'),
//             Text('ETC: \$${etc.toString()}'),
//             Text('VAC: \$${vac.toString()}'),
//             Text('EDAC: $edac months'),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'Dashboard.dart';

class ForecastCard extends StatelessWidget {
  final ProjectMetricData metric;
  const ForecastCard({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Project Forecast', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('EAC: \$${metric.estimateAtCompletion}'),
            Text('ETC: \$${metric.estimateToComplete}'),
            Text('VAC: \$${metric.varianceAtCompletion}'),
            Text('EDAC: ${metric.estimateDurationAtCompletion} months'),
          ],
        ),
      ),
    );
  }
}

