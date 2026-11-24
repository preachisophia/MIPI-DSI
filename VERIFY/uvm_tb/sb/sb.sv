class sb extends uvm_scoreboard;
`uvm_component_utils(sb)

uvm_tlm_analysis_fifo #(dc_xtn)  dc_fifo;
uvm_tlm_analysis_fifo #(ppi_xtn) ppi_fifo;
dc_xtn  d_xh,cov_xh;
ppi_xtn p_xh;

int  byte_cnt    = 0;
int  payload_cnt = 0;

bit [7:0]  byte_q;
bit [7:0]  header_byte_q[$];
bit [7:0]  payload_byte_q_q[$];
bit [23:0] ppi_pixel_q[$];
bit [23:0] dc_pixel_q[$];

bit long_packet_started;
int trailer_cnt;  // long-packet trailer bytes still to consume: CRC LSB, CRC MSB, FF, BB

int payload_expected;

int unsigned match_cnt;
int unsigned mismatch_cnt;

int unsigned dc_cnt;
int unsigned ppi_cnt;
bit [23:0] pixel_data_cov;

covergroup dc_cg;
option.per_instance=1;
CP_DATA_VALID : coverpoint d_xh.data_valid 
				{
				 bins INVALID = {0};
				 bins VALID   = {1};
				}
CP_VSYNC : coverpoint d_xh.vsync
				{				
				 bins HIGH = {1};
				 bins LOW  = {0};
				}
CP_HSYNC : coverpoint d_xh.hsync
				{
				 bins HIGH = {1};
				 bins LOW  = {0};
				}
CP_PIXEL_DATA : coverpoint d_xh.pixel_data_quemon				
				{
				 bins ZERO       = {24'h000000};
				 bins MAX        = {24'hFFFFFF};
				 bins RANGE      = {[24'h000001 : 24'hFFFFFE]};
				}
CROSS_VSYNC_HSYNC: cross CP_VSYNC,CP_HSYNC;

endgroup

covergroup ppi_cg;
option.per_instance=1;
CP_LANE0_EN : coverpoint p_xh.ppi_lane0_en 
				{
				 bins DISABLED = {0};
				 bins ENABLED  = {1};
				}
CP_LANE1_EN : coverpoint p_xh.ppi_lane1_en 
				{
				 bins DISABLED = {0};
				 bins ENABLED  = {1};
				}
CP_LANE2_EN : coverpoint p_xh.ppi_lane2_en 
				{
				 bins DISABLED = {0};
				 bins ENABLED  = {1};
				}
CP_LANE3_EN : coverpoint p_xh.ppi_lane3_en 
				{
				 bins DISABLED = {0};
				 bins ENABLED  = {1};
				}	
endgroup

function new(string name="sb",uvm_component parent);
    super.new(name,parent);
    dc_cg =new();
    ppi_cg=new();    
endfunction

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    dc_fifo  = new("dc_fifo",this);
    ppi_fifo = new("ppi_fifo",this);
endfunction

task run_phase(uvm_phase phase);
fork
begin
    forever
    begin
        dc_fifo.get(d_xh);
        dc_cnt++;
	    dc_cg.sample();	    
        `uvm_info("SB_DC",$sformatf("Received DC Transaction DC_PIXEL DATAS=%0p",d_xh.pixel_data_quemon),UVM_MEDIUM)
	    if(d_xh.data_valid)
            dc_pixel_q.push_back(d_xh.pixel_data_quemon);
            `uvm_info("SB_DC_PIXEL",$sformatf("DC Pixel = %0h",d_xh.pixel_data_quemon),UVM_MEDIUM)
    end
end

begin
    forever
    begin
        ppi_fifo.get(p_xh);
        ppi_cnt++;
	ppi_cg.sample();
//        `uvm_info("SB_PPI",$sformatf("Received PPI Transaction %0d\n%s",ppi_cnt,p_xh.sprint()),UVM_MEDIUM)
        if(p_xh.ppi_lane0_en)
            process_byte_q(p_xh.ppi_data_lane0);
        if(p_xh.ppi_lane1_en)
            process_byte_q(p_xh.ppi_data_lane1);
        if(p_xh.ppi_lane2_en)
            process_byte_q(p_xh.ppi_data_lane2);
        if(p_xh.ppi_lane3_en)
            process_byte_q(p_xh.ppi_data_lane3);
    end
end
join
endtask

task process_byte_q(bit [7:0] rx_byte);

    bit [31:0] rx_header;
    bit [15:0] wc;

    // LONG PACKET TRAILER : CRC (2 bytes), FF, BB - consumed so a CRC byte of AA is not taken as a packet start
    if (trailer_cnt > 0)
    begin
        trailer_cnt--;
        if (trailer_cnt == 1 && rx_byte != 8'hFF)
            `uvm_error("SB_PACKET",$sformatf("Expected FF after CRC, got %02h",rx_byte))
        if (trailer_cnt == 0 && rx_byte != 8'hBB)
            `uvm_error("SB_PACKET",$sformatf("Expected BB at end of long packet, got %02h",rx_byte))
        return;
    end

    // WAITING FOR PACKET START : AA
    if (!long_packet_started)
    begin
        if (rx_byte == 8'hAA)
        begin
            long_packet_started = 1;

            byte_cnt         = 0;
            payload_cnt      = 0;
            payload_expected = 0;

            header_byte_q.delete();
            payload_byte_q_q.delete();

            `uvm_info("SB_PACKET","LONG PACKET START : AA detected",UVM_MEDIUM)
        end
    end
    // PACKET PROCESSING
    else
    begin

        byte_cnt++;

        // FF AFTER AA
        if (byte_cnt == 1)
        begin
            if (rx_byte == 8'hFF)
            begin
                `uvm_info("SB_PACKET","FF after AA detected",UVM_MEDIUM)
            end
            else
            begin
                `uvm_error("SB_PACKET",$sformatf("Expected FF after AA, got %02h",rx_byte))
            end
        end
        // HEADER : 4 BYTES
        else if ((byte_cnt >= 2) && (byte_cnt <= 5))
        begin
            header_byte_q.push_back(rx_byte);

            `uvm_info("SB_HEADER",$sformatf("HEADER BYTE[%0d] = %02h",byte_cnt - 2,rx_byte),UVM_MEDIUM)

            if (header_byte_q.size() == 4)
            begin
                rx_header = {header_byte_q[3],header_byte_q[2],header_byte_q[1],header_byte_q[0]};
                wc = rx_header[23:8];
                payload_expected = wc;

                `uvm_info("SB_HEADER",$sformatf("HEADER = %08h WC = %0d",rx_header,payload_expected),UVM_MEDIUM)
            end
        end
        // PAYLOAD
        else if (payload_cnt < payload_expected)
        begin

            payload_byte_q_q.push_back(rx_byte);
            payload_cnt++;

            `uvm_info("SB_PAYLOAD",$sformatf("PAYLOAD BYTE[%0d] = %02h",payload_cnt - 1,rx_byte),UVM_MEDIUM)
            // 3 BYTES = 1 PIXEL
            if (payload_byte_q_q.size() == 3)
            begin

                bit [7:0] b0;
                bit [7:0] b1;
                bit [7:0] b2;

                bit [23:0] pixel;

                b0 = payload_byte_q_q.pop_front();
                b1 = payload_byte_q_q.pop_front();
                b2 = payload_byte_q_q.pop_front();

                pixel = {b0, b1, b2};  // DSI 8.8.23: wire order is R, G, B; pixel_data is {R,G,B}

                ppi_pixel_q.push_back(pixel);

                `uvm_info("SB_PPI_PIXEL",$sformatf("PPI PIXEL[%0d] = %06h",ppi_pixel_q.size()-1,pixel),UVM_MEDIUM)

                drain_compare();
            end

            // LAST PAYLOAD BYTE RECEIVED
            if (payload_cnt == payload_expected)
            begin
                `uvm_info("SB_PACKET",$sformatf("PAYLOAD COMPLETE : %0d bytes received",payload_cnt),UVM_MEDIUM)
                // Reset packet state
                long_packet_started = 0;
                trailer_cnt         = 4;

                byte_cnt         = 0;
                payload_cnt      = 0;
                payload_expected = 0;

                header_byte_q.delete();
                payload_byte_q_q.delete();

                `uvm_info("SB_PACKET","PACKET STATE RESET - WAITING FOR NEXT AA",UVM_MEDIUM)
            end
        end
    end

endtask

task drain_compare();
    while(dc_pixel_q.size() > 0 && ppi_pixel_q.size() > 0)
    begin
        bit [23:0] dc_pix;
        bit [23:0] ppi_pix;

        dc_pix  = dc_pixel_q.pop_front();
        ppi_pix = ppi_pixel_q.pop_front();
        // Compare
        if(dc_pix == ppi_pix)
        begin
            match_cnt++;
          `uvm_info("SB_MATCH",$sformatf("\nMATCH[%0d]\nDC Pixel = %06h\nPPI Pixel = %06h",match_cnt, dc_pix, ppi_pix),UVM_LOW)
        end

        else
        begin
            mismatch_cnt++;
          `uvm_error("SB_COMPARE",$sformatf("\nMISMATCH[%0d]\nExpected(DC) = %06h\nActual(PPI) = %06h",mismatch_cnt, dc_pix, ppi_pix))
        end
          `uvm_info("SB_COMPARE_SIZE",$sformatf("SIZE OF DC=%0d PPI=%0d",dc_pixel_q.size(),ppi_pixel_q.size()),UVM_MEDIUM)
    end
endtask

function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (dc_pixel_q.size() != 0 || ppi_pixel_q.size() != 0)
      `uvm_error("SB_PENDING",$sformatf("%0d DC and %0d PPI pixels were never compared",dc_pixel_q.size(),ppi_pixel_q.size()))
endfunction

function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    $display("\n========================================");
    $display("           SCOREBOARD REPORT              ");
    $display("========================================");
    $display("DC Transactions        : %0d", dc_cnt);
    $display("PPI Transactions       : %0d", ppi_cnt);
    $display("Matched Pixels         : %0d", match_cnt);
    $display("Mismatched Pixels      : %0d", mismatch_cnt);
    $display("Pending DC Pixels      : %0d", dc_pixel_q.size());
    $display("Pending PPI Pixels     : %0d", ppi_pixel_q.size());
    $display("----------------------------------------");
    $display("DC  FUNCTIONAL COVERAGE: %0.2f%%", dc_cg.get_coverage());
    $display("DC  FUNCTIONAL COVERAGE DATA_VALID: %0.2f%%", dc_cg.CP_DATA_VALID.get_coverage());
    $display("PPI FUNCTIONAL COVERAGE: %0.2f%%", ppi_cg.get_coverage());
    $display("----------------------------------------");
    $display("========================================");
endfunction

endclass
