// feedforward
Impulse i => Delay delay => dac;
// feedback
delay => Gain g => delay;

// set delay
10::ms => delay.max => delay.delay;
// set attenuation
.98 => g.gain;

while( true )
{
    // fire!
    1 => i.next;
    // advance time
    2::second => now;
}
