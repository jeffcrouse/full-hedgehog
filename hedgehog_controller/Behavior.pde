
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
  float age() {
    return (millis()-born) / 1000.0;
  }
  float pct() {
    return 0;
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
  float pct() {
    return 0;
  }
}


/**************************************
 *  A simple wave that starts at the 
 *  center and extends outwatds
 **************************************/
public class Ripples extends Behavior {

  private float theta, r;  // The polar coordinates of the center of the ripples
  private PVector center = new PVector(); // the cartesian coordinates of the center of the ripples
  private ArrayList<Float> ripples = new ArrayList<Float>(); // The radii of the ripples
  private float ring_width = 100; // The width of the effect of each ripple
  private float speed = 800;  // how fast the ripples move
  private float strength = 10;  // how much effect they have on the servos as they pass by
  private float lastRipple = -10;    // When did the last ripple occur?
  private float removeAt = 700;  // At what radius should we remove a ripple?
  private int n = 0;  // How many ripples have been destroyed?
  private float rippleDelay = 1.5; // how many seconds between ripples?



  // ---------------------------------------
  Ripples(float theta, float r) {
    super();

    this.theta = theta;
    this.r = r;
    this.center.x = cos(theta) * r;
    this.center.y = sin(theta) * r;
  }

  // ---------------------------------------
  public String toString() {
    return "Ripples "+pct();
  }

  // ---------------------------------------
  void draw() {
    noFill();
    strokeWeight(ring_width);
    stroke(100, 200, 100, 100);
    for (int i=0; i<ripples.size (); i++) {
      ellipse(center.x, center.y, ripples.get(i)*2, ripples.get(i)*2);
    }
  }

  // ---------------------------------------
  void update(float deltaTime) {
    float now = millis() / 1000.0;
    float maxEffect = deltaTime * strength;

    if (now-this.lastRipple > rippleDelay && n < 3) {
      ripples.add( 0.0 );
      this.lastRipple = now;
    }

    for (int i=0; i<ripples.size (); i++) {
      Float ripple = ripples.get(i);

      ripple += (deltaTime * this.speed);
      ripples.set(i, ripple);

      for (int s=0; s<servos.length; s++) {
        Servo servo = servos[s];
        float center_dist = servo.center.dist( this.center );
        float dist_to_perimeter = abs(center_dist - ripple);
        float effect = map(dist_to_perimeter, 0, ring_width, maxEffect, 0);
        effect = constrain(effect, 0, maxEffect);

        servo.value += effect;
      }

      if (ripple > removeAt) {
        this.n++;
        ripples.remove(i);
      }
    }
  }

  float pct() {
    float sum = (n*removeAt);
    for (int i=0; i<ripples.size (); i++) {
      sum += ripples.get(i);
    }
    return sum / (removeAt * 3);
  }
}




/**************************************
 *  A simple wave that starts at the 
 *  center and extends outwatds
 **************************************/
public class RadialWipe extends Behavior {

  private float theta = 0;                // The current angle of the wand
  private float wipe_width = PI/4.0;      // The width of the area of effect (as angle)
  private float speed = 4;                  // How fast does the wand spin around?
  private float strength = 10.0;          // How much effect does the wand have on the servos
  private float maxTheta = TWO_PI * 3.0;  // When does it stop?

  // ---------------------------------------
  RadialWipe() {
    super();
  }

  // ---------------------------------------
  public String toString() {
    return "Wipe "+pct();
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
    float inc = (deltaTime * speed);
    this.theta += inc;

    float maxEffect = deltaTime * strength;

    for (int i=0; i<servos.length; i++) {

      float angle = abs(servos[i].theta - (this.theta%TWO_PI));
      if (angle > PI) 
        angle = TWO_PI - angle;

      float effect = map(angle, 0, wipe_width, maxEffect, 0);
      effect = constrain(effect, 0, maxEffect);

      servos[i].value += effect;
    }

    servos[0].value = oscMax;
  }

  // ---------------------------------------
  float pct() {
    return this.theta / this.maxTheta;
  }
}



/**************************************
 *  Activates servos from along horizontal axis
 **************************************/
public class Wipe extends Behavior {

  private float wipe_width = 100;
  private float speed = 0.3;  // The speed at which the wipe moves across the screen (normalized)
  private float posNorm;          // The progress of the wipe (normalized)
  private float posActual;         // the actual x position (calculated)
  private float strength = 10.0;
  private float start = -600;
  private float end = 600;

  private boolean x_axis;
  
  
  // ---------------------------------------
  Wipe(boolean EastWest, boolean NorthSouth) {
    super();
    this.x_axis = NorthSouth;
    this.start = EastWest ? -600 : 600;
    this.end = EastWest ? 600 : -600;
    this.posNorm = 0;
  }

  // ---------------------------------------
  public String toString() {
    return "Wipe "+pct();
  }

  // ---------------------------------------
  void draw() {
    noFill();
    strokeWeight(wipe_width);
    stroke(100, 200, 100, 100);
    float x1 = this.x_axis ? posActual : -500;
    float y1 = this.x_axis ? -500 : posActual;
    float x2 = this.x_axis ? posActual : 500;
    float y2 = this.x_axis ? 500 : posActual;
    line(x1, y1, x2, y2);
  }

  // ---------------------------------------
  void update(float deltaTime) {
    posNorm += this.speed * deltaTime;
    posActual = map(posNorm, 0, 1, start, end);

    float maxEffect = deltaTime * strength;

    for (int i=0; i<servos.length; i++) {
      float reference = this.x_axis ? servos[i].center.x : servos[i].center.y;
      float dist = abs(reference - posActual);
      float effect = map(dist, 0, wipe_width, maxEffect, 0);
      effect = constrain(effect, 0, maxEffect);

      servos[i].value += effect;
    }
  }

  // ---------------------------------------
  float pct() {
    return posNorm;
  }
}


/**************************************
 * Spiral effect
 **************************************/
public class Spiral extends Behavior {

  private float r = 20;          // Current radius of behavior
  private float theta = 0;       // Current theta of behavior

  private float theta_speed = 1;  // How fast does the behavior spin around?

  private float max_r = 600;

  private PVector center = new PVector();  // Cartesian coordinate of effector
  private float size = 200;  // How big is the area of effect?

  private float strength = 6.0;  // How much effect does this behavior have on the Servos?

  // ---------------------------------------
  Spiral() {
    super();
  }

  // ---------------------------------------
  public String toString() {
    return "Spiral "+pct();
  }

  // ---------------------------------------
  void update(float deltaTime) {
    r += deltaTime * map(r, 0, max_r, 30, 6);
    theta += deltaTime * theta_speed;

    center.x = cos(theta) * r;
    center.y = sin(theta) * r;

    float maxEffect = deltaTime * strength;

    // DO something to the servos
    for (int i=0; i<servos.length; i++) {
      float dist = servos[i].center.dist( this.center );
      float effect = map(dist, 0, size, maxEffect, 0);
      effect = constrain(effect, 0, maxEffect);

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
  float pct() {
    return r / max_r;
  }
}



/**************************************
 * Undulate effect
 **************************************/
public class Undulate extends Behavior {

  
  private float strength = 3.0;  // How much effect does this behavior have on the Servos?
  float[] thetas;
  float speed = 1.4;

  // ---------------------------------------
  Undulate() {
    super();
    thetas = new float[servos.length];
    for(int i=0; i<thetas.length; i++) {
      thetas[i] = sin( (i/(float)thetas.length) * (TWO_PI*2) );
    }
  }

  // ---------------------------------------
  public String toString() {
    return "Undulate "+pct();
  }

  // ---------------------------------------
  void update(float deltaTime) {
   
    float maxEffect = deltaTime * strength;
    
    for (int i=0; i<servos.length; i++) {
      
      float effect = map(sin(thetas[i]), -1, 1, 0, maxEffect);
      effect = constrain(effect, 0, maxEffect);

      servos[i].value += effect;
      thetas[i] += deltaTime * this.speed;
    }
  }

  // ---------------------------------------
  void draw() {
    noStroke();
    fill(100, 200, 100, 100);
    //ellipse(center.x, center.y, size, size);
  }

  // ---------------------------------------
  float pct() {
    return age() / 5.0;
  }
}
