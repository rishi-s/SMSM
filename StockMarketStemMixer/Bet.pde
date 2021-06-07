//Class for the bet object (i.e. sub-grid of 16 squares in UI)


class Bet {
  int source=-1; //Current chip number placing bet (-1 = null)
  int x;         //X position of bet square
  int y;         //Y position of bet square
  int port;      //UDP port to use for messages from this square



  //Constructor method for class
  Bet (int currentChip, int xVal, int yVal, int portNum) {
    source=currentChip;
    x=xVal;
    y=yVal;
    port=portNum;
  }
 
  //Method for updating the chip placing the bet.
  void setSource(int currentChip){
    source=currentChip;
  }
}