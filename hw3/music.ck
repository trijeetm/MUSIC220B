//-----------------------------------------------------------------------------
// name: music.ck
// desc: 
//
// authors: Trijeet Mukhopadhyay (trijeetm@ccrma.stanford.edu)
// date: winter 2016
//       Stanford University
//-----------------------------------------------------------------------------
main();

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

  Channel c_chant, c_piston, c_chant2;
  Granulizer g_chant, g_piston, g_chant2;

  g_chant.setup("tibetan-chant.wav", c_chant);
  g_chant2.setup("tibetan-chant.wav", c_chant);
  g_piston.setup("piston.wav", c_piston);

  // --- 1 --- //
  g_chant.setLength(0.5);
  g_chant.setPos(0.4);

  spork ~ g_chant.setRandomness(0.001, 0.5, metro.getMeasureDur(8));
  spork ~ c_chant.interpMaster(0, 1, metro.getMeasureDur(8));

  spork ~ g_chant.granulize();

  metro.waitTillMeasure(8);

  spork ~ c_chant.interpPan(0, -0.2, metro.getMeasureDur(8));
  spork ~ c_chant.interpMaster(1, 0.9, metro.getMeasureDur(8));

  spork ~ g_piston.granulize();
  spork ~ g_piston.setLength(0.05, 0.8, metro.getMeasureDur(16));
  spork ~ g_piston.setPos(0, 0.75, metro.getMeasureDur(16));
  spork ~ c_piston.interpMaster(0, 1, metro.getMeasureDur(16));
  spork ~ c_piston.interpPan(1, 0, metro.getMeasureDur(16));

  metro.waitTillMeasure(24);
  spork ~ g_piston.setLength(0.8, 0.05, metro.getMeasureDur(8));
  spork ~ g_piston.setRate(1, 0.5, metro.getMeasureDur(8));
  spork ~ c_piston.interpPan(0, 1, metro.getMeasureDur(8));
  spork ~ c_piston.interpMaster(1, 0, metro.getMeasureDur(8));

  metro.waitTillMeasure(28);
  spork ~ g_chant.setRate(1, 2, metro.getMeasureDur(24));
  spork ~ c_chant.interpMaster(1, 0.3, metro.getMeasureDur(24));

  g_chant2.setLength(0.25);
  g_chant2.setPos(0.4);

  spork ~ g_chant2.setRandomness(0.001, 0.5, metro.getMeasureDur(24));
  spork ~ c_chant2.interpMaster(0, 0.6, metro.getMeasureDur(24));

  spork ~ g_chant2.granulize();

  // --- 3 --- //

  metro.waitTillMeasure(32);

  spork ~ g_piston.setLength(0.05, 0.8, metro.getMeasureDur(24));
  spork ~ g_piston.setPos(0, 0.75, metro.getMeasureDur(24));
  spork ~ c_piston.interpMaster(0, 1, metro.getMeasureDur(24));
  spork ~ c_piston.interpPan(1, 0, metro.getMeasureDur(24));

  metro.waitTillMeasure(56);

  spork ~ g_piston.setLength(0.8, 0.05, metro.getMeasureDur(16));
  spork ~ g_piston.setRate(1, 0.5, metro.getMeasureDur(16));
  spork ~ c_piston.interpPan(0, 1, metro.getMeasureDur(16));
  spork ~ c_piston.interpMaster(1, 0, metro.getMeasureDur(16));

  spork ~ g_chant.setLength(0.5, 0, metro.getMeasureDur(16));
  spork ~ g_chant2.setLength(0.25, 0, metro.getMeasureDur(16));
  spork ~ c_chant.interpMaster(0.3, 0, metro.getMeasureDur(16));
  spork ~ c_chant2.interpMaster(0.3, 0, metro.getMeasureDur(16));
  spork ~ c_chant.interpPan(c_chant.pan.pan(), -1, metro.getMeasureDur(16));
  spork ~ c_chant2.interpPan(c_chant2.pan.pan(), 1, metro.getMeasureDur(16));

  metro.waitTillMeasure(72);
}

fun void logger(Metronome met) {
  while (true) {
    <<< met.getMeasure(), met.getQuarterNoteCount() >>>;
    met.quarterNoteTick => now;
  }
}