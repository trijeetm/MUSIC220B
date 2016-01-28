//SinOsc s => LPF lpf => dac;
SndBuf buff => LPF lpf => dac;
"special:dope" => buff.read;
1 => buff.loop;

// 440 => s.freq;
10000 => lpf.freq;
10 => lpf.Q;

while (lpf.freq() > 100) {
  lpf.freq() - 1 => lpf.freq;
  <<< lpf.freq() >>>;
  1::ms => now;
}