#include <gamekit.h>
#include <avr/pgmspace.h>

/* gamekit internally reverses rows/columns, so redefine here */
#define PIXEL_ROWS gamekit_col_count
#define PIXEL_COLUMNS gamekit_row_count

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

uint8_t status_pixelvalues[MAX_STATUS] = {
   0,
  16,
  15,
};

char *status_strings[MAX_STATUS] = {
  "success",
  "running",
  "failed",
};

static int i;

/*
 * pixelfunction for status running:
 *  - dimming up and down slowly
 *  - only dim out to a certain minimum level
 *  - a break when dimmed out
 */
uint8_t pixelfunc_running(uint8_t row, uint8_t col, uint32_t systemcounter)
{
#define MIN_LEVEL 2
  static uint8_t val = MIN_LEVEL;
  static uint32_t old_counter = 0;
  static uint8_t up_down = 0;
  static uint8_t dimming = 1;

  if (!dimming) {
    if (systemcounter >= (old_counter + 1000)) {
      dimming = 1;
    } else {
      return val;
    }
  }

  if(systemcounter >= (old_counter + 6))
  {
    if (up_down == 0)
    {
      val++;
      if(val == gamekit_max_bright)
        up_down = 1;
    }
    else
    {
      val--;
      if(val == MIN_LEVEL) {
        up_down = 0;
        dimming = 0;
      }
    };
    old_counter= systemcounter;
  }

  return val;
#undef MIN_LEVEL
}

void setup() {
  gamekit.Begin();
  gamekit.assign_pixelfunction(16, pixelfunc_running);

  Serial.begin(9600);
}

void update_status(::Status status) {
  uint8_t row, column, val = status_pixelvalues[status];

  for (row = 0; row < PIXEL_ROWS; row++) {
    for (column = 0; column < PIXEL_COLUMNS; column++) {
      gamekit.set_pixel(row, column, val);
    }
  }
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
    update_status(status);
  }
}
