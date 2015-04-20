// TO DO
// 1. Optimize OSC sending - send all updates in 1 message
// 2. Audio events
// 3. Onset detection
// 4. Sound input is only mono - no reason to caluclate both channels


import controlP5.*;
import oscP5.*;
import netP5.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

OscP5 oscP5;
NetAddress pi;
ControlP5 cp5;
Minim minim;
AudioInput mic;
PitchDetector pitchdetect;   


Servo[] servos = new Servo[43];
ArrayList<Behavior> behaviors = new ArrayList<Behavior>();


boolean autoServo = false;
float oscMin = 0;
float oscMax = 1;
float levelMin = 0;
float levelMax = 1;
float levelMultiplier;
float speed;
float pitch, pitchSmoothed;
float level, levelMovingAgerage = 0;
ArrayList<Float> levels = new ArrayList<Float>();
float onsetCounter = 0;
float onsetRecoveryPeriod = 4;
float fadeSpeed = 2.0;

// ------------------------------------------------------------
void setup() {
  size(1100, 1100);
  frameRate(25);
  registerPre(this);


  // Setup ControlP5
  int y = 50;
  cp5 = new ControlP5(this);
  cp5.addRange("OSC value range")
    .setPosition(20, y)
      .setSize(400, 40)
        .setHandleSize(20)
          .setRange(0, 1)
            .setRangeValues(0, 1)
              ;

  y += 50;
  cp5.addRange("mic level range")
    .setPosition(20, y)
      .setSize(400, 40)
        .setHandleSize(20)
          .setRange(0, 1)
            .setRangeValues(0, 1)
              ;

  y += 50;
  cp5.addSlider("speed")
    .setPosition(20, y)
      .setSize(400, 40)
        .setRange(0, 11.0)
          ;

  y += 50;
  cp5.addSlider("fadeSpeed")
    .setPosition(20, y)
      .setSize(400, 40)
        .setRange(1.0, 5.0)
          ;

  cp5.loadProperties("hedgehog.properties");


  // Setup OSC stuff
  oscP5 = new OscP5(this, 7000);
  pi = new NetAddress("hedgehog.local", 7000);


  // Setup Audio stuff
  minim = new Minim(this);
  mic = minim.getLineIn(Minim.MONO, 512, 44100);
  pitchdetect = new PitchDetector(); 
  mic.addEffect(pitchdetect); 


  // Setup Servos!
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

  level = pitchdetect.getAmplitude();

  // Calculate the moving average of the last 30 samples
  levels.add( level );
  if (levels.size() > 30) {
    levels.remove(0);
  }
  float sum = 0;
  for (int i=0; i<levels.size (); i++) {
    sum += levels.get(i);
  }
  levelMovingAgerage = sum / (float)levels.size();

  levelMultiplier = map(levelMovingAgerage, levelMin, levelMax, 0, 1);
  levelMultiplier = constrain(levelMultiplier, 0, 1);
  
  // Do onset calculation
  if (onsetCounter > 0) {
    onsetCounter -= deltaTime;
  }

  float louder = level - levelMovingAgerage;
  float thresh = level * 1.5;
  if (louder > thresh && onsetCounter < 0.01) {
    onOnset();
    onsetCounter = onsetRecoveryPeriod;
  }

  pitch = map(pitchdetect.getPitch(), 100, 900, 0, 1);
  pitchSmoothed += (pitch-pitchSmoothed)/10.0;
}

// ------------------------------------------------------------
void onOnset() {
}


// ------------------------------------------------------------
int lastFrameTime = 0;
void pre() {

  int now = millis();
  float deltaTime = (now-lastFrameTime)/1000.0;
  lastFrameTime = now;

  updateAudio(deltaTime);

  for (int i = behaviors.size () - 1; i >= 0; i--) {
    Behavior b = behaviors.get(i);
    b.update(deltaTime * speed);
    if (b.pct() >= 1.0) {
      behaviors.remove(i);
    }
  }

  boolean noBehaviors = behaviors.size()<1;
  boolean lastBehaviorAlmostDone = !noBehaviors && behaviors.size() < 2 && behaviors.get(0).pct() > 0.9;

  if (noBehaviors || lastBehaviorAlmostDone) {
    addRandomBehavior();
  }

  for (int i=0; i<servos.length; i++) {
    servos[i].update(deltaTime * speed);
  }
}

// ------------------------------------------------------------
void addRandomBehavior() {
  int n = (int)random(5);
  switch(n) {
  case 0:
    float r = random(TWO_PI);
    float theta = random(100);
    behaviors.add(new Ripples(r, theta));
    break;
  case 1:
    behaviors.add(new RadialWipe());
    break;
  case 2:
    boolean NorthSouth = random(10)>5;
    boolean EastWest = random(10)>5;
    behaviors.add( new Wipe(NorthSouth, EastWest) );
    break;
  case 3:
    behaviors.add( new Undulate() );
    break;
  }
}

// ------------------------------------------------------------
void draw() {

  float b = map(onsetCounter, 0, onsetRecoveryPeriod, 0, 255);
  background(50);

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
// draw the waveforms so we can see what we are monitoring
void drawAudioPreview() {
  noStroke();
  strokeWeight(1);

  float x1, y1, x2, y2;
  float h = 100;
  pushMatrix();
  translate(0, height-150);


  fill(255);
  text("level", 10, 0);
  rect(0, 15, map(level, 0, 1, 0, width), 20);
  fill(100);
  rect(0, 20, map(levelMovingAgerage, 0, 1, 0, width), 10);

  fill(255);
  text("pitch", 10, 60);
  rect(0, 65, map(pitch, 0, 1, 0, width), 20);
  fill(100);
  rect(0, 70, map(pitchSmoothed, 0, 1, 0, width), 10);



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

  popMatrix();
}

// ------------------------------------------------------------
void controlEvent(ControlEvent theControlEvent) {
  if (theControlEvent.isFrom("OSC value range")) {

    oscMin = theControlEvent.getController().getArrayValue(0);
    oscMax = theControlEvent.getController().getArrayValue(1);
  } else if (theControlEvent.isFrom("mic level range")) {

    levelMin = theControlEvent.getController().getArrayValue(0);
    levelMax = theControlEvent.getController().getArrayValue(1);


    
  } else if (theControlEvent.isFrom("speed")) {

    speed = theControlEvent.getController().getValue();
  } else if (theControlEvent.isFrom("fadeSpeed")) {

    fadeSpeed = theControlEvent.getController().getValue();
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
    float r = 0; //random(TWO_PI);
    float theta = 0; //random(300);
    behaviors.add(new Ripples(r, theta));
  } else if (key == '2') {
    behaviors.add(new RadialWipe());
  } else if ( key=='3') {
    boolean NorthSouth = random(10)>5;
    boolean EastWest = random(10)>5;
    behaviors.add( new Wipe(NorthSouth, EastWest) );
  } else if ( key=='4') {
    behaviors.add( new Spiral() );
  } else if ( key=='5') {
    behaviors.add( new Undulate() );
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

