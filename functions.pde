
//display the ground grid
void display() {
  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      int type = grid[x][y];
      int colour;
      switch(type) {
      case 0:
        colour = qrgb(20, 20, 20); //void
        break;
      case 1:
      case 2:
      case 3:
      case 4:
        colour = qrgb(0, 200 - (type - 1) * 30, 0); //the greens
        break;
      case 10:
        colour = qrgb(101, 67, 33); //dirt brown
        break;
      case 100:
        colour = qrgb(50, 50, 50); //button area
        break;
      default:
        colour = qrgb(255, 255, 255);
        break;
      }
      pixels[x + y * width] = colour;
    }
  }
  updatePixels();
}

//fast color()
int qrgb(int r, int g, int b) {
  return -(1 << 24) + (r << 16) + (g << 8) + b;
}

//2D random terrain generation
void initiateGround(int smoothness, int variance) {
  int groundClearance = 100;
  int topClearance = buttonHeight;
  grid = new int[width][height];

  int level = height / 2 + (int)random(random(-variance, 0), random(0, variance));
  int[] H = new int[width];   //initial line
  int[] HF = new int[width];  //smoothed line

  //save heights for each x value
  for (int x = 0; x < width; x++) {
    level = limit(level, groundClearance, height - topClearance);
    H[x] = level;

    level += (int)random(random(-variance, 0), random(0, variance)); //crude gaussian
  }

  //average out the values based on neighbouring values
  for (int x = 0; x < width; x++) {
    int sum = 0;
    for (int i = 0; i < smoothness; i++) {
      int val = H[(x + i) % width];
      sum += val;
    }   
    HF[x] = sum / smoothness;
  }

  //set grid based on values in HF
  for (int x = 0; x < width; x++) {
    for (int y = HF[x]; y < height; y++) {            
      if (y - HF[x] < 25) {
        grid[x][y] = 1;
      } else if (y - HF[x] < 75) {
        grid[x][y] = 2;
      } else if (y - HF[x] < 125) {
        grid[x][y] = 3;
      } else {
        grid[x][y] = 4;
      }
    }
  }
}

//initiate button layer
void initiateButtons() {
  for (int x = 0; x < width; x++) {
    for (int y = height - buttonHeight; y < height; y++) {
      grid[x][y] = 100;
    }
  }
}

//apply physics to ground grid
void iterativeDown() {
  continuePhysics = false;
  for (int x = 0; x < width; x++) {
    for (int y = height - 1; y > 0; y--) {
      if (grid[x][y - 1] != 0 && grid[x][y] == 0) { //if there is a free space to move to
        grid[x][y] = grid[x][y - 1]; //have the particle switch places with the empty place
        grid[x][y - 1] = 0;
        continuePhysics = true;
      }
    }
  }
}

//sphere placing function
void sphere(int cx, int cy, int r, int filler) {
  for (int x = -r; x < r; x++) {
    for (int y = -r; y < r; y++) {
      if (x * x + y * y < r * r && cx + x < width && cx + x >= 0 && cy + y < height && cy + y >= 0 && grid[cx + x][cy + y] != 100) {
        grid[cx + x][cy + y] = filler;
      }
    }
  }
}

//limit x between a and b
int limit(int x, int a, int b) {
  if (x < a) {
    return a;
  } else if (x > b) {
    return b;
  } else {
    return x;
  }
}

void addInflictor(String type) {//, float angle) {
  float a = vehicles.get(currentPlayerIndex).angle;
  float x = vehicles.get(currentPlayerIndex).pos.x + vehicles.get(currentPlayerIndex).boreLength * cos(a);
  float y = vehicles.get(currentPlayerIndex).pos.y - 5 - vehicles.get(currentPlayerIndex).h - vehicles.get(currentPlayerIndex).boreLength * sin(a); 
  float p = vehicles.get(currentPlayerIndex).power;
  float deg = TWO_PI / 360.0;

  //inflictor(P(x, y), P(vx, vy), mass, radius, aoeRadius, color, trailLength, filltype, damage, aoeDamage)
  switch(type) {
  case "single shot":
    shotsPerLaunch = 1;
    inflictors.add(new inflictor(new PVector(x, y), new PVector(cos(vehicles.get(currentPlayerIndex).angle), sin(-vehicles.get(currentPlayerIndex).angle)).mult(p).div(10), 10, 10, 10, color(255), 100, 0, 10, 10));
    break;
  case "big shot":
    shotsPerLaunch = 1;
    inflictors.add(new inflictor(new PVector(x, y), new PVector(cos(vehicles.get(currentPlayerIndex).angle), sin(-vehicles.get(currentPlayerIndex).angle)).mult(p).div(10), 1, 10, 50, color(255), 100, 0, 20, 10));
    break;
  case "3 shot":
    shotsPerLaunch = 3;
    for (int i = 0; i < 3; i++) {
      inflictors.add(new inflictor(new PVector(x, y), new PVector(cos(vehicles.get(currentPlayerIndex).angle + (i-1) * 5 * deg), sin(-(vehicles.get(currentPlayerIndex).angle + (i-1) * 5 * deg))).mult(p).div(10), 9, 9, 9, color(255), 100, 0, 10, 10));
    }
    break;
  case "5 shot":
    shotsPerLaunch = 5;
    for (int i = 0; i < 5; i++) {
      inflictors.add(new inflictor(new PVector(x, y), new PVector(cos(vehicles.get(currentPlayerIndex).angle + (i-2) * 4 * deg), sin(-(vehicles.get(currentPlayerIndex).angle + (i-2) * 4 * deg))).mult(p).div(10), 9, 9, 9, color(255), 100, 0, 10, 10));
    }
    break;
  case "sniper":
    shotsPerLaunch = 1;
    inflictors.add(new inflictor(new PVector(x, y), new PVector(cos(vehicles.get(currentPlayerIndex).angle), sin(-vehicles.get(currentPlayerIndex).angle)).mult(p).div(10), 10, 4, 2, color(200), 100, 0, 100, 0));
    break;
  case "dirtball":
    shotsPerLaunch = 1;
    inflictors.add(new inflictor(new PVector(x, y), new PVector(cos(vehicles.get(currentPlayerIndex).angle), sin(-vehicles.get(currentPlayerIndex).angle)).mult(p).div(10), 10, 10, 100, color(101, 67, 33), 100, 10, 10, 0));
    break;
  case "tommy gun":
    shotsPerLaunch = 25;
    for (int i = 0; i < 25; i++) {
      float chaos = TWO_PI * random(-10, 10) / 360.0;
      inflictors.add(new inflictor(new PVector(x, y), new PVector(cos(vehicles.get(currentPlayerIndex).angle + chaos), sin(-(vehicles.get(currentPlayerIndex).angle + chaos))).mult(p).div(10).mult(random(0.9, 1.1)), 10, 4, 2, color(240, 240, 0), 10, 0, 5, 0));
    }
    break;
  default:
    println("help");
    break;
  }
}


boolean isCollision(int x, int y, PVector p, int radius, int w, int h) {
  if ((x + w - p.x) * (x + w - p.x) + (y + h - p.y) * (y + h - p.y) < radius * radius || (x - w - p.x) * (x - w - p.x) + (y + h - p.y) * (y + h - p.y) < radius * radius || (x - w - p.x) * (x - w - p.x) + (y - h - p.y) * (y - h - p.y) < radius * radius || (x + w - p.x) * (x + w - p.x) + (y - h - p.y) * (y - h - p.y) < radius * radius) {
    return true;
  } else {
    return false;
  }
}

//change this to a preset arraylist, to save on code
int getDamage(boolean aoe, String type) {
  int damage = 0;
  switch(type) {
  case "single shot":
    if (aoe) {
      damage = 10;
    } else {
      damage = 10;
    }
    break;
  case "big shot":
    if (aoe) {
      damage = 10;
    } else {
      damage = 20;
    }
    break;
  case "3 shot":
    if (aoe) {
      damage = 10;
    } else {
      damage = 10;
    }
    break;
  case "5 shot":
    if (aoe) {
      damage = 10;
    } else {
      damage = 10;
    }
    break;
  case "sniper":
    if (aoe) {
      damage = 0;
    } else {
      damage = 100;
    }
    break;
  case "dirtball":
    if (aoe) {
      damage = 0;
    } else {
      damage = 10;
    }
    break;
  case "tommy gun":
    if (aoe) {
      damage = 0;
    } else {
      damage = 5;
    }
    break;
  }
  return damage;
}

//intro screen vehicle draw function
void drawVehicle(int x, int y, float angle, color col, float rot, float scale) {
  int wheelw = (int)(20 * scale);
  int boreLength = (int)(80 * scale);
  int w = (int)(80 * scale);
  int h = (int)(15 * scale);
  translate(x, y);
  rotate(rot);
  noStroke();
  fill(col);
  rectMode(CENTER);
  rect(0, - h/2, w, h);        
  stroke(255);
  strokeWeight(5 * scale);
  line(0, -h - 5, boreLength * cos(angle), -h - 5 - boreLength * sin(angle));        
  fill(col);
  noStroke();
  ellipse(0, -h, 50 * scale, 30 * scale);    
  fill(col + qrgb(30, 30, 30));
  noStroke();
  for (int i = 0; i < w / wheelw - 1; i++) {
    ellipse(-3 * w / 8 + (i + 1.0/2.0) * wheelw, 0, wheelw, wheelw);
  }
  ellipse(-w / 2 + wheelw/4, 0, wheelw/2, wheelw/2);
  ellipse(w / 2 - wheelw/4, 0, wheelw/2, wheelw/2);
  rotate(-rot);
  translate(-x, -y);
}

void initializeGameButtons() {
  buttons.add(new button(width / 2, height - buttonHeight / 2, 250, 125, qrgb(255, 140, 20), qrgb(20, 20, 20), "Fire", 50, 20));
  buttons.add(new button(6 * width / 8, height - buttonHeight / 2 + 30, 50, 50, qrgb(255, 255, 255), qrgb(20, 20, 20), "+", 50, 13));
  buttons.add(new button(6 * width / 8 + 60, height - buttonHeight / 2 + 30, 50, 50, qrgb(255, 255, 255), qrgb(20, 20, 20), "-", 50, 13));

  buttons.add(new button(7 * width / 8, height - buttonHeight / 2 + 30, 50, 50, qrgb(255, 255, 255), qrgb(20, 20, 20), "+", 50, 13));
  buttons.add(new button(7 * width / 8 + 60, height - buttonHeight / 2 + 30, 50, 50, qrgb(255, 255, 255), qrgb(20, 20, 20), "-", 50, 13));

  buttons.add(new button(width / 4 + 50, height - buttonHeight / 2, 250, 60, qrgb(255, 255, 255), qrgb(20, 20, 20), "Select", 45, 12));
  buttons.get(5).isSwitch = true;

  signs.add(new sign(100, 40, 200, 50, qrgb(20, 20, 20), "Player 1", 50, 15, vehicles.get(0).col));
  signs.add(new sign(width - 100, 40, 200, 50, qrgb(20, 20, 20), "Player 2", 50, 15, vehicles.get(1).col));

  signs.add(new sign(50, 100, 200, 50, qrgb(20, 20, 20), "0", 50, 15, vehicles.get(0).col));
  signs.add(new sign(width - 50, 100, 200, 50, qrgb(20, 20, 20), "0", 50, 15, vehicles.get(1).col));

  signs.add(new sign(width / 8, height - buttonHeight / 2, 50, 50, qrgb(20, 20, 20), "Moves\n5", 30, -37, qrgb(255, 255, 255)));
  signs.add(new sign(6 * width / 8 + 30, height - buttonHeight / 2 - 40, 0, 0, qrgb(50, 50, 50), "Angle", 30, 0, qrgb(255, 255, 255)));
  signs.add(new sign(7 * width / 8 + 30, height - buttonHeight / 2 - 40, 0, 0, qrgb(50, 50, 50), "Power", 30, 0, qrgb(255, 255, 255)));
  signs.add(new sign(6 * width / 8 + 30, height - buttonHeight / 2 - 17, 114, 30, qrgb(20, 20, 20), "0", 30, 11, qrgb(255, 255, 255)));
  signs.add(new sign(7 * width / 8 + 30, height - buttonHeight / 2 - 17, 114, 30, qrgb(20, 20, 20), "50", 30, 11, qrgb(255, 255, 255)));

  signs.add(new sign(250, 35, 20, 20, color(255), " ", 1, 0, qrgb(0, 0, 0))); //active player marker
}

void initializeIntroButtons() {
  buttons.add(new button(width / 2, height/2, 250, 125, qrgb(255, 255, 255), qrgb(20, 20, 20), "Play", 50, 20));
  buttons.add(new button(width / 2, height/2 + 140, 250, 125, qrgb(255, 255, 255), qrgb(20, 20, 20), "Settings", 50, 20));
  buttons.add(new button(width / 2, height/2 + 280, 250, 125, qrgb(255, 255, 255), qrgb(20, 20, 20), "Quit", 50, 20));
  for (int i = 0; i < buttons.size(); i++) {
    buttons.get(i).stroke = false;
  }
}

void initializeInflictorSelectionButtons() {
}

void initializeEndOfGameButtons() {
  buttons.add(new button(width / 2 - 150, height/2 + 100, 250, 125, qrgb(255, 255, 255), qrgb(20, 20, 20), "Restart", 50, 20));
  buttons.add(new button(width / 2 + 150, height/2 + 100, 250, 125, qrgb(255, 255, 255), qrgb(20, 20, 20), "Quit", 50, 20));
}


void resetButtons() {
  buttons = new ArrayList<button>();
  signs = new ArrayList<sign>();
}
