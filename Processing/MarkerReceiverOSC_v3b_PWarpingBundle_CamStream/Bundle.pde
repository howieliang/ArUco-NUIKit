class Bundle {
  int TTL = 200;
  boolean active;
  long ts;
  ArrayList<Integer> ids;
  ArrayList<PVector> offs;
  float x, y, z, r, p, yaw;

  Bundle(ArrayList<Integer> bundleIDs, ArrayList<PVector> IDoffsets) {
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

  void setInactive() {
    if (this.active && (millis()-this.ts)>this.TTL) {
      this.active = false;
      bundleAbsent2D(this.ids.get(0), this.x, this.y, this.z, this.yaw); 
    }
  }

  void set(float x, float y, float z, float r, float p, float yaw) {
    this.ts = millis();
    this.x = x;
    this.y = y;
    this.z = z;
    this.r = r;
    this.p = p;
    this.yaw = yaw;
    if (!this.active){
      bundlePresent2D(this.ids.get(0), this.x, this.y, this.z, this.yaw);
    }else{
      bundleUpdate2D(this.ids.get(0), this.x, this.y, this.z, this.yaw);
    }
    this.active = true;
  }
  
  PVector getOffsetFromID (int targetID){
    int index = -1;
    for (int i = 0; i < this.ids.size(); i++) {
      if (this.ids.get(i) == targetID) {
        index = i;
        break;
      }
    }
    if(index>=0) return this.offs.get(index);
    else return new PVector(0,0,0);
  }
}
