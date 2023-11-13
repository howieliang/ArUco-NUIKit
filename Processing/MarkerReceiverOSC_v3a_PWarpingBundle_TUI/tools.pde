PVector[] srcPoints = new PVector[4];
PVector[] dstPoints = new PVector[4];

void initTagManager() {
  idBundles = new ArrayList();
  offsetBundles = new ArrayList();
  for (int i = 0; i < bundlesIDs.length; i++) {
    ArrayList ids = new ArrayList();
    ArrayList offsets = new ArrayList();
    for (int j = 0; j < bundlesIDs[i].length; j++) {
      ids.add(bundlesIDs[i][j]);
      offsets.add(bundlesOffsets[i][j]);
    }
    idBundles.add(ids);
    offsetBundles.add(offsets);
  }
  tm = new TagManager(600, idBundles, offsetBundles);
}

void calculateHomographyMatrix() {
  srcPoints[0] = new PVector(tm.tags[cornersID[0]].x, tm.tags[cornersID[0]].y, tm.tags[cornersID[0]].z);
  srcPoints[1] = new PVector(tm.tags[cornersID[1]].x, tm.tags[cornersID[1]].y, tm.tags[cornersID[1]].z);
  srcPoints[2] = new PVector(tm.tags[cornersID[2]].x, tm.tags[cornersID[2]].y, tm.tags[cornersID[2]].z);
  srcPoints[3] = new PVector(tm.tags[cornersID[3]].x, tm.tags[cornersID[3]].y, tm.tags[cornersID[3]].z);

  dstPoints[0] = new PVector(0, 0);
  dstPoints[1] = new PVector(1, 0);
  dstPoints[2] = new PVector(1, 1);
  dstPoints[3] = new PVector(0, 1);

  homography = calculateHomography(srcPoints, dstPoints);
}

boolean cornersDetected() {
  if (tm.tags[cornersID[0]].active &&
      tm.tags[cornersID[1]].active &&
      tm.tags[cornersID[2]].active &&
      tm.tags[cornersID[3]].active) {
    return true;
  } else {
    return false;
  }
}

boolean isCorner(int id) {
  if (id == cornersID[0] || id == cornersID[1] || id == cornersID[2] || id == cornersID[3]) {
    return true;
  } else {
    return false;
  }
}

SimpleMatrix calculateHomography(PVector[] srcPoints, PVector[] dstPoints) {
  SimpleMatrix srcMatrix = new SimpleMatrix(3, 4);
  SimpleMatrix dstMatrix = new SimpleMatrix(3, 4);

  for (int i = 0; i < 4; i++) {
    srcMatrix.set(0, i, srcPoints[i].x);
    srcMatrix.set(1, i, srcPoints[i].y);
    srcMatrix.set(2, i, srcPoints[i].z);

    dstMatrix.set(0, i, dstPoints[i].x);
    dstMatrix.set(1, i, dstPoints[i].y);
    dstMatrix.set(2, i, 1.0);
  }

  return dstMatrix.mult(srcMatrix.pseudoInverse());
}

PVector transformPoint(PVector point, SimpleMatrix homography) {
  float x = point.x;
  float y = point.y;
  float z = point.z;

  SimpleMatrix result = homography.mult(new SimpleMatrix(new double[][] {{x}, {y}, {z}}));

  float w = (float) result.get(2, 0);
  float transformedX = (float) (result.get(0, 0) / w);
  float transformedY = (float) (result.get(1, 0) / w);

  return new PVector(transformedX*U+O.x+offsetX+imgX, transformedY*U+O.y+offsetY+imgY);
}
