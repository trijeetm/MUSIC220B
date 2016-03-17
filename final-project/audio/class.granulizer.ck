//-----------------------------------------------------------------------------
// name: granulizer.ck
// desc: a granular synthesis engine
//
// authors: Trijeet Mukhopadhyay (trijeetm@ccrma.stanford.edu)
// date: winter 2016
//       Stanford University
//-----------------------------------------------------------------------------

public class Granulizer {
    // overall volume
    1 => float MAIN_VOLUME;
    // grain duration
    0::ms => dur SAMPLE_LENGTH;
    // 0::ms => dur GRAIN_LENGTH;
    0 => float GRAIN_LENGTH;
    // factor relating grain duration to ramp up/down time
    .5 => float GRAIN_RAMP_FACTOR;
    // playback rate
    1 => float GRAIN_PLAY_RATE;
    // grain position (0 start; 1 end)
    0 => float GRAIN_POSITION;
    // grain position randomization
    0 => float GRAIN_POSITION_RANDOM;
    // grain jitter (0 == periodic fire rate)
    1 => float GRAIN_FIRE_RANDOM;
    // grain play rate
    2::second => dur GRAIN_FIRE_RATE;

    false => int GRANULATE;

    0 => int id;

    // ----
    // lisa
    // ----
    
    200 => int LISA_MAX_VOICES;

    LiSa @ lisa;

    PoleZero blocker;
    // pole location to block DC and ultra low frequencies
    0.95 => blocker.blockZero;

    // ----

    // ---
    // osc
    // ---

    // name
    "localhost" => string hostname;
    4242 => int port;

    // send object
    OscSend xmit;

    // aim the transmitter
    xmit.setHost( hostname, port );

    // ---

    fun void setup(int _id, string file, Channel channel) {
        _id => id;

        // init graphics
        xmit.startMsg("/granulizer/init", "i");
        id => xmit.addInt;

        channel.setMaster(0);
        load(file) @=> lisa;
        lisa.chan(0) => blocker => channel;
        channel.setup(id);

        setPos(0);
        setLength(0);
    }

    fun void granulize() {
        // main loop
        while (GRANULATE)
        {
            // fire a grain
            fireGrain();
            // amount here naturally controls amount of overlap between grains
            GRAIN_FIRE_RATE + Math.random2f(0, GRAIN_FIRE_RANDOM)::ms => now;
        }
    }

    fun void incGrainFireRate() {
        GRAIN_FIRE_RATE / 2 => GRAIN_FIRE_RATE;
    }

    fun void decGrainFireRate() {
        GRAIN_FIRE_RATE * 2 => GRAIN_FIRE_RATE;
    }

    fun void start() {
        true => GRANULATE;
        spork ~ granulize();

        xmit.startMsg( "/granulizer/toggle", "i i" );
        id => xmit.addInt;
        1 => xmit.addInt;
    }

    fun void stop() {
        false => GRANULATE;

        xmit.startMsg( "/granulizer/toggle", "i i" );
        id => xmit.addInt;
        0 => xmit.addInt;
    }

    fun void setPos(float pos) {
        pos => GRAIN_POSITION;

        xmit.startMsg( "/granulizer/prop/pos", "i f" );
        id => xmit.addInt;
        pos => xmit.addFloat;
    }

    fun void setPos(float end, dur duration) {
        setPos(GRAIN_POSITION);
        Interpolator interp;
        interp.setup(GRAIN_POSITION, end, duration);
        interp.interpolate();
        while (interp.getCurrent() != interp.end) {
            setPos(interp.getCurrent());
            interp.delta => now;
        }
        setPos(interp.getCurrent());
    }

    fun void setPos(float start, float end, dur duration) {
        setPos(start);
        Interpolator interp;
        interp.setup(start, end, duration);
        interp.interpolate();
        while (interp.getCurrent() != interp.end) {
            setPos(interp.getCurrent());
            interp.delta => now;
        }
        setPos(interp.getCurrent());
    }

    fun void setRate(float rate) {
        if (rate > 0)
            rate => GRAIN_PLAY_RATE;
    }

    fun void setRate(float end, dur duration) {
        setRate(GRAIN_PLAY_RATE);
        Interpolator interp;
        interp.setup(GRAIN_PLAY_RATE, end, duration);
        interp.interpolate();
        while (interp.getCurrent() != interp.end) {
            setRate(interp.getCurrent());
            interp.delta => now;
        }
        setRate(interp.getCurrent());
    }

    fun void setRate(float start, float end, dur duration) {
        setRate(start);
        Interpolator interp;
        interp.setup(start, end, duration);
        interp.interpolate();
        while (interp.getCurrent() != interp.end) {
            setRate(interp.getCurrent());
            interp.delta => now;
        }
        setRate(interp.getCurrent());
    }

    fun void setLength(float len) {
        len => GRAIN_LENGTH;

        xmit.startMsg( "/granulizer/prop/len", "i f" );
        id => xmit.addInt;
        len => xmit.addFloat;
    }

    fun void setLength(float end, dur duration) {
        setLength(GRAIN_LENGTH);
        Interpolator interp;
        interp.setup(GRAIN_LENGTH, end, duration);
        interp.interpolate();
        while (interp.getCurrent() != interp.end) {
            setLength(interp.getCurrent());
            interp.delta => now;
        }
        setLength(interp.getCurrent());
    }

    fun void setLength(float start, float end, dur duration) {
        setLength(start);
        Interpolator interp;
        interp.setup(start, end, duration);
        interp.interpolate();
        while (interp.getCurrent() != interp.end) {
            setLength(interp.getCurrent());
            interp.delta => now;
        }
        setLength(interp.getCurrent());
    }

    fun void setRandomness(float rand) {
        rand => GRAIN_POSITION_RANDOM;
    }

    fun void setRandomness(float start, float end, dur duration) {
        start => GRAIN_POSITION_RANDOM;
        Interpolator interp;
        interp.setup(start, end, duration);
        interp.interpolate();
        while (interp.getCurrent() != interp.end) {
            interp.getCurrent() => GRAIN_POSITION_RANDOM;
            interp.delta => now;
        }
        interp.getCurrent() => GRAIN_POSITION_RANDOM;
    }

    // load file into a LiSa
    fun LiSa load(string _filename) {
        me.sourceDir() + "/samples/" => string path;
        path + _filename => string filename;

        // sound buffer
        SndBuf buffy;
        // load it
        filename => buffy.read;

        // get length
        buffy.length() => SAMPLE_LENGTH;
        0 => GRAIN_LENGTH;
        
        // new LiSa
        LiSa lisa;
        // set duration
        buffy.samples()::samp => lisa.duration;
        
        // transfer values from SndBuf to LiSa
        for( 0 => int i; i < buffy.samples(); i++ ) {
            // args are sample value and sample index
            // (dur must be integral in samples)
            lisa.valueAt( buffy.valueAt(i), i::samp );        
        }
        
        // set LiSa parameters
        lisa.play( false );
        lisa.loop( false );
        lisa.maxVoices( LISA_MAX_VOICES );

        // send sample data to processing
        0 => int s;
        150 => int nSlices;
        for (int i; i < nSlices; i++) {
            xmit.startMsg("/granulizer/setup", "i f");
            id => xmit.addInt;
            buffy.valueAt(s) => float _samp;
            if (_samp < 0)
                -1 *=> _samp;
            _samp => xmit.addFloat;
            buffy.samples() / nSlices +=> s;
        }
        xmit.startMsg( "/granulizer/setup", "i f" );
        id => xmit.addInt;
        -1 => xmit.addFloat;
        
        return lisa;
    }

    // fire!
    fun void fireGrain() {
        // grain length
        GRAIN_LENGTH * SAMPLE_LENGTH => dur grainLen;
        // ramp time
        grainLen * GRAIN_RAMP_FACTOR => dur rampTime;
        // play pos
        GRAIN_POSITION + Math.random2f(0, GRAIN_POSITION_RANDOM) => float pos;

        xmit.startMsg( "/granulizer/fire", "i f" );
        id => xmit.addInt;
        (grainLen / 1::second) / GRAIN_PLAY_RATE => xmit.addFloat;

        // a grain
        if( lisa != null && pos >= 0 )
            spork ~ grain( lisa, pos * lisa.duration(), grainLen, rampTime, rampTime, 
            GRAIN_PLAY_RATE );
    }

    // grain sporkee
    fun void grain( LiSa @ lisa, dur pos, dur grainLen, dur rampUp, dur rampDown, float rate ) {
        // get a voice to use
        lisa.getVoice() => int voice;

        grainLen / rate => grainLen;
        rampUp / rate => rampUp;
        rampDown / rate => rampDown;

        // if available
        if( voice > -1 )
        {
            // no loop
            lisa.loop(voice, 0);
            // set rate
            lisa.rate( voice, rate );
            // set playhead
            lisa.playPos( voice, pos );
            // ramp up
            lisa.rampUp( voice, rampUp );
            // wait
            (grainLen - rampUp) => now;
            // ramp down
            lisa.rampDown( voice, rampDown );
            // wait
            rampDown => now;
            // stop
            lisa.rate(voice, 0);
        }
    }
}