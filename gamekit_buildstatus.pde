#include <gamekit.h>
#include <avr/pgmspace.h>

enum Status {
  STAT_SUCCESS,
  STAT_RUNNING,
  STAT_FAILED,
  MAX_STATUS
};

char status_chars[MAX_STATUS] = {
  's',
  'r',
  'f',
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

void setup() {
  gamekit.Begin();
  Serial.begin(9600);
}

void loop() {
  int update = 0;
  Status status;
  
  if (Serial.available()) {
    char c = Serial.read();
    
    for (i = 0; i < MAX_STATUS; i++) {
      if (c == status_chars[i]) {
        status = static_cast<Status>(i);
        update = 1;
      }
    }
  }

  if (gamekit.button_pressed(butt_UP)) {
    status = STAT_SUCCESS;
    update = 1;
  }

  if (gamekit.button_pressed(butt_LEFT) ||
      gamekit.button_pressed(butt_RIGHT)) {
    status = STAT_RUNNING;
    update = 1;
  }

  if (gamekit.button_pressed(butt_DOWN)) {
    status = STAT_FAILED;
    update = 1;
  }

  if (update) {
    gamekit.load_image(images[status]);
  }
}
