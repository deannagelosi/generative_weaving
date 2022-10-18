//import processing.svg.*;

// 3. build out frame lift plan for all 40 rows
// 3a. random frames for each row
// 3b. play with patterning
// 3c. play with inverting (color and direction)

// 4. glitching the final pattern 
// 4a. hit 'g' on keyboard for a new random glitch

// stretch: enable clicking the image for a new pattern gen


int rectSize; // size of each cell in the output

// 4-frame direct tie-up loom
int[] frame1 = {1, 5, 9, 13, 17, 21, 25, 29, 33, 37};
int[] frame2 = {2, 6, 10, 14, 18, 22, 26, 30, 34, 38};
int[] frame3 = {3, 7, 11, 15, 19, 23, 27, 31, 35, 39};
int[] frame4 = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};
int[][] allFrames = {frame1, frame2, frame3, frame4};

void setup() {
  rectSize = 20;
  size(800, 800);
}

void draw() {
  background(255); // white
  
  int[] selection = chooseFrames();
  int[] rowLift = combineFrames(selection, allFrames);
  
  //for () {
  
  //}
  
  //boolean[][] draftArray = createDraft(allRowLifts);

  //printDraft(draftArray); 
  
  noLoop();
}

boolean[][] createDraft(int[][] allRowLifts) {
  
  //allRowLifts = 
  //  {
  //    {1, 5, 9, 13, 17, 21, 25, 29, 33, 37},
  //    {2, 6, 10, 14, 18, 22, 26, 30, 34, 38, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40},
  //    {3, 7, 11, 15, 19, 23, 27, 31, 35, 39}
  //  };
  
  //allRowLifts[1] -> {2, 6, 10, 14, 18, 22, 26, 30, 34, 38, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40}
  
  
  // allRowLifts is all the warp lifts on each row of the draft
  
  boolean[][] draftArray = new boolean[40][40]; // boolean[row][col]
  
  for (int row = 0; row < 40; row++) {
    for (int col = 0; col < 40; col++) {
   
      // is column 1 in the seclected frames? no --> return false
      if (arrayContains(allRowLifts[row], col+1)) {
        draftArray[row][col] = true;
      } else {
        draftArray[row][col] = false;
      }
    }
  }
  
  return draftArray;
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
  // Read row data by counting from 0 to 39, moving down each row.
  // Read column data by counting from 0 to 39, moving across the row.
  for (int row = 0; row < 40; row++) {
    for (int col = 0; col < 40; col++) {
      
      // 1. Detect if each cell is true (yarn up) or false (yarn down)
      if (draftArray[row][col] == true) {
        fill(0); // black
      } else {
        fill(255); // white
      }
      
      // 2. Draw black and white rects in a grid to represent the draft result.
      // **Note**: The swatch is woven from the bottom up, upside down of how the array stores data.
      // 2a. Convert each row to a y pixel position.
      // - The top of the canvas is y 0, the bottom of the canvas is y height.
      // - Start y at image height (minus the rect height), and move towards pixelY = 0. (780 -> 0)
      // 2b. Convert each col to a x pixel position.
      // - Start x at 0 and move pixelX towards the image width (minus the rect width). (0 -> 780)
      
      // tl;dr - Start in the bottom left corner when printing the swatch.
     
      int pixelX = col * rectSize;      
      int pixelY = height - (row * rectSize) - rectSize;
       
      rect(pixelX, pixelY, rectSize, rectSize);
    }
  }
}

int[] combineFrames(int[] selection, int[][] allFrames) {
  int[] liftWarps = new int[0];
  
  // index allFrames by selection
  for (int frame : selection) {
    //printArray(allFrames[frame - 1]);
    // combine frames selected
    liftWarps = concat(liftWarps, allFrames[frame - 1]);
  }
  println("selection: ");
  printArray(selection);
  println("allWarps: ");
  printArray(liftWarps);
  return liftWarps;
}
