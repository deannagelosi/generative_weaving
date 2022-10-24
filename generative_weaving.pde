import processing.svg.*;

// UI changes
// make canvas bigger (done)
// make cells smaller (done)
// pad around print()
// add tie ups and lift plan
// convert 4 to 8-shafts


// perlin noise influences which shafts are lifted
// play with inverting rows (mirror or up/down flip)

// glitching the final pattern (first, manually)

// stretch: press 'g' for a new random glitch

// Declare global variables
int rectSize = 15; // size of each cell in the output 
int padding = 30;
int weftQuant = 40;
int warpQuant = 40;

// 4-shaft direct tie-up loom
int[] shaft1 = {1, 5, 9, 13, 17, 21, 25, 29, 33, 37};
int[] shaft2 = {2, 6, 10, 14, 18, 22, 26, 30, 34, 38};
int[] shaft3 = {3, 7, 11, 15, 19, 23, 27, 31, 35, 39};
int[] shaft4 = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};
int[][] tieUps = {shaft1, shaft2, shaft3, shaft4};
int numShafts = tieUps.length;

// overrides filename until saved, series # randomly selected
String filename;
int series;
int fileIndex;

void setup() {
  size(800, 800);
  fileIndex = 1;
  series = (int)random(1000);
}

void draw() {
  background(255); // white
  
  int[][] liftPlan = new int[weftQuant][0];
  for (int i=0; i<weftQuant; i++) {
    int[] shaftSelection = chooseRandomShafts(); // ex: [2,4]
    liftPlan[i] = shaftSelection;
  }
  
  boolean[][] draftArray = createDraft(liftPlan);  // ex: [[false, true, false ... false, false, true], ... ]
  printDraft(draftArray); 
  
  noLoop();
}

boolean[][] createDraft(int[][] liftPlan) {
  // mirroring and tiling lift plan, then convert into true/false for all rows
  
  for (int row = 0; row < liftPlan.length; row++) {
    
    int[] draftRow;
    
    for (int shaft = 0; shaft < numShafts; shaft++) {
      int currentShaft = liftPlan[row][shaft]; 
      int[] draftRowSoFar = tieUp[currentShaft - 1]
      
      // concat draftrowsofar to draftwor
    }
    
    // sort the draft row
  }
  // do this in print() -> convert the draft row to trues/falses
  
  /// --------------
  
  // use the lift plan to create the drawdown
  //int[][] drawdown = new int[weftQuant][0];
  //for (int weft = 0; weft < liftPlan.length; weft++) {
  //  drawdown[weft] = reverse(liftPlan[weft]);
  //}
  
  //boolean[][] draftArray = new boolean[weftQuant][warpQuant]; // boolean[row][col]
  
  //for (int weft = 0; weft < weftQuant; weft++) {
  //  for (int warp = 0; warp < warpQuant; warp++) {
   
  //    if (arrayContains(liftPlan[weft], warp+1)) {
  //      draftArray[weft][warp] = true;
  //    } else {
  //      draftArray[weft][warp] = false;
  //    }
  //  }
  //}
  
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

int[] chooseRandomShafts() {
  // create array defining which random shafts to lift
  
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

int[] choosePerlinShafts(int i) {
  // create array defining which shafts to lift based on Perlin noise field
  
  int[] shaftSelection = new int[0]; 
  //while ((shaftSelection.length == 0) || (shaftSelection.length == 4)) { 
  //  // randomly selects 1, 2, or 3 shafts to lift
  //  shaftSelection = new int[0];
  //  for (int i = 1; i < 5; i++) {
  //    if (randomBool() == true) {
  //      shaftSelection = append(shaftSelection, i);
  //    }
  //  }
  //}
  
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
  filename = "drawdowns/drawdown-" + series + "-" + fileIndex + ".svg";
  
  beginRecord(SVG, filename);
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
     
      int pixelX = width - col * rectSize - padding;      
      int pixelY = height - (row * rectSize) - rectSize - padding; // starts at the bottom of the canvas
       
      rect(pixelX, pixelY, rectSize, rectSize);
    }
  }
  
  
  
  
  
  
  endRecord();
}

void mousePressed() {
  loop();
}

void keyPressed() {
  if (key == 's') {
    fileIndex++;
  }
}
