import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Calculator App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 124, 83, 150)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
  String buttonValue = '';
  void appendToValue(String value) {
    buttonValue += value;
    notifyListeners();
  }
  void clearValue() {
    buttonValue = '';
    notifyListeners();
  }

  // this function acts as a controller depending on the operator we click on
  void evalValue(String value, String label, BuildContext context) {
    // hitting C clears the calculator
    if (label == 'C') {
      clearValue();
    } else if (label == '=') {
      // once we hit =, is when we parse the string with all the inputs
      int result = convertToOperators(value, context);
      if (result == 0) {
        clearValue();
      } else {
        buttonValue = result.toString();
      }
    }
  }

  // this function parses the string and separates into operands and operators
  int convertToOperators(String value, BuildContext context) {
    List<String> parts = value.split(RegExp(r'[-+x/]'));
    String operator = value.replaceAll(RegExp(r'[0-9]'), '');
    // we handle errors when the syntax is incorrect
    // if we hit any operator more than once, so we cannot do 1++2
    // or if we hit = with no operators
    if (operator.length > 1) {
        showErrorSnackbar(context, 'Too many operators');
        return 0;
    } else if (operator.isEmpty) {
        showErrorSnackbar(context, 'Invalid operator');
        return 0;
    }

    int operand1 = int.parse(parts[0]);
    int operand2 = int.parse(parts.length > 1 ? parts[1] : '');

    // this case is for when we do something like 1+=
    if (parts[1] == "" ) {
        showErrorSnackbar(context, 'Missing operands');
        return 0;      
    }


    // handling the operations
    switch (operator) {
      case '+':
        return operand1 + operand2;
      case '-':
        return operand1 - operand2;
      case 'x':
        return operand1 * operand2;
      case '/':
        if (operand2 == 0) {
          throw Exception('Division by zero');
        }
        // only going to handle integer division
        return operand1 ~/ operand2;

      // handling other edge cases
      default:
        showErrorSnackbar(context, 'Invalid values');
        return 0;
    }
  }

  // function to show the error message, gets activated when clicking =
  void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3), // Adjust duration as needed
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
          },
        ),
      ),
    );
  }
}


class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var buttonValue = appState.buttonValue;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to your calculator!',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w200,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      body: Center(
        child: 
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BigCard(pair: buttonValue),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child:
                  CalculatorKeypad(
                      onPressed: (label) {
                        // it is all processed in a string that we append to as we click
                        context.read<MyAppState>().appendToValue(label);
                        context.read<MyAppState>().evalValue(buttonValue, label, context);
                      },
                    ),
              ),
            ],
          ),
      )
    );
  }
}

// screen with the numbers and operators
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final String pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return SizedBox(
      width: 360,
      child: Card(
        color: theme.colorScheme.primaryContainer,
        child: 
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(pair, style: style),
        ),
      )

    );
  }
}

// calculator layout
class CalculatorKeypad extends StatelessWidget {
  final Function(String) onPressed;

  const CalculatorKeypad({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(['7', '8', '9', '/'], context),
        _buildRow(['4', '5', '6', 'x'], context),
        _buildRow(['1', '2', '3', '-'], context),
        _buildRow(['C', '0', '=', '+'], context),
      ],
    );
  }

  Widget _buildRow(List<String> buttonLabels, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttonLabels
          .map((label) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => onPressed(label),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: EdgeInsets.all(20.0),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}