//import processing.svg.*;

int gridSize;

void setup() {
  gridSize = 20;
  size(800, 800);
}

void draw() {
  background(255);

  // define draft
  // boolean[col = x][rows = y]
  boolean[][] draftArray = new boolean[40][40];
  for (int y=0; y<40; y++) {
    for (int x=0; x<40; x++) {
      //rect(x, y, gridSize, gridSize);
      draftArray[x][y] = true;
    }
  }

  // display final draft
  for (int y=0; y<height; y+=gridSize) {
    for (int x=0; x<width; x+=gridSize) {
      if (draftArray[x/gridSize][y/gridSize] == true) {
        fill(0); 
      } else {
        fill(255);
      }
      rect(x, y, gridSize, gridSize);
    }
  }
}
