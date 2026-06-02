
LIBRARY  = liberis
VERSION  = 1.0.0
CFLAGS  += -Wall -g
LDLIBS  += -lcurl
LIBDIR  ?= /usr/lib
INCDIR  ?= /usr/include

TESTS = \
	test-liberis-gpios    \
	test-liberis-leds     \

LN ?= ln

.PHONY: all
all: dynamic

.PHONY: dynamic
dynamic: $(LIBRARY).so

.PHONY: static
static: $(LIBRARY).a

.PHONY: install
install: dynamic_install

.PHONY:dynamic_install
dynamic_install: $(LIBRARY).so.$(VERSION)
	cp $(LIBRARY).so.$(VERSION) $(LIBDIR)
	$(LN) -s $(LIBDIR)/$(LIBRARY).so.$(VERSION) $(LIBDIR)/$(LIBRARY).so
	cp $(LIBRARY).h $(INCDIR)

.PHONY:static_install
static_install: static
	cp $(LIBRARY).a $(LIBDIR)
	cp $(LIBRARY).h $(INCDIR)

$(LIBRARY).o: $(LIBRARY).c $(LIBRARY).h
	$(CC) -c $(CFLAGS) -fPIC $<

$(LIBRARY).a: $(LIBRARY).o
	ar -rcs $@ $^

$(LIBRARY).so: $(LIBRARY).so.$(VERSION)
	$(LN) -s  $(LIBRARY).so.$(VERSION)  $(LIBRARY).so

$(LIBRARY).so.$(VERSION): $(LIBRARY).o
	$(CC) $(LDFLAGS) -shared -Wl,-soname,$(LIBRARY).so -o $(LIBRARY).so.$(VERSION) $^ $(LDLIBS)

tests: $(TESTS)

%: %.c liberis.h
	$(CC) $(CFLAGS) -I. $(LDFLAGS) -L. $< -o $@ -leris

doc:
	doxygen  Doxyfile

clean:
	rm -rf out *.o $(LIBRARY).so* $(LIBRARY).a $(TESTS)
