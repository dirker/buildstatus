#include <gamekit.h>
#include <avr/pgmspace.h>

#define BUFSIZE 16

enum status {
  STAT_SUCCESS,
  STAT_RUNNING,
  STAT_FAILED,
  MAX_STATUS
};

char *status_strings[MAX_STATUS] = {
  "success",
  "running",
  "failed",
};

uint8_t images[MAX_STATUS][5][7] PROGMEM = {
  /* success image */
  {
    15, 0, 0, 0, 0, 0, 0,
    15, 0, 0, 0, 0, 0, 0,
    15, 0, 0, 0, 0, 0, 0,
    15, 0, 0, 0, 0, 0, 0,
    15, 0, 0, 0, 0, 0, 0,
  },
  /* running image */
  {
     0,10, 0, 0, 0, 0, 0,
     0,10, 0, 0, 0, 0, 0,
     0,10, 0, 0, 0, 0, 0,
     0,10, 0, 0, 0, 0, 0,
     0,10, 0, 0, 0, 0, 0,
  },
  /* failed image */
  {
     0, 0,10, 0, 0, 0, 0,
     0, 0,10, 0, 0, 0, 0,
     0, 0,10, 0, 0, 0, 0,
     0, 0,10, 0, 0, 0, 0,
     0, 0,10, 0, 0, 0, 0,
  },
};

static int i;

static char buf[BUFSIZE];
static int bufidx;

void setup() {
  gamekit.Begin();
  Serial.begin(9600);
}

void loop() {
  int received = 0;
  
  if (Serial.available()) {
    char c = Serial.read();
    
    if (c == '\r' || c == '\n')
      c = 0;
      
    if (bufidx < BUFSIZE)
      buf[bufidx++] = c;
      
    if (bufidx == BUFSIZE)
      bufidx = BUFSIZE - 1;
    
    if (!c) {
      buf[bufidx] = 0;
      bufidx = 0;
      received = 1;
    }
  }

  if (!received)
    return;
  
  for (i = 0; i < MAX_STATUS; i++) {
    if (strcmp(buf, status_strings[i]) == 0) {
      break;
    }
  }

  if (i < MAX_STATUS)
    gamekit.load_image(images[i]);  
}
