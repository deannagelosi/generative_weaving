//import processing.svg.*;

// 2a. click to generate new image
// 2b. press s to save

// 3b. play with patterning
// 3c. play with inverting (color and direction)

// 4. glitching the final pattern 
// 4a. press 'g' for a new random glitch

// Declare global variables
int rectSize = 20; // size of each cell in the output 

// 4-shaft direct tie-up loom
int[] shaft1 = {1, 5, 9, 13, 17, 21, 25, 29, 33, 37};
int[] shaft2 = {2, 6, 10, 14, 18, 22, 26, 30, 34, 38};
int[] shaft3 = {3, 7, 11, 15, 19, 23, 27, 31, 35, 39};
int[] shaft4 = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};
int[][] allShafts = {shaft1, shaft2, shaft3, shaft4};

void setup() {
  size(800, 800);
}

void draw() {
  background(255); // white
  
  int[][] allWarps = new int[40][0];
  for (int i=0; i<40; i++) {
    int[] shaftSelection = chooseShafts(); // ex: [2,4]
    int[] warpLift = shafts2Warps(shaftSelection, allShafts); // ex: [2, 6, 10, ... 32, 36, 40]
    allWarps[i] = warpLift;
  }
  
  boolean[][] draftArray = createDraft(allWarps);  // ex: [[false, true, false ... false, false, true], ... ]
  printDraft(draftArray); 
  
  noLoop();
}

boolean[][] createDraft(int[][] allWarps) {
  // converts warp #s into true/false for all rows for print function
  
  boolean[][] draftArray = new boolean[40][40]; // boolean[row][col]
  
  for (int row = 0; row < 40; row++) {
    for (int col = 0; col < 40; col++) {
   
      if (arrayContains(allWarps[row], col+1)) {
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

int[] chooseShafts() {
  // create array defining which shafts to lift
  
  int[] shaftSelection = new int[0]; 
  while ((shaftSelection.length == 0) || (shaftSelection.length == 4)) { 
    // randomly selects 1, 2, or 3 shafts to lift
    shaftSelection = new int[0];
    for (int i = 1; i < 5; i++) {
      if (randomBool() == true) {
        shaftSelection = append(shaftSelection, i);
      }
    }
  }
  
  return shaftSelection;
}

boolean randomBool() {
  return random(0, 1) <= 0.5;
}

int[] shafts2Warps(int[] selection, int[][] allShafts) {
  // convert shaft selection into warps lifted
  
  int[] liftWarps = new int[0];
  
  for (int shaft : selection) {
    liftWarps = concat(liftWarps, allShafts[shaft - 1]);
  }

  return liftWarps;
}

void printDraft(boolean[][] draftArray) {
  
  // read row data by counting from 0 to 39, moving down each row.
  // read column data by counting from 0 to 39, moving across the row.
  for (int row = 0; row < 40; row++) {
    for (int col = 0; col < 40; col++) {
      
      // detect if each cell is true (yarn up) or false (yarn down)
      if (draftArray[row][col] == true) {
        fill(0); // black
      } else {
        fill(255); // white
      }
     
      int pixelX = col * rectSize;      
      int pixelY = height - (row * rectSize) - rectSize; // starts at the bottom of the canvas
       
      rect(pixelX, pixelY, rectSize, rectSize);
    }
  }
}

void mousePressed() {
  loop();
}
