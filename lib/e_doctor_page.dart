import 'package:flutter/material.dart';

class EDoctorPage extends StatefulWidget {
  const EDoctorPage({super.key});

  @override
  State<EDoctorPage> createState() => _EDoctorPageState();
}

class _EDoctorPageState extends State<EDoctorPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  
  // Appointment booking variables
  String? _selectedDoctor;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;

  // List of available doctors
  final List<Map<String, dynamic>> _doctors = [
    {
      'name': 'Dr. Sarah Johnson',
      'specialty': 'Dermatologist',
      'rating': 4.9,
      'image': 'assets/images/previous_diagnosis_image.png',
      'available': true,
    },
    {
      'name': 'Dr. Michael Chen',
      'specialty': 'Oncologist',
      'rating': 4.8,
      'image': 'assets/images/previous_diagnosis_image.png',
      'available': true,
    },
    {
      'name': 'Dr. Emily Rodriguez',
      'specialty': 'Dermatologist',
      'rating': 4.7,
      'image': 'assets/images/previous_diagnosis_image.png',
      'available': false,
    },
  ];

  // Sample automated responses
  final List<String> _autoResponses = [
    "I recommend applying sunscreen with at least SPF 30 daily, even on cloudy days.",
    "Based on your symptoms, I suggest scheduling an in-person appointment for a thorough examination.",
    "Remember to perform regular skin self-examinations and look for any changes in existing moles.",
    "Stay hydrated and maintain a balanced diet rich in antioxidants for healthier skin.",
    "Avoid tanning beds and excessive sun exposure, especially between 10 AM and 4 PM.",
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    setState(() {
      // Add user message
      _messages.add({
        'text': message,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _messageController.clear();
      _isLoading = true;
    });

    // Scroll to bottom
    _scrollToBottom();

    // Simulate doctor response after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          // Add doctor response
          _messages.add({
            'text': _autoResponses[_messages.length % _autoResponses.length],
            'isUser': false,
            'timestamp': DateTime.now(),
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Doctor'),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: Column(
        children: [
          // Available doctors section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Doctors',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = _doctors[index];
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: Image.asset(
                                    doctor['image'],
                                    height: 70,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: doctor['available'] ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor['name'],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    doctor['specialty'],
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.amber, size: 14),
                                      Text(
                                        ' ${doctor['rating']}',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Chat section
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Chat header
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline),
                      const SizedBox(width: 8),
                      const Text(
                        'Chat with Doctor',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          // Show appointment dialog
                          _showAppointmentDialog(context);
                        },
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: const Text('Book Appointment'),
                        style: TextButton.styleFrom(foregroundColor: Colors.blue),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Chat messages
                  Expanded(
                    child: _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'Start a conversation with our doctors',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Ask about skin conditions, treatments, or prevention',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              final isUser = message['isUser'] as bool;

                              return Align(
                                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isUser ? Colors.blue[100] : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(message['text']),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Loading indicator
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundImage: AssetImage('assets/images/previous_diagnosis_image.png'),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 4),
                                SizedBox(
                                  width: 8,
                                  height: 8,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('Typing...', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Message input
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.attach_file),
                          onPressed: () {
                            // Attach file functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Attach file feature coming soon')),
                            );
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type your message...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.blue),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setDialogState) {
          return AlertDialog(
            title: const Text('Book an Appointment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Doctor selection
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select Doctor'),
                  items: _doctors.map((doctor) {
                    return DropdownMenuItem<String>(
                      value: doctor['name'] as String,
                      child: Text(doctor['name'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // Store selected doctor
                    setDialogState(() {
                      _selectedDoctor = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Date selection
                InkWell(
                  onTap: () async {
                    // Show date picker
                    final DateTime? pickedDate = await showDatePicker(
                      context: stateContext,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    
                    // Update the UI if a date was picked
                    if (pickedDate != null) {
                      setDialogState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Date'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_selectedDate.toString().substring(0, 10)),
                        const Icon(Icons.calendar_today, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Time selection
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select Time'),
                  items: ['9:00 AM', '10:00 AM', '11:00 AM', '2:00 PM', '3:00 PM'].map((time) {
                    return DropdownMenuItem<String>(
                      value: time,
                      child: Text(time),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // Store selected time
                    setDialogState(() {
                      _selectedTime = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Validate that all fields are selected
                  if (_selectedDoctor == null || _selectedTime == null) {
                    ScaffoldMessenger.of(stateContext).showSnackBar(
                      const SnackBar(content: Text('Please select all fields')),
                    );
                    return;
                  }
                  
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Appointment with $_selectedDoctor booked for ${_selectedDate.toString().substring(0, 10)} at $_selectedTime')),
                  );
                },
                child: const Text('Book'),
              ),
            ],
          );
        },
      ),
    );
  }
}
