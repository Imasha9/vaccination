import 'package:flutter/material.dart';

class OnboardingCard extends StatelessWidget {
  final String image, title, description, buttonText;
  final Function onPressed;

  const OnboardingCard({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.80,
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Image.asset(
              image,
              fit: BoxFit.contain,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.black26,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                    children: _buildTextSpans(title),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                    ),
                    children: _buildTextSpans(description),
                  ),
                ),
              ),
            ],
          ),
          MaterialButton(
            minWidth: 300,
            onPressed: () => onPressed(),
            color: const Color(0xFF17C2EC),
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
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
