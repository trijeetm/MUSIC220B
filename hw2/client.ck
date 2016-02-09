//-----------------------------------------------------------------------------
// name: client.ck
// desc: a simple client for demonstrating some of the features of Brewery,
// the library for creating algorithmic beat based compositions
//
// authors: Trijeet Mukhopadhyay (trijeetm@ccrma.stanford.edu)
// date: winter 2016
//       Stanford University
//-----------------------------------------------------------------------------

/* ----------------------
 * class.ks-chord example
 * ----------------------
 */

// testKSChord();

fun void testKSChord() {
    // sound to chord to dac
    SndBuf buffy => KSChord object => dac;
    // load a sound
    "special:dope" => buffy.read;
    // set feedback
    object.feedback(.93);

    // offset
    -24 => int x;
    // tune
    object.tune( 60+x, 65+x, 72+x, 76+x );

    0 => float gain;
    gain => buffy.gain;

    // loop
    while( true )
    {
        // set playhead to beginning
        0 => buffy.pos;
        // set rate
        1 => buffy.rate;
        // advance time
        550::ms / buffy.rate() => now;
    }
}

/* --------------------------
 * class.interpolator example
 * --------------------------
 */

// testInterpolator();

fun void testInterpolator() {
    Interpolator i1;
    i1.setup(0, 1, 10000::ms);
    i1.interpolate();

    Interpolator i2;
    i2.setup(10, 1, 1000::ms);
    i2.interpolate();

    while (true) {
        <<< i1.getCurrent() >>>;
        <<< i2.getCurrent() >>>;
        <<< "-----" >>>;
        1::ms => now;
    }
}

/* -----------------------
 * class.metronome example
 * -----------------------
 */

testMetro();

fun void wait1(Metronome m) {
    m.waitTillMeasure(10);
    <<< "10!" >>>;
}

fun void wait2(Metronome m) {
    m.waitTillMeasure(5);
    <<< "5!" >>>;
}

fun void testMetro() {
    Metronome metro;

    metro.setup(120, 4, 4);
    metro.start();

    spork ~ wait1(metro);
    spork ~ wait2(metro);

    while (metro.getMeasure() < 20) {
        <<< metro.getMeasure(), 
            metro.getWholeNoteCount(), 
            metro.getHalfNoteCount(), 
            metro.getQuarterNoteCount(), 
            metro.getEighthNoteCount(), 
            metro.getSixteenthNoteCount() >>>;
        metro.sixteenthNoteTick => now;
    }

    metro.waitTillMeasure(30);

    metro.stop();
}