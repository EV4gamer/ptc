
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
void sphere(int cx, int cy, int r, int col) {
  for (int x = -r; x < r; x++) {
    for (int y = -r; y < r; y++) {
      if (x * x + y * y < r * r && cx + x < width && cx + x >= 0 && cy + y < height && cy + y >= 0 && grid[cx + x][cy + y] != 100) {
        grid[cx + x][cy + y] = col;
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

void addInflictor(String type){//, float angle) {
  float a = vehicles.get(currentPlayerIndex).angle;
  float x = vehicles.get(currentPlayerIndex).pos.x + 100 * cos(a);
  float y = vehicles.get(currentPlayerIndex).pos.y - 55 - 100 * sin(a); 
  float p = vehicles.get(currentPlayerIndex).power;
  float deg = TWO_PI / 360.0;
  
  //inflictor(P(x, y), P(vx, vy), mass, radius, aoeRadius, color, trailLength, filltype)
  switch(type) {
  case "single shot":
    //inflictors.add(new inflictor(pos, vel, 10, 10, 10, color(255), 100, 0));
    break;
  case "big shot":
    //inflictors.add(new inflictor(pos, vel, 25, 10, 50, color(255), 100, 0));
    break;
  case "3 shot":
    for(int i = 0; i < 3; i++){
      inflictors.add(new inflictor(new PVector(x, y), new PVector(cos(vehicles.get(currentPlayerIndex).angle + (i-1) * 5 * deg), sin(-(vehicles.get(currentPlayerIndex).angle + (i-1) * 5 * deg))).mult(p).div(10), 9, 9, 9, color(255), 100, 0));
    }
    break;
  case "5 shot":
    for(int i = 0; i < 5; i++){
      inflictors.add(new inflictor(new PVector(x, y), new PVector(cos(vehicles.get(currentPlayerIndex).angle + (i-2) * 4 * deg), sin(-(vehicles.get(currentPlayerIndex).angle + (i-2) * 4 * deg))).mult(p).div(10), 9, 9, 9, color(255), 100, 0));
    }
    break;
  case "sniper":
    //inflictors.add(new inflictor(pos, vel, 10, 4, 2, color(200), 100, 0));
    break;
  case "dirtball":
    //inflictors.add(new inflictor(pos, vel, 10, 10, 100, color(255), 100, 10));
    break;
  case "tommy gun":
    for (int i = 0; i < 25; i++) {
      float chaos = TWO_PI * random(-10, 10) / 360.0;
      inflictors.add(new inflictor(new PVector(x, y), new PVector(cos(vehicles.get(currentPlayerIndex).angle + chaos), sin(-(vehicles.get(currentPlayerIndex).angle + chaos))).mult(p).div(10).mult(random(0.9, 1.1)), 10, 4, 2, color(240, 240, 0), 10, 0));
    }
    break;
  }
}
