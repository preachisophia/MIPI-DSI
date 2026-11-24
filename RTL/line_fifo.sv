
// line_fifo: buffer one line of pixels into the flat payload bus; raise fifo_done at end-of-line.
module line_fifo (
  input                         pclk,
  input        [15:0]            WC,
  input        [23:0]            pixel_data,
  input                         data_valid,
  output reg [(dsi.FRAME_LENGTH*24)-1:0] payload,
  output reg                    fifo_done
);

  reg [23:0] payload_temp [0:dsi.FRAME_LENGTH-1];
  int i;  // pixel write index into payload_temp (0..FRAME_LENGTH-1)

  always @(posedge pclk) begin
    if (!data_valid) begin
      // idle / reset state
      i         <= 0;
      fifo_done <= 0;
    end
    else begin
      // capture pixels; i may legally reach FRAME_LENGTH-1 (payload_temp is [0:FRAME_LENGTH-1]).
      // Do NOT clamp to FRAME_LENGTH-1 or the last pixel of every line is dropped.
      if (i < dsi.FRAME_LENGTH) begin
        payload_temp[i] <= pixel_data;
        i <= i + 1;
      end
    end

    // end of line detection
    if (data_valid == 0 && i != 0) begin
      for (int j = 0; j < i; j++) begin
        payload[j*24 +: 24] <= {payload_temp[j][7:0], payload_temp[j][15:8], payload_temp[j][23:16]};  // DSI 8.8.23: R, G, B on the wire
      end
      fifo_done <= 1;
    end
  end

endmodule

