

void dataObjectValueMultiSwipedX(int dataID, int ctrlID) {
  println("DataObject", dataID, "is being multi-swiped (X-axis): Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if (dataID==4) DOlist.get(dataID).setTempVal(map(degrees(obj.translation.x), 0, 100, 0, 10));
}

void dataObjectValueMultiSwipedY(int dataID, int ctrlID) {
  println("DataObject", dataID, "is being multi-swiped (Y-axis): Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if (dataID==5) DOlist.get(dataID).setTempVal(map(degrees(-obj.translation.y), 0, 100, 0, 10));
}

void dataObjectValueMultiScaled(int dataID, int ctrlID) {
  println("DataObject", dataID, "is being Pinched: Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if (dataID==6) DOlist.get(dataID).setTempVal(map(degrees(-obj.scale), 0, 100, 0, 10));
}

void dataObjectValueMultiRotated(int dataID, int ctrlID) {
  println("DataObject", dataID, "is being multi-Rotated: Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if (dataID==7) DOlist.get(dataID).setTempVal(map(degrees(-obj.rotation), 0, 100, 0, 10));
}

void dataObjectValueRotated(int dataID, int ctrlID) {
  //println("DataObject", dataID, "is being Rotated : Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  //if(ctrlID == 57 && dataID == 1) obj.setTempVal(map(degrees(obj.rotation),0,100,0,10));
  obj.setTempVal(map(degrees(obj.rotation), 0, 100, 0, 10));
}

void dataObjectTranslatedAndValueRotated(int dataID, int ctrlID) {
  //println("DataObject", dataID, "is being Rotated and Translated : Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  Bundle b = tm.getBundle(ctrlID);
  if (b!=null) {
    PVector loc2D = img2screen(transformPoint(new PVector(b.tx, b.ty, b.tz), homography));
    obj.setTempVal(map(degrees(obj.rotation), 0, 100, 0, 10));
    obj.updateLoc2D(loc2D.x, loc2D.y);
  }
}

void dataObjectRotatedAndTranslated(int dataID, int ctrlID) {
  //println("DataObject", dataID, "is being Rotated and Translated : Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  Bundle b = tm.getBundle(ctrlID);
  if (b!=null) {
    PVector loc2D = img2screen(transformPoint(new PVector(b.tx, b.ty, b.tz), homography));
    PVector ori3D = new PVector(b.rx-global_rx, b.ry-global_ry, b.rz-global_rz);
    obj.updateLoc2D(loc2D.x, loc2D.y);
    obj.updateOri2D(obj.rotation); //relative rotation (as a knob)
  }
}

void dataObjectTapped(int dataID, int ctrlID) {
  //println("DataObject", dataID,"Tapped: Bundle", ctrlID);
  //DataObject obj = DOlist.get(dataID);
  //obj.setValue(10.);
}
