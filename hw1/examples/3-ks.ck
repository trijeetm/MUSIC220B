// feedforward
Impulse i => Delay delay => dac;
// feedback
delay => Gain g => OneZero lowpass => delay;

// delay length
500 => int L;
// set the delay
L::samp => delay.max => delay.delay;
// set attenuation
.99 => g.gain;
// set the lowpass
-1 => lowpass.zero;

while( true )
{
    // fire
    1 => i.next;

    // time
    5::second => now;
}