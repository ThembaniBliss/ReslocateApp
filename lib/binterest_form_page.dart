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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Interest in ${widget.house['name']}'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuestionWidget(
              question: 'Did you like the place?',
              onAnswer: (answer) {
                setState(() {
                  answers['like_place'] = answer;
                });
              },
            ),
            QuestionWidget(
              question: 'Is the location convenient for you?',
              onAnswer: (answer) {
                setState(() {
                  answers['convenient_location'] = answer;
                });
              },
            ),
            QuestionWidget(
              question: 'Do you find the price reasonable?',
              onAnswer: (answer) {
                setState(() {
                  answers['reasonable_price'] = answer;
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
    );
  }
}

class QuestionWidget extends StatelessWidget {
  final String question;
  final Function(String) onAnswer;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => onAnswer('Yes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 23, 30, 39),
       
              ),
              child: const Text('Yes'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => onAnswer('No'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 176, 221, 231),
              ),
              child: const Text('No'),
            ),
          ],

        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
