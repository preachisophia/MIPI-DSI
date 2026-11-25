class mipi_test extends uvm_test;

`uvm_component_utils(mipi_test)
env	e_h;
env_cfg	e_cfg;
dc_cfg	d_cfg;
ppi_cfg	p_cfg;

bit has_sb=1;
bit has_ahb_agt=1;
bit has_dc_agt=1;
bit has_ppi_agt=1;

ahb_seqs ahb_sqsh; 
dc_seqs  dc_sqsh;

function new(string name="mipi_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
e_cfg=env_cfg::type_id::create("e_cfg");
d_cfg=dc_cfg::type_id::create("d_cfg");
p_cfg=ppi_cfg::type_id::create("p_cfg");

ahb_sqsh=ahb_seqs::type_id::create("ahb_sqsh",this);
dc_sqsh=dc_seqs::type_id::create("dc_sqsh",this);

d_cfg.is_active=UVM_ACTIVE;
p_cfg.is_active=UVM_PASSIVE;

if(!uvm_config_db#(virtual dc_if)::get(this,"","dc_if",d_cfg.vif))
`uvm_fatal("TEST_FILE","DC_IF GETTING FAILD")
e_cfg.d_cfg=d_cfg;
if(!uvm_config_db#(virtual ppi_if)::get(this,"","ppi_if",p_cfg.vif))
`uvm_fatal("TEST_FILE","PPI_IF GETTING FAILD")
e_cfg.p_cfg=p_cfg;

e_cfg.has_sb=has_sb;
e_cfg.has_ahb_agt=has_ahb_agt;
e_cfg.has_dc_agt=has_dc_agt;
e_cfg.has_ppi_agt=has_ppi_agt;

uvm_config_db#(env_cfg)::set(this,"*","env_cfg",e_cfg);

e_h=env::type_id::create("e_h",this);
endfunction

function void end_of_elaboration_phase(uvm_phase phase);
super.end_of_elaboration_phase(phase);
uvm_top.print_topology();
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
//phase.raise_objection(this);
//fork
//ahb_sqsh.start(e_h.ahb_sqr);
//dc_sqsh.start(e_h.dc_agth.dc_sqrh);
//join
//#1000;
//phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& LANE_0_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class lane_0_test extends mipi_test;

`uvm_component_utils(lane_0_test)

ahb_seqs_lane_0 ahb_sqsh_l0; 
resol_normal_seqs         dc_sqsh;

function new(string name="lane_0_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l0=ahb_seqs_lane_0::type_id::create("ahb_sqsh_l0",this);
dc_sqsh=resol_normal_seqs::type_id::create("dc_sqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l0.start(e_h.ahb_sqr);
dc_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& LANE_1_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class lane_1_test extends mipi_test;

`uvm_component_utils(lane_1_test)

ahb_seqs_lane_1 ahb_sqsh_l1; 
resol_normal_seqs         dc_sqsh;

function new(string name="lane_1_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l1=ahb_seqs_lane_1::type_id::create("ahb_sqsh_l1",this);
dc_sqsh=resol_normal_seqs::type_id::create("dc_sqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l1.start(e_h.ahb_sqr);
dc_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& LANE_2_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class lane_2_test extends mipi_test;

`uvm_component_utils(lane_2_test)

ahb_seqs_lane_2 ahb_sqsh_l2; 
resol_normal_seqs         dc_sqsh;

function new(string name="lane_2_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l2=ahb_seqs_lane_2::type_id::create("ahb_sqsh_l2",this);
dc_sqsh    =resol_normal_seqs::type_id::create("dc_sqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l2.start(e_h.ahb_sqr);
dc_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& LANE_3_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class lane_3_test extends mipi_test;

`uvm_component_utils(lane_3_test)

ahb_seqs_lane_3 ahb_sqsh_l3; 
resol_normal_seqs        dc_sqsh;

function new(string name="lane_3_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l3=ahb_seqs_lane_3::type_id::create("ahb_sqsh_l3",this);
dc_sqsh=resol_normal_seqs::type_id::create("dc_sqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l3.start(e_h.ahb_sqr);
dc_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& FRAME_5_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class dsi_frame5_test extends mipi_test;

`uvm_component_utils(dsi_frame5_test)

ahb_dsireg_seqs   ahb_sqsh;
frame_5_seqs      dsi_sqsh; 

function new(string name="pixel_black_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh   =ahb_dsireg_seqs::type_id::create("ahb_sqsh",this);
dsi_sqsh   =frame_5_seqs::type_id::create("dsi_sqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh.start(e_h.ahb_sqr);
dsi_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& FRAME_10_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class frame_10_test extends mipi_test;

`uvm_component_utils(frame_10_test)

ahb_seqs_lane_3 ahb_sqsh_l3; 
frame_10_seqs    f10_sqsh;

function new(string name="frame_10_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l3=ahb_seqs_lane_3::type_id::create("ahb_sqsh_l3",this);
f10_sqsh   =frame_10_seqs::type_id::create("f10_sqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l3.start(e_h.ahb_sqr);
f10_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& VSYNC_RANDOM_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class vsync_random_test extends mipi_test;

`uvm_component_utils(vsync_random_test)

ahb_seqs_lane_3    ahb_sqsh_l3; 
vsync_random_seqs  vrand_sqsh;

function new(string name="vsync_random_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l3 =ahb_seqs_lane_3::type_id::create("ahb_sqsh_l3",this);
vrand_sqsh  =vsync_random_seqs::type_id::create("vrand_sqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l3.start(e_h.ahb_sqr);
vrand_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& VSYNC_5_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class vsync_5_test extends mipi_test;

`uvm_component_utils(vsync_5_test)

ahb_seqs_lane_3 ahb_sqsh_l3; 
vsync_5_seqs    v5_sqsh;

function new(string name="vsync_5_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l3=ahb_seqs_lane_3::type_id::create("ahb_sqsh_l3",this);
v5_sqsh   =vsync_5_seqs::type_id::create("v5_sqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l3.start(e_h.ahb_sqr);
v5_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& VSYNC_10_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class vsync_10_test extends mipi_test;

`uvm_component_utils(vsync_10_test)

ahb_seqs_lane_3 ahb_sqsh_l3; 
vsync_10_seqs    v10_sqsh;

function new(string name="vsync_10_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l3=ahb_seqs_lane_3::type_id::create("ahb_sqsh_l3",this);
v10_sqsh   =vsync_10_seqs::type_id::create("v10_sqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l3.start(e_h.ahb_sqr);
v10_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& PIXEL_RANDOM_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class pixel_random_test extends mipi_test;

`uvm_component_utils(pixel_random_test)

ahb_seqs_lane_3      ahb_sqsh_l3; 
pixel_random_seqs    pixrand_sqsh;

function new(string name="pixel_random_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l3  =ahb_seqs_lane_3::type_id::create("ahb_sqsh_l3",this);
pixrand_sqsh =pixel_random_seqs::type_id::create("pixrand_sqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l3.start(e_h.ahb_sqr);
pixrand_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& PIXEL_WHITE_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class pixel_white_test extends mipi_test;

`uvm_component_utils(pixel_white_test)

ahb_seqs_lane_3      ahb_sqsh_l3; 
pixel_white_seqs     white_sqsh;

function new(string name="pixel_white_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l3  =ahb_seqs_lane_3::type_id::create("ahb_sqsh_l3",this);
white_sqsh   =pixel_white_seqs::type_id::create("white_sqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l3.start(e_h.ahb_sqr);
white_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& PIXEL_BLACK_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class pixel_black_test extends mipi_test;

`uvm_component_utils(pixel_black_test)

ahb_seqs_lane_3      ahb_sqsh_l3; 
pixel_black_seqs     black_sqsh;

function new(string name="pixel_black_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l3  =ahb_seqs_lane_3::type_id::create("ahb_sqsh_l3",this);
black_sqsh   =pixel_black_seqs::type_id::create("black_sqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l3.start(e_h.ahb_sqr);
black_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& PIXEL_RED_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class pixel_red_test extends mipi_test;

`uvm_component_utils(pixel_red_test)

ahb_seqs_lane_3    ahb_sqsh_l3; 
pixel_red_seqs     red_sqsh;

function new(string name="pixel_red_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l3 =ahb_seqs_lane_3::type_id::create("ahb_sqsh_l3",this);
red_sqsh    =pixel_red_seqs::type_id::create("red_sqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l3.start(e_h.ahb_sqr);
red_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& PIXEL_GREEN_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class pixel_green_test extends mipi_test;

`uvm_component_utils(pixel_green_test)

ahb_seqs_lane_3      ahb_sqsh_l3; 
pixel_green_seqs     green_sqsh;

function new(string name="pixel_green_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l3  =ahb_seqs_lane_3::type_id::create("ahb_sqsh_l3",this);
green_sqsh   =pixel_green_seqs::type_id::create("green_sqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l3.start(e_h.ahb_sqr);
green_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& PIXEL_BLUE_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class pixel_blue_test extends mipi_test;

`uvm_component_utils(pixel_blue_test)

ahb_seqs_lane_3     ahb_sqsh_l3; 
pixel_blue_seqs     blue_sqsh;

function new(string name="pixel_blue_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l3  =ahb_seqs_lane_3::type_id::create("ahb_sqsh_l3",this);
blue_sqsh    =pixel_blue_seqs::type_id::create("blue_sqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l3.start(e_h.ahb_sqr);
blue_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& PIXEL_LOW_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class pixel_low_test extends mipi_test;

`uvm_component_utils(pixel_low_test)

ahb_seqs_lane_3      ahb_sqsh_l3; 
pixel_low_seqs       pixlow_sqsh;

function new(string name="pixel_low_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l3  =ahb_seqs_lane_3::type_id::create("ahb_sqsh_l3",this);
pixlow_sqsh  =pixel_low_seqs::type_id::create("pixlow_sqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l3.start(e_h.ahb_sqr);
pixlow_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& PIXEL_HIGH_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class pixel_high_test extends mipi_test;

`uvm_component_utils(pixel_high_test)

ahb_seqs_lane_3      ahb_sqsh_l3; 
pixel_high_seqs      pixhigh_sqsh;

function new(string name="pixel_high_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l3  =ahb_seqs_lane_3::type_id::create("ahb_sqsh_l3",this);
pixhigh_sqsh =pixel_high_seqs::type_id::create("pixhigh_sqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l3.start(e_h.ahb_sqr);
pixhigh_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& RESOL_RANDOM_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class resol_random_test extends mipi_test;

`uvm_component_utils(resol_random_test)

ahb_seqs_lane_3      ahb_sqsh_l3; 
resol_rand_seqs    resrand_sqsh;

function new(string name="resol_random_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l3  =ahb_seqs_lane_3::type_id::create("ahb_sqsh_l3",this);
resrand_sqsh =resol_rand_seqs::type_id::create("resrand_sqsh",this);
ahb_sqsh_l3.set_pixels_per_line(640);  // dsi_lng = WC for one 640-pixel line
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l3.start(e_h.ahb_sqr);
resrand_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#10000;  // last line needs ~5us on 4 lanes at FULL_HD
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& RESOL_NORMAL_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class resol_normal_test extends mipi_test;

`uvm_component_utils(resol_normal_test)

ahb_seqs_lane_3      ahb_sqsh_l3; 
resol_normal_seqs    resnml_sqsh;

function new(string name="resol_normal_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l3  =ahb_seqs_lane_3::type_id::create("ahb_sqsh_l3",this);
resnml_sqsh  =resol_normal_seqs::type_id::create("resnml_sqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l3.start(e_h.ahb_sqr);
resnml_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& RESOL_HD_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class resol_hd_test extends mipi_test;

`uvm_component_utils(resol_hd_test)

ahb_seqs_lane_3      ahb_sqsh_l3; 
resol_hd_seqs        reshd_sqsh;

function new(string name="resol_hd_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l3  =ahb_seqs_lane_3::type_id::create("ahb_sqsh_l3",this);
reshd_sqsh   =resol_hd_seqs::type_id::create("reshd_sqsh",this);
ahb_sqsh_l3.set_pixels_per_line(1280);  // dsi_lng = WC for one 1280-pixel line
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l3.start(e_h.ahb_sqr);
reshd_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#10000;  // last line needs ~5us on 4 lanes at FULL_HD
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& RESOL_FULLHD_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class resol_fullhd_test extends mipi_test;

`uvm_component_utils(resol_fullhd_test)

ahb_seqs_lane_3      ahb_sqsh_l3; 
resol_fullhd_seqs        resfhd_sqsh;

function new(string name="resol_fullhd_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l3  =ahb_seqs_lane_3::type_id::create("ahb_sqsh_l3",this);
resfhd_sqsh  =resol_fullhd_seqs::type_id::create("resfhd_sqsh",this);
ahb_sqsh_l3.set_pixels_per_line(1920);  // dsi_lng = WC for one 1920-pixel line
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l3.start(e_h.ahb_sqr);
resfhd_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#10000;  // last line needs ~5us on 4 lanes at FULL_HD
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& RESOL_VGA_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class resol_vga_test extends mipi_test;

`uvm_component_utils(resol_vga_test)

ahb_seqs_lane_3      ahb_sqsh_l3; 
resol_vga_seqs       resvga_sqsh;

function new(string name="resol_vga_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_sqsh_l3  =ahb_seqs_lane_3::type_id::create("ahb_sqsh_l3",this);
resvga_sqsh  =resol_vga_seqs::type_id::create("resvga_sqsh",this);
ahb_sqsh_l3.set_pixels_per_line(640);  // dsi_lng = WC for one 640-pixel line
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_sqsh_l3.start(e_h.ahb_sqr);
resvga_sqsh.start(e_h.dc_agth.dc_sqrh);
join
#10000;  // last line needs ~5us on 4 lanes at FULL_HD
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& REG_PAYLOAD_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class ahb_payloadreg_test extends mipi_test;

`uvm_component_utils(ahb_payloadreg_test)

ahb_payloadreg_seqs  ahb_seqsh; 

function new(string name="ahb_payloadreg_seqs",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_seqsh    =ahb_payloadreg_seqs::type_id::create("ahb_seqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_seqsh.start(e_h.ahb_sqr);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& REG_DSICMD_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class ahb_dsicmdreg_test extends mipi_test;

`uvm_component_utils(ahb_dsicmdreg_test)

ahb_dsicmdreg_seqs  ahb_seqsh; 

function new(string name="ahb_dsicmdreg_seqs",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_seqsh    =ahb_dsicmdreg_seqs::type_id::create("ahb_seqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_seqsh.start(e_h.ahb_sqr);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& REG_DSILNG_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class ahb_dsilngreg_test extends mipi_test;

`uvm_component_utils(ahb_dsilngreg_test)

ahb_dsilngreg_seqs  ahb_seqsh; 

function new(string name="ahb_dsilngreg_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_seqsh    =ahb_dsilngreg_seqs::type_id::create("ahb_seqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_seqsh.start(e_h.ahb_sqr);
join
#1000;
phase.drop_objection(this);
endtask

endclass

//&&&&&&&&&&&&&&&&&&&&&&&& REG_CTRL0_TEST &&&&&&&&&&&&&&&&&&&&&&&&&
class ahb_ctrl0reg_test extends mipi_test;

`uvm_component_utils(ahb_ctrl0reg_test)

ahb_dsictrl0reg_seqs  ahb_seqsh; 

function new(string name="ahb_ctrl0reg_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ahb_seqsh    =ahb_dsictrl0reg_seqs::type_id::create("ahb_seqsh",this);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);
fork
ahb_seqsh.start(e_h.ahb_sqr);
join
#1000;
phase.drop_objection(this);
endtask

endclass
