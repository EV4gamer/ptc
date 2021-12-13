

void display() {
  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      int type = grid[x][y];
      int colour;
      switch(type) {
      case 0:
        colour = qrgb(20, 20, 20);
        break;
      case 1:
      case 2:
      case 3:
      case 4:
        colour = qrgb(0, 200 - (type - 1) * 30, 0);
        break;
      case 100:
        colour = qrgb(50, 50, 50);
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

int qrgb(int r, int g, int b) {
  return -(1 << 24) + (r << 16) + (g << 8) + b;
}

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

void initiateButtons() {
  for (int x = 0; x < width; x++) {
    for (int y = height - buttonHeight; y < height; y++) {
      grid[x][y] = 100;
    }
  }
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

void sphere(int cx, int cy, int r, int col) {
  for (int x = -r; x < r; x++) {
    for (int y = -r; y < r; y++) {
      if (x * x + y * y < r * r && cx + x < width && cx + x >= 0 && cy + y < height && cy + y >= 0 && grid[cx + x][cy + y] != 100) {
        grid[cx + x][cy + y] = col;
      }
    }
  }
}

int limit(int x, int a, int b) {
  if (x < a) {
    return a;
  } else if (x > b) {
    return b;
  } else {
    return x;
  }
}
