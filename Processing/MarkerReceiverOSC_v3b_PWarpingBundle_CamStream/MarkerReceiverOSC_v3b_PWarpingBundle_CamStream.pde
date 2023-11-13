//*********************************************
// Example Code: ArUCo Fiducial Marker Detection in OpenCV Python and then send to Processing via OSC
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************

import org.ejml.simple.SimpleMatrix;
import oscP5.*;
import netP5.*;
import processing.net.*;

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

Client client; //for camera streaming
PImage prevFrame;
PImage background;

int camWidth = 640;
int camHeight = 480;
//int camWidth = 1280;
//int camHeight = 720;
int dataOffset = 163;

float[] srcX;
float[] srcY;
float[] dstX;
float[] dstY;

void setup() {
  size(800, 800, P2D);
  oscP5 = new OscP5(this, 9000);
  prevFrame = createImage(camWidth, camHeight, RGB);
  client = new Client(this, "localhost", 8762);
  initTagManager();
  srcX = new float[4];
  srcY = new float[4];
  dstX = new float[4];
  dstY = new float[4];
}

void draw() {
  tm.update();
  background(255);
  getGrayscaleImgFromServer();
  image(prevFrame, 0, 0);
  tm.displayRaw();

  if (!homographyMatrixCalculated) {
    //background(100);
    getGrayscaleImgFromServer();
    if (cornersDetected()) {
      calculateHomographyMatrix();
      background = prevFrame;
      PVector[] cornerCenters = new PVector[4];
      for (int i=0; i<cornerCenters.length; i++) {
        cornerCenters[i] = new PVector((tm.tags[cornersID[i]].corners[0].x+tm.tags[cornersID[i]].corners[2].x)/2, (tm.tags[cornersID[i]].corners[0].y+tm.tags[cornersID[i]].corners[2].y)/2);
      }
      srcX[0] = cornerCenters[0].x;
      srcX[1] = cornerCenters[1].x;
      srcX[2] = cornerCenters[2].x;
      srcX[3] = cornerCenters[3].x;
      srcY[0] = cornerCenters[0].y; 
      srcY[1] = cornerCenters[1].y;
      srcY[2] = cornerCenters[2].y;
      srcY[3] = cornerCenters[3].y;
      
      dstX[0] = 0;
      dstX[1] = background.width;
      dstX[2] = background.width;
      dstX[3] = 0;
      dstY[0] = 0; 
      dstY[1] = 0;
      dstY[2] = background.height;
      dstY[3] = background.height;

      homographyMatrixCalculated = true;
    }
  } else {
    beginShape();
    texture(background);
    //fill(255);
    for (int i = 0; i < 4; i++) {
      vertex(dstX[i], dstY[i], srcX[i], srcY[i]);
    }
    endShape(CLOSE);
    getGrayscaleImgFromServer();
    tm.display2D(homography);
  }
}
