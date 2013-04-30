
/**
 * Interface for the general purpose timers.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

interface HplGpTimer<size_type> {
  async event void fired ();
  async command void enable ();
  async command void disable ();
  async command bool isEnabled ();
  async command size_type get ();
  async command void setCompare (size_type compare);
  async command size_type getCompare ();
}
