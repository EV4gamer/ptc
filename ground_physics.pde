
int[][] grid;
ArrayList<inflictor> inflictors;
ArrayList<vehicle> vehicles;
ArrayList<button> buttons;

boolean continuePhysics = true;
vehicle player_one;
vehicle player_two;

int currentPlayerIndex = 0;
int buttonHeight;

void setup() {
  size(1600, 900);
  buttonHeight = height / 4;  
  initiateGround(100, 75);  
  initiateButtons(); 

  inflictors = new ArrayList<inflictor>();
  vehicles = new ArrayList<vehicle>();
  buttons = new ArrayList<button>();

  vehicle player_one = new vehicle(new PVector(width / 5, 0), 10, color(0, 0, 200));
  vehicle player_two = new vehicle(new PVector(4 * width / 5, 0), 10, color(200, 0, 0));
  vehicles.add(player_one);
  vehicles.add(player_two);
  player_one.active = true;  

  buttons.add(new button(width / 2, (int)((7.0/8.0)* height), 250, 125, color(20, 20, 20), "TEST", 50));
  
  for (int i = 0; i < vehicles.size(); i++) { //check player index
    if (vehicles.get(i).active == true) {
      currentPlayerIndex = i;
      break;
    }
  }  
}

void draw() {
  display();

  //update shells
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

  //update players
  for (int i = 0; i < vehicles.size(); i++) {
    vehicles.get(i).update(1);
    vehicles.get(i).render();
  }

  //update buttons
  for (int i = 0; i < buttons.size(); i++) {
    buttons.get(i).render();
  }
  
  for (int i = 0; i < vehicles.size(); i++) {
    if (i == currentPlayerIndex) {
      vehicles.get(i).active = true;
    } else {
      vehicles.get(i).active = false;
    }
  }
  
  
}

void mousePressed() {
  //int r = 100;
  //int c = (mouseButton == LEFT ? 0 : 1);
  //sphere(mouseX, mouseY, r, c);
  //continuePhysics = true;

  for (int i = 0; i < buttons.size(); i++) {
    button b = buttons.get(i);
    if (mouseX > b.x - b.w && mouseX < b.x + b.w && mouseY > b.y - b.h && mouseY < b.y + b.h) { //if mouse in button hitbox
      if (b.pressed == true) {
        b.longPress = true;
      } else {
        b.pressed = true;
      }
    }
  }
  
  for (int i = 0; i < buttons.size(); i++) {
    button b = buttons.get(i);
    if(b.pressed == true){
      currentPlayerIndex = (currentPlayerIndex + 1) % vehicles.size(); //next player's turn      
    }
  }
}

void mouseReleased() {
  for (int i = 0; i < buttons.size(); i++) {
    buttons.get(i).pressed = false;
    buttons.get(i).longPress = false;
  }
}

void keyPressed() {

  switch(key) {
  case 'w':
    break;
  case 'a':
    if (vehicles.get(currentPlayerIndex).movesLeft > 0) {
      vehicles.get(currentPlayerIndex).movesToTarget -= width / 20;
      vehicles.get(currentPlayerIndex).movesLeft--;
    }
    break;
  case 's':
    break;
  case 'd':
    if (vehicles.get(currentPlayerIndex).movesLeft > 0) {
      vehicles.get(currentPlayerIndex).movesToTarget += width / 20;
      vehicles.get(currentPlayerIndex).movesLeft--;
    }
    break;
  }
}
