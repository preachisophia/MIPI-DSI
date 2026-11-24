class dc_seqs extends uvm_sequence#(dc_xtn);

`uvm_object_utils(dc_seqs)

function new(string name="dc_seqs");
super.new(name);
endfunction

task body();
endtask

endclass

//%%%%%%%%%%%%%%%%% FRAME_5_SEQS %%%%%%%%%%%%%%%%%%%
class frame_5_seqs extends dc_seqs;

`uvm_object_utils(frame_5_seqs)

function new(string name="frame_5_seqs");
super.new(name);
endfunction

task body();
req=dc_xtn::type_id::create("req");
start_item(req);
req.randomize() with {req.resol==NORMAL;
		      req.v_sync_cycles==5;
		      req.h_sync_cycles==5;
		      req.no_of_frames==5;};
finish_item(req);
endtask

endclass

//%%%%%%%%%%%%%%%%% FRAME_10_SEQS %%%%%%%%%%%%%%%%%%%
class frame_10_seqs extends dc_seqs;

`uvm_object_utils(frame_10_seqs)

function new(string name="frame_10_seqs");
super.new(name);
endfunction

task body();
req=dc_xtn::type_id::create("req");
start_item(req);
req.randomize() with {req.resol==NORMAL;
		      req.v_sync_cycles==5;
		      req.h_sync_cycles==5;
		      req.no_of_frames==10;};
finish_item(req);
endtask

endclass

//%%%%%%%%%%%%%%%%% VSYNC_RANDOM_SEQS %%%%%%%%%%%%%%%%%%%
class vsync_random_seqs extends dc_seqs;

`uvm_object_utils(vsync_random_seqs)

function new(string name="vsync_random_seqs");
super.new(name);
endfunction

task body();
req=dc_xtn::type_id::create("req");
start_item(req);
req.randomize() with {req.resol==NORMAL;
	              req.no_of_frames==2;};
finish_item(req);
endtask

endclass

//%%%%%%%%%%%%%%%%% VSYNC_5_SEQS %%%%%%%%%%%%%%%%%%%
class vsync_5_seqs extends dc_seqs;

`uvm_object_utils(vsync_5_seqs)

function new(string name="vsync_5_seqs");
super.new(name);
endfunction

task body();
req=dc_xtn::type_id::create("req");
start_item(req);
req.randomize() with {req.resol==NORMAL;
		              req.v_sync_cycles==5;
		              req.h_sync_cycles==5;
			          req.no_of_frames==2;};
finish_item(req);
endtask

endclass

//%%%%%%%%%%%%%%%%% VSYNC_10_SEQS %%%%%%%%%%%%%%%%%%%
class vsync_10_seqs extends dc_seqs;

`uvm_object_utils(vsync_10_seqs)

function new(string name="vsync_10_seqs");
super.new(name);
endfunction

task body();
req=dc_xtn::type_id::create("req");
start_item(req);
req.randomize() with {req.resol==NORMAL;
		              req.v_sync_cycles==10;
		              req.h_sync_cycles==10;
			          req.no_of_frames==2;};
finish_item(req);
endtask

endclass

//%%%%%%%%%%%%%%%%% PIXEL_RANDOM_SEQS %%%%%%%%%%%%%%%%%%%
class pixel_random_seqs extends dc_seqs;

`uvm_object_utils(pixel_random_seqs)

function new(string name="pixel_random_seqs");
super.new(name);
endfunction

task body();
req=dc_xtn::type_id::create("req");
start_item(req);
req.randomize() with {req.resol==NORMAL;
		              req.v_sync_cycles==10;
		              req.h_sync_cycles==10;
			          req.no_of_frames==2;};
finish_item(req);
endtask

endclass

//%%%%%%%%%%%%%%%%% PIXEL_WHITE_SEQS %%%%%%%%%%%%%%%%%%%
class pixel_white_seqs extends dc_seqs;

`uvm_object_utils(pixel_white_seqs)

function new(string name="pixel_white_seqs");
super.new(name);
endfunction

task body();
req=dc_xtn::type_id::create("req");
start_item(req);
req.randomize() with {req.resol==NORMAL;
		              req.v_sync_cycles==10;
		              req.h_sync_cycles==10;
			          req.no_of_frames ==2;
					   foreach (req.pixel_data[i])
                               req.pixel_data[i] == 24'hFFFFFF;
					  };
finish_item(req);
endtask

endclass

//%%%%%%%%%%%%%%%%% PIXEL_BLACK_SEQS %%%%%%%%%%%%%%%%%%%
class pixel_black_seqs extends dc_seqs;

  `uvm_object_utils(pixel_black_seqs)

  function new(string name = "pixel_black_seqs");
    super.new(name);
  endfunction

  task body();
    req = dc_xtn::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {req.resol          == NORMAL;
                               req.v_sync_cycles  == 10;
                               req.h_sync_cycles  == 10;
                               req.no_of_frames   == 2;
                              foreach (req.pixel_data[i])
                                req.pixel_data[i] == 24'h000000;
                               })
      `uvm_fatal("PIX_BLACK", "BLACK pixel sequence randomization failed")
    finish_item(req);
  endtask

endclass

//%%%%%%%%%%%%%%%%% PIXEL_RED_SEQS %%%%%%%%%%%%%%%%%%%
class pixel_red_seqs extends dc_seqs;

  `uvm_object_utils(pixel_red_seqs)

  function new(string name = "pixel_red_seqs");
    super.new(name);
  endfunction

  task body();
    req = dc_xtn::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {req.resol          == NORMAL;
                               req.v_sync_cycles  == 10;
                               req.h_sync_cycles  == 10;
                               req.no_of_frames   == 2;
                              foreach (req.pixel_data[i])
                               req.pixel_data[i] == 24'hFF0000;
                              })
      `uvm_fatal("PIX_RED", "Red pixel sequence randomization failed")
    finish_item(req);
  endtask

endclass

//%%%%%%%%%%%%%%%%% PIXEL_GREEN_SEQS %%%%%%%%%%%%%%%%%%%
class pixel_green_seqs extends dc_seqs;

  `uvm_object_utils(pixel_green_seqs)

  function new(string name = "pixel_green_seqs");
    super.new(name);
  endfunction

  task body();
    req = dc_xtn::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {req.resol          == NORMAL;
                               req.v_sync_cycles  == 10;
                               req.h_sync_cycles  == 10;
                               req.no_of_frames   == 2;
                              foreach (req.pixel_data[i])
                               req.pixel_data[i] == 24'h00FF00;
                              })
      `uvm_fatal("PIX_GREEN", "Green pixel sequence randomization failed")
    finish_item(req);
  endtask

endclass

//%%%%%%%%%%%%%%%%% PIXEL_BLUE_SEQS %%%%%%%%%%%%%%%%%%%
class pixel_blue_seqs extends dc_seqs;

  `uvm_object_utils(pixel_blue_seqs)

  function new(string name = "pixel_blue_seqs");
    super.new(name);
  endfunction

  task body();
    req = dc_xtn::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {req.resol          == NORMAL;
                               req.v_sync_cycles  == 10;
                               req.h_sync_cycles  == 10;
                               req.no_of_frames   == 2;
                              foreach (req.pixel_data[i])
                               req.pixel_data[i] == 24'h0000FF;
                              })
      `uvm_fatal("PIX_BLUE", "Blue pixel sequence randomization failed")
    finish_item(req);
  endtask

endclass

//%%%%%%%%%%%%%%%%% PIXEL_LOW_SEQS %%%%%%%%%%%%%%%%%%%
class pixel_low_seqs extends dc_seqs;

  `uvm_object_utils(pixel_low_seqs)

  function new(string name = "pixel_low_seqs");
    super.new(name);
  endfunction

  task body();
    req = dc_xtn::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {req.resol          == NORMAL;
                               req.v_sync_cycles  == 10;
                               req.h_sync_cycles  == 10;
                               req.no_of_frames   == 2;
                              foreach (req.pixel_data[i])
                                req.pixel_data[i] inside {[24'h000000:24'h00000F]};
                              })
      `uvm_fatal("PIX_LOW", "Low pixel sequence randomization failed")
    finish_item(req);
  endtask

endclass

//%%%%%%%%%%%%%%%%% PIXEL_HIGH_SEQS %%%%%%%%%%%%%%%%%%%
class pixel_high_seqs extends dc_seqs;

  `uvm_object_utils(pixel_high_seqs)

  function new(string name = "pixel_high_seqs");
    super.new(name);
  endfunction

  task body();
    req = dc_xtn::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {req.resol          == NORMAL;
                               req.v_sync_cycles  == 10;
                               req.h_sync_cycles  == 10;
                               req.no_of_frames   == 2;
                             foreach (req.pixel_data[i])
                                req.pixel_data[i] inside {[24'hFFFFF0:24'hFFFFFF]};
    })
      `uvm_fatal("PIX_HIGH", "High pixel sequence randomization failed")
    finish_item(req);
  endtask

endclass

//%%%%%%%%%%%%%%%%% RESOL_NORMAL_SEQS %%%%%%%%%%%%%%%%%%%
class resol_normal_seqs extends dc_seqs;

  `uvm_object_utils(resol_normal_seqs)

  function new(string name = "resol_normal_seqs");
    super.new(name);
  endfunction

  task body();
    req = dc_xtn::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {req.resol          == NORMAL;
                               req.v_sync_cycles  == 10;
                               req.h_sync_cycles  == 10;
                               req.no_of_frames   == 2;
                              })
      `uvm_fatal("RESOL_NORMAL", "RESOL_NORMAL pixel sequence randomization failed")
    finish_item(req);
  endtask

endclass

//%%%%%%%%%%%%%%%%% RESOL_HD_SEQS %%%%%%%%%%%%%%%%%%%
class resol_hd_seqs extends dc_seqs;

  `uvm_object_utils(resol_hd_seqs)

  function new(string name = "resol_hd_seqs");
    super.new(name);
  endfunction

  task body();
    req = dc_xtn::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {req.resol          == HD;
                               req.v_sync_cycles  == 10;
                               req.h_sync_cycles  == 10;
                               req.no_of_frames   == 2;
                              })
      `uvm_fatal("RESOL_HD", "RESOL_HD pixel sequence randomization failed")
    finish_item(req);
  endtask

endclass

//%%%%%%%%%%%%%%%%% RESOL_FULL_HD_SEQS %%%%%%%%%%%%%%%%%%%
class resol_fullhd_seqs extends dc_seqs;

  `uvm_object_utils(resol_fullhd_seqs)

  function new(string name = "resol_fullhd_seqs");
    super.new(name);
  endfunction

  task body();
    req = dc_xtn::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {req.resol          == FULL_HD;
                               req.v_sync_cycles  == 10;
                               req.h_sync_cycles  == 10;
                               req.no_of_frames   == 2;
                              })
      `uvm_fatal("RESOL_FULLHD", "RESOL_FULLHD pixel sequence randomization failed")
    finish_item(req);
  endtask

endclass

//%%%%%%%%%%%%%%%%% RESOL_VGA_SEQS %%%%%%%%%%%%%%%%%%%
class resol_vga_seqs extends dc_seqs;

  `uvm_object_utils(resol_vga_seqs)

  function new(string name = "resol_vga_seqs");
    super.new(name);
  endfunction

  task body();
    req = dc_xtn::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {req.resol          == VGA;
                               req.v_sync_cycles  == 10;
                               req.h_sync_cycles  == 10;
                               req.no_of_frames   == 2;
                              })
      `uvm_fatal("RESOL_VGA", "RESOL_VGA pixel sequence randomization failed")
    finish_item(req);
  endtask

endclass

//%%%%%%%%%%%%%%%%% RESOL_RAND_SEQS %%%%%%%%%%%%%%%%%%%
class resol_rand_seqs extends dc_seqs;

  `uvm_object_utils(resol_rand_seqs)

  function new(string name = "resol_rand_seqs");
    super.new(name);
  endfunction

  task body();
    req = dc_xtn::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {req.resol          == VGA;
                               req.v_sync_cycles  == 10;
                               req.h_sync_cycles  == 10;
                               req.no_of_frames   == 2;
                              })
      `uvm_fatal("RESOL_RAND", "RESOL_RAND pixel sequence randomization failed")
    finish_item(req);
  endtask

endclass

