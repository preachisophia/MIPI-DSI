class ppi_xtn extends uvm_sequence_item;

`uvm_object_utils(ppi_xtn)

//OUTPUT
logic [7:0] ppi_data_lane0;
logic [7:0] ppi_data_lane1;
logic [7:0] ppi_data_lane2;
logic [7:0] ppi_data_lane3;
logic       ppi_lane0_en;
logic       ppi_lane1_en;
logic       ppi_lane2_en;
logic       ppi_lane3_en;

function new(string name="ppi_xtn");
super.new(name);
endfunction

function void do_print(uvm_printer printer);
super.do_print(printer);
printer.print_field("ppi_lane0_en",this.ppi_lane0_en,1,UVM_BIN);
printer.print_field("ppi_data_lane0",this.ppi_data_lane0,8,UVM_HEX);
printer.print_field("ppi_lane1_en",this.ppi_lane1_en,1,UVM_BIN);
printer.print_field("ppi_data_lane1",this.ppi_data_lane1,8,UVM_HEX);
printer.print_field("ppi_lane2_en",this.ppi_lane2_en,1,UVM_BIN);
printer.print_field("ppi_data_lane2",this.ppi_data_lane2,8,UVM_HEX);
printer.print_field("ppi_lane3_en",this.ppi_lane3_en,1,UVM_BIN);
printer.print_field("ppi_data_lane3",this.ppi_data_lane3,8,UVM_HEX);
endfunction

endclass
