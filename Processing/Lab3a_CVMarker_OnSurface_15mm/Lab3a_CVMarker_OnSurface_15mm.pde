//*********************************************
// Example Code: Lab3a_CVMarker_OnSurface_15mm
// ArUCo Fiducial Marker Detection in OpenCV Python and then send to Processing via OSC
// Tracking Tangibles on a Surface or Flat Panel Display with 15mm-width Markers
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************


import oscP5.*;
import netP5.*;
import processing.net.*;

TagManager tm;
OscP5 oscP5;

//camera parameters
final int camWidth = 1280; //camera resolution (width)
final int camHeight = 720; //camera resolution (height)

//list of active tags
ArrayList<Tag> activeTagList = new ArrayList<Tag>();

////set the bundle IDs
int[][] bundlesIDs = {{12},{14},{16},{49}}; //four objects: first 3 are knobs and the last one is a nail-mounted marker.

////set the bundle offsets (unit: m)
PVector[][] bundlesOffsets = {{new PVector(0,0,-0.01)},{new PVector(0,0,-0.01)},{new PVector(0,0,-0.01)},{new PVector(0,0,-0.015)}};

////set the paper width on screen (initial value: 297; unit mm)
float paperWidthOnScreen = 297.; //when using a printed A4 paper for calibration
//float paperWidthOnScreen = 129.; //if the a4 paper's on-screen width is 227mm

float calibgridWidth = 115; //unit:mm
float calibgridHeight = 115; //unit:mm

////set the marker width on screen (initial value: 297; unit mm)
float markerWidth = 15; //change this if the marker is of different width

////set the touch threshold (unit: m)
float touchThreshold = 0.02; //change this to adjust sensitivity of touch sensing.

////set the stylus' ID (unit: m)
final int stylus_ID = 49; //set stylus_ID = -1 when there's no stylus

ArrayList<DataObject> DOlist = new ArrayList<DataObject>(); //the data objects
ArrayList<PVector> inkList = new ArrayList<PVector>(); // the ink traces

void initDataObjects() { //set up the data objects
  //DataObject(int did, boolean multi, float val, float x, float y, float w, String name)
  DOlist.add(new DataObject(0, false, 10, width/2-200, height/2-200, 300, "Obj. 1"));
  DOlist.add(new DataObject(1, false, 10, width/2+200, height/2-200, 300, "Obj. 2"));
  DOlist.add(new DataObject(2, false, 10, width/2-200, height/2+200, 300, "Obj. 3"));
  DOlist.add(new DataObject(3, false, 10, width/2+200, height/2+200, 300, "Obj. 4"));
}

void setup() {
  size(1920, 1080); //initialize canvas
  oscP5 = new OscP5(this, 9000); //initialize OSC connection via port 9000
  initTagManager(); //initialize tag manager
  calibImg = loadImage("ArUco_Grid15_85.png"); //select the calibration image
  imageOffset.set((width - calibImg.width)/2, (height - calibImg.height)/2); //center the calibration image
  initDataObjects(); //initialize the data objects.
}

void draw() {
  tm.update(); //update the tag manager and the states of tags.
  updateActiveTags(); //update the list of active tags
  if (resetData) resetDataObjects();

  if (!homographyMatrixCalculated) { //if the homography matrix has not been calculated
    background(100);
    drawCalibImage(); //draw the calibration image
    if (cornersDetected()) { //when the corner markers are detected
      calculateHomographyMatrix(); //calculate the homography matrix
      registerPlanePoints(); //register the plane points for plane calculation.
      registerPlaneOrientation(); //register the plane orientation for plane calculation.
      homographyMatrixCalculated = true; //set the homography matrix flag to "calculated"
    }
  } else {
    background(0);
    int gestureMode = 3; //try 1 to 3.
    updateAllDataObjects(gestureMode); //update the state of data objects
    displayUI(gestureMode); //display the UI without debugging message.
    //displayCustomUI(); //display your custom UI without debugging message.
    drawCustomInk(); //when a stylus does not land on a data object, show the ink trace.

    tm.drawActiveBundles(homography);  //draw the computed bundle locations in 2D
    //tm.drawCustomActiveBundles(homography);  //draw the computed bundle locations in 2D

    ////for debugging
    showDebuggers();
    ////
  }
}

void displayCustomUI() {
  //make your own visualization
  for (DataObject obj : DOlist) {
    int dataID = obj.dataID;
    int value = (int)(obj.val+obj.tempVal);
    pushMatrix();
    fill(52);
    pushStyle();
    rectMode(CENTER);
    pushMatrix();
    translate(obj.x, obj.y);
    rotate(obj.rz);
    rect(0, 0, obj.w, obj.h);
    popMatrix();
    fill(52);
    textSize(0);
    text(value, obj.x, obj.y);
    popMatrix();
  }
}

void drawCustomInk() {
  pushStyle();
  fill(255, 255, 0, 128);
  noStroke();
  for (PVector p : inkList) ellipse(p.x, p.y, 50, 50);
  popStyle();
}

void resetDataObjects() {
  DOlist.clear();
  inkList.clear();
  initDataObjects();
  resetData = false;
}

void showDebuggers() {
  if (dataObjectDebug) displayDataObjects(); //display the debugging message of data objects
  if (gestureDebug) drawAllGestures(); //display the debugging messages of gestures
  if (tagDebug) tm.drawActiveTags(homography);  //draw the computed bundle locations in 2D
}

void updateActiveTags() {
  activeTagList.clear();
  for (int tagIndex : tm.activeTags) {
    activeTagList.add(tm.tags[tagIndex]);
  }
}

void displayDataObjects() {
  for (DataObject obj : DOlist) {
    obj.display();
  }
}

void displayUI(int output_mode) {
  for (DataObject obj : DOlist) {
    String value = nf((int)(obj.val+obj.tempVal), 0, 0);
    String label = "("+obj.dataID+")"+obj.name+":"+value;
    pushMatrix();
    pushStyle();
    rectMode(CENTER);
    noStroke();
    if (obj.multiControl) fill(250, 177, 160);
    else fill(162, 155, 254);
    pushMatrix();
    translate(obj.x, obj.y);
    rotate(obj.rz);
    rect(0, 0, obj.w, obj.h);
    popMatrix();
    fill(52);
    if (output_mode == 1 || output_mode == 2) {
      textAlign(LEFT, TOP);
      textSize(obj.w/10);
      text(label, obj.x-obj.w/2, obj.y+obj.h/2-obj.w/10);
      textAlign(CENTER, CENTER);
      textSize(obj.w/2);
      text(value, obj.x, obj.y);
    }
    if (output_mode == 3) {
      textAlign(CENTER, CENTER);
      textSize(obj.w/10);
      text(label, obj.x, obj.y);
    }
    popStyle();
    popMatrix();
  }
}

void updateAllDataObjects(int output_mode) {
  for (DataObject obj : DOlist) {
    if (obj.multiControl == false) {
      int numOfBlobs = obj.getCtrlCounts();
      if (numOfBlobs<=0) {
        if (obj.bEngaged) {
          obj.val += obj.tempVal;
          obj.tempVal = 0;
          obj.getSTGestureType();
          obj.bEngaged = false;
        }
      } else if (numOfBlobs>0) {
        PVector m = new PVector(0, 0);
        float theta = 0;
        float rx = 0;
        float ry = 0;
        for (Bundle b : tm.getActiveBundles()) {
          if (b.getBundleID() == obj.ctrlIDList.get(0)) {
            m = img2screen(transformPoint(new PVector(b.tx, b.ty, b.tz), homography));
            theta = b.rz-global_rz;
          }
        }
        if (!obj.bEngaged) {
          obj.theta0 = theta-obj.prev_rotation;
          obj.theta_p = obj.theta0;
          obj.m0 = new PVector(m.x, m.y);
          obj.bEngaged = true;
          obj.gestureType = obj.UNDEFINED; //by default
          obj.numTouches = numOfBlobs;
          obj.lastCtrlID = obj.ctrlIDList.get(0);
          obj.gesturePerformed = true;
        } else {
          float newAngle = unwrapAngle(theta, obj.theta_p);
          obj.rotation = -(obj.theta0-newAngle);
          obj.theta_p = newAngle;
          obj.translation = PVector.sub(m, obj.m0);
          if (numOfBlobs>obj.numTouches) obj.numTouches = numOfBlobs;

          switch(output_mode) { //Data Behaviors: in "ContinuousGestures" tab
          case 1:
            dataObjectValueRotated(obj.dataID, obj.lastCtrlID);
            break;
          case 2:
            dataObjectTranslatedAndValueRotated(obj.dataID, obj.lastCtrlID);
            break;
          case 3:
            dataObjectRotatedAndTranslated(obj.dataID, obj.lastCtrlID);
            break;
          default:
            break;
          }
        }
      }
    }
  }
}

void drawAllGestures() {
  for (DataObject obj : DOlist) {
    if (obj.multiControl == false) {
      int numOfBlobs = obj.getCtrlCounts();
      if (numOfBlobs==0) {
        obj.drawSTGestureType(); //check this function for the triggers of discrete gestures.
      } else {
        obj.drawSTGestureInfo(); //check this function for the triggers of discrete gestures.
      }
    }
  }
}

float unwrapAngle(float currentAngle, float previousAngle) {
  float deltaAngle = currentAngle - previousAngle;
  if (deltaAngle > PI) {
    currentAngle -= TWO_PI;
  } else if (deltaAngle < -PI) {
    currentAngle += TWO_PI;
  }
  return currentAngle;
}

void drawCalibImage() {
  pushStyle();
  imageMode(CENTER);
  image(calibImg, width/2, height/2, (float)calibImg.width*tag2screenRatio, (float)calibImg.height*tag2screenRatio);
  popStyle();
}

void drawCanvas() {
  pushStyle();
  noStroke();
  fill(10);
  rectMode(CENTER);
  rect(width/2, height/2, (float)calibImg.width*tag2screenRatio, (float)calibImg.height*tag2screenRatio);
  popStyle();
}

void showInfo(String s, int x, int y) {
  pushStyle();
  fill(52);
  textAlign(LEFT, BOTTOM);
  textSize(48);
  text(s, x, y);
  popStyle();
}
