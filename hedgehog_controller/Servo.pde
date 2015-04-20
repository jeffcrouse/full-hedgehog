

class Servo {

  public float diameter = 130;
  public float theta;
  public float r;
  public PVector center = new PVector();
  public int id;
  private float offset;
  public float value;
  private float lastValueSent;
  private String label;

  private float seed;


  // -------------------------------------------
  Servo(float theta, float r, int id) {
    this.r = r;
    this.theta = theta;
    this.id = id;

    this.center.x = cos(theta) * r;
    this.center.y = sin(theta) * r;

    this.value = 0;
    this.lastValueSent = -1;

    this.seed = random(TWO_PI);

    label = id+"";
  }

  // -------------------------------------------
  void update(float deltaTime) {

    this.seed += deltaTime;
    if (autoServo) {
      value = 0.5 * cos(seed) + 0.5;
    }

    if (idleMode) {
      value = constrain(value, 0, 1);
      if (value>0) {
        value -= deltaTime * fadeSpeed;
      }
    }
  }

  // -------------------------------------------
  void draw() {

    float c = map(value, 0, 1, 0, 255);
    if (c > 255 || c < 0) {
      // make it red -- warning! our of range!
    }
    fill(c);
    stroke(204, 102, 0);
    strokeWeight(4);
    ellipse(center.x, center.y, diameter, diameter);

    noStroke();
    fill(255-c);
    textSize(18);

    text(label, center.x-20, center.y+10);
  }
}

