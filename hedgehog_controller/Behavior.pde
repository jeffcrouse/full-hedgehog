
/**************************************
 *  Base class for all behaviors that can be applied to the servos
 **************************************/
public class Behavior {

  private int born;
  
  Behavior() {
    born = millis();
  }
  public String toString() { 
    return "[override me]";
  }
  void update(float deltaTime) {
  }
  void draw() {
  }
  boolean finished() {
    return false;
  }
  float age() {
    return (millis()-born) / 1000.0;
  }
}






/**************************************
 *  A simple wave that starts at the 
 *  center and extends outwatds
 **************************************/
public class Shockwave extends Behavior {

  private float radius;
  private float ring_width = 100;
  private float speed = 100;
  
  // ---------------------------------------
  Shockwave() {
    super();
    radius = 0;
  }

  // ---------------------------------------
  public String toString() {
    return "Shockwave "+radius;
  }

  // ---------------------------------------
  void draw() {
    noFill();
    strokeWeight(ring_width);
    stroke(100, 200, 100, 100);
    ellipse(0, 0, radius*2, radius*2);
  }

  // ---------------------------------------
  void update(float deltaTime) {
    this.radius += (deltaTime * speed);

    float max = deltaTime * 4.0;
  
    for (int i=0; i<servos.length; i++) {
      float dist = abs(servos[i].radius - this.radius);
      float effect = map(dist, 0, ring_width, max, 0);
      effect = constrain(effect, 0, max);
      
      servos[i].value += effect;
    }
  }

  // ---------------------------------------
  boolean finished() {
    return radius > 575;
  }
}




/**************************************
 *  A simple wave that starts at the 
 *  center and extends outwatds
 **************************************/
public class Wipe extends Behavior {

  private float angle;
  private float wipe_width = PI/4.0;
  private float speed = PI;
  private int n = 3;
  
  // ---------------------------------------
  Wipe() {
    super();
    angle = 0;
  }

  // ---------------------------------------
  public String toString() {
    return "Wipe "+angle;
  }

  // ---------------------------------------
  void draw() {
    noFill();
    strokeWeight(50);
    stroke(100, 200, 100, 100);
    
    float x = cos(angle) * 500;
    float y = sin(angle) * 500;
    line(0, 0, x, y);
  }

  // ---------------------------------------
  void update(float deltaTime) {
    this.angle += (deltaTime * speed);
    if(this.angle > TWO_PI) {
      this.angle %= (TWO_PI);
      this.n--;
    }
    

    float max = deltaTime * 10.0;
  
    for (int i=0; i<servos.length; i++) {
      float dist = abs(servos[i].angle - this.angle);
      float effect = map(dist, 0, wipe_width, max, 0);
      effect = constrain(effect, 0, max);
      
      servos[i].value += effect;
    }
  }

  // ---------------------------------------
  boolean finished() {
    return this.n < 1;
  }
}

