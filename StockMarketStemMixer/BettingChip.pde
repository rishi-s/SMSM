//Class for the BettingChip object

class BettingChip {
  //Display variables
  final float diameter = height*0.125;  
  final int xOrigin;
  final int yOrigin;
  int xPos;
  int yPos;
  color chipColour;
  color chipBackground;
  String name;
  
  //Data varialble arrays
  int[] gateSwitches= new int[16];
  int[] filterSteps= new int[16];
  int[] filterEnvelope= new int[4];
  String[] delay= new String[3];

  // Constructor method
  BettingChip(int x, int y, int r, int g, int b, int rb, int gb, int bb, String stock, String[]stockHistory) {
    xPos = xOrigin = x;
    yPos = yOrigin = y;
    chipColour = color(r, g, b);
    chipBackground = color(rb, gb, bb);
    name = stock;
    float total=0.0;
    float high = float(stockHistory[0]);
    float low = float(stockHistory[0]);
    float mean;

    // get useful values for cotrollers
    for (int i=0; i<=15; i++) {
      //get low
      if (float(stockHistory[i]) < low) {
        low=float(stockHistory[i]);
      }
      //get high
      if (float(stockHistory[i]) > high) {
        high=float(stockHistory[i]);
      }
      //get total
      total+=float(stockHistory[i]);
    }
    
    // calculate mean
    mean=total/16;

    // set a gate open/close sequence by checking each day against the mean
    // normalise the range to set a step filter sequence mapped to MIDI notes
    for (int i=0; i<=15; i++) {
      // set the gate switch values      
      if (float(stockHistory[i]) > mean) {
        gateSwitches[i]=1;
      } else {
        gateSwitches[i]=0;
      }
      // constrain step values from 60 to 127 (C4 upwards), into the array 
      filterSteps[i]=round(((float(stockHistory[i])-low)/(high-low)*67)+60);
    }

    // create a LPF cuttoff frequency sweep by normalising values from every fourth day
    // constrain the values to 880Hz upwards
    filterEnvelope[0]=round(((float(stockHistory[3])-low)/(high-low)*81)+46);
    filterEnvelope[1]=round(((float(stockHistory[7])-low)/(high-low)*81)+46);
    filterEnvelope[2]=round(((float(stockHistory[11])-low)/(high-low)*81)+46);    
    filterEnvelope[3]=round(((float(stockHistory[15])-low)/(high-low)*81)+46);

    // create a delay level of 0-50, based on the mean in relation to high 
    delay[0]=str(round((mean-low)/(high-low)*50));
    // create a delay feedback of 0-0.5, based on the 1st day in relation to high
    delay[1]=str((float(stockHistory[0])-low)/(high-low)/2);
    // create a delay time in note values depending on the 9th day in relation to high
    String delayValue;
    if ((float(stockHistory[8])-low)/(high-low)>0.5) {
      delayValue="16n";
    } else if ((float(stockHistory[8])-low)/(high-low)>0.4) {
      delayValue="8nt";
    } else if ((float(stockHistory[8])-low)/(high-low)>0.3) {
      delayValue="8n";
    } else {
      delayValue="4n";
    }
    delay[2]=delayValue;

// LEFT IN to shop API and paramater caluclation
// For each chip, display the stock history, key values and parameter arrays on load
    print(name + ": "); 
    for (String sh : stockHistory)print(sh + "; "); 
    println();
    println("Low/High/Mean Values: "+ low +"; " + high +"; " + mean);
    print("Gating sequence : "); 
    for (int gs : gateSwitches)print(gs); 
    println();
    print("Step Filter sequence : "); 
    for (float fs : filterSteps)print(fs + "; ");
    println();
    print("Filter Sweep values : "); 
    for (float fe : filterEnvelope)print(fe + "; ");
    println();
    print("Delay Level/Feedback/Time: "); 
    for (String dl : delay)print(dl + "; ");    
    println();
  }
  
  // Rendering method for chips
  void display() {
    // draw the chip
    noStroke();
    fill(chipColour);
    ellipse(xPos, yPos, diameter, diameter);
    fill(chipBackground);
    // iterate in a loop to draw the fan lines
    for (int i=0; i<=22; i+=2) {
      float offset=i*(2*PI/24);
      arc(xPos, yPos, diameter, diameter, HALF_PI+offset, HALF_PI+offset+(2*PI/24), PIE);
    }
    // draw a centre disc for the name background
    fill(chipColour);
    ellipse(xPos, yPos, diameter*0.9, diameter*0.9);
    // write the stock name
    fill(chipBackground);
    textSize(15);
    textAlign(CENTER, CENTER);
    text(name, xPos, yPos+4);
  }

// Method for snapping chips to the centre of a grid square.
// Check the position and assign a new position based on rules.
  void alignChip() {
    if (xPos >= width/10*2 && xPos < width/10*2+(width/20*3) &&
      yPos >= height/10*1 && yPos < height/10*3) {
      xPos=width/10*2+(width/40*3);
      yPos=height/10*2;
    } else if (xPos >= width/10*2+(width/20*3) && xPos < width/2 &&
      yPos >= height/10*1 && yPos < height/10*3) {
      xPos=width/10*2+(width/40*9);
      yPos=height/10*2;
    } else if (xPos >= width/10*2+(width/20*3) && xPos < width/2 &&
      yPos >= height/10*3 && yPos < height/2) {
      xPos=width/10*2+(width/40*9);
      yPos=height/10*4;
    } else if (xPos >= width/10*2 && xPos < width/10*2+(width/20*3) &&
      yPos >= height/10*3 && yPos < height/2) {
      xPos=width/10*2+(width/40*3);
      yPos=height/10*4;
    } else if (xPos >= width/2 && xPos < width/2+(width/20*3) &&
      yPos >= height/10*1 && yPos < height/10*3) {
      xPos=width/2+(width/40*3);
      yPos=height/10*2;
    } else if (xPos >= width/2+(width/20*3) && xPos <= width/10*8 &&
      yPos >= height/10*1 && yPos < height/10*3) {
      xPos=width/2+(width/40*9);
      yPos=height/10*2;
    } else if (xPos >= width/2+(width/20*3) && xPos <= width/10*8 &&
      yPos >= height/10*3 && yPos < height/2) {
      xPos=width/2+(width/40*9);
      yPos=height/10*4;
    } else if (xPos >= width/2 && xPos < width/2+(width/20*3) &&
      yPos >= height/10*3 && yPos < height/2) {
      xPos=width/2+(width/40*3);
      yPos=height/10*4;
    } else if (xPos >= width/2 && xPos < width/2+(width/20*3) &&
      yPos >= height/2 && yPos < height/10*7) {
      xPos=width/2+(width/40*3);
      yPos=height/10*6;
    } else if (xPos >= width/2+(width/20*3) && xPos <= width/10*8 &&
      yPos >= height/2 && yPos < height/10*7) {
      xPos=width/2+(width/40*9);
      yPos=height/10*6;
    } else if (xPos >= width/2+(width/20*3) && xPos <= width/10*8 &&
      yPos >= height/10*6 && yPos <= height/10*9) {
      xPos=width/2+(width/40*9);
      yPos=height/10*8;
    } else if (xPos >= width/2 && xPos < width/2+(width/20*3) &&
      yPos >= height/10*6 && yPos <= height/10*9) {
      xPos=width/2+(width/40*3);
      yPos=height/10*8;
    } else if (xPos >= width/10*2 && xPos < width/10*2+(width/20*3) &&
      yPos >= height/2 && yPos < height/10*7) {
      xPos=width/10*2+(width/40*3);
      yPos=height/10*6;
    } else if (xPos >= width/10*2+(width/20*3) && xPos < width/2 &&
      yPos >= height/2 && yPos < height/10*7) {
      xPos=width/10*2+(width/40*9);
      yPos=height/10*6;
    } else if (xPos >= width/10*2+(width/20*3) && xPos < width/2 &&
      yPos >= height/10*7 && yPos <= height/10*9) {
      xPos=width/10*2+(width/40*9);
      yPos=height/10*8;
    } else if (xPos >= width/10*2 && xPos < width/10*2+(width/20*3) &&
      yPos >= height/10*7 && yPos <= height/10*9) {
      xPos=width/10*2+(width/40*3);
      yPos=height/10*8;
    } else {
      xPos=xOrigin;
      yPos=yOrigin;
    }
  }
}