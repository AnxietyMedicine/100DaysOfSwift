# Project 5 - Word Scramble

This project includes solutions to the challenges.

## Challenges

1. Disallow answers that are shorter than three letters or are just our start word. For the three-letter check, the easiest thing to do is put a check into `isReal()` that returns false if the word length is under three letters. For the second part, just compare the start word against their input word and return false if they are the same.
2. Refactor all the `else` statements we just added so that they call a new method called `showErrorMessage()`. This should accept an error message and a title, and do all the `UIAlertController` work from there.
3. Add a left bar button item that calls `startGame()`, so users can restart with a new word whenever they want to.

## Screenshots

### Light Mode

<div>
  <img src="Screenshots/Light/Light_01.png" width="250">
  <img src="Screenshots/Light/Light_02.png" width="250">
  <img src="Screenshots/Light/Light_03.png" width="250">
  <img src="Screenshots/Light/Light_04.png" width="250">
  <img src="Screenshots/Light/Light_05.png" width="250">
</div>

### Dark Mode

<div>
  <img src="Screenshots/Dark/Dark_01.png" width="250">
  <img src="Screenshots/Dark/Dark_02.png" width="250">
  <img src="Screenshots/Dark/Dark_03.png" width="250">
  <img src="Screenshots/Dark/Dark_04.png" width="250">
  <img src="Screenshots/Dark/Dark_05.png" width="250">
</div>
