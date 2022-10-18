//import processing.svg.*;

// 1. move draftArray creating to a lifting function
// 2. enable clicking the image for a new pattern gen

// 3. build out frame lift plan for all 40 rows
// 3a. random frames for each row
// 3b. play with patterning
// 3c. play with inverting (color and direction)

// 4. glitching the final pattern 
// 4a. hit 'g' on keyboard for a new random glitch

int gridSize; // size of each cell in the output

// 4-frame direct tie-up loom
int[] frame1 = {1, 5, 9, 13, 17, 21, 25, 29, 33, 37};
int[] frame2 = {2, 6, 10, 14, 18, 22, 26, 30, 34, 38};
int[] frame3 = {3, 7, 11, 15, 19, 23, 27, 31, 35, 39};
int[] frame4 = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};
int[][] allFrames = {frame1, frame2, frame3, frame4};

void setup() {
  gridSize = 20;
  size(800, 800);
}

void draw() {
  background(255); // white
  
  int[] selection = chooseFrames();
  int[] allWarps = combineFrames(selection, allFrames);

  // define draft
  // boolean[col = x][rows = y]
  boolean[][] draftArray = new boolean[40][40];
  for (int y=0; y<40; y++) {
    for (int x=0; x<40; x++) {
      //draftArray[x][y] = true;
      // is column 1 in frame 2? no --> return false
      if (arrayContains(allWarps, x+1)) {
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

int[] chooseFrames() {
  // create array defining which frames to lift
  int[] selection = new int[0];
  // randomly selects 1, 2, or 3 frames to lift
  while ((selection.length == 0) || (selection.length == 4)) {
    selection = new int[0];
    for (int i = 1; i < 5; i++) {
      if (randomBool() == true) {
        selection = append(selection, i);
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

int[] combineFrames(int[] selection, int[][] allFrames) {
  int[] allWarps = new int[0];
  
  // index allFrames by selection
  for (int frame : selection) {
    //printArray(allFrames[frame - 1]);
    // combine frames selected
    allWarps = concat(allWarps, allFrames[frame - 1]);
  }
  println("selection: ");
  printArray(selection);
  println("allWarps: ");
  printArray(allWarps);
  return allWarps;
}
