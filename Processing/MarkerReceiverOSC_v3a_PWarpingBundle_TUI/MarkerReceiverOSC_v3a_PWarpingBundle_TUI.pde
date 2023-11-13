//*********************************************
// Example Code: ArUCo Fiducial Marker Detection in OpenCV Python and then send to Processing via OSC
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************

import org.ejml.simple.SimpleMatrix;
import oscP5.*;
import netP5.*;

TagManager tm;
OscP5 oscP5;

boolean homographyMatrixCalculated = false;

int[] cornersID = {1, 3, 2, 0};
int[][] bundlesIDs = {
  {5, 11, 13, 19},
  {9, 15, 17, 23},
  {33, 39, 41, 47},
  {37, 43, 45, 51},
  {61, 67, 69, 75},
  {65, 71, 73, 79},
};
PVector[][] bundlesOffsets = {
  {new PVector(0, -0.02, 0), new PVector(0.02, 0, 0), new PVector(-0.02, 0, 0), new PVector(0, 0.02, 0)},
  {new PVector(0, -0.02, 0), new PVector(0.02, 0, 0), new PVector(-0.02, 0, 0), new PVector(0, 0.02, 0)},
  {new PVector(0, -0.02, 0), new PVector(0.02, 0, 0), new PVector(-0.02, 0, 0), new PVector(0, 0.02, 0)},
  {new PVector(0, -0.02, 0), new PVector(0.02, 0, 0), new PVector(-0.02, 0, 0), new PVector(0, 0.02, 0)},
  {new PVector(0, -0.02, 0), new PVector(0.02, 0, 0), new PVector(-0.02, 0, 0), new PVector(0, 0.02, 0)},
  {new PVector(0, -0.02, 0), new PVector(0.02, 0, 0), new PVector(-0.02, 0, 0), new PVector(0, 0.02, 0)}
};
ArrayList idBundles;
ArrayList offsetBundles;

SimpleMatrix homography;

PImage calibImg;

int U = 523;
PVector O = new PVector(178.5, 56.5);
int offsetX = -30;
int offsetY = -25;
float imgX;
float imgY;

void setup() {
  size(1100, 750);
  oscP5 = new OscP5(this, 9000);
  initTagManager();
  calibImg = loadImage("ArUCo_GRID.png");
  imgX = (width - calibImg.width)/2;
  imgY = (height - calibImg.height)/2;
  background(100);
}

void draw() {
  tm.update();
  background(100);
  //tm.displayRaw();
  image(calibImg,imgX,imgY);
  if (!homographyMatrixCalculated) {
    if (cornersDetected()) {
      calculateHomographyMatrix();
      homographyMatrixCalculated = true;
    }
  } else {
    background(255);
    tm.display2D(homography);
  }
}
