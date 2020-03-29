class Ball {
  PVector position;
  PVector velocity;

  float radius, m;
  
  int state;
  float rTimer;

  Ball(float x, float y, float r_) {
    position = new PVector(x, y);
    velocity = PVector.random2D();
    velocity.mult(0.01);
    radius = r_;
    m = 1;
    rTimer = 500;
    state = 0;
  }

  void update() {
    if (state == 1) {
      rTimer -= 0.01;
    }
    if (rTimer <= 0) {
      state = 2;
    }
    
    position.add(velocity);
  }

  void checkBoundaryCollision() {
    if (position.x > width-radius) {
      position.x = width-radius;
      velocity.x *= -1;
    } else if (position.x < radius) {
      position.x = radius;
      velocity.x *= -1;
    } else if (position.y > height-radius) {
      position.y = height-radius;
      velocity.y *= -1;
    } else if (position.y < radius+60) {
      position.y = radius+60;
      velocity.y *= -1;
    }
  }

  void checkCollision(Ball other) {
    PVector distanceVect = PVector.sub(other.position, position);
    float distanceVectMag = distanceVect.mag();
    float minDistance = radius + other.radius;

    if (distanceVectMag < minDistance) {
      float distanceCorrection = (minDistance-distanceVectMag)/2.0;
      PVector d = distanceVect.copy();
      PVector correctionVector = d.normalize().mult(distanceCorrection);
      other.position.add(correctionVector);
      position.sub(correctionVector);

      float theta  = distanceVect.heading();
      float sine = sin(theta);
      float cosine = cos(theta);

      PVector[] bTemp = {
        new PVector(), new PVector()
      };

      bTemp[1].x  = cosine * distanceVect.x + sine * distanceVect.y;
      bTemp[1].y  = cosine * distanceVect.y - sine * distanceVect.x;

      PVector[] vTemp = {
        new PVector(), new PVector()
      };

      vTemp[0].x  = cosine * velocity.x + sine * velocity.y;
      vTemp[0].y  = cosine * velocity.y - sine * velocity.x;
      vTemp[1].x  = cosine * other.velocity.x + sine * other.velocity.y;
      vTemp[1].y  = cosine * other.velocity.y - sine * other.velocity.x;
      
      PVector[] vFinal = {  
        new PVector(), new PVector()
      };

      vFinal[0].x = ((m - other.m) * vTemp[0].x + 2 * other.m * vTemp[1].x) / (m + other.m);
      vFinal[0].y = vTemp[0].y;

      vFinal[1].x = ((other.m - m) * vTemp[1].x + 2 * m * vTemp[0].x) / (m + other.m);
      vFinal[1].y = vTemp[1].y;

      bTemp[0].x += vFinal[0].x;
      bTemp[1].x += vFinal[1].x;

      PVector[] bFinal = { 
        new PVector(), new PVector()
      };

      bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
      bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
      bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
      bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;

      other.position.x = position.x + bFinal[1].x;
      other.position.y = position.y + bFinal[1].y;

      position.add(bFinal[0]);

      velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y;
      velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x;
      other.velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y;
      other.velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x;
      
      // if (random(1) < 0.2) {
      if (random(1) < 0.5) {
        if (state == 0 && other.state == 1) {
          state = 1;
        } else if (state == 1 && other.state == 0) {
          other.state = 1;
        }
      }
    }
  }

  void display() {
    noStroke();
    if      (state == 0) fill(0, 255, 0);
    else if (state == 1) fill(255, 0, 0);
    else                 fill(0, 0, 255);
    ellipse(position.x, position.y, radius*2, radius*2);
  }
}
