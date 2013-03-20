#include <Storage.h>

/**
 * Private component of the AT45DB implementation of the handloff log
 * abstraction.
 *
 * @author Pat Pannuto <pat.pannuto@gmail.com>
 */

module BatchUploadLoggerP {
  provides {
    interface HandoffLogWrite;
  }
  uses {
    interface At45db;
    interface At45dbVolume[uint8_t logId];
    interface Resource[uint8_t logId];
  }
}

implementation {
  /* High-Level Design:

    - Wear-leveling be damned! Block 0 holds all of the metadata and its
      contents is considered valid if the magic cookie value is present.

    - The remaining pages are treated as a circular array with pointers
      to *pages* (not offsets):

      > DATA_TAIL- the last page of valid data not yet exported
      > DATA_HEAD- the first page of valid data not yet exported

    - The data logger has 1+1+1+N, N>=1 page-sized buffers in RAM.

      > 1 buffer holds data currently being exported
      > 1 buffer holds the next page to be exported

      > 1 buffer is partially empty and accepts new appends
      > N buffers are pending / being written out to flash

      The logger will always attempt to keep 1 completely empty buffer page.
      Once this low water mark is hit, it will begin writing RAM buffers to
      flash (e.g. if N == 1, then it will write to flash once one page of data
      is filled, if N == 2 after two pages are filled both will be written to
      flash, etc)

    - Once EXPORT_THREASHOLD percent of the flash pages are filled, the export
      subsystem will begin attempting to contact a base station to dump out
      pages. Attempting an export is a state, and thus can be entered by
      user-prompting as well. Attempts to cancel the export process after
      EXPORT_THREASHOLD is exceeded will fail until the threashold is no longer
      met.

    - Once a base station is contacted, the first page is written the the radio.
      At the same time, the DATA_HEAD+1 page is read into memory. The DATA_HEAD
      is not advanced until the export is acknowledged. The DATA_HEAD is not
      written to metadata until the completion of the the entire export
      transaction under the assumption that power loss during export is
      unlikely.

    - IDEA: The actual metadata is stored not as pointers, but a bit vector of
      pages with valid data. Given that 1->0 transitions are relatively cheap
      and 0->1 transitions are expensive, the invalid state is represented as
      1's. As pages are filled, bits are 0'd. Upon the completion of an export,
      all the 0->1 transitions for the meta data are batched.

    - IDEA: Can we erase pages on export? Is that any different than erasing on
      first use?
  */

  // Configuration (Modularize?)
  enum {
    NUM_RAM_CACHE_PAGES = 1,
  };

  enum {
    NUM_LOGS = uniqueCount("at45db.HandoffLog"),
    EFF_PAGE_SIZE = AT45_PAGE_SIZE - sizeof(uint16_t),
    BATCH_UPLOAD_LOGGER_COOKIE = 0x554C,
  };

  enum {
    UPLOAD_IDLE,
    UPLOAD_SEARCHING,
    UPLOAD_ACTIVE,
  } upload_state_t;

  // State // TODO-Brad: Should all this be in a per-client struct?
  at45page_t DATA_TAIL, DATA_HEAD;

  uint8_t export_buf[AT45_PAGE_SIZE];
  uint8_t export_next_buf[AT45_PAGE_SIZE];

  uint8_t append_buf[AT45_PAGE_SIZE];
  uint8_t ram_cache[NUM_RAM_CACHE_PAGES][AT45_PAGE_SIZE];

  enum upload_state_t upload_state;

  uint8_t *COUNT_NOK(len) buf; // NULL --> No active req
  storage_len_t len;

  ////////////////////
  // IMPLEMENTATION //

  command error_t append(void* buf, storage_len_t len) {
    if (len > EFF_PAGE_SIZE)
      return EINVAL;

    // append
  }

  
}
