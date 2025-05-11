import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'diagnosis_result_page.dart';
import 'services/firebase_storage_service.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  List<Map<String, dynamic>> _previousDiagnoses = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  
  @override
  void initState() {
    super.initState();
    _loadDiagnosesFromFirebase();
  }
  
  // Load diagnoses from Firebase
  Future<void> _loadDiagnosesFromFirebase() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final images = await FirebaseStorageService.getSkinImages();
      
      setState(() {
        _previousDiagnoses = images.map((image) {
          // Extract diagnosis information or use defaults
          final String diagnosis = image['diagnosis'] ?? 'Unknown';
          String riskLevel = 'Low';
          int score = 0;
          
          // Determine risk level based on diagnosis
          if (diagnosis.contains('Melanoma') || diagnosis.contains('Squamous Cell Carcinoma')) {
            riskLevel = 'High';
            score = 85;
          } else if (diagnosis.contains('Basal Cell Carcinoma')) {
            riskLevel = 'Moderate';
            score = 60;
          } else if (diagnosis.contains('Nevus') || diagnosis.contains('Benign')) {
            riskLevel = 'Low';
            score = 20;
          }
          
          return {
            'id': image['id'],
            'date': image['upload_time'] != null 
                ? (image['upload_time'] as Timestamp).toDate() 
                : DateTime.now(),
            'diagnosis': diagnosis,
            'risk_level': riskLevel,
            'score': score,
            'image_path': image['image_url'],
            'notes': 'Analyzed with AI model',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading diagnoses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  final List<String> _filterOptions = ['All', 'High Risk', 'Moderate Risk', 'Low Risk'];

  List<Map<String, dynamic>> get _filteredDiagnoses {
    if (_selectedFilter == 'All') return _previousDiagnoses;
    
    final String riskLevel = _selectedFilter.split(' ')[0].toLowerCase();
    return _previousDiagnoses.where((diagnosis) => 
      diagnosis['risk_level'].toString().toLowerCase() == riskLevel
    ).toList();
  }
  

  @override
  Widget build(BuildContext context) {
    // Use the _filteredDiagnoses getter to get filtered diagnoses
    final List<Map<String, dynamic>> filteredDiagnoses = _filteredDiagnoses;
            
    // Show loading indicator while fetching data
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Archive")),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Loading diagnoses..."),
            ],
          ),
        ),
        );
      
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis History'),
        backgroundColor: const Color(0xFF0D47A1),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDiagnosesFromFirebase,
            tooltip: 'Refresh diagnoses',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDiagnosesFromFirebase,
        child: Column(
        children: [
          // Filter options
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Filter by: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _filterOptions.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Diagnosis list
          Expanded(
            child: filteredDiagnoses.isEmpty
                ? const Center(child: Text('No diagnoses found'))
                : ListView.builder(
                    itemCount: filteredDiagnoses.length,
                    itemBuilder: (context, index) {
                        final diagnosis = filteredDiagnoses[index];
                      final date = diagnosis['date'] as DateTime;
                      final formattedDate = DateFormat('EEEE, d MMM yyyy | HH:mm').format(date);
                      
                      // Get color based on risk level
                      Color riskColor;
                      switch (diagnosis['risk_level']) {
                        case 'High':
                          riskColor = Colors.red;
                          break;
                        case 'Moderate':
                          riskColor = Colors.orange;
                          break;
                        default:
                          riskColor = Colors.green;
                      }
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: InkWell(
                          onTap: () {
                            // Navigate to diagnosis details
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DiagnosisResultPage(
                                  imagePath: diagnosis['image_path'],
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    diagnosis['image_path'],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            diagnosis['diagnosis'],
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: riskColor.withAlpha(50),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${diagnosis['score']}%',
                                              style: TextStyle(color: riskColor, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${diagnosis['risk_level']} Risk',
                                        style: TextStyle(color: riskColor, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        diagnosis['notes'],
                                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          ],
        ),
      ),
    );
  }
}
