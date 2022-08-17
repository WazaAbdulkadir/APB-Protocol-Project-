`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.08.2022 13:10:44
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define CLK @(posedge PCLK) 

module tb( );

parameter size = 7; 

logic PCLK;
logic PRESET_n;
    
logic [1:0] read_or_write; // 2'b00: NOP, 2'b01: READ, 2'b10: NOP, 2'b11: WRITE
    
logic PREADY_i;
logic [size:0]PREAD_i;
    
logic [size:0]PADDR_o;
logic [size:0]PWDATA_o;
logic PSEL_o;
logic PENABLE_o;
logic PWRITE_o;
 
 
 initial begin
 PCLK = 1'b0; 
 forever # 5 PCLK = ~PCLK;
 end 
apb_protocol_top dut (.PCLK(PCLK), .PRESET_n(PRESET_n) ,.read_or_write(read_or_write)); 

initial begin 
  
   PRESET_n = 1'b0;
   read_or_write = 2'b00;
 //  PREADY_i = 1'b0;
   repeat (2) `CLK;
   
   PRESET_n = 1'b1;
   repeat (2) `CLK; // 2 cycle 
   
   // initiate a read transaction
   read_or_write = 2'b01;
   `CLK;
   read_or_write = 2'b00;
   repeat (4) `CLK; 
  // PREADY_i = 1'B1;  
    
   // initiate a write transaction 
   read_or_write = 2'b11;
   `CLK;
//   add_i = 2'b00;
   repeat (4) `CLK; 
   
    $finish();
end 


endmodule
