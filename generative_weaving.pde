import processing.svg.*;

//==== global variables ====//
int seed;
int pZoom; 
int pan;

int cellSize; 
int weftQuant;
int warpQuant;
int numShafts;

int[] rowFrequency; // glitch metrics to check error distribution

RowData[] liftPlan;
RowData[] drawdown;
RowData[] threading;
RowData[] tieUps;

// weave patterns
int[][] activePattern;
// int[][] twoByTwoTwill = { // 4-shaft
//   {2, 3}, 
//   {3, 4}, 
//   {1, 4}, 
//   {3, 4}, 
//   {2, 3}, 
//   {1, 2}
// };
// int[][] warpFacingTwill = { // 8-shaft
//   {1, 2, 3, 5, 6, 7},
//   {2, 3, 4, 6, 7, 8},
//   {1, 3, 4, 5, 7, 8},
//   {1, 2, 4, 5, 6, 8}
// };

void setup() {
  size(1400, 705); // 47 rects wide and high
  seed = int(random(1, 100));
  noiseSeed(seed);
  pan = 0;
  pZoom = 10; // Perlin noise zoom level

  cellSize = 8; // size of each cell in the output
  warpQuant = 144;
  weftQuant = 40;
  numShafts = 8;
  threading = createThreading(numShafts, warpQuant);
  tieUps = createTieUps(numShafts);
  
  Pattern[] patterns = importJSONPatterns("patterns.json"); 
  println(patterns[0].name + " - " + patterns[0].numShafts);
  // println(patterns[0].shafts[0]);

  // activePattern = warpFacingTwill;
  activePattern = patterns[1].shafts;
}

void draw() {
  rowFrequency = new int[activePattern.length];
  
  // Fill up the liftplan with empty rows
  liftPlan = new RowData[0];
  for (int i = 0; i < weftQuant; i++) {
    RowData newRow = new RowData(new int[0]);
    liftPlan = addRow(liftPlan, newRow);
  }

  // Fill first liftplan rows with starter pattern
  for (int i = 0; i < activePattern.length; i++) {
    liftPlan[i] = new RowData(activePattern[i]);
  }

  int rowPosition = activePattern.length - 1;
  int segmentCounter = 0;
  
  for (int i=0; i < liftPlan.length; i = i + activePattern.length) {
    RowData[] modLiftPlan = gradientGlitch(activePattern, segmentCounter, rowPosition);
    // Add new pattern to the liftPlan
    for (int j=0; j < modLiftPlan.length; j++) {
      rowPosition++;
      if (rowPosition < weftQuant) {
        // liftPlan[rowPosition].shafts = modLiftPlan[j];
        liftPlan[rowPosition] = modLiftPlan[j];
      } else {
        break;
      }
    }
    segmentCounter++;
  }
  
  drawdown = createDrawdown(liftPlan, threading);
  printDraft(liftPlan, drawdown, threading, tieUps);

  // println(rowFrequency);

  noLoop();
}

RowData[] gradientGlitch(int[][] liftPlanSegment, int currentLoop, int rowPosition) {
  int numChanges = currentLoop + 1;
  
  // copy liftPlanSegment into modLiftPlan
  RowData[] modLiftPlan = new RowData[liftPlanSegment.length];
  for (int i = 0; i < liftPlanSegment.length; i++) {
    RowData newRow = new RowData(liftPlanSegment[i]);
    modLiftPlan[i] = newRow;
  }

  int px = 0; // left-most point on the rectangle
  for (int i = 0; i < numChanges; i++) {
    if (modLiftPlan.length > 1) {
      // choose row
      int py = rowPosition * cellSize; 
      int selectedRow = perlinChoose(modLiftPlan.length, px, py);
      rowFrequency[selectedRow]++;

      // select shaft
      py = (rowPosition + selectedRow) * cellSize;
      int selectedShaft = perlinChoose(modLiftPlan[selectedRow].shafts.length, px, py);

      // glitch lift plan row at selected shaft
      if (modLiftPlan[selectedRow].shafts.length <= 1) {
        // Deleting the shaft will leave none. Choose a new shaft instead.
        int[] newShaftArray = {perlinChoose(numShafts, px, py) + 1}; 
        if (modLiftPlan[selectedRow].shafts[0] != newShaftArray[0]) {
          RowData modRow = new RowData(newShaftArray);
          modRow.glitched = true;
          modLiftPlan[selectedRow] = modRow; // ex: [3]
        }        
      } else {
        modLiftPlan[selectedRow].shafts = deleteElement(modLiftPlan[selectedRow].shafts, selectedShaft);
        modLiftPlan[selectedRow].glitched = true;
      }

      // change sampling position in Perlin noise field
      px = px + cellSize;
    } 
  }
  
  return modLiftPlan; 
}

int perlinChoose(int numItems, int px, int py) {
  // use xy coords to select an item deterministically
  // if numItems = 4, will return a num between 0 and 3
  px = px + pan; // add offest when panning

  // noise() never returns 0 or 1, but some value in between and more likely a number in the middle
  // use trim to adjust row distribution more equally across all shafts when mapping noise to shaft selection
  float trim = 0.3;
  float pNoise = noise(px/pZoom, py/pZoom); //0..1

  if (pNoise < trim) {
    pNoise = trim + 0.01;
  } else if (pNoise > (1 - trim)) {
    pNoise = 1 - trim - 0.01;
  }
  int selected = floor(map(pNoise, trim, (1-trim), 0, numItems));

  return selected;
}

RowData[] createDrawdown(RowData[] liftPlan, RowData[] threading) {
  // uses threading and liftplan to make drawdown
  RowData[] drawdown = new RowData[liftPlan.length];
  for (int i = 0; i < liftPlan.length; i++) {

    int[] rowShafts = new int[0];
    for (int j = 0; j < liftPlan[i].shafts.length; j++) {
      // building drawdown by accessing warps lifted
      int shaft = liftPlan[i].shafts[j];
      rowShafts = concat(rowShafts, threading[shaft - 1].shafts);
    }

    drawdown[i] = new RowData(rowShafts);
    if (liftPlan[i].glitched == true) {
      drawdown[i].glitched = true;
    }
  }

  return drawdown;
}

RowData[] createThreading(int numShafts, int numWarps) {
  // 4-shaft straight draft
  // int[] shaft1 = {1, 5, 9, 13, 17, 21, 25, 29, 33, 37};
  // int[] shaft2 = {2, 6, 10, 14, 18, 22, 26, 30, 34, 38};
  // int[] shaft3 = {3, 7, 11, 15, 19, 23, 27, 31, 35, 39};
  // int[] shaft4 = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};
  // int[][] threading = {shaft1, shaft2, shaft3, shaft4};
  RowData[] threading = new RowData[numShafts];
  for (int i = 0; i < numShafts; i++) {

    // create a shaft tie-up
    int[] shaft = new int[numWarps / numShafts];
    for (int j = 0; j < shaft.length; j++) {
      shaft[j] = (i + 1) + (numShafts * j);
    }

    threading[i] = new RowData(shaft);
  }

  return threading;
}

RowData[] createTieUps(int numShafts) {
  RowData[] tieUps = new RowData[numShafts];
  // tieUps = {{1}, {2}, {3}, ...}
  for (int i = 0; i < numShafts; i++) {
    int[] shaft = {i + 1};
    tieUps[i] = new RowData(shaft);
  }

  return tieUps;
}

void printDraft(RowData[] liftPlan, RowData[] drawdown, RowData[] threading, RowData[] tieUps) {
  // visual output for draft
  background(100); // dark grey

  int padding = cellSize;
  int liftPlanWidth = numShafts * cellSize;
  int threadingHeight = numShafts * cellSize;
  
  // print tie-ups
  printSection(tieUps, "bottom-right", numShafts, liftPlanWidth, threadingHeight);

  // print threading
  printSection(threading, "bottom-left", warpQuant, 2*padding+liftPlanWidth, threadingHeight);

  // print lift plan
  printSection(liftPlan, "top-right", numShafts, liftPlanWidth, 2*padding+threadingHeight);

  // print drawdown
  printSection(drawdown, "top-left", warpQuant, 2*padding+liftPlanWidth, 2*padding+threadingHeight);
}

void printSection(RowData[] sectionData, String mode, int numCols, int leftBuffer, int topBuffer) {

  for (int row = 0; row < sectionData.length; row++) {
    for (int col = 0; col < numCols; col++) {

      boolean warpLifted = arrayContains(sectionData[row].shafts, col + 1);
      boolean weftGlitched = sectionData[row].glitched;

      if (warpLifted == true) {
        fill(0); // black cell
      } else {
        fill(255); // white cell
      }

      if (warpLifted == true && weftGlitched == true) {
        fill(255, 51, 153); // pink cell
      } else if (warpLifted == false && weftGlitched == true){
        fill(255, 204, 255); // light pink cell
      }

      // draw rectangle
      int pixelX = 0;
      int pixelY = 0;

      // mode defines which corner of the grid section to start printing from
      switch(mode) {
        case "bottom-right": 
          pixelX = leftBuffer - (col * cellSize);
          pixelY = topBuffer - (row * cellSize);
          break;
        case "bottom-left": 
          pixelX = leftBuffer + (col * cellSize);
          pixelY = topBuffer - (row * cellSize);
          break;
        case "top-right": 
          pixelX = leftBuffer - (col * cellSize);
          pixelY = topBuffer + (row * cellSize);
          break;
        case "top-left": 
          pixelX = leftBuffer + (col * cellSize);
          pixelY = topBuffer + (row * cellSize);
          break;
      }

      rect(pixelX, pixelY, cellSize, cellSize);
    }
  }
}

//==== controls ====//
void keyPressed() {
  if (key == 's') {
    String filename = "drawdowns/drawdown-s" + seed + "-p" + pan + "-z" + pZoom + ".svg";

    beginRecord(SVG, filename);
    printDraft(liftPlan, drawdown, threading, tieUps);
    endRecord();

  } else if (key == CODED) {
    // Zoom and Pan the Perlin Field
    if (keyCode == UP) {
      pZoom = pZoom + cellSize    ;
      println("pZoom: ", pZoom);
      loop();
    } else if (keyCode == DOWN) {
      pZoom = pZoom - cellSize    ;
      println("pZoom: ", pZoom);
      loop();
    } else if (keyCode == LEFT) {
      pan = pan - cellSize    ;
      println("pan: ", pan);
      loop();
    }else if (keyCode == RIGHT) {
      pan = pan + cellSize    ;
      println("pan: ", pan);
      loop();
    }
  }
}

//==== helper functions ====//
Pattern[] importJSONPatterns(String filename) {

  JSONArray patternsJSON = loadJSONArray(filename);

  Pattern[] patterns = new Pattern[patternsJSON.size()];
  for (int i = 0; i < patternsJSON.size(); i++) {

    // load pattern
    JSONObject patternJSON = patternsJSON.getJSONObject(i); 
    String name = patternJSON.getString("name");
    int numShafts = patternJSON.getInt("numShafts");

    // parse the shafts 2d int array
    JSONArray shaftsJSON = patternJSON.getJSONArray("shafts");
    int[][] shafts = new int[shaftsJSON.size()][0];
    for (int j = 0; j < shaftsJSON.size(); j++) {

      JSONArray shaftJSON = shaftsJSON.getJSONArray(j);
      int[] shaft = new int[shaftJSON.size()];
      for (int k = 0; k < shaftJSON.size(); k++) {
        shaft[k] = shaftJSON.getInt(k);
      }

      shafts[j] = shaft;
    }

    Pattern pattern = new Pattern(name, numShafts, shafts);
    patterns[i] = pattern;
  }

  return patterns;
}

boolean arrayContains(int[] array, int check) {
  // checks if the array contains an integer
  for (int item : array) {
    if (item == check) {
      return true;
    }
  }

  return false;
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

RowData[] addRow(RowData[] rows, RowData newRow) {
  RowData[] appendedRows = new RowData[rows.length + 1];

  for (int i = 0; i < rows.length; i++) {
    appendedRows[i] = rows[i];
  }
  appendedRows[rows.length] = newRow;

  return appendedRows;
}

//==== custom classes ====//
class RowData {
  int[] shafts;
  boolean glitched;

  // constructor
  RowData(int[] shafts_) {
    shafts = shafts_;
    glitched = false;
  }
}

class Pattern {
  String name;
  int numShafts;
  int[][] shafts;

  // constructor
  Pattern(String name_, int numShafts_, int[][] shafts_) {
    name = name_;
    numShafts = numShafts_;
    shafts = shafts_;
  }
}