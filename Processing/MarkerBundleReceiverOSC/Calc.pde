PVector[] srcPoints = new PVector[4];
PVector[] dstPoints = new PVector[4];

boolean cornersDetected() {
  if ( tm.tags[corners[0]].active &&
    tm.tags[corners[1]].active &&
    tm.tags[corners[2]].active &&
    tm.tags[corners[3]].active ) {
    return true;
  } else {
    return false;
  }
}

boolean isCorner(int id){
  if ( id == corners[0] || id == corners[1] || id == corners[2] || id == corners[3] ) {
    return true;
  } else {
    return false;
  }
}

// Calculate the homography matrix using the provided points
SimpleMatrix calculateHomography(PVector[] srcPoints, PVector[] dstPoints) {
  // Create matrices to store the points
  SimpleMatrix srcMatrix = new SimpleMatrix(3, 4);
  SimpleMatrix dstMatrix = new SimpleMatrix(3, 4);

  // Fill the matrices with the points
  for (int i = 0; i < 4; i++) {
    srcMatrix.set(0, i, srcPoints[i].x);
    srcMatrix.set(1, i, srcPoints[i].y);
    srcMatrix.set(2, i, srcPoints[i].z);

    dstMatrix.set(0, i, dstPoints[i].x);
    dstMatrix.set(1, i, dstPoints[i].y);
    dstMatrix.set(2, i, 1.0);
  }

  // Calculate the homography matrix
  return dstMatrix.mult(srcMatrix.pseudoInverse());
}

// Transform a 3D point using the homography matrix
PVector transformPoint(PVector point, SimpleMatrix homography) {
  float x = point.x;
  float y = point.y;
  float z = point.z;

  SimpleMatrix result = homography.mult(new SimpleMatrix(new double[][] {{x}, {y}, {z}}));

  float w = (float) result.get(2, 0);
  float transformedX = (float) (result.get(0, 0) / w);
  float transformedY = (float) (result.get(1, 0) / w);

  return new PVector(transformedX, transformedY);
}
