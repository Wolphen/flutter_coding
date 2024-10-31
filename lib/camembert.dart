import 'package:flutter/material.dart';
import 'package:flutter_coding/bdd/connectToDTB.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartPage extends StatelessWidget {
  final MongoDBService mongoDBService = MongoDBService();

  PieChartPage({Key? key}) : super(key: key);

  Future<Map<String, Map<String, double>>> fetchSuccessRates() async {
    await mongoDBService.connect();
    return await mongoDBService.getSuccessRatesByCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiques de Réussite'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                await mongoDBService.generateRandomNotes();
                // Rafraîchit la page après la génération
                (context as Element).reassemble();
              },
              child: Text('Générer des notes aléatoires'),
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, Map<String, double>>>(
              future: fetchSuccessRates(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Erreur : ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Aucune donnée disponible."));
                }

                final data = snapshot.data!;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: data.entries.map((entry) {
                    final category = entry.key;
                    final successData = entry.value;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          category,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 150,
                          width: 150,
                          child: PieChart(
                            PieChartData(
                              sections: successData.entries.map((entry) {
                                return PieChartSectionData(
                                  color: entry.key == 'Réussite' ? Colors.green : Colors.red,
                                  value: entry.value,
                                  title: '${entry.key}: ${entry.value.toStringAsFixed(1)}%',
                                  radius: 50,
                                  titleStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
