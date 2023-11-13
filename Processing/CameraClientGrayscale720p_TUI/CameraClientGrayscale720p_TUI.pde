import processing.core.*;
import processing.net.*;

Client client;
PImage prevFrame;

int camWidth = 1280;
int camHeight = 720;
int dataOffset = 163;

PImage calibImg;
PImage background;

float[] markerX = {136, 136, 659, 659};
float[] markerY = {14, 537, 14, 537};
int U = 523;
PVector O = new PVector(178.5,56.5);

float screenRatio = 1;

void setup() {
  size(1280, 720);
  prevFrame = createImage(width, height, RGB);
  client = new Client(this, "localhost", 8762);
  //calibImg = loadImage("ArUCo_GRID.png");

  noLoop();
}

void draw() {
  background(255);
  
  image(calibImg, 0, 0);
  noFill();
  stroke(0);

  rect(0, 0, calibImg.width, calibImg.height);
  float r = (15.0/25.4)*72;
  for (int i = 0; i < markerX.length; i++) {
    ellipse(markerX[i], markerY[i], 5, 5);
    ellipse(markerX[i]+r, markerY[i], 5, 5);
    ellipse(markerX[i]+r, markerY[i]+r, 5, 5);
    ellipse(markerX[i], markerY[i]+r, 5, 5);
  }

  //getGrayscaleImgFromServer();
  //image(prevFrame, 0, 0);
}
