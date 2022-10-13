//import processing.svg.*;

int gridSize;
int[] frame1 = {1, 5, 9, 13, 17, 21, 25, 29, 33, 37};
int[] frame2 = {2, 6, 10, 14, 18, 22, 26, 30, 34, 38};
int[] frame3 = {3, 7, 11, 15, 19, 23, 27, 31, 35, 39};
int[] frame4 = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};

void setup() {
  gridSize = 20;
  size(800, 800);
}

void draw() {
  background(255);
  
  //int i = 0;
  //while (i < 320) {
  //  line(120, i, 320, i);
  //  i = i + 20;
  //}  

  ArrayList<Integer> selection = new ArrayList<Integer>();
  while ((selection.size() == 0) || (selection.size() == 4)) {
    selection.clear();
    //Boolean select1 = Math.random.nextBoolean();
    for (int i = 1; i <5; i++){
      if (randomBool() == true) {
        selection.add(i);
      }
    }
  }
  println(selection);
  
  // define draft
  // boolean[col = x][rows = y]
  boolean[][] draftArray = new boolean[40][40];
  for (int y=0; y<40; y++) {
    for (int x=0; x<40; x++) {
      //rect(x, y, gridSize, gridSize);
      draftArray[x][y] = true;
    }
  }

  // display final draft
  for (int y=0; y<height; y+=gridSize) {
    for (int x=0; x<width; x+=gridSize) {
      if (draftArray[x/gridSize][y/gridSize] == true) {
        fill(0); 
      } else {
        fill(255);
      }
      rect(x, y, gridSize, gridSize);
    }
  }
  
  noLoop();
}

boolean randomBool() {
  return random(0, 1) <= 0.5;
}
