
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
  size(1000, 600);
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
  buttons.add(new button(3 * width / 4, 7 * height / 8, 50, 50, color(20, 20, 20), "+", 50));
  buttons.add(new button(3 * width / 4 + 100, 7 * height / 8, 50, 50, color(20, 20, 20), "-", 50));
  
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
  
  //update ground
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

  //set next player in the list to be the active one if currentindexed isnt active
  if (vehicles.get(currentPlayerIndex).active != true) {
    for (int i = 0; i < vehicles.size(); i++) {
      if (i == currentPlayerIndex) {
        vehicles.get(i).active = true;
      } else {
        vehicles.get(i).active = false;
      }
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
    if (mouseX > b.x - b.w / 2 && mouseX < b.x + b.w / 2 && mouseY > b.y - b.h / 2 && mouseY < b.y + b.h / 2) { //if mouse in button hitbox
      if (b.pressed == true) {
        b.longPress = true;
      } else {
        b.pressed = true;
      }
    }
  }

  //for (int i = 0; i < buttons.size(); i++) {
  //  button b = buttons.get(i);
  //  if (b.pressed == true) {
  //    currentPlayerIndex = (currentPlayerIndex + 1) % vehicles.size(); //next player's turn
  //  }
  //}
}

void mouseReleased() {
  for (int i = 0; i < buttons.size(); i++) {
    if(buttons.get(i).pressed == true){
      
      //do the action the button is related to
      switch(i){
        case 0:
        println("test b1");
        //currentPlayerIndex = (currentPlayerIndex + 1) % vehicles.size(); //next player's turn
          break;
        case 1:
          println("test b2");
          vehicles.get(currentPlayerIndex).angle += TWO_PI / 36;
          break;
        case 2:
        println("test b3");
          vehicles.get(currentPlayerIndex).angle -= TWO_PI / 36;
          break;
      }
    }
  }
  
  //reset all buttons to false;
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
