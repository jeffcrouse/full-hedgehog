// TO DO
// 1. Optimize OSC sending - send all updates in 1 message


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
Undulate undulate = new Undulate();

boolean autoServo = false;
float oscMin = 0;
float oscMax = 1;
float oscSendPeriod = 1/20.0;
float oscLastSend = -1;

float micRangeMin = 0;
float micRangeMax = 1;

float level, levelSmoothed, levelAdjusted = 0;
float fadeSpeed = 2.0;

float amplify;
float audioSmoothing;

boolean idleMode = true;
float idleTimeout = 10;
float lastAudioInput = -1;


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
  cp5.addRange("micRange")
    .setPosition(20, y)
      .setSize(400, 40)
        .setHandleSize(20)
          .setRange(0, 0.1)
            .setRangeValues(0, 1)
              ;
  y += 50;
  cp5.addSlider("fadeSpeed")
    .setPosition(20, y)
      .setSize(400, 40)
        .setRange(1.0, 5.0)
          ;

  y += 50;
  cp5.addSlider("amplify")
    .setPosition(20, y)
      .setSize(400, 40)
        .setRange(1.0, 10.0)
          ;
  y += 50;
  cp5.addSlider("audioSmoothing")
    .setPosition(20, y)
      .setSize(400, 40)
        .setRange(1.0, 20.0)
          ;

  cp5.loadProperties("controler01.properties");


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
float lastFrameTime = 0;
void pre() {

  float now = millis() / 1000.0;
  float deltaTime = now - lastFrameTime;
  lastFrameTime = now;

  // Calculate level variables
  level = pitchdetect.getAmplitude();

  if (level < micRangeMin) {
    levelAdjusted = 0;
  } else if (level > micRangeMin && level < micRangeMax) {
    levelAdjusted = map(level, micRangeMin, micRangeMax, 0, 1);
  } else {
    levelAdjusted = 1;
  }

  levelSmoothed += (levelAdjusted-levelSmoothed) / audioSmoothing;

  // Have we heard any audio?
  if (levelSmoothed > 0) {
    lastAudioInput = now;
  }
  float elapsed = now - lastAudioInput;
  idleMode = elapsed > idleTimeout;

  if (idleMode) {
    boolean noBehaviors = behaviors.size()<1;
    boolean lastBehaviorAlmostDone = !noBehaviors && behaviors.size() < 2 && behaviors.get(0).pct() > 0.85;

    if (noBehaviors || lastBehaviorAlmostDone) {
      addRandomBehavior();
    }
  } else {
    undulate.update(deltaTime);
  }

  for (int i =0; i <  servos.length; i++) {
    servos[i].update(deltaTime);
  }

  for (int i = behaviors.size () - 1; i >= 0; i--) {
    Behavior b = behaviors.get(i);
    b.update(deltaTime);
    if (b.pct() >= 1.0) {
      behaviors.remove(i);
    }
  }

  if ( now - oscLastSend > oscSendPeriod ) {

    OscMessage msg = new OscMessage("/pwm");

    for (int i =0; i <  servos.length; i++) {

      float value = map(servos[i].value, 0, 1, oscMin, oscMax);
      msg.add( constrain(value, 0, 1) );
    }
    oscP5.send(msg, pi);
    oscLastSend = now;
  }
}

// ------------------------------------------------------------
void addRandomBehavior() {
  int n = (int)random(4);
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
  }
}

// ------------------------------------------------------------
void draw() {

  background(idleMode ? 200: 100);
  text(frameRate, 10, 20);

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
void controlEvent(ControlEvent theControlEvent) {
  if (theControlEvent.isFrom("OSC value range")) {
    oscMin = theControlEvent.getController().getArrayValue(0);
    oscMax = theControlEvent.getController().getArrayValue(1);
  } else if (theControlEvent.isFrom("micRange")) {
    micRangeMin = theControlEvent.getController().getArrayValue(0);
    micRangeMax = theControlEvent.getController().getArrayValue(1);
  } else if (theControlEvent.isFrom("fadeSpeed")) {
    fadeSpeed = theControlEvent.getController().getValue();
  } else if (theControlEvent.isFrom("amplify")) {
    amplify = theControlEvent.getController().getValue();
  } else if (theControlEvent.isFrom("audioSmoothing")) {
    audioSmoothing = theControlEvent.getController().getValue();
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
    cp5.saveProperties("controler01.properties");
  } else if (key=='l') {
    cp5.loadProperties("controler01.properties");
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
  cp5.saveProperties("controler01.properties");

  mic.close();
  minim.stop();
  super.stop();
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
  rect(0, 20, map(level, 0, 1, 0, width), 20);
  fill(150);
  rect(0, 40, map(levelAdjusted, 0, 1, 0, width), 20);
  fill(0);
  rect(0, 60, map(levelSmoothed, 0, 1, 0, width), 20);

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

