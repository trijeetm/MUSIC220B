// feedforward
Noise noise => Delay delay => dac;
// feedback
delay => Gain g => OneZero lowpass => delay;

// delay length
1200 => int L;
// set the delay
L::samp => delay.max => delay.delay;
// set attenuation
.99 => g.gain;
// set the lowpass
-1 => lowpass.zero;

// L samples
L::samp => now;
// silence noise
0 => noise.gain;

// advance time
15::second => now;