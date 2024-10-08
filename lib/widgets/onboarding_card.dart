import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardingCard extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;

  const OnboardingCard({
    required this.image,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            // Make the image take up available space
            child: Image.asset(image),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.black26, // Title color
                      fontSize: 25, // Title font size
                      fontWeight: FontWeight.bold, // Title font weight
                    ),
                    children:
                        _buildTextSpans(title), // Use _buildTextSpans for title
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.black, // Description color
                      fontSize: 15, // Description font size
                      fontWeight: FontWeight.w300, // Description font weight
                    ),
                    children: _buildTextSpans(
                        description), // Use _buildTextSpans for description
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Rounded corners
              ),
              backgroundColor: Color(0xFF17C2EC),
              padding:
                  const EdgeInsets.symmetric(vertical: 16), // Increased height
            ),
            child: SizedBox(
              width: 300, // Makes the button take full width
              child: Text(
                buttonText,
                style: const TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center, // Center the text
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildTextSpans(String text) {
    final highlightColor = const Color(0xFF17C2EC);

    // Define words/phrases to be highlighted
    final wordsToHighlight = ['immunity', 'vaccines', 'vaccine ID'];

    // Use a regular expression to find all the words
    List<TextSpan> spans = [];
    String lowerText = text.toLowerCase();

    int start = 0;
    for (final word in wordsToHighlight) {
      String lowerWord = word.toLowerCase();
      int index = lowerText.indexOf(lowerWord, start);

      while (index != -1) {
        // Add non-highlighted text before the word
        if (index > start) {
          spans.add(TextSpan(
            text: text.substring(start, index),
            style: const TextStyle(color: Colors.black),
          ));
        }

        // Add the highlighted word
        spans.add(TextSpan(
          text: text.substring(index, index + word.length),
          style: TextStyle(color: highlightColor),
        ));

        start = index + word.length;
        index = lowerText.indexOf(lowerWord, start);
      }
    }

    // Add the remaining non-highlighted text after the last word
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: const TextStyle(color: Colors.black),
      ));
    }

    return spans;
  }
}
