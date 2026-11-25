class ahb_xtn extends uvm_sequence_item;

`uvm_object_utils(ahb_xtn)

//single 32-bit transfer (AHB-Lite, HBURST=SINGLE, HSIZE=WORD)
rand bit        write;
rand bit [31:0] addr;
rand bit [31:0] data;   //write data, or read data after the transfer completes
bit      [1:0]  resp;

constraint c_word_aligned{addr[1:0] == 2'b00;}

function new(string name="ahb_xtn");
super.new(name);
endfunction

function string convert2string();
return $sformatf("%s addr=%08h data=%08h resp=%0d",write ? "WRITE" : "READ",addr,data,resp);
endfunction

endclass
