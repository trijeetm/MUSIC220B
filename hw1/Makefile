CLASSES = class.metronome.ck class.interpolator.ck class.ks-chord.ck
DEFAULTEXEC = client.ck

all: 
	chuck $(CLASSES) $(DEFAULTEXEC)

test_classes: 
	chuck $(CLASSES)

client: 
	chuck $(CLASSES) client.ck

milestone: 
	chuck $(CLASSES) milestone.ck