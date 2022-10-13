//import processing.svg.*;

int gridSize;

void setup() {
  gridSize = 20;
  size(800, 800);
}

void draw() {
  background(255);
  //noStroke();
  
  for (int y=0; y<height; y+=gridSize) {
    for (int x=0; x<width; x+=gridSize) {
      rect(x, y, gridSize, gridSize);
    }
  }
}
