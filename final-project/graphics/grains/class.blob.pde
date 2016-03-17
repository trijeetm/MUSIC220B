class Blob {
  float x, y, radius;
  int id;
  Colors colors = new Colors();
  float alpha = 0;

  Blob(int _id) {
    x = 950;
    y = 530;
    radius = 0;
    id = _id;
  }

  void setGain(float gain) {
    float _radius = 100 * gain;
    Ani.to(this, 0.1, "radius", _radius);
  }

  void setPan(float pan) {
    float _x = 950 + (200 * pan);
    Ani.to(this, 0.1, "x", _x);
  }

  void hide() {
    Ani.to(this, 2, "alpha", 0);
  }

  void show() {
    Ani.to(this, 2, "alpha", 255);
  }

  void draw() {
    fill(colors.getById(id), alpha);
    ellipse(x, y, radius, radius);
  }
}