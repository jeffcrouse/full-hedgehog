// TO DO
// 1. Optimize OSC sending - send all updates in 1 message
// 2. Audio events
// 3. Onset detection


import controlP5.*;
import oscP5.*;
import netP5.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

OscP5 oscP5;
NetAddress pi;
Servo[] servos = new Servo[43];
int lastFrameTime = 0;
ControlP5 cp5;

boolean autoServo = false;
float oscMin = 0;
float oscMax = 1;
float speed;
Minim minim;
AudioInput mic;
float levelLeft = 0;
float levelRight = 0;
float level, levelMovingAgerage = 0;
ArrayList<Float> levels = new ArrayList<Float>();
ArrayList<Behavior> behaviors = new ArrayList<Behavior>();
float onsetCounter = 0;
float onsetRecoveryPeriod = 3;


// ------------------------------------------------------------
void setup() {
  size(1100, 1100);
  frameRate(25);
  registerPre(this);


  // Setup ControlP5
  cp5 = new ControlP5(this);
  cp5.addRange("OSC value range")
    .setPosition(20, 50)
      .setSize(400, 40)
        .setHandleSize(20)
          .setRange(0, 1)
            .setRangeValues(0, 1)
              ;

  cp5.addSlider("speed")
    .setPosition(20, 100)
      .setSize(400, 40)
        .setRange(0, 11.0)
          ;

  cp5.loadProperties("hedgehog.properties");


  // Setup OSC stuff
  oscP5 = new OscP5(this, 7000);
  pi = new NetAddress("hedgehog.local", 7000);


  // Setup Audio stuff
  minim = new Minim(this);
  mic = minim.getLineIn(Minim.MONO, 512);


  setupServos();
}

// ------------------------------------------------------------
void setupServos() {
  int id=0;
  float angle = 0;
  float ring_radius = 0;

  // Center servo
  servos[0] = new Servo(angle, ring_radius, id);
  id++;


  // First ring 8 waggglers (1-8)
  angle = 0;
  ring_radius = 167;
  for (int i=1; i<9; i++) {
    servos[i] = new Servo(radians(angle), ring_radius, id);
    angle += 360/8.0;
    id++;
  }

  // Second ring 14 wagglers (9-22)
  angle = 0;
  ring_radius = 296;
  for (int i=9; i<23; i++) {
    servos[i] = new Servo(radians(angle), ring_radius, id);
    angle += 360/14.0;
    id++;
  }



  // third ring 20 wagglers (24-42) 
  angle = 0;
  ring_radius = 425;
  for (int i=23; i<43; i++) {
    servos[i] = new Servo(radians(angle), ring_radius, id);
    angle += 360/20.0;
    id++;
  }
}


// ------------------------------------------------------------
void updateAudio(float deltaTime) {

  // calculate the left and right channels
  float sum=0;
  for (int i = 0; i < mic.bufferSize () - 1; i++) {
    sum += abs(mic.right.get(i));
  }
  levelRight = sum / mic.bufferSize();

  sum=0;
  for (int i = 0; i < mic.bufferSize () - 1; i++) {
    sum += abs(mic.left.get(i));
  }
  levelLeft = sum / mic.bufferSize();

  // Average level
  level = (levelLeft+levelRight)/2.0;

  // Calculate the moving average of the last 30 samples
  levels.add( level );
  if (levels.size() > 120) {
    levels.remove(0);
  }
  sum = 0;
  for (int i=0; i<levels.size (); i++) {
    sum += levels.get(i);
  }
  levelMovingAgerage = sum / (float)levels.size();


  // Do onset calculation
  if (onsetCounter > 0) {
    onsetCounter -= deltaTime;
  }

  float louder = level - levelMovingAgerage;
  float thresh = level * 0.8;
  if (louder > thresh && onsetCounter < 0.01) {
    onOnset();
    onsetCounter = onsetRecoveryPeriod;
  }
}

// ------------------------------------------------------------
void onOnset() {
  int n = (int)random(4);
  switch(n) {
  case 0:
    float r = random(TWO_PI);
    float theta = random(300);
    behaviors.add(new Shockwave(r, theta));
    break;
  case 1:
    behaviors.add(new RadialWipe());
    break;
  case 2:
    behaviors.add( new HorizontalWipe() );
    break;
  case 3:
    behaviors.add( new Spiral() );
    break;
  }
}


// ------------------------------------------------------------
void pre() {
  int now = millis();
  float deltaTime = (now-lastFrameTime)/1000.0;
  lastFrameTime = now;

  updateAudio(deltaTime);

  for (int i = behaviors.size () - 1; i >= 0; i--) {
    Behavior b = behaviors.get(i);
    b.update(deltaTime * speed);
    if (b.finished()) {
      behaviors.remove(i);
    }
  }

  for (int i=0; i<servos.length; i++) {
    servos[i].update(deltaTime * speed);
  }
}


// ------------------------------------------------------------
void draw() {

  float b = map(onsetCounter, 0, onsetRecoveryPeriod, 0, 255);
  background(b);

  pushMatrix();
  translate(width-300, 20);

  stroke(255);
  textSize(14);


  float y = 0;
  for (int i=0; i<behaviors.size (); i++) {
    text(behaviors.get(i).toString(), 0, y);
    y += 14;
  }

  popMatrix();

  pushMatrix();
  translate(width/2, height/2);

  for (int i=0; i<servos.length; i++) {
    servos[i].draw();
  }

  for (int i=0; i<behaviors.size (); i++) {
    behaviors.get(i).draw();
  }

  popMatrix();

  drawAudioPreview();
}


// ------------------------------------------------------------
void drawAudioPreview() {
  // draw the waveforms so we can see what we are monitoring
  strokeWeight(1);

  float x1, y1, x2, y2;
  float h = 100;
  pushMatrix();
  translate(0, height-150);

  noStroke();
  fill(255);
  rect(0, 0, map(levelLeft, 0, 1, 0, width), 10);
  rect(0, 20, map(levelMovingAgerage, 0, 1, 0, width), 20);
  rect(0, 50, map(levelRight, 0, 1, 0, width), 10);


  stroke(100, 200, 150);
  for (int i = 0; i < mic.bufferSize () - 1; i++)
  {
    x1 = map(i, 0, mic.bufferSize()-1, 0, width);
    y1 = mic.left.get(i) * h;
    x2 = map(i+1, 0, mic.bufferSize()-1, 0, width);
    y2 = mic.left.get(i+1) * h;
    line( x1, y1, x2, y2 );
  }
  translate(0, 100);
  for (int i = 0; i < mic.bufferSize () - 1; i++)
  { 
    x1 = map(i, 0, mic.bufferSize()-1, 0, width);
    y1 = mic.right.get(i) * h;
    x2 = map(i+1, 0, mic.bufferSize()-1, 0, width);
    y2 = mic.right.get(i+1) * h;
    line( x1, y1, x2, y2 );
  }
  noStroke();

  popMatrix();
}

// ------------------------------------------------------------
void controlEvent(ControlEvent theControlEvent) {
  if (theControlEvent.isFrom("OSC value range")) {

    oscMin = theControlEvent.getController().getArrayValue(0);
    oscMax = theControlEvent.getController().getArrayValue(1);

    println("min", oscMin, "max", oscMax);
  }

  if (theControlEvent.isFrom("speed")) {
    speed = theControlEvent.getController().getValue();
  }
}

// ------------------------------------------------------------
void mousePressed() {
}

// ------------------------------------------------------------
void keyPressed() {
  // default properties load/save key combinations are 
  // alt+shift+l to load properties
  // alt+shift+s to save properties
  if (key=='s') {
    cp5.saveProperties("hedgehog.properties");
  } else if (key=='l') {
    cp5.loadProperties("hedgehog.properties");
  } else if (key == '1') {
    float r = random(TWO_PI);
    float theta = random(300);
    behaviors.add(new Shockwave(r, theta));
  } else if (key == '2') {
    behaviors.add(new RadialWipe());
  } else if ( key=='3') {
    behaviors.add( new HorizontalWipe() );
  } else if ( key=='4') {
    behaviors.add( new Spiral() );
  }
}


// ------------------------------------------------------------
/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}

// ------------------------------------------------------------
void stop() {
  cp5.saveProperties("hedgehog.properties");

  mic.close();
  minim.stop();
  super.stop();
}

