//trigger your events here
  
void tagPresent2D(int id, float x, float y, float z, float yaw) { 
  if (homographyMatrixCalculated && !isCorner(id)) {
    PVector t = transformPoint(new PVector(x, y, z), homography);
    println("+ Tag:", id, "loc = (", t.x, ",", t.y, "), angle = ", degrees(yaw));
  }
}

void tagAbsent2D(int id, float x, float y, float z, float yaw) {
  if (homographyMatrixCalculated && !isCorner(id)) {
    PVector t = transformPoint(new PVector(x, y, z), homography);
    println("- Tag:", id, "loc = (", t.x, ",", t.y, "), angle = ", degrees(yaw));
  }
}

void tagUpdate2D(int id, float x, float y, float z, float yaw) {
  if (homographyMatrixCalculated && !isCorner(id)) {
    PVector t = transformPoint(new PVector(x, y, z), homography);
    //println("% Tag:", id, "loc = (", t.x, ",", t.y, "), angle = ", degrees(yaw));
  }
}

void bundlePresent2D(int id, float x, float y, float z, float yaw) {
  if (homographyMatrixCalculated && !isCorner(id)) {
    PVector t = transformPoint(new PVector(x, y, z), homography);
    println("+ Bundle:", id, "loc = (", t.x, ",", t.y, "), angle = ", degrees(yaw));
  }
}

void bundleAbsent2D(int id, float x, float y, float z, float yaw) {
  if (homographyMatrixCalculated && !isCorner(id)) {
    PVector t = transformPoint(new PVector(x, y, z), homography);
    println("- Bundle:", id, "loc = (", t.x, ",", t.y, "), angle = ", degrees(yaw));
  }
}

void bundleUpdate2D(int id, float x, float y, float z, float yaw) {
  if (homographyMatrixCalculated && !isCorner(id)) {
    PVector t = transformPoint(new PVector(x, y, z), homography);
    //println("% Tag:", id, "loc = (", t.x, ",", t.y, "), angle = ", degrees(yaw));
  }
}
