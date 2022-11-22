import processing.svg.*;

//==== global variables ====//
int seed;
int pZoom; 
int pan;
int glitchMod;
int glitchSectionSize;

int cellSize; 
int weftQuant;
int warpQuant;
int numShafts;

// weave patterns
int selectedPattern;
int[] threadingBase;
int[][] patternShafts;

RowData[] liftPlan;
RowData[] drawdown;
RowData[] threading;
RowData[] tieUps;

// glitch metrics to check error distribution
int[] rowFrequency;

void setup() {
  size(705, 705); // 47 rects wide and high
  seed = int(random(1, 100));
  noiseSeed(seed);
  pan = 0;
  pZoom = 10; // Perlin noise zoom level
  glitchMod = 0;
  cellSize = 15; // size of each cell in the output
  
  // loom variables
  warpQuant = 40;
  weftQuant = 40;

  // weave pattern variables
  Pattern[] patterns = importJSONPatterns("patterns.json"); 
  selectedPattern = 7;
  patternShafts = patterns[selectedPattern].shafts;
  numShafts = patterns[selectedPattern].numShafts;
  threadingBase = patterns[selectedPattern].threadingBase;
  glitchSectionSize = patterns[selectedPattern].glitchSectionSize;

  threading = createThreading(threadingBase, warpQuant, numShafts);
  tieUps = createTieUps(numShafts);
  println("Selected Pattern: ", patterns[0].name);
}

void draw() {
  rowFrequency = new int[patternShafts.length];

  // create unglitched lift plan by tiling the pattern
  int patternLength = patternShafts.length;
  liftPlan = new RowData[0];

  for (int i = 0; i < weftQuant; i = i + patternLength) {
    for (int j = 0; j < patternLength; j++) {
      if (liftPlan.length <= weftQuant) {
        // append the next row
        int[] tempRow = patternShafts[j];
        RowData newRow = new RowData(tempRow);
        liftPlan = addRow(liftPlan, newRow);
      } else {
        break;
      }
    }
  }

  int currRow = 0;
  int currSection = 0;
  // glitch sections of lift plan, increasing in frequency, deterministally
  for (int i = 0; i < liftPlan.length; i = i + glitchSectionSize) {
    int sliceSize; 
    if (liftPlan.length - currRow > glitchSectionSize) {
      sliceSize = glitchSectionSize;
    } else {
      sliceSize = liftPlan.length - currRow;
    }
    // glitch section
    RowData[] slice = (RowData[]) subset(liftPlan, i, sliceSize);
    RowData[] glitchSection = gradientGlitch(slice, currSection, currRow);
    for (int j = 0; j < glitchSection.length; j++) {
      liftPlan[currRow] = glitchSection[j];
      currRow++;
    }
    currSection++;
  }
  
  drawdown = createDrawdown(liftPlan, threading);
  printDraft(liftPlan, drawdown, threading, tieUps);

  // println(rowFrequency);

  noLoop();
}

RowData[] gradientGlitch(RowData[] liftPlanSegment, int currSection, int currRow) {
  int numChanges; 
  if (currSection == 0) {
    numChanges = 0;
  } else {
    numChanges = currSection + glitchMod;
  }
  
  // copy liftPlanSegment into modLiftPlan
  RowData[] modLiftPlan = new RowData[liftPlanSegment.length];
  for (int i = 0; i < liftPlanSegment.length; i++) {
    RowData newRow = new RowData(liftPlanSegment[i].positions);
    modLiftPlan[i] = newRow;
  }

  int px = 0; // left-most point on the rectangle
  for (int i = 0; i < numChanges; i++) {
    if (modLiftPlan.length > 1) {
      // choose row
      int py = currRow * cellSize; 
      int selectedRow = perlinChoose(modLiftPlan.length, px, py);
      rowFrequency[selectedRow]++;

      // select shaft
      py = (currRow + selectedRow) * cellSize;
      int selectedShaft = perlinChoose(modLiftPlan[selectedRow].positions.length, px, py);

      // glitch lift plan row at selected shaft
      if (modLiftPlan[selectedRow].positions.length <= 1) {
        // Deleting the shaft will leave none. Choose a new shaft instead.
        int[] newShaftArray = {perlinChoose(numShafts, px, py) + 1}; 
        if (modLiftPlan[selectedRow].positions[0] != newShaftArray[0]) {
          RowData modRow = new RowData(newShaftArray);
          modRow.glitched = true;
          modLiftPlan[selectedRow] = modRow; // ex: [3]
        }        
      } else {
        modLiftPlan[selectedRow].positions = deleteElement(modLiftPlan[selectedRow].positions, selectedShaft);
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

    int[] rowLiftedWarps = new int[0];
    for (int j = 0; j < liftPlan[i].positions.length; j++) {
      // building drawdown by accessing warps lifted
      
      int shaft = liftPlan[i].positions[j];
      rowLiftedWarps = concat(rowLiftedWarps, threading[shaft - 1].positions);
    }

    // println("lifted warps on a row:");
    // println(rowLiftedWarps);

    drawdown[i] = new RowData(rowLiftedWarps);
    if (liftPlan[i].glitched == true) {
      drawdown[i].glitched = true;
    }
  }

  return drawdown;
}

RowData[] createThreading(int[] threadingBase, int targetSize, int numShafts) {
  int[] fullThread = fillArray(threadingBase, targetSize); // [1,2,3,4,1,2,3,4, etc...]

  // index the position data for all the warp shaft connections
  int[][] positions = new int[numShafts][0];

  for (int i = 0; i < fullThread.length; i++) {
    int currKey = fullThread[i];

    if (positions[currKey - 1].length == 0) {
      // not seen this key yet, add it
      positions[currKey - 1] = new int[]{i + 1};
    } else {
      // update existing key
      positions[currKey-1] = append(positions[currKey-1], i + 1);
    }
  }

  RowData[] threading = new RowData[numShafts];

  for (int i = 0; i < threading.length; i++) {  
    RowData threadRow = new RowData(positions[i]);
    threading[i] = threadRow;
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

      boolean warpLifted = arrayContains(sectionData[row].positions, col + 1);
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
    String filename = "drawdowns/drawdown-s" + seed + "-p" + pan + "-z" + pZoom + "-g" + glitchMod + ".svg";

    beginRecord(SVG, filename);
    printDraft(liftPlan, drawdown, threading, tieUps);
    endRecord();

  } else if (key == 'g') {
    glitchMod++;
    println("glitchMod: ", glitchMod);
    loop();
  } else if (key == 'd') {
    glitchMod--;
    println("glitchMod: ", glitchMod);
    loop();
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
    int glitchSectionSize = patternJSON.getInt("glitchSectionSize");
    
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

    JSONArray threadingJSON = patternJSON.getJSONArray("threading");
    int[] threadingBase = new int[threadingJSON.size()];
    for (int j = 0; j < threadingJSON.size(); j++) {
      threadingBase[j] = threadingJSON.getInt(j);      
    }

    Pattern pattern = new Pattern(name, numShafts, shafts, threadingBase, glitchSectionSize);
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

int[] fillArray(int[] array, int targetSize) {
  // duplicating array until it hits the target length
  int loopQuant = ceil(float(targetSize) / float(array.length));
  int[] filledArray = new int[0];

  for (int i = 0; i < loopQuant; i++) {
    for (int j = 0; j < array.length; j++) {
      if (filledArray.length == targetSize) {
        break;
      } else {
        filledArray = append(filledArray, array[j]);
      }
    }
  }

  return filledArray;
}

//==== custom classes ====//
class RowData {
  int[] positions; // selected shafts or threads 
  boolean glitched;

  // constructor
  RowData(int[] positions_) {
    positions = positions_;
    glitched = false;
  }
}

class Pattern {
  String name;
  int numShafts;
  int[][] shafts;
  int[] threadingBase;
  int glitchSectionSize;

  // constructor
  Pattern(String name_, int numShafts_, int[][] shafts_, int[] threading_, int glitchSectionSize_) {
    name = name_;
    numShafts = numShafts_;
    shafts = shafts_;
    threadingBase = threading_;
    glitchSectionSize = glitchSectionSize_;
  }
}