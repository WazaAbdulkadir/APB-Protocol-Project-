`timescale 1ns / 1ps



module apb_slave_2
#(parameter [3:0] data_size = 7,
            address_size = 8)
(                input logic PCLK,
                 input logic PRESET_n,
                 input logic PSEL_i,
                 input logic PENABLE_i,
                 input logic PWRITE_i,
                 input logic [address_size:0] PADDR_i,
                 input logic [data_size:0] PWDATA_i,
                 
                 output logic [data_size:0] PRDATA2_o,
                 output logic PREADY_o 
                 );

logic [7:0] valid_addr;                  
logic [7:0] mem2 [0:255]; 
                 

          
assign PRDATA2_o = mem2[valid_addr]; 
          
integer i = 0;                
always_ff @(posedge PCLK or negedge PRESET_n) begin
    
    if (~PRESET_n) begin
        valid_addr = 8'b0;
        PREADY_o   = 1'b0;
         for (i = 0; i < 256 ; i ++) begin
            mem2[i] <= 8'b0;
        end 
        //PRDATA1_o  = 8'b0;
    end 
        
    else if (PSEL_i & !PENABLE_i & !PWRITE_i) begin
        
        PREADY_o = 1'b0;
    end 
    
    
    else if (PSEL_i & PENABLE_i & !PWRITE_i) begin
        valid_addr = PADDR_i;
        PREADY_o = 1'b1; 
    end 
    
    
    else if (PSEL_i & !PENABLE_i &PWRITE_i) begin
        PREADY_o = 1'b0; 
    end 
    
    else if (PSEL_i & PENABLE_i &PWRITE_i) begin
        mem2 [PADDR_i] = PWDATA_i; 
        PREADY_o = 1'b1;  
        
    end 
    
    else 
        PREADY_o = 1'b0;
end      
                 
endmodule

 
