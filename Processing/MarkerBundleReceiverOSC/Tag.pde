class Tag {
  // Define constants and variables for a Tag object
  float W = 10;          // Width (mm)
  float L = 0.5;         // Length
  float H = 10;          // Height (mm)
  int TTL = 60;         // Time To Live
  boolean active;        // Is the tag active?
  long ts;               // Timestamp
  int id;                // Identifier
  float x, y, z, r, p, yaw; // Position and orientation
  PVector[] vertices = new PVector[8]; // Array to store vertices of the tag
  int[][] edges = {
    {0, 1}, {1, 3}, {3, 2}, {2, 0},
    {4, 5}, {5, 7}, {7, 6}, {6, 4},
    {0, 4}, {1, 5}, {2, 6}, {3, 7}  // Vertical edges
  };

  // Constructor for creating a Tag object
  Tag(int id) {
    // Initialize variables with default values
    this.id = id;
    this.x = 0;
    this.y = 0;
    this.z = 0;
    this.r = 0;
    this.p = 0;
    this.yaw = 0;
    this.ts = 0;
    this.active = false;
    // Generate the vertices of the tag
    vertices = generateFlatBoxVertices(W, L, H);
  }

  // Constructor for creating a Tag object with specific attributes
  Tag(int id, float x, float y, float z, float r, float p, float yaw) {
    // Initialize variables with provided values
    this.id = id;
    this.x = x;
    this.y = y;
    this.z = z;
    this.r = r;
    this.p = p;
    this.yaw = yaw;
    this.ts = 0;
    this.active = false;
    // Generate the vertices of the tag
    vertices = generateFlatBoxVertices(W, L, H);
  }

  // Method to check if the tag is active based on its time to live (TTL)
  void checkActive() {
    if (active && (millis()-ts)>TTL) {
      active = false;
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

  // Method to display the tag as a 2D ellipse
  void display2D() {
    if (active) {
      fill(255);
      ellipse(x, y, 20, 20);
      textAlign(CENTER, CENTER);
      fill(0);
      text(id, x, y);
    }
  }

  // Method to display the tag in 3D space
  void display3D() {
    if (active) {
      pushMatrix();
      fill(255);
      translate(x, y, z);
      rotateZ(yaw);
      rotateX(r);
      rotateY(p);
      drawTagBox();
      textAlign(CENTER, CENTER);
      PVector labelPosition = PVector.add(vertices[4], vertices[5]).mult(0.2);
      textSize(10);
      fill(0);
      scale(1, 1);
      text(id, labelPosition.x, labelPosition.y, labelPosition.z);
      popMatrix();
    }
  }

  // Method to generate the vertices of a flat box
  PVector[] generateFlatBoxVertices(float W, float H, float L) {
    PVector[] vertices = new PVector[8];
    for (int i = 0; i < 8; i++) {
      float x = (i & 1) == 0 ? -W / 2 : W / 2;
      float y = (i & 2) == 0 ? -L / 2 : L / 2;
      float z = (i & 4) == 0 ? H : 0;
      vertices[i] = new PVector(x, y, z);
    }
    return vertices;
  }

  // Method to draw the edges of the tag's box
  void drawTagBox() {
    for (int[] edge : edges) {
      PVector v1 = vertices[edge[0]];
      PVector v2 = vertices[edge[1]];
      line(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
    }
  }
}
