import netP5.*;
import oscP5.*;

OscP5 gOscController;  // Main controller object that oscP5 uses
int gOscReceivePort = 12000;  // Port to receive messages (NOT USED)
String gOscTransmitHost = "127.0.0.1";  // Host to send messages to
int gOscTransmitPort;           // Port to send messages to (SET FOR EACH MESSAGE)
NetAddress gRemoteDestination; // Location to send messages to


// Declare the font class
PFont programmeFont; 


//Declaration and global variables for betting chip class objects
BettingChip chip1, chip2, chip3, chip4;
String[] amazonStock = new String[16];
String[] appleStock = new String[16];
String[] facebookStock = new String[16];
String[] googleStock = new String[16];
ArrayList<BettingChip> chips = new ArrayList<BettingChip>();
boolean locked=false;
int chipSelected=-1;
int xOffset=0;
int yOffset=0;


//Declaration and global variables for suit class objects 
Suit clubs, hearts, spades, diamonds;
Bet clubs1, clubs2, clubs3, clubs4, hearts1, hearts2, hearts3, hearts4, 
  spades1, spades2, spades3, spades4, diamonds1, diamonds2, diamonds3, diamonds4;
ArrayList <Bet> XY = new ArrayList<Bet>();
boolean[] betPlaced = new boolean[16];
boolean[] betPlacedPreviously = new boolean[16];



void setup() {
  size(1280, 800);

  // Load and assign the font
  programmeFont = loadFont("CopperplateGothic-Bold-100.vlw");
  textFont(programmeFont);

  // Initialise the OSC controller.
  gOscController = new OscP5(this, gOscReceivePort);

  // Initialise the OSC remote destination for sending messages.
  gRemoteDestination = new NetAddress(gOscTransmitHost, gOscTransmitPort);

  //Create varialbes with which to parse the stock data, then parse:
  String frontURL = "https://www.quandl.com/api/v3/datasets/WIKI/";
  String startDate =("&start_date="+year()+"-"+(month()-1)+"-"+(day()-3));
  String endDate = ("&end_date="+year()+"-"+month()+"-"+day());
  String endURL ="&collapse=daily&transform=price&api_key=CAy11jsnxbgoBvdws_g2";
  XML amazon = loadXML(frontURL+"AMZN.xml?column_index=4"+startDate+endDate+endURL);
  XML apple = loadXML(frontURL+"AAPL.xml?column_index=4"+startDate+endDate+endURL);
  XML facebook = loadXML(frontURL+"FB.xml?column_index=4"+startDate+endDate+endURL);  
  XML google = loadXML(frontURL+"GOOGL.xml?column_index=4"+startDate+endDate+endURL);
  parseXML(amazon, amazonStock);
  parseXML(apple, appleStock);
  parseXML(facebook, facebookStock);
  parseXML(google, googleStock);

  //Create the chip objects
  chip1 = new BettingChip(width/10*9, height/10*2, 254, 153, 39, 255, 255, 255, "Amazon", amazonStock);
  chip2 = new BettingChip(width/10*9, height/10*4, 100, 100, 100, 255, 255, 255, "Apple", appleStock);
  chip3 = new BettingChip(width/10*9, height/10*6, 60, 90, 151, 255, 255, 255, "Facebook", facebookStock);
  chip4 = new BettingChip(width/10*9, height/10*8, 255, 255, 255, 70, 136, 241, "Google", googleStock);

  //Add the objects to an ArrayList to store and draw on the data for each one later
  chips.add(chip1); 
  chips.add(chip2); 
  chips.add(chip3); 
  chips.add(chip4);

  // Create the suit objects
  clubs = new Suit(width/10*2, height/10*1, "SuitClubs.png");
  hearts = new Suit(width/10*5, height/10*1, "SuitHearts.png");
  spades = new Suit(width/10*5, height/10*5, "SuitSpades.png");
  diamonds = new Suit(width/10*2, height/10*5, "SuitDiamonds.png");

  // Create the processing parameter grid within each suit
  clubs1 = new Bet(-1, width/10*2+(width/40*3), height/10*2, 12001);
  clubs2 = new Bet(-1, width/10*2+(width/40*9), height/10*2, 12003);
  clubs3 = new Bet(-1, width/10*2+(width/40*9), height/10*4, 12005);
  clubs4 = new Bet(-1, width/10*2+(width/40*3), height/10*4, 12007);
  hearts1 = new Bet(-1, width/2+(width/40*3), height/10*2, 12009);
  hearts2 = new Bet(-1, width/2+(width/40*9), height/10*2, 12011);
  hearts3 = new Bet(-1, width/2+(width/40*9), height/10*4, 12013);
  hearts4 = new Bet(-1, width/2+(width/40*3), height/10*4, 12015);
  spades1 = new Bet(-1, width/2+(width/40*3), height/10*6, 12017);
  spades2 = new Bet(-1, width/2+(width/40*9), height/10*6, 12019);
  spades3 = new Bet(-1, width/2+(width/40*9), height/10*8, 12021);
  spades4 = new Bet(-1, width/2+(width/40*3), height/10*8, 12023);
  diamonds1 = new Bet(-1, width/10*2+(width/40*3), height/10*6, 12025);
  diamonds2 = new Bet(-1, width/10*2+(width/40*9), height/10*6, 12027);
  diamonds3 = new Bet(-1, width/10*2+(width/40*9), height/10*8, 12029);
  diamonds4 = new Bet(-1, width/10*2+(width/40*3), height/10*8, 12031);

  // Add the grid boxes to an ArrayLIst to store and draw on the data for each one later
  XY.add(clubs1); 
  XY.add(clubs2); 
  XY.add(clubs3); 
  XY.add(clubs4);
  XY.add(hearts1); 
  XY.add(hearts2); 
  XY.add(hearts3); 
  XY.add(hearts4);
  XY.add(spades1); 
  XY.add(spades2); 
  XY.add(spades3); 
  XY.add(spades4);
  XY.add(diamonds1); 
  XY.add(diamonds2); 
  XY.add(diamonds3); 
  XY.add(diamonds4);
}

// Method for parsing the stock data from Quandl as XML
void parseXML (XML toParse, String [] toStore) {
  for (int i=15; i>=0; i--) {
    int j = (i*2)+1;
    XML[] value = toParse.getChild(1).getChild(35).getChild(j).getChild(3).getChildren();
    toStore[i]=value[0].getContent();
  }
}



void draw() {
  imageMode(CENTER);
  background(50);
  //Show the suits
  clubs.display();
  hearts.display();
  diamonds.display();
  spades.display();
  //Add the accompanying text for each suit and corner
  fill(255);
  textSize(30);
  textAlign(CENTER, BOTTOM);
  text("drums", (width/10*2)+(width/40*6), (height/10*1)-10);
  text("bass", (width/2)+(width/40*6), (height/10*1)-10);  
  textAlign(CENTER, TOP);
  text("lead", (width/10*2)+(width/40*6), (height/10*9)+10);
  text("harmony", (width/2)+(width/40*6), (height/10*9)+10);
  textSize(18);
  textAlign(LEFT, CENTER);
  text("gate", (width/10*2)+15, (height/10*1)+15);
  text("delay", (width/10*2)+15, (height/2)-15);
  text("gate", (width/10*2)+15, (height/2)+15);
  text("delay", (width/10*2)+15, (height/10*9)-15);
  text("gate", (width/2)+15, (height/10*1)+15);
  text("delay", (width/2)+15, (height/2)-15);
  text("gate", (width/2)+15, (height/2)+15);
  text("delay", (width/2)+15, (height/10*9)-15);  
  textAlign(RIGHT, CENTER);
  text("step filter", (width/2)-15, (height/10*1)+15);
  text("lpf adsr", (width/2)-15, (height/2)-15);
  text("step filter", (width/2)-15, (height/2)+15);
  text("lpf adsr", (width/2)-15, (height/10*9)-15);
  text("step filter", (width/10*8)-15, (height/10*1)+15);
  text("lpf adsr", (width/10*8)-15, (height/2)-15);
  text("step filter", (width/10*8)-15, (height/2)+15);
  text("lpf adsr", (width/10*8)-15, (height/10*9)-15);
  textAlign(LEFT, CENTER);
  //Display each chip
  chip1.display();
  chip2.display();
  chip3.display();
  chip4.display();
  //Check whether a chip has been moved this time
  checkChips();
}


//Method for checking if a chip's has been selected.
//Updates currently selected chip if true
void checkChips() {
  //If a chip isn't already selected
  if (locked==false) {
    //Loop through the chips and check if the mouse XY is over any of them. If so, update global variable.
    for (int c=0; c<=3; c++) {
      if (sq(mouseX-(chips.get(c).xPos))+sq(mouseY-(chips.get(c).yPos))<=sq(1+(chips.get(c).diameter/2))) {
        chipSelected=c;
        break;
      } else {
        chipSelected=-1;
      }
    }
  }
}

//Method for updating the bets
void updateBets() {
  // loop through the squares
  for (int i=0; i<XY.size(); i++) {
    betPlacedPreviously[i]=betPlaced[i];
    // for each square, loop through the chips
    for (int j=0; j<chips.size(); j++) {
      //assign active bet statuses
      // if the square centre matches a chip centre there is a bet
      if (chips.get(j).xPos==XY.get(i).x && chips.get(j).yPos==XY.get(i).y) {
        betPlaced[i]=true;
        XY.get(i).setSource(j);
        break;
        // otherwise, there is no bet
      } else {
        betPlaced[i]=false;
      }
    }
  }
}

void clearOldBets() {
  // loop through the squares
  for (int i=0; i<XY.size(); i++) {
    // if there is no bet, but there was previously ...
    if (betPlaced[i]==false && betPlacedPreviously[i]==true) {
      // update the bet source value and turn off the FX
      XY.get(i).setSource(-1);
      OscMessage deactivateParam = new OscMessage("bang");        
      gOscTransmitPort=XY.get(i).port+1;
      gRemoteDestination = new NetAddress(gOscTransmitHost, gOscTransmitPort);        
      gOscController.send(deactivateParam, gRemoteDestination);
      println("DEACTIVATE:"+deactivateParam + "; "+gRemoteDestination); // LEFT IN TO ILLUSTRATE OSC
    }
  }
}


void placeNewBets() {
  // loop through the grid squares
  for (int i=0; i<XY.size(); i++) {
    // for each square, loop through the chips
    for (int j=0; j<chips.size(); j++) {
      // if it's a new bet ...
      if (betPlaced[i]==true && betPlacedPreviously[i]==false) {
        //compile the message string, depending on the type of square
        String text="";
        if (i==0 | i==4 | i==8 | i==12) {
          for (int k=0; k<=15; k++) {
            text=text + str(chips.get(XY.get(i).source).gateSwitches[k])+" ";
          }
        } else 
        if (i==1 | i==5 | i==9 | i==13) {
          for (int k=0; k<=15; k++) {
            text=text + str(chips.get(XY.get(i).source).filterSteps[k])+" ";
          }
        } else 
        if (i==2 | i==6 | i==10 | i==14) {
          for (int k=0; k<=3; k++) {
            text=text + str(chips.get(XY.get(i).source).filterEnvelope[k])+" ";
          }
        } else 
        if (i==3 | i==7 | i==11 | i==15) {
          for (int k=0; k<=2; k++) {
            text=text + (chips.get(XY.get(i).source).delay[k])+" ";
          }
        }
        // Set the FX parameters with chip values:
        OscMessage newMessage = new OscMessage(text);        
        gOscTransmitPort=XY.get(i).port;
        gRemoteDestination = new NetAddress(gOscTransmitHost, gOscTransmitPort);        
        gOscController.send(newMessage, gRemoteDestination);
        println(newMessage + "; "+gRemoteDestination); // LEFT IN TO ILLUSTRATE OSC
        // Turn on the FX
        OscMessage activateParam = new OscMessage("bang");        
        gOscTransmitPort=XY.get(i).port+1;
        gRemoteDestination = new NetAddress(gOscTransmitHost, gOscTransmitPort);        
        gOscController.send(activateParam, gRemoteDestination);
        println("ACTIVATE:"+activateParam + "; "+gRemoteDestination); // LEFT IN TO ILLUSTRATE OSC
        break;
      }
    }
  }
}

// If the mouse is pressed and a chip is selected, calculate the offset from cursor to chip centre
void mousePressed() {
  if (chipSelected >-1) {
    locked=true;
    xOffset= mouseX-(chips.get(chipSelected).xPos);
    yOffset= mouseY-(chips.get(chipSelected).yPos);
  } else {
    locked=false;
  }
}

// If the mouse is pressed and a chip is selected, move the chip in relation to the cursor
void mouseDragged() {
  if (locked==true) {
    chips.get(chipSelected).xPos=mouseX-xOffset;
    chips.get(chipSelected).yPos=mouseY-yOffset;
  }
}

//When the mouse is released refresh all chip positions and resulting bets 
void mouseReleased() {
  locked=false;
  chip1.alignChip();
  chip2.alignChip();
  chip3.alignChip();
  chip4.alignChip();
  updateBets();
  clearOldBets();  
  placeNewBets();
}