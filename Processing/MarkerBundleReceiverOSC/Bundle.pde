class Bundle {
  // Define constants and variables for a Tag object
  int TTL = 60;         // Time To Live
  boolean active;        // Is the tag active?
  long ts;               // Timestamp
  ArrayList<Integer> ids;                // Identifier
  ArrayList<PVector> offs;                // Identifier
  float x, y, z, r, p, yaw; // Position and orientation

  // Constructor for creating a Tag object
  Bundle(ArrayList<Integer> bundleIDs, ArrayList<PVector> IDoffsets) {
    // Initialize variables with default values
    this.ids = new ArrayList<Integer>();
    this.offs = new ArrayList<PVector>();
    for (int i = 0; i < bundleIDs.size(); i++) {
      this.ids.add(bundleIDs.get(i));
      this.offs.add(IDoffsets.get(i));
    }
    this.x = 0;
    this.y = 0;
    this.z = 0;
    this.r = 0;
    this.p = 0;
    this.yaw = 0;
    this.ts = 0;
    this.active = false;
  }
  
  PVector getOffsetFromID (int targetID){
    int index = -1; // Initialize the index to -1, indicating the value was not found initially
    for (int i = 0; i < ids.size(); i++) {
      if (ids.get(i) == targetID) {
        index = i; // Set the index to the position where the value was found
        break; // Exit the loop as you've found the value
      }
    }
    if(index>=0) return this.offs.get(index);
    else return new PVector(0,0,0);
  }

  // Method to check if the tag is active based on its time to live (TTL)
  void setInactive() {
    if (active && (millis()-ts)>TTL) {
      this.active = false;
    }
  }

  // Method to set the position and orientation of the tag
  void set(float x, float y, float z, float r, float p, float yaw) {
    ts = millis();
    this.x = x;
    this.y = y;
    this.z = z;
    this.r = r;
    this.p = p;
    this.yaw = yaw;
    active = true;
  }

  // Method to set the position and orientation of the tag
  void set2D(float x, float y, float yaw) {
    ts = millis();
    this.x = x;
    this.y = y;
    this.yaw = yaw;
    this.z = 0;
    this.r = 0;
    this.p = 0;
    active = true;
  }

  // Method to display the tag as a 2D ellipse
  void display2D() {
    if (active) {
      fill(0, 255, 0);
      ellipse(x, y, 20, 20);
      textAlign(CENTER, CENTER);
      fill(0);
      text(ids.get(0), x, y);
    }
  }
}
