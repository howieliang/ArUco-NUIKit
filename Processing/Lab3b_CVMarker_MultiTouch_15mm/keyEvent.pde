void keyPressed() {
  if (key == ' ') {
    homographyMatrixCalculated = false;
  }
  if (key == 'r') {
    resetData = true;
  }
  if (key == 'g') {
    gestureDebug = !gestureDebug;
  }
  if (key == 't') {
    tagDebug= !tagDebug;
  }
  if (key == 'd') {
    dataObjectDebug = !dataObjectDebug;
  }
  if (key == 's') {
    serialDebug= !serialDebug;
  }
}
