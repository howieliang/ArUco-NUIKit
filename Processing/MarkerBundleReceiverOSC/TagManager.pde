// Define a class called TagManager to manage an array of Tag objects.
class TagManager {
  Tag[] tags; // Declare an array of Tag objects.
  ArrayList<Bundle> tagBundles; // Declare an array of Bundle objects.
  PMatrix3D projectionMatrix; // Projection matrix

  // Constructor for the TagManager class, takes an integer 'n' as a parameter.
  TagManager(int n) {
    tags = new Tag[n]; // Initialize the 'tags' array with 'n' elements.
    // Loop through the array and create a new Tag object for each element.
    for (int i = 0; i < n; i++) {
      tags[i] = new Tag(i);
    }
  }

  // Constructor for the TagManager class, takes an integer 'n' as a parameter.
  TagManager(int n, ArrayList b_ids, ArrayList b_offs) {
    tags = new Tag[n]; // Initialize the 'tags' array with 'n' elements.
    this.tagBundles = new ArrayList<Bundle>();
    // Loop through the array and create a new Tag object for each element.
    for (int i = 0; i < n; i++) {
      tags[i] = new Tag(i);
    }
    // Register the tag bundles
    for (int i = 0; i < b_ids.size(); i++) {
      ArrayList<Integer> ids = (ArrayList<Integer>) b_ids.get(i);
      ArrayList<PVector> offs = (ArrayList<PVector>) b_offs.get(i);
      this.tagBundles.add( new Bundle(ids, offs) );
    }
  }

  // Set method to update the properties of a specific Tag object by its 'id'.
  void set(int id, float x, float y, float z, float r, float p, float yaw) {
    tags[id].set(x, y, z, r, p, yaw); // Call the set method on the specified Tag object.
  }

  // Update method to check the activity status of all Tag objects.
  void update() {
    for (Tag t : this.tags) {
      t.checkActive(); // Call the checkActive method on each Tag object.
    }
    for (Bundle b : this.tagBundles) {
      ArrayList<Tag> activeTags = new ArrayList<Tag>();
      for (Integer id : b.ids) {
        if (tags[id].active) {
          activeTags.add(tags[id]);
        }
      }
      if (activeTags.size()>0) {
        PVector loc = new PVector(0, 0, 0);
        PVector ori = new PVector(0, 0, 0);
        for (Tag t : activeTags) {
          projectionMatrix = new PMatrix3D();
          projectionMatrix.rotateZ(t.yaw);
          projectionMatrix.rotateX(t.r);
          projectionMatrix.rotateY(t.p);
          PVector off = b.getOffsetFromID(t.id);
          PVector projectedPoint = new PVector();
          projectionMatrix.mult(off,projectedPoint);
          loc.add(new PVector(t.x+projectedPoint.x, t.y+projectedPoint.y, t.z+projectedPoint.z));
          ori.add(new PVector(t.r, t.p, t.yaw));
        }
        loc.div(activeTags.size());
        ori.div(activeTags.size());
        b.set(loc.x, loc.y, loc.z, ori.x, ori.y, ori.z);
      } else {
        b.setInactive();
      }
    }
  }

  // Display method to display all Tag objects.
  void display2D(SimpleMatrix homography) {
    for (Tag t : tags) {
      if (!isCorner(t.id) && t.active) {
        float tagR = 30;
        float angle = t.yaw;
        pushMatrix();
        pushStyle();
        fill(0, 127, 255);
        stroke(0);
        PVector p = new PVector(t.x, t.y, t.z);
        PVector transformed = transformPoint(p, homography);
        ellipse(transformed.x, transformed.y, tagR, tagR);
        line(transformed.x, transformed.y, transformed.x+tagR/2*(cos(angle)), transformed.y+tagR/2*(sin(angle)));
        fill(255);
        noStroke();
        textAlign(CENTER, CENTER);
        text(t.id, transformed.x, transformed.y);
        popStyle();
        popMatrix();
      }
    }
    for (Bundle b : tagBundles) {
      if (b.active) {
        float bundleR = 30;
        float angle = b.yaw;
        pushMatrix();
        pushStyle();
        fill(127, 255, 0);
        stroke(0);
        PVector p = new PVector(b.x, b.y, b.z);
        PVector transformed = transformPoint(p, homography);
        ellipse(transformed.x, transformed.y, bundleR, bundleR);
        line(transformed.x, transformed.y, transformed.x+bundleR/2*(cos(angle)), transformed.y+bundleR/2*(sin(angle)));
        fill(255);
        noStroke();
        textAlign(CENTER, CENTER);
        text(b.ids.get(0), transformed.x, transformed.y);
        popStyle();
        popMatrix();
      }
    }
  }

  // Display3D method to display all Tag objects in a 3D context.
  void display3D() {
    for (Tag t : tags) {
      t.display3D(); // Call the display3D method on each Tag object.
    }
  }
}
