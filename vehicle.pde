
class vehicle {
  boolean active;
  PVector pos;
  PVector vel;
  PVector acc;
  float mass;

  int movesLeft = 5;
  int score = 0;
  int movesToTarget = 0;

  float angle = 0;
  int power = 50;
  color col;
  
  String selectedInflictor = "default";
  
  vehicle(PVector p, float m, color c) {
    pos = p;
    //if spawned above ground, move down
    for (int y = 0; y < height; y++) {
      if (grid[(int)pos.x][(int)pos.y + 1] == 0) {
        pos.y += 1;
      }
    }

    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    mass = m;
    col = c;
    active = false;
  }

  void applyForce(PVector f) {
    acc.add(f.div(mass));
  }

  void update(float fac) {    
    vel.add(PVector.mult(acc, fac));
    pos.add(PVector.mult(vel, fac));
    if (acc.mag() > 0 || vel.mag() > 0) {      
      if ((int)pos.y < height -1 && (int)pos.y > 0) {
        if((int)pos.x < 0 || (int)pos.x > width - 1){ //bounce in width
          vel.x = - vel.x;
          pos.x = limit((int)pos.x, 0, width - 1);
        }
        
        if (grid[(int)pos.x][(int)pos.y + 1] != 0) { //bounce in height
          vel.y = -abs(vel.y);
        }
      } else {
        pos.y = limit((int)pos.y, 0, height - 1);
        vel.y = -vel.y;
      }       
      acc.mult(0);
    } else if ((int)pos.y + 1 < height) {
      if (grid[(int)pos.x][(int)pos.y + 1] == 0) { //if pixel below is void, move towards it
        pos.y += 2;
      }
    }
    if (movesToTarget != 0) {
      if ((int)pos.y + 1 < height && (int)pos.y > 0) {        
        if (grid[(int)pos.x][(int)pos.y - 1] == 0) { //if pixel above is void, free to move
          pos.x += movesToTarget / abs(movesToTarget);          
          pos.x = limit((int)pos.x, 0, width);
          if (grid[(int)pos.x][(int)pos.y] != 0) { //if pixel moved to is inside the ground
            while (grid[(int)pos.x][(int)pos.y] != 0) {
              pos.y -= 1;
            }
          }
        } else {  //if submerged while trying to move
          pos.y -= height / 25;
          movesToTarget = 0;
        }
      }
      if (movesToTarget != 0) {
        movesToTarget -= movesToTarget / abs(movesToTarget);
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
    set((int)pos.x, (int)pos.y, color(0));
    for (int x = - 40; x < 40; x++) {
      for (int y = - 50; y < 0; y++) {
        set((int)pos.x + x, (int)pos.y + y, col);
      }
    }

    fill(col);
    noStroke();
    ellipse(pos.x, pos.y - 50, 50, 50);

    stroke(255);
    strokeWeight(5);
    line(pos.x, pos.y - 55, pos.x + 100 * cos(angle), pos.y - 55 - 100 * sin(angle));
  }
}
