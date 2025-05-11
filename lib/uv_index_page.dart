import 'package:flutter/material.dart';

class UVIndexPage extends StatefulWidget {
  const UVIndexPage({super.key});

  @override
  State<UVIndexPage> createState() => _UVIndexPageState();
}

class _UVIndexPageState extends State<UVIndexPage> {
  // Sample UV index data - in a real app, this would come from an API
  final int currentUVIndex = 7;
  final Map<String, dynamic> forecast = {
    'Morning': 4,
    'Noon': 9,
    'Afternoon': 7,
    'Evening': 3,
  };

  // Get color based on UV index severity
  Color _getUVIndexColor(int index) {
    if (index <= 2) return Colors.green;
    if (index <= 5) return Colors.yellow;
    if (index <= 7) return Colors.orange;
    if (index <= 10) return Colors.red;
    return Colors.purple;
  }

  // Get risk level based on UV index
  String _getRiskLevel(int index) {
    if (index <= 2) return 'Low';
    if (index <= 5) return 'Moderate';
    if (index <= 7) return 'High';
    if (index <= 10) return 'Very High';
    return 'Extreme';
  }

  // Get protection recommendations
  List<Map<String, dynamic>> _getRecommendations(int index) {
    final List<Map<String, dynamic>> baseRecommendations = [
      {
        'icon': Icons.wb_sunny,
        'title': 'Seek Shade',
        'description': 'Stay in shade during midday hours',
      },
      {
        'icon': Icons.face,
        'title': 'Cover Up',
        'description': 'Wear protective clothing and hats',
      },
      {
        'icon': Icons.water_drop,
        'title': 'Sunscreen',
        'description': 'Apply SPF 30+ sunscreen every 2 hours',
      },
    ];
    
    if (index >= 6) {
      baseRecommendations.add({
        'icon': Icons.watch_later,
        'title': 'Limit Time Outside',
        'description': 'Minimize outdoor activities between 10am-4pm',
      });
    }
    
    if (index >= 8) {
      baseRecommendations.add({
        'icon': Icons.visibility_off,
        'title': 'Eye Protection',
        'description': 'Wear UV-blocking sunglasses',
      });
    }
    
    return baseRecommendations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UV Index'),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current UV Index
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Current UV Index',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getUVIndexColor(currentUVIndex),
                        boxShadow: [
                          BoxShadow(
                            color: _getUVIndexColor(currentUVIndex).withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$currentUVIndex',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getRiskLevel(currentUVIndex),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getUVIndexColor(currentUVIndex),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Updated: Today, 12:30 PM',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Today's Forecast
            const Text(
              'Today\'s Forecast',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: forecast.length,
                itemBuilder: (context, index) {
                  final time = forecast.keys.elementAt(index);
                  final value = forecast.values.elementAt(index);
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(time, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getUVIndexColor(value),
                          ),
                          child: Center(
                            child: Text(
                              '$value',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Protection Recommendations
            const Text(
              'Protection Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._getRecommendations(currentUVIndex).map((recommendation) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(recommendation['icon'], color: Colors.blue),
                  title: Text(recommendation['title']),
                  subtitle: Text(recommendation['description']),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
