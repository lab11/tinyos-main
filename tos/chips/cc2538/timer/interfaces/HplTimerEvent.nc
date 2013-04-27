
/**
 * Simple interface that the c interrupt handlers use to notify the actual
 * timers.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

interface HplTimerEvent {
  async event void fired ();
}
