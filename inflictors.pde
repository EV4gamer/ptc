
class inflictor {
  PVector pos;
  PVector vel;
  PVector acc;

  float mass;
  float radius;
  float aoe;
  int fillType;
  
  color col;
  int TRAIL_LENGTH;
  ArrayList<PVector> trail;
  
  boolean purge = false;
  boolean offscreen = false;

  inflictor(PVector p, PVector v, float m, float r, float ar, color c, int tl, int ft) {
    pos = p;
    vel = v;
    radius = r;
    acc = new PVector(0, 0);
    mass = m;
    col = c;
    aoe = ar;
    TRAIL_LENGTH = tl;
    fillType = ft;
    trail = new ArrayList<PVector>();
    for (int i = 0; i < TRAIL_LENGTH; i++) {
      trail.add(pos.copy());
    }
  }
  
  void applyForce(PVector f) {
    acc.add(f.div(mass));
  }

  void update(float fac) {
    vel.add(PVector.mult(acc, fac));
    pos.add(PVector.mult(vel, fac));
    acc.mult(0);
  }

  void trailUpdate() {
    trail.add(pos.copy());

    while (trail.size() > TRAIL_LENGTH) {
      trail.remove(0);
    }
  }

  void render() {
    trailUpdate();
    strokeCap(SQUARE);
    noFill();
    beginShape();
    for (int i = 0; i < trail.size(); i++) {
      PVector pb = trail.get(i);
      stroke(col, map(i, 0, trail.size(), 0, 200));
      strokeWeight(map(i, 0, trail.size(), 0, radius / 4));
      curveVertex(pb.x, pb.y);
    }
    endShape();

    noStroke();
    fill(col);
    circle(pos.x, pos.y, radius * 2);
  }
}
