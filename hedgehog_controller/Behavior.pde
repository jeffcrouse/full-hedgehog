
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
 * Use this as a template for new behaviors
 * Put a description here
 **************************************/
public class SampleBehavior extends Behavior {

  // ---------------------------------------
  SampleBehavior() {
    super();
  }

  // ---------------------------------------
  public String toString() {
    return "[change me] ";
  }

  // ---------------------------------------
  void update(float deltaTime) {
    // DO something to the servos
    for (int i=0; i<servos.length; i++) {
      servos[i].value += 0;
    }
  }

  // ---------------------------------------
  void draw() {
  }

  // ---------------------------------------
  boolean finished() {
    return false;
  }
}


/**************************************
 *  A simple wave that starts at the 
 *  center and extends outwatds
 **************************************/
public class Shockwave extends Behavior {

  private float theta;
  private float r;
  private PVector center = new PVector();
  private float current_radius;
  private float ring_width = 100;
  private float speed = 100;

  // ---------------------------------------
  Shockwave(float theta, float r) {
    super();

    this.theta = theta;
    this.r = r;
    this.center.x = cos(theta) * r;
    this.center.y = sin(theta) * r;

    this.current_radius = 0;
  }

  // ---------------------------------------
  public String toString() {
    return "Shockwave "+current_radius;
  }

  // ---------------------------------------
  void draw() {
    noFill();
    strokeWeight(ring_width);
    stroke(100, 200, 100, 100);
    ellipse(center.x, center.y, current_radius*2, current_radius*2);
  }

  // ---------------------------------------
  void update(float deltaTime) {
    this.current_radius += (deltaTime * speed);

    float max = deltaTime * 4.0;

    for (int i=0; i<servos.length; i++) {

      float center_dist = servos[i].center.dist( this.center );
      float dist_to_perimeter = abs(center_dist - this.current_radius);


      float effect = map(dist_to_perimeter, 0, ring_width, max, 0);
      effect = constrain(effect, 0, max);

      servos[i].value += effect;
    }
  }

  // ---------------------------------------
  boolean finished() {
    return current_radius > 875;
  }
}




/**************************************
 *  A simple wave that starts at the 
 *  center and extends outwatds
 **************************************/
public class RadialWipe extends Behavior {

  private float theta;
  private float wipe_width = PI/4.0;
  private float speed = PI;
  private int n = 3;

  // ---------------------------------------
  RadialWipe() {
    super();
    theta = 0;
  }

  // ---------------------------------------
  public String toString() {
    return "Wipe "+theta;
  }

  // ---------------------------------------
  void draw() {
    noFill();
    strokeWeight(50);
    stroke(100, 200, 100, 100);

    float x = cos(theta) * 500;
    float y = sin(theta) * 500;
    line(0, 0, x, y);
  }

  // ---------------------------------------
  void update(float deltaTime) {
    this.theta += (deltaTime * speed);
    if (this.theta > TWO_PI) {
      this.theta %= (TWO_PI);
      this.n--;
    }


    float max = deltaTime * 10.0;

    for (int i=0; i<servos.length; i++) {
      float dist = abs(servos[i].theta - this.theta);
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



/**************************************
 *  Activates servos from left to right
 **************************************/
public class HorizontalWipe extends Behavior {

  private float wipe_width = 100;
  private float speed = 100.0;
  private float x = -500;

  // ---------------------------------------
  HorizontalWipe() {
    super();
  }

  // ---------------------------------------
  public String toString() {
    return "HorizontalWipe "+x;
  }

  // ---------------------------------------
  void draw() {
    noFill();
    strokeWeight(wipe_width);
    stroke(100, 200, 100, 100);

    line(x, -500, x, 500);
  }

  // ---------------------------------------
  void update(float deltaTime) {
    x += speed * deltaTime;

    float max = deltaTime * 10.0;

    for (int i=0; i<servos.length; i++) {
      float dist = abs(servos[i].center.x - this.x);
      float effect = map(dist, 0, speed, max, 0);
      effect = constrain(effect, 0, max);

      servos[i].value += effect;
    }
  }

  // ---------------------------------------
  boolean finished() {
    return this.x > 500;
  }
}


/**************************************
 * Spiral effect
 **************************************/
public class Spiral extends Behavior {

  private float r = 0;
  private float theta = 0;
  private PVector center = new PVector();
  private float size = 150;
  private float r_speed = 8;
  private float theta_speed = 0.5;

  // ---------------------------------------
  Spiral() {
    super();
  }

  // ---------------------------------------
  public String toString() {
    return "Spiral ";
  }

  // ---------------------------------------
  void update(float deltaTime) {
    r += deltaTime * r_speed;
    theta += deltaTime * theta_speed;
    
    center.x = cos(theta) * r;
    center.y = sin(theta) * r;
    
   float max = deltaTime * 6.0;
 
    // DO something to the servos
    for (int i=0; i<servos.length; i++) {
      float dist = servos[i].center.dist( this.center );
      float effect = map(dist, 0, size, max, 0);
      servos[i].value += effect;
    }
  }

  // ---------------------------------------
  void draw() {
    noStroke();
    fill(100, 200, 100, 100);
    ellipse(center.x, center.y, size, size);
  }

  // ---------------------------------------
  boolean finished() {
    return this.r > 600;
  }
}

