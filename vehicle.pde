
class vehicle {
  PVector pos;
  PVector vel;
  PVector acc;
  float mass;
  int movesLeft;
  int healthLeft;
  float angle;
  color col;

  vehicle(PVector p, float m, color c) {
    pos = p;
    for (int y = 0; y < height; y++) {
      if (grid[(int)pos.x][(int)pos.y + 1] == 0) {
        pos.y += 1;
      }
    }

    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    mass = m;
    col = c;
    movesLeft = 5;
    healthLeft = 100;
    angle = 0;
  }

  void applyForce(PVector f) {
    acc.add(f.div(mass));
  }

  void update(float fac) {
    if (acc.mag() > 0 || vel.mag() > 0) {
      vel.add(PVector.mult(acc, fac));
      pos.add(PVector.mult(vel, fac));
      acc.mult(0);
    } else if ((int)pos.y + 1 < height) {

      if (grid[(int)pos.x][(int)pos.y + 1] == 0) {
        pos.y += 2;
      }
    }
  }

  void render() {
    fill(255);
    noStroke();
    ellipse(pos.x, pos.y, 50, 50);

    //set((int)pos.x, (int)pos.y, color(0));
    //for(int x = (int)pos.x - 40; x < (int)pos.x + 40; x++){
    //  for(int y = (int)pos.y - 50; y < 0; y++){
    //    set(x, y, color(255));
    //  }
    //}
  }
}
