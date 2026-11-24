interface ppi_if();
bit d_clk;
//OUTPUT
logic [7:0] ppi_data_lane0;
logic [7:0] ppi_data_lane1;
logic [7:0] ppi_data_lane2;
logic [7:0] ppi_data_lane3;
logic       ppi_lane0_en;
logic       ppi_lane1_en;
logic       ppi_lane2_en;
logic       ppi_lane3_en;

clocking ppi_mon_cb@(posedge d_clk);
default input #1 output #1;
input ppi_data_lane0, ppi_data_lane1,ppi_data_lane2,ppi_data_lane3,ppi_lane0_en,
ppi_lane1_en,ppi_lane2_en,ppi_lane3_en;
endclocking

modport ppi_mon_mp(clocking ppi_mon_cb);


/*
  // --------------------------------------------------
  // PPI_A2: Lane 0 data must be known when enabled
  // --------------------------------------------------
  property ppi_lane0_valid;
    @(posedge d_clk)
       (ppi_lane0_en === 1'b1) |-> (!$isunknown(ppi_data_lane0));
  endproperty

  PPI_A2: assert property (ppi_lane0_valid)
    else $error("PPI_A2: Lane 0 enabled with X/Z data");


  // --------------------------------------------------
  // PPI_A3: Lane 1 data must be known when enabled
  // --------------------------------------------------
  property ppi_lane1_valid;
    @(posedge d_clk)
       (ppi_lane1_en === 1'b1) |-> (!$isunknown(ppi_data_lane1));
  endproperty

  PPI_A3: assert property (ppi_lane1_valid)
    else $error("PPI_A3: Lane 1 enabled with X/Z data");


  // --------------------------------------------------
  // PPI_A4: Lane 2 data must be known when enabled
  // --------------------------------------------------
  property ppi_lane2_valid;
    @(posedge d_clk)
        (ppi_lane2_en === 1'b1)  |-> (!$isunknown(ppi_data_lane2));
  endproperty

  PPI_A4: assert property (ppi_lane2_valid)
    else $error("PPI_A4: Lane 2 enabled with X/Z data");


  // --------------------------------------------------
  // PPI_A5: Lane 3 data must be known when enabled
  // --------------------------------------------------
  property ppi_lane3_valid;
    @(posedge d_clk)
        (ppi_lane3_en === 1'b1) |-> (!$isunknown(ppi_data_lane3));
  endproperty

  PPI_A5: assert property (ppi_lane3_valid)
    else $error("PPI_A5: Lane 3 enabled with X/Z data");

  // --------------------------------------------------
  // Coverage: exercise all lane configurations
  // --------------------------------------------------
  PPI_C1: cover property (
    @(posedge d_clk)
    {ppi_lane3_en, ppi_lane2_en, ppi_lane1_en, ppi_lane0_en} == 4'b0001);

  PPI_C2: cover property (
    @(posedge d_clk)
    {ppi_lane3_en, ppi_lane2_en, ppi_lane1_en, ppi_lane0_en} == 4'b0011);

  PPI_C3: cover property (
    @(posedge d_clk)
    {ppi_lane3_en, ppi_lane2_en, ppi_lane1_en, ppi_lane0_en} == 4'b0111);

  PPI_C4: cover property (
    @(posedge d_clk) 
    {ppi_lane3_en, ppi_lane2_en, ppi_lane1_en, ppi_lane0_en} == 4'b1111);

*/

endinterface
