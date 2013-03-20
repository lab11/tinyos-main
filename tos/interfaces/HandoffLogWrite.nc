/**
 * Write-only interface for the Handoff Log abstraction.
 *
 * A handoff log is defined as an `infinitely-deep' recording abstraction. The
 * handoff logger accepts <code>record</code>s of freeform structure (an array
 * of bytes) and `saves' the records to an _external_ system. As the recorded
 * data is ultimately all sent off-device, the handoff log provides no reading
 * mechanism. The handoff log also acknowledges that depending on the exact
 * mechanism employed, the ability to offload records may lag too far behind the
 * writing of new records (that is, the internal handoff staging buffer fills).
 * To accomodate this an optional `almost-full' alarm event is provided and a
 * run-time configurable choice to either reject new records or overwrite the
 * oldest records.
 *
 * An example of a Handoff Logger is the BatchUploadLogger, which collects
 * records first in RAM, then Flash, then periodically uploads them to an
 * external service.
 *
 * A simpler example of a Handoff Logger is the RadioUploadLogger, which assumes
 * an omnipresent base station, immediately sending log records over the air.
 *
 * @author Pat Pannuto <pat.pannuto@gmail.com>
 */

#include "Storage.h"

interface HandoffLogWrite{
  /**
   * Log a record to a given volume. Upon completion an
   * <code>logRecordDone</code> event will be signaled.
   *  TODO: Pend calls or only one live?
   *
   * @param 'void* COUNT(len) buf' buffer to record data from
   * @param len number of bytes to write
   * @return
   *   <li>SUCCESS if the record was handed off successfully
   *   <li>EINVAL if the request is invalid (will never succeed, i.e. too large)
   *   <li>EBUSY if a transient error occurred (should retry)
   *   <li>ESIZE if the buffer storage is full and not in overwrite mode
   */
  command error_t logRecord(void* buf, storage_len_t len);

  /**
   * Signals the completion of an logRecord operation.
   *  TODO: Sync() API? SplitControl?
   *
   * @param 'void* COUNT(len) buf' buffer that was passed to logRecord
   * @param len number of bytes actually written (valid even in error cases)
   * @param recordsLost TRUE if this logRecord destroyed some old records
   * @param error SUCCESS if appeneded, ESIZE if the buffer storage is full and
   *        not in overwrite mode, and FAIL for other errors
   */
  event void logRecordDone(void* buf, storage_len_t len, bool recordsLost,
      error_t error);

  /**
   * Clears all pending operations and drops all records not yet handed off to
   * the external service. If a connection (e.g. a TCP session) is made to an
   * external service, it is dropped. Signals resetDone on completion.
   */
  event void reset();

  /**
   * Signals the completion of a reset operation.
   *
   * @param recordsLost TRUE if records were dropped as a result of reset
   */
  event void resetDone();

  /**
   * Sets an alarm to trigger if the remaining cache is nearly full. To disable
   * an alarm, set the threashold parameter to 0. Out of reset both alarms are
   * set to 0 (disabled).
   *
   * @param percentage An integer threashold (0,100] of space remaining
   *        expressed as a percentage (e.g. set to 5 for 95% full warning)
   * @param bytes Trigger an alarm if the number of bytes remaining falls below
   *        this value
   */
  command void setCacheAlarm(uint8_t percentage, uint32_t bytes);

  /**
   * An alarm event warning that the cache storage layer is nearly full.
   *
   * @param isByteAlarm TRUE if alarm was triggered by number of bytes remaining
   *                    FALSE if alarm was triggered by percentage remaining
   */
  event void cacheAlarm(bool isByteAlarm);
}
