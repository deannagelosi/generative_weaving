import processing.svg.*;

// to dos
// learn how to do Processing in VS Code

// start from a known structure (satin, twill) for X rows
// apply perlin noise to slightly alter the structure for X rows
// repeat on previous rows, continues to evolve (i.e. game of telephone)
// ends with a different looking but similar struture to first X rows
// predefined total number of rows (weftQuant)


// Declare global variables
int rectSize = 15; // size of each cell in the output
int weftQuant = 40;
int warpQuant = 40;
float pZoom = 200; // Perlin noise zoom level

// 4-shaft straight draft
int[] shaft1 = {1, 5, 9, 13, 17, 21, 25, 29, 33, 37};
int[] shaft2 = {2, 6, 10, 14, 18, 22, 26, 30, 34, 38};
int[] shaft3 = {3, 7, 11, 15, 19, 23, 27, 31, 35, 39};
int[] shaft4 = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};
int[][] threading = {shaft1, shaft2, shaft3, shaft4};
int numShafts = threading.length;

// weave pattern
int[][] twoByTwoTwill = {
  {2, 3}, 
  {3, 4}, 
  {1, 4}, 
  {3, 4}, 
  {2, 3}, 
  {1, 2}
};

// overrides filename until saved, series # randomly selected
String filename;
int series;
int fileIndex;

void setup() {
  size(705, 705); // 47 rects wide and high
  fileIndex = 1;
  series = (int)random(1000);
  noiseSeed(16);
}

void draw() {
  background(100); // dark grey
    
  int[][] liftPlan = new int[weftQuant][0];
  for (int i=0; i < twoByTwoTwill.length; i++) {
    liftPlan[i] = twoByTwoTwill[i];
  }
  
  int rowPosition = twoByTwoTwill.length - 1;

  int[][] modifiedPattern = twoByTwoTwill;
  
  for (int i=0; i < liftPlan.length; i = i + twoByTwoTwill.length) {
    // modifiedPattern = devolution(modifiedPattern);  // telephone
    modifiedPattern = devolution(twoByTwoTwill, i, rowPosition); // gradient
    for (int j=0; j < modifiedPattern.length; j++) {
      rowPosition++;
      if (rowPosition < weftQuant) {
        liftPlan[rowPosition] = modifiedPattern[j];
      } else {
        break;
      }
    }
  }
  
  // stretch goal: more strutures that you can keyboard select
  // for loop, within it there's a Perlin noise function that adjusts the lift plan

  int[][] drawdown = createDrawdown(liftPlan);
  printDraft(drawdown, liftPlan);

  noLoop();
}

int[][] devolution(int[][] weaveSegment, int currentLoop, int rowPosition) {
  int numChanges = currentLoop + 1;
  //int[][] modifiedWeaveSegment;

  // // choose row
  int px = 0; // left-most point on the rectangle
  int py = rowPosition * rectSize; 
  int selectedRow = perlinChoose(weaveSegment.length, px, py);
  println("selectedRow: ", selectedRow);

  // // select shaft
  px = 0;
  py = (rowPosition + selectedRow) * rectSize;
  int selectedShaft = perlinChoose(weaveSegment[selectedRow].length, px, py);
  println("selectedShaft: ", selectedShaft);
  
  // takes in a segment of the lift plan
  // modifies it using Perlin noise
  // returns the next segment of the lift plan

  // Perlin noise field selects which row and shaft
  // in each loop, remove a selected shaft for a specific row
  // increase the number of shafts removed with each loop
  // if about to delete the last shaft in a row, change to another row


  // for each loop, sample the Perlin noise field at the x, y coords at row 1, col 1 for that section
  // to select a row, map the value onto a scale of 0 through pattern.length, rounding down
  // go to pattern[row], returns an array of shafts: [shaft1, shaft4]
  // sample noise at the beginning of the selected row
  // to select a shaft, map the value onto a scale of 0 through pattern[row].length, rounding down
  // remove the shaft at specified position pattern[row][shaftPosition]

  // do above for the number of changes (offset the Perlin noise samples for each instance)

  // note: doesn't have to return the same number of rows


  return weaveSegment; // to do: change this to the modified return
}

int perlinChoose(int numItems, int px, int py) {
  float trim = 0.3;

  float pNoise = noise(px/pZoom, py/pZoom); //0..1

  // perlin is never fully 0 or 1, so trim to stretch the middle
  if (pNoise < trim) {
    pNoise = trim + 0.01;
  } else if (pNoise > (1 - trim)) {
    pNoise = 1 - trim - 0.01;
  }
  // println("pNoise", pNoise);
  int selected = floor(map(pNoise, trim, (1-trim), 0, numItems));

  return selected;
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

void printDraft(int[][] drawdown, int[][] liftPlan) {
  // visual output for draft

  filename = "drawdowns/drawdown-" + series + "-" + fileIndex + ".svg";

  beginRecord(SVG, filename);

  int padding = rectSize;
  int liftPlanWidth = numShafts * rectSize;
  int threadingHeight = numShafts * rectSize;
  
  // print tie ups
  int[][] tieUps = {{1}, {2}, {3}, {4}};
  
  for (int row = 0; row < tieUps.length; row++) {
    for (int col = 0; col < numShafts; col++) {

      if (arrayContains(tieUps[row], col + 1)) {
        fill(0); // fill rectangle with black
      } else {
        fill(255); // no fill
      }

      // draw rectangle
      int pixelX = liftPlanWidth - (col * rectSize);
      int pixelY = threadingHeight - (row * rectSize);

      rect(pixelX, pixelY, rectSize, rectSize);
    }
  }

  // print lift plan
  for (int row = 0; row < liftPlan.length; row++) {
    for (int col = 0; col < numShafts; col++) {

      if (arrayContains(liftPlan[row], col + 1)) {
        fill(0); // fill rectangle with black
      } else {
        fill(255); // no fill
      }

      // draw rectangle
      int pixelX = liftPlanWidth - (col * rectSize);
      int pixelY = 2*padding + threadingHeight + (row * rectSize);

      rect(pixelX, pixelY, rectSize, rectSize);
    }
  }

  // print threading
  for (int row = 0; row < threading.length; row++) {
    for (int col = 0; col < warpQuant; col++) {

      if (arrayContains(threading[row], col + 1)) {
        fill(0); // fill rectangle with black
      } else {
        fill(255); // no fill
      }

      // draw rectangle
      int pixelX = 2*padding + liftPlanWidth + (col * rectSize);
      int pixelY = threadingHeight - (row * rectSize);

      rect(pixelX, pixelY, rectSize, rectSize);
    }
  }

  // print drawdown
  for (int row = 0; row < drawdown.length; row++) {
    for (int col = 0; col < warpQuant; col++) {

      if (arrayContains(drawdown[row], col + 1)) {
        fill(0); // fill rectangle with black, raised warp
      } else {
        fill(255); // no fill, lowered warp
      }

      // draw rectangle
      int pixelX = 2*padding + liftPlanWidth + (col * rectSize);
      int pixelY = 2*padding + threadingHeight + (row * rectSize);

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
