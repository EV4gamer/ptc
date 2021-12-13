
int[][] grid;
inflictor object;
ArrayList<inflictor> inflictors;
boolean continuePhysics = true;
vehicle player_one;
vehicle player_two;

void setup() {
  size(600, 600);
  initiateGround(100, 75);
  inflictors = new ArrayList<inflictor>();
  player_one = new vehicle(new PVector(width / 5, 0), 10, color(0, 0, 200));
  player_two = new vehicle(new PVector(4 * width / 5, 0), 10, color(200, 0, 0));

  //object = new inflictor(new PVector(width/2, height/2), new PVector(10, 1), 1, 50, 0, color(0, 0, 255), 50);;
}



void draw() {
  display();
  for (int i = 0; i < inflictors.size(); i++) {
    inflictors.get(i).applyForce(new PVector(0, 0.1));
    inflictors.get(i).update(1);
    inflictors.get(i).render();
  }
  if (continuePhysics) {
    for (int s = 0; s < 2; s++) {
      iterativeDown();
    }
  }
  player_one.update(1);
  player_two.update(1);    
  player_one.render();
  player_two.render();
  
  println(player_one.pos);
}

void display() {
  int background = -(1 << 24) + 20 * 256 * 256 + 20 * 256 + 20;
  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      pixels[x + y * width] = (grid[x][y] == 0 ?  background : -(1 << 24) + ((200 - (grid[x][y] - 1) * 30) << 8)); //green or black
    }
  }
  updatePixels();
}


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

void mousePressed() {
  int r = 100;
  int c = (mouseButton == LEFT ? 0 : 1);
  sphere(mouseX, mouseY, r, c);
  continuePhysics = true;
}

void sphere(int cx, int cy, int r, int col) {
  for (int x = -r; x < r; x++) {
    for (int y = -r; y < r; y++) {
      if (x * x + y * y < r * r && cx + x < width && cx + x >= 0 && cy + y < height && cy + y >= 0) {
        grid[cx + x][cy + y] = col;
      }
    }
  }
}

void initiateGround(int smoothness, int variance) {
  int groundClearance = 100;
  int topClearance = 100;
  grid = new int[width][height];

  int level = height / 2 + (int)random(random(-variance, 0), random(0, variance));
  int[] H = new int[width];   //initial line
  int[] HF = new int[width];  //smoothed line

  //save heights for each x value
  for (int x = 0; x < width; x++) {
    if (level > height - topClearance) {
      level = height - topClearance;
    }
    if (level < groundClearance) {
      level = groundClearance;
    }
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
