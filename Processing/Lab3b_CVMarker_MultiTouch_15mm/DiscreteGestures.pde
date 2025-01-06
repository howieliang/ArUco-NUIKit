void dataObjectIsSingleTapped(int dataID, int ctrlID){
  //println("DataObject", dataID,"Tapped: Bundle", ctrlID);
  //DataObject obj = DOlist.get(dataID);
  //obj.setValue(10.);
}

void dataObjectIsMultiTapped(int dataID, int ctrlID, int n){
  //println("DataObject", dataID,"Multi-Tapped: Bundle", ctrlID);
  //DataObject obj = DOlist.get(dataID);
  //obj.setValue(10.);
}

void dataObjectIsSwipedLeft(int dataID, int ctrlID){
  println("DataObject", dataID,"Swiped Left: Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if(dataID==0) obj.setValue(obj.val-1);
}

void dataObjectIsSwipedRight(int dataID, int ctrlID){
  println("DataObject", dataID,"Swiped Right: Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if(dataID==0) obj.setValue(obj.val+1);
}

void dataObjectIsSwipedUp(int dataID, int ctrlID){
  println("DataObject", dataID,"Swiped Up: Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if(dataID==1) obj.setValue(obj.val+1);
}

void dataObjectIsSwipedDown(int dataID, int ctrlID){
  println("DataObject", dataID,"Swiped Down: Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if(dataID==1) obj.setValue(obj.val-1);
}

void dataObjectIsSpreaded(int dataID, int ctrlID){
  println("DataObject", dataID,"Spreaded: Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if(dataID==2) obj.setValue(obj.val+1);
}

void dataObjectIsPinched(int dataID, int ctrlID){
  println("DataObject", dataID,"Pinched: Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if(dataID==2) obj.setValue(obj.val-1);
}

void dataObjectIsTurnedLeft(int dataID, int ctrlID){
  println("DataObject", dataID,"Turned Left: Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if(dataID==3) obj.setValue(obj.val-1);
}

void dataObjectIsTurnedRight(int dataID, int ctrlID){
  println("DataObject", dataID,"Turned Right: Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if(dataID==3) obj.setValue(obj.val+1);
}

void dataObjectIsSingleTurnedLeft(int dataID, int ctrlID){
  println("DataObject", dataID,"Turned Left: Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if(dataID==8) obj.setValue(obj.val-1);
}

void dataObjectIsSingleTurnedRight(int dataID, int ctrlID){
  println("DataObject", dataID,"Turned Right: Bundle", ctrlID);
  DataObject obj = DOlist.get(dataID);
  if(dataID==8) obj.setValue(obj.val+1);
}
