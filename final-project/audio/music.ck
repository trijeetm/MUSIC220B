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

  // spork ~ logger(metro);

  spork ~ intro(metro, 0);

  metro.waitForMeasures(512);
}

fun void intro(Metronome metro, int startMeasure) {
  metro.waitTillMeasure(startMeasure);

  Channel c_piston;
  Granulizer g_piston;

  g_piston.setup(0, "piston.wav", c_piston);

  Channel c_glass;
  Granulizer g_glass;

  g_glass.setup(1, "glass.wav", c_glass);

  // --- 1 --- //
  spork ~ g_piston.granulize();
  g_piston.setLength(0.5);
  g_piston.setPos(0);
  g_piston.setRate(7.5);
  // spork ~ g_piston.setLength(0.8, 0.25, metro.getMeasureDur(16));
  // spork ~ g_piston.setPos(0, 0.75, metro.getMeasureDur(16));
  // spork ~ g_piston.setRate(1, 4, metro.getMeasureDur(16));
  spork ~ c_piston.interpMaster(0.5, 0.7, metro.getMeasureDur(16));
  c_piston.setRev(0.25);

  spork ~ g_glass.granulize();
  spork ~ c_glass.interpMaster(0.1, 0.3, metro.getMeasureDur(4));
  // spork ~ g_glass.setPos(0, 0.5, metro.getMeasureDur(16));
  // spork ~ g_glass.setLength(0.1, 0.5, metro.getMeasureDur(16));
  // spork ~ g_glass.setRate(1, 4, metro.getMeasureDur(16));
  g_glass.setLength(0.5);
  g_glass.setPos(0);
  g_glass.setRate(4);
  c_glass.setRev(0.25);

  while (true) {
    g_piston.setLength(Math.randomf());
    g_piston.setPos(Math.randomf());
    g_piston.setRate(Math.random2f(0.1, 8));

    g_glass.setLength(Math.randomf());
    g_glass.setPos(Math.randomf());
    g_glass.setRate(Math.random2f(0.1, 8));

    metro.waitForMeasures(2);
  }

  metro.waitTillMeasure(72);
}

fun void logger(Metronome met) {
  while (true) {
    <<< met.getMeasure(), met.getQuarterNoteCount() >>>;
    met.quarterNoteTick => now;
  }
}