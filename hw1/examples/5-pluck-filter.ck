// feedforward
SndBuf buffy => Delay delay => JCRev r => dac;
// feedback
delay => OneZero lowpass => delay;
// read
"ohno.aiff" => buffy.read;
// chunk
1024 => buffy.chunks;
// set gain
.25 => buffy.gain;
// set reverb mix
.1 => r.mix;

// random playback
Std.rand2f(.1, 1.5) => buffy.rate;

// set delay
500::samp => delay.delay;
// set lowpass zero position
-1 => lowpass.zero;
// set feedback gain
.99 => lowpass.gain;

// advance time
15::second => now;
