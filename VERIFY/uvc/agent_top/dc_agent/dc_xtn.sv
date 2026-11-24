class dc_xtn extends uvm_sequence_item;

`uvm_object_utils(dc_xtn)

//INPUT
rand bit [23:0] pixel_data[];
bit [23:0] pixel_data_quemon;
logic 	     data_valid;
logic 	     hsync;
logic        vsync;

typedef enum{HD,VGA,FULL_HD,NORMAL}format;
rand format resol;

int vbp;
int vfp;
int hbp;
int hfp;
  
int vbs;
int vbe;
int hbs;
int hbe;
  
int vactive;
int hactive;
  
int vtotal;
int htotal;
  
//For eg My pixel is 5x3 with 1 frame (then 5 pixels per line  so 3 hsync lines with 1 frame)
//this is for 10x3 so 10 pixels per line and totaly 3 lines with one frame) 
rand int no_of_pixels;
rand int no_of_lines;
rand int no_of_frames;
rand int v_sync_cycles;
rand int h_sync_cycles;

//CONSTRAINTS
constraint c_resolution
{
  (resol == HD)      -> (no_of_pixels == 1280 && no_of_lines == 720);
  (resol == VGA)     -> (no_of_pixels == 640  && no_of_lines == 480);
  (resol == FULL_HD) -> (no_of_pixels == 1920 && no_of_lines == 1080);
  (resol == NORMAL)  -> (no_of_pixels == 10   && no_of_lines == 3);
}

constraint c_pixel_data_size{pixel_data.size() == no_of_pixels*no_of_lines;}

// Bound the sync widths: the driver loops repeat(v_sync_cycles/h_sync_cycles),
// and post_randomize computes hbp = hbe - h_sync_cycles with hbe = 10.
constraint c_sync_cycles
{
  v_sync_cycles inside {[1:10]};
  h_sync_cycles inside {[1:10]};
}

function void post_randomize();    
begin
    vbp=5;
    vfp=5;

    hbs    = 20;
    hbe    = 10;
    htotal = 25;
   
end 
    hbp = hbe-h_sync_cycles;//5
    hfp = htotal-hbs;//5
    hactive = htotal-(hbe+hfp);

endfunction

function new(string name="dc_xtn");
super.new(name);
endfunction

function void do_print(uvm_printer printer);
super.do_print(printer);
printer.print_field("vsync",this.vsync,1,UVM_BIN);
printer.print_field("hsync",this.hsync,1,UVM_BIN);
printer.print_field("data_valid",this.data_valid,1,UVM_BIN);
$display("//////////////// IT PRINTS ENTIRE PIXELS THAT RANDOMIZED //////////////");
foreach(pixel_data[i])
printer.print_field($sformatf("pixel_data[%0d]",i),pixel_data[i],24,UVM_HEX);
endfunction

function void driver_print_line(int lines);
   int start;
   int finish;

   start  = lines * no_of_pixels;
   finish = start + no_of_pixels;

   $display("---------------DC_DRV FOR LINES ALONE----------------------");
   $display("DRIVER_LINE NUMBER = %0d",lines);

    for(int i=start;i<finish;i++)
      $display("pixel_data[%0d] = %h",i,pixel_data[i]);

endfunction

endclass


