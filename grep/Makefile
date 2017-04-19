eXe = grep
OBJS = $(eXe).o 

CFLAGS = -pipe -W -Wall -D_GNU_SOURCE
LIBS = -lpthread

all: $(eXe)

$(eXe): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LIBS)

clean:
	rm -f core $(eXe) *~
