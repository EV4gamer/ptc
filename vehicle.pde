int pixelsPerMove = 2;
int pixelvoid = 0;

class vehicle {
  boolean active;
  PVector pos;
  PVector vel;
  PVector acc;
  float mass;

  int movesLeft;
  int healthLeft;
  int movesToTarget;

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
    movesToTarget = 0;
    active = false;
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
      if (grid[(int)pos.x][(int)pos.y + 1] == 0) { //if pixel below is void, move towards it
        pos.y += 2;
      }
    }
    if (movesToTarget != 0) {
      if ((int)pos.y + 1 < height && (int)pos.y > 0) {        
        if (grid[(int)pos.x][(int)pos.y - 1] == 0) { //if pixel above is void, free to move
          pos.x += pixelsPerMove * movesToTarget / abs(movesToTarget);          
          pos.x = limit((int)pos.x, 0, width);
          if (grid[(int)pos.x][(int)pos.y] != 0) { //if pixel moved to is inside the ground
            while (grid[(int)pos.x][(int)pos.y] != 0) {
              pos.y -= 1;
            }
          }
        } else {  //if submerged while trying to move
          pos.y -= height / 50 * pixelsPerMove;
          movesToTarget = 0;
        }
      }
      if (movesToTarget != 0) {
        movesToTarget -= pixelsPerMove * movesToTarget / abs(movesToTarget);
      }

      if (grid[(int)pos.x][(int)pos.y + 1] == 0) { //if pixel below is void again
        while (grid[(int)pos.x][(int)pos.y + 1] == 0) {
          pos.y += 1;
        }
      }
    }
  }

  void moveTo(int deltax) {
    if (movesLeft > 0 && deltax != 0) {
      movesToTarget += deltax;
    }
  }

  void render() {
    fill(255);
    noStroke();
    //ellipse(pos.x, pos.y, 50, 50);

    set((int)pos.x, (int)pos.y, color(0));
    for (int x = - 40; x < 40; x++) {
      for (int y = - 50; y < 0; y++) {
        set((int)pos.x + x, (int)pos.y + y, col);
      }
    }
  }
}
