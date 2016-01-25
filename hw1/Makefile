CLASSES = class.interpolator.ck class.metronome.ck class.channel.ck class.ks.ck class.ks-chord.ck
DEFAULTEXEC = client.ck

all: 
	chuck $(CLASSES) $(DEFAULTEXEC)

test_classes: 
	chuck $(CLASSES)

client: 
	chuck $(CLASSES) client.ck

milestone: 
	chuck $(CLASSES) milestone.ck

music: 
	chuck $(CLASSES) music.ck