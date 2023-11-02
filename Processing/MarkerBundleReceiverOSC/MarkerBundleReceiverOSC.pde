//*********************************************
// Example Code: ArUCo Fiducial Marker Detection in OpenCV Python and then send to Processing via OSC
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************

// Import the necessary libraries for OSC communication
import org.ejml.simple.SimpleMatrix;

import oscP5.*;
import netP5.*;

TagManager tm;
OscP5 oscP5;
final float SCALE = 100*10;

boolean matrixCalculated = false;

int[] corners = {1, 3, 2, 0};
int[][] bundles = {{38, 44, 46, 52}, {42, 48, 50, 56}, {70, 76, 78, 84}}; //IDs of each tag bundles
PVector[][] vectors = {{new PVector(0, -0.02, 0), new PVector(0.02, 0, 0), new PVector(-0.02, 0, 0), new PVector(0, 0.02, 0)}, {new PVector(0, -0.02, 0), new PVector(0.02, 0, 0), new PVector(-0.02, 0, 0), new PVector(0, 0.02, 0)}, {new PVector(0, -0.02, 0), new PVector(0.02, 0, 0), new PVector(-0.02, 0, 0), new PVector(0, 0.02, 0)}}; //reference point of each tag in the bundle
ArrayList idBundles;
ArrayList offsetBundles;

SimpleMatrix homography;

void setup() {
  // Set the canvas size to 800x800 pixels with a 3D rendering context
  size(800, 800, P2D);

  // Initialize the OSC communication on port 9000 (should match the port used in Python)
  oscP5 = new OscP5(this, 9000);

  // Create a TagManager to manage ArUco fiducial markers
  idBundles = new ArrayList();
  offsetBundles = new ArrayList();
  for (int i = 0; i<bundles.length; i++) {
    ArrayList ids = new ArrayList();
    ArrayList offsets = new ArrayList();
    for (int j = 0; j<bundles[i].length; j++) {
      ids.add(bundles[i][j]);
      offsets.add(vectors[i][j]);
    }
    idBundles.add(ids);
    offsetBundles.add(offsets);
  }
  tm = new TagManager(600, idBundles, offsetBundles);
}

void draw() {
  // Update and display the ArUco fiducial markers in 3D space
  if (!matrixCalculated) background(100);
  else background(255);

  tm.update();

  // Define the 3D coordinates of the source quadrilateral
  if (cornersDetected() && !matrixCalculated) {
    // Clear the background with white
    //background(255);
    srcPoints[0] = new PVector(tm.tags[corners[0]].x, tm.tags[corners[0]].y, tm.tags[corners[0]].z);
    srcPoints[1] = new PVector(tm.tags[corners[1]].x, tm.tags[corners[1]].y, tm.tags[corners[1]].z);
    srcPoints[2] = new PVector(tm.tags[corners[2]].x, tm.tags[corners[2]].y, tm.tags[corners[2]].z);
    srcPoints[3] = new PVector(tm.tags[corners[3]].x, tm.tags[corners[3]].y, tm.tags[corners[3]].z);

    // Define the 2D coordinates of the target quadrilateral
    dstPoints[0] = new PVector(0, 0);
    dstPoints[1] = new PVector(width, 0);
    dstPoints[2] = new PVector(width, height);
    dstPoints[3] = new PVector(0, height);

    // Calculate the homography matrix
    homography = calculateHomography(srcPoints, dstPoints);
    matrixCalculated = true;
  } else {
    //background(100);
  }
  if (matrixCalculated) tm.display2D(homography);
}

void oscEvent(OscMessage msg) {
  // Check if the received OSC message matches the address pattern "/message"
  if (msg.checkAddrPattern("/message")) {
    // Extract data from the OSC message
    int id = msg.get(0).intValue();
    float x = msg.get(1).floatValue();
    float y = msg.get(2).floatValue();
    float z = msg.get(3).floatValue();
    float r = msg.get(4).floatValue();
    float p = msg.get(5).floatValue();
    float yaw = msg.get(6).floatValue();

    // Update the TagManager with the received fiducial marker data
    tm.set(id, x, y, z, r, p, yaw);
  }
}

void keyPressed() {
  // Example: Check if a specific key was pressed (e.g., the spacebar)
  if (key == ' ') {
    matrixCalculated = false;
  }
}
