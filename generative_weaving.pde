import processing.svg.*;

// UI changes
// add threading and lift plan to print
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
int[][] threading = {shaft1, shaft2, shaft3, shaft4};
int numShafts = threading.length;

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

  int[][] drawdown = createDrawdown(liftPlan);
  printDraft(drawdown);

  noLoop();
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

int[][] createDrawdown(int[][] liftPlan) {
  // uses threading and lift plan to make drawdown

  int[][] drawdown = new int[liftPlan.length][0];

  for (int i = 0; i < liftPlan.length; i++) {

    int[] drawdownRow = new int[0];
    for (int shaft : liftPlan[i]) {
      // building drawdown by accessing warps lifted
      drawdownRow = concat(drawdownRow, threading[shaft - 1]);
    }
    drawdown[i] = drawdownRow;
  }

  return drawdown;
}

void printDraft(int[][] drawdown) {
  // visual output for draft

  filename = "drawdowns/drawdown-" + series + "-" + fileIndex + ".svg";

  beginRecord(SVG, filename);
  
  for (int row = 0; row < drawdown.length; row++) {
    for (int col = 0; col < warpQuant; col++) {
      
      if (arrayContains(drawdown[row], col + 1)) {
        fill(0); // fill rectangle with black, raised warp
      } else {
        fill(255); // no fill, lowered warp
      }
    
      // draw rectangle
      int pixelX = width - col * rectSize - padding;
      int pixelY = height - (row * rectSize) - rectSize - padding; // starts at the bottom of the canvas
  
      rect(pixelX, pixelY, rectSize, rectSize);
    }

  }

  endRecord();
}

// keyboard commands
void mousePressed() {
  loop();
}

void keyPressed() {
  if (key == 's') {
    fileIndex++;
  }
}

// helper functions
boolean arrayContains(int[] array, int check) {
  // checks if the array contains an integer
  
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
