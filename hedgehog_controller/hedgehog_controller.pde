import controlP5.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress pi;
Servo[] servos = new Servo[10];
int lastFrameTime = 0;
ControlP5 cp5;
Range range;
float oscMin = 0;
float oscMax = 1;

// ------------------------------------------------------------
void setup() {
  size(1000, 1000);
  frameRate(25);
  registerPre(this);
  cp5 = new ControlP5(this);
  range = cp5.addRange("OSC value range")
    // disable broadcasting since setRange and setRangeValues will trigger an event
    .setBroadcast(false) 
      .setPosition(50, 50)
        .setSize(400, 40)
          .setHandleSize(20)
            .setRange(0, 1)
              .setRangeValues(0.1, 0.9)
                // after the initialization we turn broadcast back on again
                .setBroadcast(true)
                      ;
  cp5.loadProperties(("hedgehog.properties"));
  
  
  oscP5 = new OscP5(this, 7000);
  pi = new NetAddress("hedgehog.local", 7000);

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
  for (int i=1; i<10; i++) {
    servos[i] = new Servo(angle, ring_radius, id);
    angle += 360/9.0;
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
    servos[i].update(deltaTime);
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
}

// ------------------------------------------------------------
void controlEvent(ControlEvent theControlEvent) {
  if (theControlEvent.isFrom("OSC value range")) {

    oscMin = theControlEvent.getController().getArrayValue(0);
    oscMax = theControlEvent.getController().getArrayValue(1);
    println("min", oscMin, "max", oscMax);
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
    cp5.saveProperties(("hedgehog.properties"));
  } else if (key=='l') {
    cp5.loadProperties(("hedgehog.properties"));
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

