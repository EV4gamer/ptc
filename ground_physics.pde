
int[][] grid;
ArrayList<inflictor> inflictors;
ArrayList<vehicle> vehicles;
ArrayList<button> buttons;
ArrayList<sign> signs;
ArrayList<String> leftForSelection;

StringList nameList;

boolean continuePhysics;
String currentScene;
vehicle player_one;
vehicle player_two;

int currentPlayerIndex;
int buttonHeight;
int physPerFrame;
int shotsPerLaunch;
int currentShots;

final int darkgrey = qrgb(20);
final int grey = qrgb(50);
final int white = qrgb(255);
final int black = qrgb(0);

void setup() {
  continuePhysics = true;
  currentScene = "Intro Scene";

  currentPlayerIndex = 0;
  buttonHeight = height / 5;
  physPerFrame = 5;
  shotsPerLaunch = 1;
  currentShots = 0;

  size(1920, 1080);
  //fullScreen();
  
  initiateGround(100, 75);  
  initiateButtons(); 
  nameList = new StringList();
  nameList.append("single shot");
  nameList.append("big shot");
  nameList.append("3 shot");
  nameList.append("5 shot");
  nameList.append("sniper");
  nameList.append("dirtball");
  nameList.append("tommy gun");

  inflictors = new ArrayList<inflictor>();
  vehicles = new ArrayList<vehicle>();
  buttons = new ArrayList<button>();
  signs = new ArrayList<sign>();
  leftForSelection = new ArrayList<String>();

  player_one = new vehicle(new PVector(width / 5, 0), 10, color(0, 0, 200));
  player_two = new vehicle(new PVector(4 * width / 5, 0), 10, color(200, 0, 0));
  vehicles.add(player_one);
  vehicles.add(player_two);
  player_one.active = true;  

  for (int i = 0; i < 8; i++) {
    leftForSelection.add(nameList.get((int)random(0, nameList.size())));
  }

  initializeIntroButtons(); //load scene 1 displayables
  //initializeGameButtons();

  for (int i = 0; i < vehicles.size(); i++) { //check player index
    if (vehicles.get(i).active == true) {
      currentPlayerIndex = i;
      break;
    }
  }
}

void draw() {
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

  if (currentScene == "Game") {
    display();

    //update shells
    for (int j = 0; j < physPerFrame; j++) {
      for (int i = 0; i < inflictors.size(); i++) {
        inflictor inf = inflictors.get(i);
        inf.applyForce(new PVector(0, 1));
        inf.update(1.0 / physPerFrame);
        inf.render();
      }
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

    signs.get(4).text = "Moves\n"+str(vehicles.get(currentPlayerIndex).movesLeft);    
    if (buttons.get(5).pressed == true) {
      rectMode(CENTER);
      fill(grey);
      stroke(black);
      rect(buttons.get(5).x, buttons.get(5).y - 50 - 2 * buttons.get(5).h, buttons.get(5).w, 5 * buttons.get(5).h);
      if (vehicles.get(currentPlayerIndex).inflictorsLeft.size() > 0) {
        for (int i = 0; i < vehicles.get(currentPlayerIndex).inflictorsLeft.size(); i++) {
          textSize(30);
          textAlign(CENTER);
          fill(white);
          if (i < 7) {
            text(vehicles.get(currentPlayerIndex).inflictorsLeft.get(i), buttons.get(5).x, buttons.get(5).y - 50 - 4 * buttons.get(5).h + i * 40);
          }
        }
      }
    }

    //purge inflictors when flagged or outside of screen
    if (inflictors.size() > 0) {
      for (int i = inflictors.size() - 1; i >= 0; i--) {
        inflictor infl = inflictors.get(i);
        if ((int)infl.pos.x < 0 || (int)infl.pos.x > width - 1 || (int)infl.pos.y > height - 1) {
          infl.purge = true;
        }
        if ((int)infl.pos.y < 0) {
          infl.offscreen = true;
        } else {
          infl.offscreen = false;
        }
      }
      for (int i = inflictors.size() - 1; i >= 0; i--) {
        if (inflictors.get(i).purge == true) {
          inflictors.remove(i);
          currentShots++;
        }
      }
    }

    //check inflictor collision
    if (inflictors.size() > 0) {
      for (int i = inflictors.size() - 1; i >= 0; i--) {
        inflictor infl = inflictors.get(i);
        if (infl.offscreen == false) {
          //ground collision test
          if (grid[(int)infl.pos.x][(int)infl.pos.y] != 0) {
            infl.purge = true;
            sphere((int)infl.pos.x, (int)infl.pos.y, (int)infl.aoe, infl.fillType);
            continuePhysics = true;
            if (isCollision((int)infl.pos.x, (int)infl.pos.y, vehicles.get((currentPlayerIndex + 1) % vehicles.size()).pos, (int)infl.aoe, vehicles.get((currentPlayerIndex + 1) % vehicles.size()).w, vehicles.get((currentPlayerIndex + 1) % vehicles.size()).h)) { //if inflictor aoe hit enemy player
              vehicles.get(currentPlayerIndex).score += getDamage(true, vehicles.get(currentPlayerIndex).selectedInflictorName); //add the score equal to aoe damage
            }
          }

          //vehicle collision test
          for (int j = 0; j < vehicles.size(); j ++) {          
            if (j != currentPlayerIndex) {
              vehicle v = vehicles.get(j);
              if ((int)infl.pos.x > (int)v.pos.x - v.w/2 - infl.radius && (int)infl.pos.x < (int)v.pos.x + v.w/2 + infl.radius) { //within width of the player
                if ((int)infl.pos.y < (int)v.pos.y + infl.radius && (int)infl.pos.y > (int)v.pos.y - v.h - infl.radius) { //within height of the player
                  infl.purge = true;
                  sphere((int)infl.pos.x, (int)infl.pos.y, (int)infl.aoe, infl.fillType);
                  continuePhysics = true;
                  vehicles.get(currentPlayerIndex).score += getDamage(false, vehicles.get(currentPlayerIndex).selectedInflictorName); //add the score equal to non-aoe damage
                  signs.get(currentPlayerIndex + 2).text = str(vehicles.get(currentPlayerIndex).score); //update score sign
                  //v.applyForce(new PVector(infl.vel.x, -abs(infl.vel.y)).mult(10)); //fix the impact force, doesnt work
                }
              }
            }
          }
        }
      }
    }  
    //if all inflictors have been purged, next player's turn
    if (currentShots >= shotsPerLaunch) {
      currentPlayerIndex = (currentPlayerIndex + 1) % vehicles.size();
      currentShots = 0;
      signs.get(8).text = str(vehicles.get(currentPlayerIndex).power);                        //update power to sign
      signs.get(7).text = str((int)(vehicles.get(currentPlayerIndex).angle / TWO_PI * 360));  //update angle to sign
      signs.get(9).x = (currentPlayerIndex == 0 ? 250 : width - 250); //active player marker

      if (vehicles.get(currentPlayerIndex).inflictorsLeft.size() > 0) { //if inflictors left to shoot
        buttons.get(5).text = vehicles.get(currentPlayerIndex).inflictorsLeft.get(0);
        vehicles.get(currentPlayerIndex).selectedInflictorName = vehicles.get(currentPlayerIndex).inflictorsLeft.get(0);
      } else { // no inflictors, end of game
        vehicles.get(currentPlayerIndex).selectedInflictorName = " ";
        currentScene = "End of Game";
        initializeEndOfGameButtons();
      }
    }
  } else if (currentScene == "Intro Scene") {
    //intro screen
    background(20);
    textAlign(CENTER);
    textSize(100);
    fill(white);
    text("Pocket Tanks", width / 2, height / 4);
    textSize(7);    
    text("Don't sue me", width / 2, height / 4 + 30);
    textSize(40);
    text("By: EV4", width - 100, height - 50);
    
    drawVehicle(width / 8, height / 2, 0.05, qrgb(0, 200, 0), -PI/12, 1.5);
    drawVehicle(width / 4, height / 2, 0.05, qrgb(200, 0, 0), -PI/12, 2);
    drawVehicle(3 * width / 4, height / 2, PI - 0.05, qrgb(0, 0, 200), PI/12, 2);
    drawVehicle(7 * width / 8, height / 2, PI - 0.05, qrgb(200, 200, 0), PI/12, 1.5);
  } else if (currentScene == "InflictorSelection") {
    //inflictor selection screen
    background(20);    
    rectMode(CENTER);
    fill(grey);
    stroke(player_one.col);
    rect(width / 5, height / 2, width / 4 - 50, height / 2);
    stroke(player_two.col);
    rect(4 * width / 5, height / 2, width / 4 - 50, height / 2);
    stroke(200);
    rect(width / 2, height / 2, width / 4 - 50, height / 2);
    
    fill(vehicles.get(0).col);
    textSize(70);
    text("Player 1", width / 5, height / 2 - width / 4 + 150);
    
    fill(vehicles.get(1).col);
    text("Player 2", 4 * width / 5, height / 2 - width / 4 + 150);
    
    stroke(white);
    fill(white);
    rect((7 + 6 * currentPlayerIndex) * width / 20, height / 2, 50, 50); //selector indicator;

    fill(white);
    textSize(32);
    for (int i = 0; i < leftForSelection.size(); i++) {
      text(leftForSelection.get(i), width/2, height / 4 + 50 + i * 40);
    }
    for (int j = 0; j < vehicles.size(); j++) {     
      for (int i = 0; i < vehicles.get(j).inflictorsLeft.size(); i++) {
        text(vehicles.get(j).inflictorsLeft.get(i), width/5 + j * 3 * width / 5, height / 4 + 50 + i * 40);
      }
    }
    if (leftForSelection.size() == 0) {
      currentScene = "Game";
      resetButtons();
      initializeGameButtons();
      vehicles.get(currentPlayerIndex).selectedInflictorName = vehicles.get(currentPlayerIndex).inflictorsLeft.get(0);
      buttons.get(5).text = vehicles.get(currentPlayerIndex).inflictorsLeft.get(0);
    }
  } else if (currentScene == "End of Game") {
    background(20);

    display();

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

    stroke(black);
    fill(grey);
    rectMode(CENTER);
    rect(width/2, height/2, width/2, height/2);
    textSize(100);
    fill(white);
    textAlign(CENTER);
    text("End of the game", width/2, height/2);
  }  

  //update buttons
  for (int i = 0; i < buttons.size(); i++) {
    if (buttons.get(i).show == true) {
      buttons.get(i).render();
    }
  }

  //update signs
  for (int i = 0; i < signs.size(); i++) {
    signs.get(i).render();
  }
}

void mousePressed() {
  if (currentScene == "Game" || currentScene == "Intro Scene") {
    for (int i = 0; i < buttons.size(); i++) {
      button b = buttons.get(i);
      if (mouseX > b.x - b.w / 2 && mouseX < b.x + b.w / 2 && mouseY > b.y - b.h / 2 && mouseY < b.y + b.h / 2) { //if mouse in button hitbox
        if (b.isSwitch == true) {
          b.pressed = !b.pressed;
        } else {
          b.pressed = true;
        }
      }
    }
    //inflictor selection switch in game
    if (currentScene == "Game") {
      if (buttons.get(5).pressed == true) {
        int index = (int)((mouseY - buttons.get(5).y + 50 + 4 * buttons.get(5).h) / 40.0 + 1);
        if (mouseX > buttons.get(5).x - buttons.get(5).w && mouseX < buttons.get(5).x + buttons.get(5).w) {
          if (index < vehicles.get(currentPlayerIndex).inflictorsLeft.size() && index < 7 && index >= 0) {
            vehicles.get(currentPlayerIndex).selectedInflictorName = vehicles.get(currentPlayerIndex).inflictorsLeft.get(index);
            buttons.get(5).text = vehicles.get(currentPlayerIndex).selectedInflictorName;
          }
        }
      }
    }
  } else if (currentScene == "InflictorSelection") {
    if (mouseX > width / 2 - (width / 4 - 50)/2 && mouseX < width / 2 + (width / 4 - 50)/2 && mouseY > height/2 - height/4 && mouseY < height/2 + height/2) {
      int index = (int)((mouseY - height/4 - 50.0) / 40.0 + 1);
      if (index < leftForSelection.size()) {
        vehicles.get(currentPlayerIndex).inflictorsLeft.add(leftForSelection.get(index));
        leftForSelection.remove(index);
        currentPlayerIndex = (currentPlayerIndex + 1) % vehicles.size();
      }
    }
  } else if (currentScene == "End of Game") {
    for (int i = 0; i < buttons.size(); i++) {
      button b = buttons.get(i);
      if (mouseX > b.x - b.w / 2 && mouseX < b.x + b.w / 2 && mouseY > b.y - b.h / 2 && mouseY < b.y + b.h / 2) { //if mouse in button hitbox
        if (b.isSwitch == true) {
          b.pressed = !b.pressed;
        } else {
          b.pressed = true;
        }
      }
    }
  }
}

void mouseReleased() {
  if (currentScene == "Game") {
    for (int i = 0; i < buttons.size(); i++) {
      if (buttons.get(i).pressed == true) {
        //do the action the button is related to
        switch(i) {
        case 0: //Fire button
          if (vehicles.get(currentPlayerIndex).inflictorsLeft.contains(vehicles.get(currentPlayerIndex).selectedInflictorName) && inflictors.size() == 0 && currentShots == 0) {
            addInflictor(vehicles.get(currentPlayerIndex).selectedInflictorName);
            vehicles.get(currentPlayerIndex).inflictorsLeft.remove(vehicles.get(currentPlayerIndex).inflictorsLeft.indexOf(vehicles.get(currentPlayerIndex).selectedInflictorName)); //remove fired inflictor
          }
          buttons.get(0).pressed = false;
          break;
        case 1:
          vehicles.get(currentPlayerIndex).angle += TWO_PI / 36.0;
          break;
        case 2:
          vehicles.get(currentPlayerIndex).angle -= TWO_PI / 36.0;
          break;
        case 3:
          vehicles.get(currentPlayerIndex).power++;
          break;
        case 4:
          vehicles.get(currentPlayerIndex).power--;
          break;
        }
      }
    }
    vehicles.get(currentPlayerIndex).power = limit(vehicles.get(currentPlayerIndex).power, 0, 200);
    signs.get(8).text = str(vehicles.get(currentPlayerIndex).power);                        //update power to sign
    signs.get(7).text = str((int)(vehicles.get(currentPlayerIndex).angle / TWO_PI * 360));  //update angle to sign
  } else if (currentScene == "Intro Scene") {
    for (int i = 0; i < buttons.size(); i++) {
      if (buttons.get(i).pressed == true) {
        //do the action the button is related to
        switch(i) {
        case 0:
          currentScene = "InflictorSelection";
          resetButtons();
          initializeInflictorSelectionButtons();
          break;
        case 1:
          buttons.get(1).text = "no"; //go to settings
          break;
        case 2:
          exit();
          break;
        }
      }
    }
  } else if (currentScene == "InflictorSelection") {
    for (int i = 0; i < buttons.size(); i++) {
      if (buttons.get(i).pressed == true) {
        //do the action the button is related to
        switch(i) {
        case 0:
          currentScene = "Game";
          resetButtons();
          initializeGameButtons();

          //should activity have been changed, make sure player 1 starts
          for (int j = 0; j < vehicles.size(); j++) {
            if (j == 0) {
              vehicles.get(j).active = true;
            } else {
              vehicles.get(j).active = false;
            }
          }
          currentPlayerIndex = 0;
          break;
        case 1:
          break;
        case 2:
          break;
        }
      }
    }
  } else if (currentScene == "End of Game") {
    for (int i = 0; i < buttons.size(); i++) {
      if (buttons.get(i).pressed == true) {
        //do the action the button is related to
        switch(i) {
        case 6:
          setup();
          break;
        case 7:
          exit();
          break;
        }
      }
    }
  }

  //reset all buttons to false;
  for (int i = 0; i < buttons.size(); i++) {
    if (buttons.get(i).isSwitch == false) {
      buttons.get(i).pressed = false;
    }
  }
}

void keyPressed() {
  switch(key) {
  case ' ':
    if (buttons.size() > 0) {
      buttons.get(0).pressed = true;
    }
    break;
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

void keyReleased() {
  switch(key) {
  case ' ':
    if (vehicles.get(currentPlayerIndex).inflictorsLeft.contains(vehicles.get(currentPlayerIndex).selectedInflictorName) && inflictors.size() == 0 && currentShots == 0) {
      addInflictor(vehicles.get(currentPlayerIndex).selectedInflictorName);
    }
    buttons.get(0).pressed = false;
    break;
  case 'e':
    break;
  }
}
