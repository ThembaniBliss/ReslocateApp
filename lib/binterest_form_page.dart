import 'package:flutter/material.dart';

class InterestFormPage extends StatefulWidget {
  final Map<String, dynamic> house;

  const InterestFormPage({super.key, required this.house});

  @override
  _InterestFormPageState createState() => _InterestFormPageState();
}

class _InterestFormPageState extends State<InterestFormPage> {
  // Map to store answers for each question
  Map<String, String> answers = {};

  // Track selected answers for each question
  String? selectedAmenity;
  String? selectedSafety;
  String? selectedFeature;
  String? selectedCommute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Interest in ${widget.house['name']}'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Which amenity is most important to have nearby?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              buildRadioQuestion(
                questionKey: 'nearby_amenity',
                options: [
                  'Public transportation',
                  'Shopping centers',
                  'Parks or recreational facilities',
                  'Libraries or study spaces',
                ],
                selectedOption: selectedAmenity,
                onSelected: (value) {
                  setState(() {
                    selectedAmenity = value;
                    answers['nearby_amenity'] = value;
                  });
                },
              ),
              const Text(
                'How important is the safety of the neighborhood to you?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              buildRadioQuestion(
                questionKey: 'safety',
                options: [
                  'Very important',
                  'Somewhat important',
                  'Neutral',
                  'Not important',
                ],
                selectedOption: selectedSafety,
                onSelected: (value) {
                  setState(() {
                    selectedSafety = value;
                    answers['safety'] = value;
                  });
                },
              ),
              const Text(
                'Which feature is most important to you in a property?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              buildRadioQuestion(
                questionKey: 'important_feature',
                options: [
                  'High-speed internet',
                  'Study spaces',
                  'Security measures (e.g., gates, cameras, alarms)',
                  'Other (please specify)',
                ],
                selectedOption: selectedFeature,
                onSelected: (value) {
                  setState(() {
                    selectedFeature = value;
                    answers['important_feature'] = value;
                  });
                },
              ),
              const Text(
                'How do you prefer to commute to school or university?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              buildRadioQuestion(
                questionKey: 'commute',
                options: [
                  'Public transportation',
                  'Walking',
                  'Cycling',
                  'Driving or being driven',
                ],
                selectedOption: selectedCommute,
                onSelected: (value) {
                  setState(() {
                    selectedCommute = value;
                    answers['commute'] = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle the submission of answers here
                    // ignore: avoid_print
                    print('User responses: $answers'); // Debug output
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for your responses!'),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Submit Answers'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRadioQuestion({
    required String questionKey,
    required List<String> options,
    required String? selectedOption,
    required Function(String) onSelected,
  }) {
    return Column(
      children: options.map((option) {
        return RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: selectedOption,
          onChanged: (value) {
            if (value != null) {
              onSelected(value);
            }
          },
        );
      }).toList(),
    );
  }
}
