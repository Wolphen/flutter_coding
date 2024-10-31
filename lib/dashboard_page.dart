import 'package:flutter/material.dart';
import 'package:flutter_coding/bdd/connectToDTB.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final MongoDBService mongoDBService = MongoDBService();
  List<Map<String, dynamic>> results = [];
  List<Map<String, dynamic>> filteredResults = [];
  String searchQuery = "";
  String selectedYear = "Toutes les années";

  @override
  void initState() {
    super.initState();
    fetchRecentResults();
  }

  Future<void> fetchRecentResults() async {
    await mongoDBService.connect();
    final notes = await mongoDBService.getRecentResults();
    setState(() {
      results = notes;
      filteredResults = notes;
    });
  }

  void filterResults() {
    setState(() {
      filteredResults = results.where((result) {
        final matchesQuery = result['nom']
            .toLowerCase()
            .contains(searchQuery.toLowerCase()) ||
            result['prenom'].toLowerCase().contains(searchQuery.toLowerCase());
        final matchesYear = selectedYear == "Toutes les années" ||
            result['annee'] == selectedYear;
        return matchesQuery && matchesYear;
      }).toList();
    });
  }

  Future<void> addRandomNotes() async {
    // Ajoute des notes aléatoires aux étudiants via MongoDBService
    await mongoDBService.generateRandomNotes();
    await fetchRecentResults(); // Rafraîchit les résultats pour inclure les nouvelles notes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Notes aléatoires ajoutées aux candidats!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tableau de Bord des Candidats")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barre de recherche par nom/prénom
            TextField(
              decoration: InputDecoration(
                labelText: "Rechercher par Nom/Prénom",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                searchQuery = value;
                filterResults();
              },
            ),
            SizedBox(height: 16),

            // Filtre par année scolaire
            DropdownButton<String>(
              value: selectedYear,
              items: ["Toutes les années", "2023", "2022"]
                  .map((year) => DropdownMenuItem(value: year, child: Text(year)))
                  .toList(),
              onChanged: (value) {
                selectedYear = value!;
                filterResults();
              },
            ),
            SizedBox(height: 16),

            // Tableau des résultats
            Expanded(
              child: ListView.builder(
                itemCount: filteredResults.length,
                itemBuilder: (context, index) {
                  final result = filteredResults[index];
                  return ListTile(
                    title: Text("${result['prenom']} ${result['nom']}"),
                    subtitle: Text("Année : ${result['annee']} - Score : ${result['score']}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addRandomNotes,
        child: Icon(Icons.note_add),
        tooltip: 'Ajouter des notes aléatoires',
      ),
    );
  }
}
