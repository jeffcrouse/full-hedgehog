import controlP5.*;
import oscP5.*;
import netP5.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

OscP5 oscP5;
NetAddress pi;
Servo[] servos = new Servo[9];
int lastFrameTime = 0;
ControlP5 cp5;

float oscMin = 0;
float oscMax = 1;
float speed;
Minim minim;
AudioInput mic;



// ------------------------------------------------------------
void setup() {
  size(1000, 1000);
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


  // First ring
  angle = 0;
  ring_radius = 164;
  for (int i=1; i<servos.length; i++) {
    servos[i] = new Servo(angle, ring_radius, id);
    angle += 360/8.0;
    id++;
  }

  // Second ring
  angle = 0;
  ring_radius = 290;
  // COMING SOON!
}


// ------------------------------------------------------------
void pre() {
  int now = millis();
  float deltaTime = (now-lastFrameTime)/1000.0;
  lastFrameTime = now;

  for (int i=0; i<servos.length; i++) {
    servos[i].update(deltaTime * speed);
  }
}

// ------------------------------------------------------------
void draw() {

  background(0);

  pushMatrix();
  translate(width/2, height/2);
  for (int i=0; i<servos.length; i++) {
    servos[i].draw();
  }

  popMatrix();


  // draw the waveforms so we can see what we are monitoring
  stroke(255);
  float x1, y1, x2, y2;
  float h = 100;
  pushMatrix();
  translate(0, height-150);
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
  
  float volume = mic.
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
  mic.close();
  minim.stop();
  super.stop();
}

