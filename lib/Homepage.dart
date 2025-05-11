import 'package:flutter/material.dart';
import 'uv_index_page.dart'; // Importation de la page UV Index
import 'archive_page.dart'; // Importation de la page Archive
import 'e_doctor_page.dart'; // Importation de la page E-Doctor
import 'scan_camera_page.dart'; // Importation de la page Scan

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isExpanded =
      false; // Variable pour contrôler si la description est étendue

  // Liste des pages à afficher pour chaque icône
  final List<Widget> _pages = [
    const Center(child: Text('Home Page', style: TextStyle(fontSize: 24))),
    const UVIndexPage(), // Page UV Index
    const Center(child: Text('Scan Page', style: TextStyle(fontSize: 24))), // Placeholder for Scan
    const ArchivePage(), // Page Archive
    const EDoctorPage(), // Page E-Doctor
  ];

  // Fonction pour changer de page
  void _onItemTapped(int index) {
    if (index == 2) {
      // Si l'index correspond au "Scan", on navigue vers la ScanPage
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const ScanCameraPage()) // Naviguer vers la ScanPage
          );
    } else {
      setState(() {
        _selectedIndex = index; // Mettre à jour la page sélectionnée
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin Cancer Detection'),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: _selectedIndex == 0 ? SingleChildScrollView(
        // Utilisation du SingleChildScrollView pour rendre la page défilable
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Hi Marina" text
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Hi ..',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            // "Let's keep your skin healthy" text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Let\'s keep your skin healthy.',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
            // Diagnosis of skin cancer section with image and description
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded; // Change l'état de l'expansion
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Image
                      Image.asset(
                        'assets/images/Home_Page_skin.png', // Remplacez par le chemin réel de l'image
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      // Title
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Diagnosis of skin cancer - what happens next?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Short description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'It is a diagnosis that is frightening and often leaves those affected and their family ...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ),
                      // Full description when expanded
                      if (_isExpanded)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Early diagnosis of skin cancer is essential as it greatly increases the chances of successful treatment and full recovery. '
                            'Detecting the disease early allows simpler, quicker, and less invasive treatments, reducing the need for complex surgeries or aggressive therapies like chemotherapy. '
                            'It prevents serious complications, such as metastasis—when cancer spreads to other organs—which can be life-threatening. '
                            'Additionally, an early diagnosis significantly lowers medical expenses and minimizes psychological stress for patients and their families. '
                            'Finally, promoting early detection raises awareness about sun protection, encouraging preventive behaviors and regular medical check-ups.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
                height: 20), // Space between text and the page content

            // Adding the "Previous Diagnoses" Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Previous Diagnoses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Creating the "Previous Diagnoses" section dynamically
                  // You can add data from your database here
                  // Placeholder items for now
                  Column(
                    children: [
                      _previousDiagnosisCard(
                          'Chicken Pox',
                          'Varicella zoster',
                          'Rear, seburn, redness',
                          'Sunday, 3 Aug 2023 | 15:00'),
                      _previousDiagnosisCard(
                          'Chicken Pox',
                          'Varicella zoster',
                          'Rear, seburn, redness',
                          'Sunday, 5 Aug 2023 | 10:00'),
                      _previousDiagnosisCard('Common Warts', 'Verruca vulgaris',
                          'Dark, bumps on skin', 'Monday, 7 Aug 2023 | 18:00'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ) : _pages[_selectedIndex], // Display the selected page when not on home page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          // Icône Home
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          // Icône UV Index
          const BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny),
            label: 'UV Index',
          ),
          // Icône Scan (bouton central flottant)
          BottomNavigationBarItem(
            icon: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue, // Couleur de fond
              ),
              child: const Icon(
                Icons.camera_alt, // Icône de caméra
                color: Colors.white, // Couleur de l'icône
              ),
            ),
            label: 'Scan', // Texte de l'icône
          ),
          // Icône Archive
          const BottomNavigationBarItem(
            icon: Icon(Icons.archive),
            label: 'Archive',
          ),
          // Icône E-Doctor
          const BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'E-Doctor',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF0D47A1),
      ),
    );
  }

  // Custom method to create the Previous Diagnosis card
  Widget _previousDiagnosisCard(
      String diagnosis, String disease, String description, String date) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(
              'assets/images/previous_diagnosis_image.png'), // Placeholder image
        ),
        title: Text(diagnosis, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(disease,
                style: TextStyle(color: Colors.black.withOpacity(0.6))),
            Text(description,
                style: TextStyle(color: Colors.black.withOpacity(0.6))),
            Text(date, style: TextStyle(color: Colors.black.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}
