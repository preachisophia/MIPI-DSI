
// Code your design here
`include "dsi_reg_block.sv"
`include "dsi_clk_gen.sv"
`include "line_fifo.sv"
`include "ecc_gen.sv"
`include "crc_gen.sv"
`include "packetizer.sv"
`include "lane_manager.sv"
//                            payload,  dsi_cmd,    dsi_lng,     dsi_ctrl0,   dsi_ctrl1;
parameter [31:0]addr[13]={'h4000_0000,'h4000_0004, 'h4000_0008, 'h4000_000C, 'h4000_0010, 'h4000_0014, 'h4000_0018, 'h4000_001C, 'h4000_0020, 'h4000_0024, 'h4000_0028, 'h4000_002C, 'h4000_0030};
// dsi: MIPI DSI TX top — AHB reg block + line_fifo -> ecc/crc -> packetizer -> lane_manager.
module dsi#(FRAME_LENGTH=1280, FRAME_DEPTH=720)
  		(input	[31:0]		haddr,
  		input			hwrite, 
           	input	[2:0]		hsize,   
           	input	[2:0]		hburst,
           	input	[1:0]		htrans,
           	input	[31:0]		hwdata,
           	input	[3:0]		hprot,
           	output	reg [1:0]	hresp,
  		output	reg		hready,
		output  reg [31:0] 	hrdata,
           
           	input 	[23:0] 		pixel_data,
  		input			data_valid,
  		input			hsync,
  	        input			vsync,
           
            input			pclk,
            output	reg		dsi_clk,
            input			dsi_rst,
            output	reg [7:0]	ppi_data_lane0,
            output	reg [7:0]	ppi_data_lane1,
            output	reg [7:0]	ppi_data_lane2,
            output	reg [7:0]	ppi_data_lane3,
            output	reg		ppi_lane0_en,
            output	reg		ppi_lane1_en,
            output	reg		ppi_lane2_en,
            output	reg		ppi_lane3_en);
  
  assign hready = 1;
  
  reg [7:0]  ecc;
  reg [15:0] crc;
  reg [31:0] header;
  reg [15:0] WC;

  reg fifo_done;
  reg ecc_done;
  reg crc_done;
  reg packet_done;
  reg lane_done;
  
  dsi_reg_block dsi_reg;
  
  initial begin
    dsi_reg=new();
  end
  
  reg [(FRAME_LENGTH*24)-1:0] payload;
  reg [FRAME_LENGTH*24+80-1:0] long_packet;
  reg [63:0] short_packet;
  
  dsi_clk_gen gen_dsi_clk (.pclk(pclk),
                           .dsi_clk(dsi_clk)
                 		  );
  
  line_fifo gen_payload(.pclk(pclk),
                        .WC(WC),
                        .pixel_data(pixel_data),
                        .data_valid(data_valid),
                        //.reg_done(reg_done),
                        .payload(payload),
                        .fifo_done(fifo_done)
                		);

  ecc_gen gen_ecc(.dsi_clk(dsi_clk),
                  .payload(payload),
                  .fifo_done(fifo_done),
                  .ecc(ecc),
                  .ecc_done(ecc_done)
             	  );
  
  crc_gen gen_crc(.dsi_clk(dsi_clk),
                  .payload(payload),
                  .fifo_done(fifo_done),
                  .crc(crc),
                  .crc_done(crc_done)
             	  );
  
  packetizer packet(.dsi_clk(dsi_clk),
                    .WC(WC),
                    .payload(payload),
                    .ecc(ecc),
                    .crc(crc),
                    .fifo_done(fifo_done),
                    .ecc_done(ecc_done),
                    .crc_done(crc_done),
                    .short_packet(short_packet),
                    .long_packet(long_packet),
                    .packet_done(packet_done)
                 	);
  
  lane_manager lane_manage (.dsi_clk(dsi_clk),
               				.short_packet(short_packet),
               				.long_packet(long_packet),
                            .packet_done(packet_done),
               				.ppi_data_lane0(ppi_data_lane0),
               				.ppi_data_lane1(ppi_data_lane1),
               				.ppi_data_lane2(ppi_data_lane2),
                            .ppi_data_lane3(ppi_data_lane3),
                            .lane_done(lane_done)
               				);
  // AHB slave: address/control are sampled in the address phase; HWDATA is only valid in the
  // following data phase, so the write is done one cycle later from the registered address.
  reg [31:0] haddr_q;
  reg        wr_q;

  always@(posedge pclk or negedge dsi_rst)
    begin
      if(~dsi_rst) begin
//***************************************************
//    Uncomment the below lines for front door access
//***************************************************
        dsi_reg.payload		= 0;
        dsi_reg.dsi_cmd		= 0;
        dsi_reg.dsi_lng		= 0;
        dsi_reg.dsi_ctrl0	= 0;
        dsi_reg.dsi_ctrl1	= 0;
        dsi_reg.dsi_ctrl2	= 0;
        dsi_reg.dsi_ctrl3	= 0;
        dsi_reg.dsi_ctrl4	= 0;
        dsi_reg.dsi_ctrl5	= 0;
        dsi_reg.rx_cmd_data = 0;
        dsi_reg.rx_cmd		= 0;
        dsi_reg.rd_cmd_wc   = 0;
        dsi_reg.rd_cmd_err  = 0;
	hresp = 0;  // AHB OKAY out of reset
        hrdata  = 0;
        haddr_q = 0;
        wr_q    = 0;
      end
      else begin
        hresp <= 0;
        // data phase of a write
        if(wr_q) begin
          case(haddr_q)  // one register per word, in the order listed above addr[]; rd_cmd_err is read-only
            addr[0]: dsi_reg.payload	<= hwdata;
            addr[1]: dsi_reg.dsi_cmd	<= hwdata;
            addr[2]: dsi_reg.dsi_lng	<= hwdata;
            addr[3]: dsi_reg.dsi_ctrl0	<= hwdata;
            addr[4]: dsi_reg.dsi_ctrl1	<= hwdata;
            addr[5]: dsi_reg.dsi_ctrl2	<= hwdata;
            addr[6]: dsi_reg.dsi_ctrl3	<= hwdata;
            addr[7]: dsi_reg.dsi_ctrl4	<= hwdata;
            addr[8]: dsi_reg.dsi_ctrl5	<= hwdata;
            addr[9]: dsi_reg.rx_cmd_data	<= hwdata;
            addr[10]: dsi_reg.rx_cmd	<= hwdata;
            addr[11]: dsi_reg.rd_cmd_wc	<= hwdata;
          endcase
        end
        // address phase of a read: drive HRDATA for the data phase
        if(htrans[1] && hready && !hwrite) begin
          if(wr_q && haddr_q == haddr)
            hrdata <= hwdata;  // read straight after a write to the same register
          else
            case(haddr)
              addr[0]: hrdata <= dsi_reg.payload;
              addr[1]: hrdata <= dsi_reg.dsi_cmd;
              addr[2]: hrdata <= dsi_reg.dsi_lng;
              addr[3]: hrdata <= dsi_reg.dsi_ctrl0;
              addr[4]: hrdata <= dsi_reg.dsi_ctrl1;
              addr[5]: hrdata <= dsi_reg.dsi_ctrl2;
              addr[6]: hrdata <= dsi_reg.dsi_ctrl3;
              addr[7]: hrdata <= dsi_reg.dsi_ctrl4;
              addr[8]: hrdata <= dsi_reg.dsi_ctrl5;
              addr[9]: hrdata <= dsi_reg.rx_cmd_data;
              addr[10]: hrdata <= dsi_reg.rx_cmd;
              addr[11]: hrdata <= dsi_reg.rd_cmd_wc;
              addr[12]: hrdata <= dsi_reg.rd_cmd_err;
	    //default : begin hresp <= 1; end
            endcase
        end
        wr_q    <= htrans[1] && hready && hwrite;
        haddr_q <= haddr;
      end
    end
  

//         @(posedge dsi_clk);
//         fifo_done=0; 
//         ecc_done=0;
//         crc_done=0;
//         packet_done=0;
//         lane_done=0;
//       end
//     end
endmodule



      
     



