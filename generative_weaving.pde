import processing.svg.*;

// to dos
// merge into main
// on screen recording of pan and zoom 
// readme

// move preloaded patterns into separate file (JSON?)
// keyboard toggle different starting swatches


// Declare global variables
String filename;
int seed;
int pZoom; 
int pan;

int rectSize; 
int weftQuant;
int warpQuant;
int numShafts;

int[][] liftPlan;
int[][] drawdown;
int[][] threading;

int[] rowFrequency;

// weave patterns
int[][] activePattern;
int[][] twoByTwoTwill = { // 4-shaft
  {2, 3}, 
  {3, 4}, 
  {1, 4}, 
  {3, 4}, 
  {2, 3}, 
  {1, 2}
};
int[][] warpFacingTwill = { // 8-shaft
  {1, 2, 3, 5, 6, 7},
  {2, 3, 4, 6, 7, 8},
  {1, 3, 4, 5, 7, 8},
  {1, 2, 4, 5, 6, 8}
};

void setup() {
  size(1400, 705); // 47 rects wide and high
  seed = 16;
  noiseSeed(seed);
  pan = 0;
  pZoom = 100; // Perlin noise zoom level

  rectSize = 8; // size of each cell in the output
  warpQuant = 144;
  weftQuant = 40;
  threading = createThreading(8, 144);
  numShafts = threading.length;
  activePattern = warpFacingTwill;
}

void draw() {
  rowFrequency = new int[6];
  liftPlan = new int[weftQuant][0];

  // fill new liftplan with starter pattern
  for (int i=0; i < activePattern.length; i++) {
    liftPlan[i] = activePattern[i];
  }

  int rowPosition = activePattern.length - 1;
  int segmentCounter = 0;
  // int[][] modifiedPattern = activePattern;
  
  for (int i=0; i < liftPlan.length; i = i + activePattern.length) {
    // modifiedPattern = gradient(modifiedPattern);  // telephone
    int[][] modifiedPattern = gradient(activePattern, segmentCounter, rowPosition); // gradient
    // Add new pattern to the liftPlan
    for (int j=0; j < modifiedPattern.length; j++) {
      rowPosition++;
      if (rowPosition < weftQuant) {
        liftPlan[rowPosition] = modifiedPattern[j];
      } else {
        break;
      }
    }
    segmentCounter++;
  }
  
  drawdown = createDrawdown(liftPlan);
  printDraft(liftPlan, drawdown);

  // println(rowFrequency);

  noLoop();
}

// int[][] devolution(int[][] weaveSegment, int currentLoop, int rowPosition) {}

int[][] gradient(int[][] weaveSegment, int currentLoop, int rowPosition) {
  // to do: track selected row frequency over time
  int numChanges = currentLoop + 1;
  
  // copy weaveSegment into modWeaveSegment
  int[][] modWeaveSegment = new int[weaveSegment.length][0];
  for (int j = 0; j < weaveSegment.length; j++) {
    modWeaveSegment[j] = weaveSegment[j];
  }

  int px = 0; // left-most point on the rectangle
  for (int i = 0; i < numChanges; i++) {
    if (modWeaveSegment.length > 1) {
      // choose row
      int py = rowPosition * rectSize; 
      int selectedRow = perlinChoose(modWeaveSegment.length, px, py);
      rowFrequency[selectedRow]++;

      // select shaft
      py = (rowPosition + selectedRow) * rectSize;
      int selectedShaft = perlinChoose(modWeaveSegment[selectedRow].length, px, py);

      // update weave
      if (modWeaveSegment[selectedRow].length <= 1) {
        // Deleting the shaft will leave none. Choose a new shaft instead.
        int newShaft = perlinChoose(numShafts, px, py) + 1; // 0..3
        int[] modRow = {newShaft};
        modWeaveSegment[selectedRow] = modRow; // ex: [3]

        // oops! only one shaft left, remove row
        // modWeaveSegment = delete2DElement(modWeaveSegment, selectedRow);
      } else {
        int[] modRow = deleteElement(modWeaveSegment[selectedRow], selectedShaft); 
        modWeaveSegment[selectedRow] = modRow;
      }

      // increase y by col width (rectSize)
      px = px + rectSize;
    } 
  }
  
  return modWeaveSegment; 
}

int perlinChoose(int numItems, int px, int py) {
  // use xy coords to select an item deterministically
  // if numItems = 4, will return a num between 0 and 3
  px = px + pan; // add offest when panning

  float trim = 0.3;
  float pNoise = noise(px/pZoom, py/pZoom); //0..1

  // perlin is never fully 0 or 1, so trim to stretch the middle
  if (pNoise < trim) {
    pNoise = trim + 0.01;
  } else if (pNoise > (1 - trim)) {
    pNoise = 1 - trim - 0.01;
  }
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

int[][] createThreading(int numShafts, int numWarps) {
  // 4-shaft straight draft
  // int[] shaft1 = {1, 5, 9, 13, 17, 21, 25, 29, 33, 37};
  // int[] shaft2 = {2, 6, 10, 14, 18, 22, 26, 30, 34, 38};
  // int[] shaft3 = {3, 7, 11, 15, 19, 23, 27, 31, 35, 39};
  // int[] shaft4 = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};
  // int[][] threading = {shaft1, shaft2, shaft3, shaft4};
  int[][] threading = new int[numShafts][0];
  for (int i = 0; i < numShafts; i++) {
    threading[i] = createShaft(numShafts, numWarps, i + 1);
  }

  return threading;
}

int[] createShaft(int numShafts, int numWarps, int whichShaft) {
  int[] shaft = new int[numWarps / numShafts];
  for (int i = 0; i < shaft.length; i++) {
    shaft[i] = whichShaft + (numShafts * i);
  }

  return shaft;
}

void printDraft(int[][] liftPlan, int[][] drawdown) {
  // visual output for draft
  background(100); // dark grey

  int padding = rectSize;
  int liftPlanWidth = numShafts * rectSize;
  int threadingHeight = numShafts * rectSize;
  
  int[][] tieUps = new int[numShafts][0];
  // tieUps = {{1}, {2}, {3}, ...}
  for (int i = 0; i < numShafts; i++) {
    int[] shaft = {i + 1};
    tieUps[i] = shaft; 
  }
  
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
}

void keyPressed() {
  if (key == 's') {
    filename = "drawdowns/drawdown-s" + seed + "-p" + pan + "-z" + pZoom + ".svg";

    beginRecord(SVG, filename);
    printDraft(liftPlan, drawdown);
    endRecord();

  } else if (key == CODED) {
    // Zoom and Pan the Perlin Field
    if (keyCode == UP) {
      pZoom = pZoom + rectSize;
      println("pZoom: ", pZoom);
      loop();
    } else if (keyCode == DOWN) {
      pZoom = pZoom - rectSize;
      println("pZoom: ", pZoom);
      loop();
    } else if (keyCode == LEFT) {
      pan = pan - rectSize;
      println("pan: ", pan);
      loop();
    }else if (keyCode == RIGHT) {
      pan = pan + rectSize;
      println("pan: ", pan);
      loop();
    }
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

int[] deleteElement(int[] array, int skipIndex) {
  // remove item at index position
  int[] modifiedArray = new int[array.length - 1];
  int j = 0;
  for (int i = 0; i < array.length; i++) {
    if (i == skipIndex) {
      // skip
    } else {
      modifiedArray[j] = array[i];
      j++;
    }
  }

  return modifiedArray;
}

int[][] delete2DElement(int[][] array, int skipIndex) {
  // remove item at index position
  int[][] modifiedArray = new int[array.length - 1][0];
  int j = 0;
  for (int i = 0; i < array.length; i++) {
    if (i == skipIndex) {
      // skip
    } else {
      modifiedArray[j] = array[i];
      j++;
    }
  }

  return modifiedArray;
}

int[] addElement(int[] array, int element) {
  int[] modifiedArray = new int[array.length + 1];
  for (int i = 0; i < array.length; i++) {
    modifiedArray[i] = array[i];
  }
  modifiedArray[array.length] = element;

  return modifiedArray;
}