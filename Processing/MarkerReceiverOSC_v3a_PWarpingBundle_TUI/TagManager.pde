class TagManager {
  Tag[] tags;
  ArrayList<Bundle> tagBundles;
  PMatrix3D projectionMatrix;

  TagManager(int n, ArrayList b_ids, ArrayList b_offs) {
    tags = new Tag[n];
    this.tagBundles = new ArrayList<Bundle>();
    for (int i = 0; i < n; i++) {
      tags[i] = new Tag(i);
    }
    for (int i = 0; i < b_ids.size(); i++) {
      ArrayList<Integer> ids = (ArrayList<Integer>) b_ids.get(i);
      ArrayList<PVector> offs = (ArrayList<PVector>) b_offs.get(i);
      this.tagBundles.add(new Bundle(ids, offs));
    }
  }

  void set(int id, float x, float y, float z, float r, float p, float yaw, PVector[] corners) {
    tags[id].set(x, y, z, r, p, yaw, corners);
  }

  void update() {
    for (Tag t : this.tags) {
      t.checkActive();
    }
    for (Bundle b : this.tagBundles) {
      ArrayList<Tag> activeTags = new ArrayList<Tag>();
      for (Integer id : b.ids) {
        if (tags[id].active) {
          activeTags.add(tags[id]);
        }
      }
      if (activeTags.size() > 0) {
        PVector loc = new PVector(0, 0, 0);
        PVector ori = new PVector(0, 0, 0);
        for (Tag t : activeTags) {
          projectionMatrix = new PMatrix3D();
          projectionMatrix.rotateZ(t.yaw);
          projectionMatrix.rotateX(t.r);
          projectionMatrix.rotateY(t.p);
          PVector off = b.getOffsetFromID(t.id);
          PVector projectedPoint = new PVector();
          projectionMatrix.mult(off, projectedPoint);
          loc.add(new PVector(t.x + projectedPoint.x, t.y + projectedPoint.y, t.z + projectedPoint.z));
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

  void displayRaw() {
    for (Tag t : tags) {
      if (t.active) {
        pushMatrix();
        pushStyle();
        noStroke();
        fill(255,0,0);
        ellipse(t.corners[0].x,t.corners[0].y,5,5);
        fill(255,255,0);
        ellipse(t.corners[1].x,t.corners[1].y,5,5);
        fill(0,255,255);
        ellipse(t.corners[2].x,t.corners[2].y,5,5);
        fill(0,0,255);
        ellipse(t.corners[3].x,t.corners[3].y,5,5);
        fill(0,0,255);
        
        noFill();
        stroke(0,255,0);
        line(t.corners[0].x,t.corners[0].y,t.corners[1].x,t.corners[1].y);
        line(t.corners[1].x,t.corners[1].y,t.corners[2].x,t.corners[2].y);
        line(t.corners[2].x,t.corners[2].y,t.corners[3].x,t.corners[3].y);
        line(t.corners[3].x,t.corners[3].y,t.corners[0].x,t.corners[0].y);
        
        fill(255);
        noStroke();
        
        PVector c = new PVector((t.corners[0].x+t.corners[2].x)/2,(t.corners[0].y+t.corners[2].y)/2); 
        
        textAlign(CENTER, CENTER);
        text(t.id, c.x, c.y);
        
        popStyle();
        popMatrix();
      }
    }
  }

  void display2D(SimpleMatrix homography) {
    for (Tag t : tags) {
      if (!isCorner(t.id) && t.active) {
        float tagD = 100;
        float angle2D = t.yaw;
        PVector loc2D = transformPoint(new PVector(t.x, t.y, t.z), homography);
        drawTagSimple(t.id, loc2D, angle2D, tagD, color(0, 127, 255)); //example visualization
      }
    }
    for (Bundle b : tagBundles) {
      if (b.active) {
        float bundleD = 100;
        float angle2D = b.yaw;
        PVector loc2D = transformPoint(new PVector(b.x, b.y, b.z), homography);
        drawTagSimple(b.ids.get(0), loc2D, angle2D, bundleD, color(127, 255, 0)); //example visualization
      }
    }
  }

  void drawTagSimple(int id, PVector loc2D, float angle2D, float bundleD, color c) {
    float bundleR = bundleD/2;
    pushMatrix();
    pushStyle();
    fill(c);
    stroke(0);
    ellipse(loc2D.x, loc2D.y, bundleD, bundleD);
    line(loc2D.x, loc2D.y, loc2D.x + bundleR * (cos(angle2D)), loc2D.y + bundleR * (sin(angle2D)));
    fill(255);
    noStroke();
    textAlign(CENTER, CENTER);
    textSize(bundleR);
    text(id, loc2D.x, loc2D.y);
    popStyle();
    popMatrix();
  }
}
