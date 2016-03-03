//-----------------------------------------------------------------------------
// name: music.ck
// desc: 
//
// authors: Trijeet Mukhopadhyay (trijeetm@ccrma.stanford.edu)
// date: winter 2016
//       Stanford University
//-----------------------------------------------------------------------------

main();

// /*
fun void main() {
  Metronome metro;
  metro.setup(90, 4, 4);  

  metro.start();

  spork ~ logger(metro);

  spork ~ intro(metro, 0);

  metro.waitForMeasures(512);
}

fun void intro(Metronome metro, int startMeasure) {
  metro.waitTillMeasure(startMeasure);

  Channel c_piston;
  Granulizer g_piston;

  g_piston.setup(1, "glass.wav", c_piston);

  // --- 1 --- //
  spork ~ g_piston.granulize();
  spork ~ g_piston.setLength(0.0, 0.8, metro.getMeasureDur(16));
  spork ~ g_piston.setPos(0, 0.75, metro.getMeasureDur(16));
  g_piston.setRate(4);
  //g_piston.setLength(1);
  //g_piston.setPos(0);
  spork ~ c_piston.interpMaster(0.9, 1, metro.getMeasureDur(16));
  c_piston.setRev(0.15);
  //spork ~ c_piston.interpPan(1, 0, metro.getMeasureDur(16));

  metro.waitTillMeasure(16);
  spork ~ g_piston.setLength(0.8, 0.05, metro.getMeasureDur(16));
  spork ~ g_piston.setRate(4, 0.5, metro.getMeasureDur(16));
  spork ~ c_piston.interpPan(0, 1, metro.getMeasureDur(16));
  spork ~ c_piston.interpMaster(1, 0, metro.getMeasureDur(16));

  metro.waitTillMeasure(72);
}

fun void logger(Metronome met) {
  while (true) {
    <<< met.getMeasure(), met.getQuarterNoteCount() >>>;
    met.quarterNoteTick => now;
  }
}