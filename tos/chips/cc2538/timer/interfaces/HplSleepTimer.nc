
/**
 * Commands that the sleep timer hardware supports.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

interface HplSleepTimer {
  async command void enable ();
  async command void disable ();
  async command bool isEnabled ();
  async command uint32_t get ();
  async command void setCompare (uint32_t compare);
  async command uint32_t getCompare ();

  async event void fired ();
}
