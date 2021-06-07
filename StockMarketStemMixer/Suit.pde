//Class for the suit object (i.e. main grid of 4 squares in UI)

class Suit {
  //Display variables
  final int suitWidth = width/10*3;
  final int suitHeight = height/10*4;
  final color boardColour[] = {20, 144, 23};
  final color boardLines = 255;
  int xPos;
  int yPos;
  
  //Load PImage class to display suit images
  //Suit image files downloaded from wikimedia commons
  PImage suits;
  String suitImage;
  // https://commons.wikimedia.org/wiki/File:SuitClubs.svg
  // https://commons.wikimedia.org/wiki/File:Suit_Hearts.svg
  // https://commons.wikimedia.org/wiki/File:SuitSpades.svg
  // https://commons.wikimedia.org/wiki/File:SuitDiamonds.svg


  // Constructor method for class
  Suit(int x, int y, String suit) {
    xPos=x;
    yPos=y;
    suitImage=suit;
  }


  // Rendering method 
  void display() {
    // draw the main grid box for the suit
    stroke(255);
    fill(boardColour[0], boardColour[1], boardColour[2]);
    strokeWeight(height/160);
    rect(xPos, yPos, suitWidth, suitHeight);
    // draw the sub-grid boxes
    noStroke();
    rect(xPos, yPos, suitWidth/2, suitHeight/2);
    rect(xPos+suitWidth/2, yPos, suitWidth/2, suitHeight/2);
    rect(xPos+suitWidth/2, yPos+suitHeight/2, suitWidth/2, suitHeight/2);   
    rect(xPos, yPos+suitHeight/2, suitWidth/2, suitHeight/2);
    // draw the suit images on top
    suits=loadImage(suitImage);
    image(suits, xPos+(suitWidth/2), yPos+(suitHeight/2), suitWidth/2, suitWidth/2*1.083);
  }
}