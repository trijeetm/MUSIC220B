class Sample {
  ArrayList<PShape> slices;
  int nSlices;
  boolean ready;
  int width;
  int height;
  int totalSlices;
  int sliceWidth;
  int slicePadding;
  int id;
  int xOffset;
  int yOffset;
  float alpha = 100;

  Sample(int _id, int _w, int _h, int _n, int _x, int _y) {
    id = _id;
    slices = new ArrayList<PShape>();
    nSlices = 0;
    ready = false;
    width = _w;
    height = _h;
    totalSlices = _n;
    slicePadding = 1;
    sliceWidth = (width / _n);
    xOffset = _x;
    yOffset = _y;
  }

  void addSlice(float amplitude) {
    if (amplitude != -1) {
      amplitude = (float)Math.pow(amplitude, 0.5);
      float x = xOffset + (nSlices * sliceWidth);
      float y = yOffset - (amplitude * height / 2);
      PShape slice = createShape(RECT, x, y, sliceWidth - slicePadding, amplitude * height);
      slices.add(slice);
      nSlices++;
    }
    else {
      ready = true;
    }
  }

  PShape getSlice(int n) {
    return slices.get(n);
  }

  ArrayList<PShape> getSlices() {
    return slices;
  }

  int getLength() {
    return nSlices;
  }

  void hide() {
    Ani.to(this, 2, "alpha", 100);
  }

  void show() {
    Ani.to(this, 2, "alpha", 255);
  }

  void draw() {
    if (!ready) 
      return;
    
    for (PShape slice : slices) {
      slice.setFill(color(100, 100, 100, alpha));
      slice.setStroke(0);
      shape(slice);
    }
  }
}