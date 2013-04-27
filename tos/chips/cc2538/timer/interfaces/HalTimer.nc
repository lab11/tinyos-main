
/**
 * Interface is a bridge between the hardware specific timer interface and
 * the very bland alarm interface.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

interface HalTimer<size_type> {

  async command void enable ();
  async command void disable ();

  async command bool isEnabled ();

  async command size_type get ();
  async command uint32_t getTimerFrequency ();

  async command void setEvent (size_type t0);
  async command void setEventFromNow (size_type dt);
  async command size_type getEvent ();

  async event void overflow ();
  async event void fired ();
}
