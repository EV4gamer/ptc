
class vehicle {
  boolean active;
  PVector pos;
  PVector vel;
  PVector acc;
  float mass;
  
  int boreLength = 80;
  int w = 80;
  int h = 15;
  int movesLeft = 5;
  int score = 0;
  int movesToTarget = 0;

  float angle = 0;
  int power = 50;
  color col;
  
  String selectedInflictorName = "default";
  ArrayList<String> inflictorsLeft = new ArrayList<String>();
  
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
    int wheelw = 20;  
    set((int)pos.x, (int)pos.y, color(0)); //debug pos marker
    noStroke();
    fill(col);
    rectMode(CENTER);
    rect(pos.x, pos.y - h/2, w, h, w/8, w/8, w/12, w/12);
        
    stroke(255);
    strokeWeight(5);
    line(pos.x, pos.y - h - 5, pos.x + boreLength * cos(angle), pos.y - h - 5 - boreLength * sin(angle));
        
    fill(col);
    noStroke();
    ellipse(pos.x, pos.y - h, 50, 30);
    
    fill(col + qrgb(30, 30, 30));
    noStroke();
    for(int i = 0; i < w / wheelw - 1; i++){
      ellipse(pos.x - 3 * w / 8 + (i + 1.0/2.0) * wheelw, pos.y, wheelw, wheelw);
    }
    ellipse(pos.x - w / 2 + wheelw/4, pos.y, wheelw/2, wheelw/2);
    ellipse(pos.x + w / 2 - wheelw/4, pos.y, wheelw/2, wheelw/2);
  }
}
