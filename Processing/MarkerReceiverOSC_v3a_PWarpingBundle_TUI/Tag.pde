class Tag {
  int TTL = 60;
  boolean active;
  long ts;
  int id;
  float x, y, z, r, p, yaw;
  PVector[] corners;

  Tag(int id) {
    this.id = id;
    this.x = 0;
    this.y = 0;
    this.z = 0;
    this.r = 0;
    this.p = 0;
    this.yaw = 0;
    this.corners = new PVector[4];
    this.ts = 0;
    this.active = false;
  }

  void checkActive() {
    if (this.active && (millis()-this.ts)>this.TTL) {
      this.active = false;
      tagAbsent2D(this.id, this.x, this.y, this.z, this.yaw);
    }
  }

  void set(float x, float y, float z, float r, float p, float yaw, PVector[] corners) {
    this.ts = millis();
    this.x = x;
    this.y = y;
    this.z = z;
    this.r = r;
    this.p = p;
    this.yaw = yaw;
    this.corners = corners;
    if (!this.active){
      tagPresent2D(this.id, this.x, this.y, this.z, this.yaw);
    }else{
      tagUpdate2D(this.id, this.x, this.y, this.z, this.yaw);
    }
    this.active = true;
  }
}
