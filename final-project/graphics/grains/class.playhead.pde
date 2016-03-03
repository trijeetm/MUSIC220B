// class Playhead {
//   ArrayList<PShape> slices;
//   int head;
//   int lead;
//   int trail;

//   Playhead(ArrayList<PShape> s) {
//     slices = s;
//     head = lead = trail = 0;
//   }

//   void update(float p, float w, float d) {
//     head = Math.round(p * 200);
//   }

//   void draw() {
//     PShape slice = slices.get(head);
//     slice.setFill(color(255, 45, 85));
//     shape(slice);

//     slice = slices.get(lead);
//     slice.setFill(color(255, 45, 85));
//     shape(slice);

//     slice = slices.get(trail);
//     slice.setFill(color(255, 45, 85));
//     shape(slice);
//   }
// }