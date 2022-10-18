//import processing.svg.*;
import java.util.Arrays;

int gridSize; // size of each cell in the output

// 4-frame direct tie-up loom
int[] frame1 = {1, 5, 9, 13, 17, 21, 25, 29, 33, 37};
int[] frame2 = {2, 6, 10, 14, 18, 22, 26, 30, 34, 38};
int[] frame3 = {3, 7, 11, 15, 19, 23, 27, 31, 35, 39};
int[] frame4 = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};

void setup() {
  gridSize = 20;
  size(800, 800);
}

void draw() {
  background(255); // white

  // define draft
  // boolean[col = x][rows = y]
  boolean[][] draftArray = new boolean[40][40];
  for (int y=0; y<40; y++) {
    for (int x=0; x<40; x++) {
      //draftArray[x][y] = true;
      // is column 1 in frame 2? no --> return false
      if (arrayContains(frame2, x+1)) {
        draftArray[x][y] = true;
      } else {
        draftArray[x][y] = false;
      }
    }
  }

  printDraft(draftArray);

  noLoop();
}

boolean arrayContains(int[] array, int check) {
  
  for (int item : array) {
    if (item == check) {
      return true;
    }
  }
  
  return false;
}


boolean randomBool() {
  return random(0, 1) <= 0.5;
}

ArrayList<Integer> chooseFrames() {
  // create array defining which frames to lift
  ArrayList<Integer> selection = new ArrayList<Integer>();
  // randomly selects 1, 2, or 3 frames to lift
  while ((selection.size() == 0) || (selection.size() == 4)) {
    selection.clear();
    for (int i = 1; i < 5; i++) {
      if (randomBool() == true) {
        selection.add(i);
      }
    }
  }
  return selection;
}

void printDraft(boolean[][] draftArray) {
  // starting in the bottom left corner
  for (int y=height-gridSize; y>0; y-=gridSize) {
    for (int x=0; x<width; x+=gridSize) {
      // convert from pixel to cell position
      if (draftArray[x/gridSize][y/gridSize] == true) {
        fill(0);
      } else {
        fill(255);
      }
      rect(x, y, gridSize, gridSize);
    }
  }
}
