class Sample {
  ArrayList<PShape> slices;
  int nSlices;
  boolean ready;

  Sample() {
    slices = new ArrayList<PShape>();
    nSlices = 0;
    ready = false;
  }

  void addSlice(float amplitude) {
    println(amplitude);
    if (amplitude != -1) {
      println(amplitude);
      PShape slice = createShape(RECT, 100 + (nSlices * 3), 400 - ((amplitude * 100) / 2), 2, (amplitude * 100));
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

  void draw() {
    if (!ready) 
      return;
    
    for (PShape slice : slices) {
      slice.setFill(color(100, 100, 100));
      slice.setStroke(0);
      shape(slice);
    }
  }
}