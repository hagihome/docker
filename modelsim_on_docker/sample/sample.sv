import uvm_pkg::*;
`include "uvm_macros.svh"

class SampleTest extends uvm_test;
  `uvm_component_utils(SampleTest)
  function new ( string name="SampleTest", uvm_component parent=null);
    super.new(name,parent);
  endfunction
  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_name(),"Hello,UVM World!",UVM_LOW)
  endtask
endclass

module tb_top;
  initial begin
    run_test("SampleTest");
  end
endmodule
