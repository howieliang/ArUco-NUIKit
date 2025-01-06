class DataObject {
  int OBJ_WIDTH = 300;
  int dataID;
  int lastCtrlID=-1;
  boolean multiControl;
  float x, y, rx, ry, rz, h, w;
  String name;
  float val;
  float tempVal = 0;
  ArrayList<Integer> ctrlIDList;
  ArrayList<PVector> ref2DList;
  ArrayList<Float> ref_rList;
  color fg_m = color(250, 177, 160);
  color fg_s = color(162, 155, 254);
  color bg = color(52);
  PVector ref2D; //reference 2D point for the MT gestures
  float ref_r; //reference angle for the MT gestures
  boolean bEngaged = false;
  float d0, theta0, theta_p;
  PVector m0;
  int textSizeL=24;
  int textSizeM=20;
  int gestureType = 0;
  int numTouches = 0;
  boolean gesturePerformed = false;
  final float TH_S = 30; // unit: px
  final float TH_R = 10; // unit: degree
  final float TH_T = 30; // unit: px
  final int UNDEFINED = 0;
  final int SCALING = 1;
  final int ROTATION = 2;
  final int TRANSLATION = 3;
  float scale = 1;
  float rotation = 0;
  float prev_rotation = 0;
  PVector translation = new PVector(0, 0);
  String lastGestureInfo = "";
  
  DataObject(int did, boolean multi, float val, float x, float y, float rx, float ry, float rz, float w, float h, String name) {
    this.dataID = did;
    this.set(val, x, y, rx, ry, rz, h, w);
    this.ref2D = new PVector(0, 0);
    this.ref_r = 0;
    this.ctrlIDList = new ArrayList<Integer>();
    this.ref2DList = new ArrayList<PVector>();
    this.ref_rList = new ArrayList<Float>();
    this.multiControl = multi;
    this.name = name;
  }

  DataObject(int did, boolean multi, float val, float x, float y, float rz, float w, float h, String name) {
    this.dataID = did;
    this.set(val, x, y, 0, 0, rz, h, w);
    this.ref2D = new PVector(0, 0);
    this.ref_r = 0;
    this.ctrlIDList = new ArrayList<Integer>();
    this.ref2DList = new ArrayList<PVector>();
    this.ref_rList = new ArrayList<Float>();
    this.multiControl = multi;
    this.name = name;
  }
  
  DataObject(int did, boolean multi, float val, float x, float y, float w, String name) {
    this.dataID = did;
    this.set(val, x, y, 0, 0, 0, w, w);
    this.ref2D = new PVector(0, 0);
    this.ref_r = 0;
    this.ctrlIDList = new ArrayList<Integer>();
    this.ref2DList = new ArrayList<PVector>();
    this.ref_rList = new ArrayList<Float>();
    this.multiControl = multi;
    this.name = name;
  }

  DataObject(int did, boolean multi, float val, float x, float y, String name) {
    this.dataID = did;
    this.set(val, x, y, 0, 0, 0, OBJ_WIDTH, OBJ_WIDTH);
    this.ref2D = new PVector(0, 0);
    this.ref_r = 0;
    this.ctrlIDList = new ArrayList<Integer>();
    this.ref2DList = new ArrayList<PVector>();
    this.ref_rList = new ArrayList<Float>();
    this.multiControl = multi;
    this.name = name;
  }

  void set(float val, float x, float y, float rx, float ry, float rz, float h, float w) {
    this.update(val, x, y, rx, ry, rz, h, w);
  }
  
  void setValue(float val){
    this.val = val;
  }
  void setTempVal(float val){
    this.tempVal = val;
  }

  void addCtrlID(int cid, PVector ref2d, float ref_r) {
    this.ctrlIDList.add(cid);
    this.ref2DList.add(ref2d);
    this.ref_rList.add(ref_r);
  }

  boolean hasCtrlID(int cid) {
    boolean found = false;
    for (int i : ctrlIDList) {
      if (i == cid) found=true;
    }
    return found;
  }
  
  void setPreviousRotation(float rz){
    prev_rotation = rz;
  }

  void removeCtrlID(int cid) {
    for (int i = ctrlIDList.size()-1; i>=0; i--) {
      if (this.ctrlIDList.get(i) == cid) {
        this.ctrlIDList.remove(i);
        this.ref2DList.remove(i);
        this.ref_rList.remove(i);
      }
    }
  }

  int getCtrlCounts() {
    return this.ctrlIDList.size();
  }

  void setRef2D(PVector l, float r) {
    this.ref2D = new PVector (l.x, l.y);
    this.ref_r = r;
  }
  
  void update(float val, float x, float y, float rx, float ry, float rz, float h, float w) {
    this.val = val;
    this.x = x;
    this.y = y;
    this.rx = rx;
    this.ry = ry;
    this.rz = rz;
    this.h = h;
    this.w = w;
  }

  void update(float val, float x, float y, float rz, float h, float w) {
    this.val = val;
    this.x = x;
    this.y = y;
    this.rz = rz;
    this.h = h;
    this.w = w;
  }

  void update(float val, float x, float y, float rz) {
    this.val = val;
    this.x = x;
    this.y = y;
    this.rz = rz;
  }

  void update(float val, float x, float y) {
    this.val = val;
    this.x = x;
    this.y = y;
  }

  void updateLoc2D(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  void updateScale2D(float scale){
    this.scale = scale;
  }
  
  void updateOri2D(float rz) {
    this.rz = rz;
  }
  
  void updateOri3D(float rx,float ry, float rz) {
    this.rx = rx;
    this.ry = ry;
    this.rz = rz;
  }

  void update(float val) {
    this.val = val;
  }

  boolean checkHit(float cx, float cy, float d) {
    boolean hit = false;
    return abs(this.x-cx)<(this.w/2) && abs(this.y-cy)<(this.h/2);
  }

  void display() {
    drawDataObject();
  }
  
  void drawDataObject(){
    String ctrlIDstr = "";
    for (int i : ctrlIDList) ctrlIDstr += ("["+i+"]");
    String label = dataID+":"+ctrlIDstr+"\n"+nf((val+tempVal),0,2);
    pushMatrix();
    pushStyle();
    if(multiControl) fill(fg_m);
    else fill(fg_s);
    noStroke();
    rectMode(CENTER);
    rect(x,y, w, w);
    fill(bg);
    noStroke();
    textSize(w/6);
    textAlign(CENTER, CENTER);
    text(label, x, y);
    popStyle();
    popMatrix();
  }
  
  
  void getSTGestureType() {
    //if (gestureType==UNDEFINED) {
    //  dataObjectIsSingleTapped(dataID, lastCtrlID);
    //}
  }
  
  void getMTGestureType() {
    if (scale>TH_S) {
      dataObjectIsPinched(dataID, lastCtrlID);
    }
    if (scale<-TH_S) {
      dataObjectIsSpreaded(dataID, lastCtrlID);
    }
    if (degrees(rotation)>TH_R) {
      dataObjectIsTurnedLeft(dataID, lastCtrlID);
    }
    if (degrees(rotation)<-TH_R) {
      dataObjectIsTurnedRight(dataID, lastCtrlID);
    }
    if (translation.x>TH_T) {
      dataObjectIsSwipedRight(dataID, lastCtrlID);
    }
    if (translation.x<-TH_T) {
      dataObjectIsSwipedLeft(dataID, lastCtrlID);
    }
    if (translation.y>TH_T) {
      dataObjectIsSwipedDown(dataID, lastCtrlID);
    }
    if (translation.y<-TH_T) {
      dataObjectIsSwipedUp(dataID, lastCtrlID);
    }
    if (gestureType==UNDEFINED) {
      dataObjectIsMultiTapped(dataID, lastCtrlID, numTouches);
    }
  }
  
  void drawSTGestureType() {
    pushMatrix();
    pushStyle();
    fill(0, 255, 0);
    textSize(textSizeM);
    translate(this.x,this.y);
    String lastGestureInfo =" rotated " + nf(degrees(this.rotation), 1, 2) + " degrees" +
      "\n translated (X: " + nf(this.translation.x, 1, 1) + ", Y:" + nf(this.translation.y, 1, 1) + ") pxs";
    text("last gesture:\n"+ lastGestureInfo, this.w/2, 0);
    //text("Can be recognized as:", 0, 3*textSizeL);
    //if (gestureType==UNDEFINED && numTouches>0) {
    //  text(dataID+":[tapped]", 0, 5*textSizeL);
    //}
    popStyle();
    popMatrix();
  }
  
  
  void drawSTGestureInfo() {
    String info = "[Thresholds > Movement]\n" + 
      "\n rotation =" + nf(degrees(rotation), 1, 2) +
      "\n translation = (X: " + nf(translation.x, 1, 1) + ", Y:" + nf(translation.y, 1, 1) + ")";
    if (gestureType!=UNDEFINED) {
      info ="[Movement > Thresholds]\n rotation = " + nf(degrees(rotation), 1, 2) + " degrees \n" +
        "translation = (X: " + nf(translation.x, 1, 1) + ", Y:" + nf(translation.y, 1, 1) + ") pixels";
    }
    pushStyle();
    fill(0, 255, 0);
    textSize(textSizeM);
    text(info, this.x+this.w/2, this.y);
    rectMode(CENTER);
    noFill();
    popStyle();
  }
  
  void drawMTGestureInfo() {
    String info = "[Thresholds > Movement]\n" + 
      "\n scale =" + nf(scale, 1, 1) +
      "\n rotation =" + nf(degrees(rotation), 1, 2) +
      "\n translation = (X: " + nf(translation.x, 1, 1) + ", Y:" + nf(translation.y, 1, 1) + ")";
    if (gestureType!=UNDEFINED) {
      info ="[Movement > Thresholds]\n scale = " + nf(scale, 1, 1) + " pixels \n"+ 
        "rotation = " + nf(degrees(rotation), 1, 2) + " degrees \n" +
        "translation = (X: " + nf(translation.x, 1, 1) + ", Y:" + nf(translation.y, 1, 1) + ") pixels";
    }
    pushStyle();
    fill(0, 255, 0);
    textSize(textSizeM);
    text(info, this.x+this.w/2, this.y);
    rectMode(CENTER);
    noFill();
    popStyle();
  }
  
  void drawMTGestureType() {
    pushMatrix();
    pushStyle();
    fill(0, 255, 0);
    textSize(textSizeM);
    translate(this.x,this.y);
    String lastGestureInfo =" scaled " + nf(this.scale, 1, 1) + " pxs" +
      "\n rotated " + nf(degrees(this.rotation), 1, 2) + " degrees" +
      "\n translated (X: " + nf(this.translation.x, 1, 1) + ", Y:" + nf(this.translation.y, 1, 1) + ") pxs"
      +"\nprevR"+nf(degrees(this.prev_rotation), 1, 2)
      +"\nrotation"+nf(degrees(this.rotation), 1, 2);
    text("last gesture:\n"+ lastGestureInfo, this.w/2, -2*textSizeL);
    text("Can be recognized as:", this.w/2, 4*textSizeL);
    if (scale>TH_S) {
      text(dataID+":[pinched]", this.w/2, 5*textSizeL);
      //myPort.write('a');
    }
    if (scale<-TH_S) {
      text(dataID+":[spreaded]", this.w/2, 5*textSizeL);
      //myPort.write('b');
    }
    if (degrees(rotation)>TH_R) {
      text(dataID+":[turned left]", this.w/2, 6*textSizeL);
    }
    if (degrees(rotation)<-TH_R) {
      text(dataID+":[turned right]", this.w/2, 6*textSizeL);
    }
    if (translation.x>TH_T) {
      text(dataID+":[swiped right]", this.w/2, 7*textSizeL);
    }
    if (translation.x<-TH_T) {
      text(dataID+":[swiped left]", this.w/2, 7*textSizeL);
    }
    if (translation.y>TH_T) {
      text(dataID+":[swiped down]", this.w/2, 8*textSizeL);
    }
    if (translation.y<-TH_T) {
      text(dataID+":[swiped up]", this.w/2, 8*textSizeL);
    }
    if (gestureType==UNDEFINED && numTouches>0) {
      text(dataID+":[tapped with "+numTouches+" fingers]", this.w/2, 9*textSizeL);
    }
    popStyle();
    popMatrix();
  }
}
