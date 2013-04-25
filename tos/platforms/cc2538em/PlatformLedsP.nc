
module PlatformLedsP {
  provides {
    interface GeneralIO as Led0;
    interface GeneralIO as Led1;
    interface GeneralIO as Led2;
  }
  uses {
    interface GeneralIO as LedIn0;
    interface GeneralIO as LedIn1;
    interface GeneralIO as LedIn2;
  }
}

implementation {
  async command void Led0.set()        { call LedIn0.clr(); }
  async command void Led0.clr()        { call LedIn0.set(); }
  async command void Led0.toggle()     { call LedIn0.toggle(); }
  async command bool Led0.get()        { return call LedIn0.get(); }
  async command void Led0.makeInput()  { call LedIn0.makeInput(); }
  async command bool Led0.isInput()    { return call LedIn0.isInput(); }
  async command void Led0.makeOutput() { call LedIn0.makeOutput(); }
  async command bool Led0.isOutput()   { return call LedIn0.isOutput(); }

  async command void Led1.set()        { call LedIn1.clr(); }
  async command void Led1.clr()        { call LedIn1.set(); }
  async command void Led1.toggle()     { call LedIn1.toggle(); }
  async command bool Led1.get()        { return call LedIn1.get(); }
  async command void Led1.makeInput()  { call LedIn1.makeInput(); }
  async command bool Led1.isInput()    { return call LedIn1.isInput(); }
  async command void Led1.makeOutput() { call LedIn1.makeOutput(); }
  async command bool Led1.isOutput()   { return call LedIn1.isOutput(); }

  async command void Led2.set()        { call LedIn2.clr(); }
  async command void Led2.clr()        { call LedIn2.set(); }
  async command void Led2.toggle()     { call LedIn2.toggle(); }
  async command bool Led2.get()        { return call LedIn2.get(); }
  async command void Led2.makeInput()  { call LedIn2.makeInput(); }
  async command bool Led2.isInput()    { return call LedIn2.isInput(); }
  async command void Led2.makeOutput() { call LedIn2.makeOutput(); }
  async command bool Led2.isOutput()   { return call LedIn2.isOutput(); }
}
