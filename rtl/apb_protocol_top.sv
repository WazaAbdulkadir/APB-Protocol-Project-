`timescale 1ns / 1ps


module apb_protocol_top
  #(parameter  data_size = 7, 
                 address_size = 8) 

(
    input logic PCLK,
    input logic PRESET_n, 
    input logic [1:0] read_or_write, // 2'b00: NOP, 2'b01: READ, 2'b10: NOP, 2'b11: WRITE 
    
    output logic [7:0] data_o
);

logic PREADY;
logic [data_size:0]PRDATA;
    
logic [address_size:0]PADDR;
logic [data_size:0]PWDATA;
    
    
//output logic PSEL_o,
logic PSEL1;
logic PSEL2;
    
logic PENABLE;
logic PWRITE;

logic PREADY1;
logic PREADY2;

logic [7:0]PRDATA1;
logic [7:0]PRDATA2; 

logic PEANBLE1,PEANBLE2;

assign PEANBLE1 = PADDR[8] ? (PENABLE ? 1'b1 : 1'b0) : 1'b0;
assign PEANBLE2 = ~PADDR[8] ? (PENABLE ? 1'b1 : 1'b0) : 1'b0;
assign PREADY = PADDR[8] ? PREADY1 :  PREADY2 ;

//assign PRDATA = (add_i[0] == 1'b1) ? ((PADDR[8] == 1)  ? PRDATA1 : PRDATA2) : 8'h0;  
//assign PRDATA = (add_i[0] == 1'b1) ? PRDATA1  : 8'h0;  
assign PRDATA = PRDATA1  ;



master master_inst          (.PSEL1_o(PSEL1), .PSEL2_o(PSEL2),.PCLK(PCLK), .PRESET_n(PRESET_n), .read_or_write(read_or_write),
                             .PREADY_i(PREADY), .PREAD_i(PRDATA),.PADDR_o(PADDR), .PWDATA_o(PWDATA),.PENABLE_o(PENABLE),
                             .PWRITE_o(PWRITE),
                             .data_o(data_o) );

apb_slave apb_slave_1_inst  (.PSEL_i(PSEL1), .PCLK(PCLK), .PRESET_n(PRESET_n),.PENABLE_i(PEANBLE1),.PWRITE_i(PWRITE),
                             .PADDR_i(PADDR), .PWDATA_i(PWDATA),.PRDATA1_o(PRDATA1), .PREADY_o(PREADY1)) ;

apb_slave_2 apb_slave_2_inst(.PSEL_i(PSEL2), .PCLK(PCLK), .PRESET_n(PRESET_n), .PENABLE_i(PEANBLE2),.PWRITE_i(PWRITE),
                             .PADDR_i(PADDR), .PWDATA_i(PWDATA),.PRDATA2_o(PRDATA2), .PREADY_o(PREADY2)) ;

endmodule
