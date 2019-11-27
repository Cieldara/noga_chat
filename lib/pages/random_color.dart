import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';

enum Game_states {
  WAITING_FOR_NEW_GAME,
  REMEMBERING_COLOR,
  GUESSING,
  GAME_END,
}

class RandomColorPage extends StatefulWidget {
  @override
  _RandomColorPageState createState() => _RandomColorPageState();
}

class _RandomColorPageState extends State<RandomColorPage> {
  Game_states gameState = Game_states.WAITING_FOR_NEW_GAME;
  HSVColor _colorToGuess;
  HSVColor _currentColor;
  double score;

  _startNewGame() {
    Random random = new Random();
    setState(() {
      this._colorToGuess = HSVColor.fromColor(Color.fromRGBO(
          random.nextInt(256), random.nextInt(256), random.nextInt(256), 1));
      this.gameState = Game_states.REMEMBERING_COLOR;
      this._currentColor = HSVColor.fromColor(Colors.blue);
      this.score = 0;
    });

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        this.gameState = Game_states.GUESSING;
      });
    });
  }

  double _computeScore(Color colorToGuess, Color colorGuessed) {

    double rMean = (colorToGuess.red + colorGuessed.red) / 2.0;
    double distanceRed = ((colorToGuess.red - colorGuessed.red) *
            (colorToGuess.red - colorGuessed.red))
        .toDouble();
    double distanceGreen = ((colorToGuess.green - colorGuessed.green) *
            (colorToGuess.green - colorGuessed.green))
        .toDouble();
    double distanceBlue = ((colorToGuess.blue - colorGuessed.blue) *
            (colorToGuess.blue - colorGuessed.blue))
        .toDouble();

    return sqrt((2.0 + (rMean / 256.0)) * distanceRed +
        4.0 * distanceGreen +
        (2.0 + (255.0 - rMean) / 256.0) * distanceBlue).floorToDouble();
  }

  _validate() {
    setState(() {
      this.gameState = Game_states.GAME_END;
      this.score = _computeScore(
          this._colorToGuess.toColor(), this._currentColor.toColor());
    });
  }

  Widget _buildNewGameScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          color: Colors.blue,
          child: Text(
            'Start a new game',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            _startNewGame();
          },
        )
      ],
    );
  }

  Widget _buildRememberColorScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Remember this color :'),
        Container(
          height: 50,
          color: this._colorToGuess.toColor(),
        )
      ],
    );
  }

  Widget _buildGuessingScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Choose your color :'),
        Container(
          height: 50,
          color: this._currentColor.toColor(),
        ),
        PaletteValuePicker(
          color: this._currentColor,
          onChanged: (newColor) {
            setState(() {
              this._currentColor = newColor;
            });
          },
        ),
        RaisedButton(
          color: Colors.blue,
          child: Text(
            'Validate',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: _validate,
        )
      ],
    );
  }

  Widget _buildGameEndScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('You scored :'),
        Text(this.score.toString()),
        RaisedButton(
          color: Colors.blue,
          child: Text(
            'New game',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: _startNewGame,
        )
      ],
    );
  }

  Widget _buildPageAccordingToGameState() {
    Widget toBuild;
    switch (this.gameState) {
      case Game_states.WAITING_FOR_NEW_GAME:
        toBuild = _buildNewGameScreen();
        break;
      case Game_states.REMEMBERING_COLOR:
        toBuild = _buildRememberColorScreen();
        break;
      case Game_states.GUESSING:
        toBuild = _buildGuessingScreen();
        break;
      case Game_states.GAME_END:
        toBuild = _buildGameEndScreen();
        break;
      default:
        toBuild = Text('Error');
    }

    return toBuild;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Don't show the leading button
        title: new Row(
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                }),
            Text('Guess the color'),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: _buildPageAccordingToGameState(),
        ),
      ),
    ));
  }
}
