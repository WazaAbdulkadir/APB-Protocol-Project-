`timescale 1ns / 1ps



module master 
    #(parameter [3:0] data_size = 7, 
                 address_size = 8) 
    
  (
    input logic PCLK,
    input logic PRESET_n,
    
    input logic [1:0] read_or_write, // 2'b00: NOP, 2'b01: READ, 2'b10: NOP, 2'b11: WRITE
    
    input logic PREADY_i,
    input logic [data_size:0]PREAD_i,
    
    output logic [address_size:0]PADDR_o,
    output logic [data_size:0]PWDATA_o,
    
    
    //output logic PSEL_o,
    output logic PSEL1_o,
    output logic PSEL2_o,
    
    output logic PENABLE_o,
    output logic PWRITE_o,
    
    output logic [7:0] data_o
    );



typedef enum logic [1:0] {IDLE, SETUP, ACCESS} apb_state_t; 

logic apb_state_setup;
logic apb_state_access; 

logic next_pwrite, pwrite_q ;
logic [data_size:0]rdata_q, next_rdata; 

logic read_from_slave_1_q, next_read_from_slave_1;

apb_state_t state_q; // current state
apb_state_t next_state;  // next state

//logic [2:0] counter;
//logic slave_change_flag;  

//always_ff @(posedge PCLK or negedge PRESET_n) begin
    
//    if (~PRESET_n) begin
//        counter <= 3'b0;
//        extra_flag <= 1'b0; 
//    end
    
//    else if ( add_i == 2'b01 | extra_flag) begin
        
//        if (counter == 3'b100) begin 
//            slave_change_flag <= 1'b1;
//            counter <= 3'b0;
//            extra_flag <= 1'b0; 
//        end  
        
//        else begin
//            counter <= counter + 1'b1; 
//            slave_change_flag <= 1'b0;
//        end 
    
//end 
    
//    else 
//        extra_flag <= 1'b1; 

//end 


// alternative: assign PADDR_o = {32{apb_state_access}} & 32'hA000   

// adresin 8. biti 1 ise PSEL2 , 0 ise PSEL1 


always_ff @ (posedge PCLK or negedge PRESET_n) begin
    
    if(~PRESET_n) 
        state_q <= IDLE; 
    else 
        state_q <= next_state; 
    
end 

logic read_from_slave_1; 

//always_ff @ (posedge PCLK or negedge PRESET_n) begin
    
//    if(~PRESET_n) 
//         read_from_slave_1 <= 1'b0;
    
//    else begin 
//              if(add_i == 2'b01 & ) 
//                    read_from_slave_1 <= 1'b1;
                
//                else 
//                    read_from_slave_1 <= 1'b0;
//   end 
   
//end    
  
always_comb begin 
     next_pwrite = pwrite_q;
     next_rdata = rdata_q; 
     next_read_from_slave_1 = read_from_slave_1_q; 
     
    case(state_q)
        
        IDLE:
            
            if(read_or_write[0]) begin // 2'b00: NOP, 2'b01: READ, 2'b10: NOP, 2'b11: WRITE
                next_state = SETUP;
                next_pwrite = read_or_write[1]; 
                
                if(read_or_write == 2'b01) begin
                    next_read_from_slave_1 = 1;
                end 
                
                else begin
                    next_read_from_slave_1 = 0;
                end 
                   
            end 
            else    
                next_state = IDLE;
            
        SETUP:  
            
            next_state = ACCESS; 
    
    
        ACCESS: 
            
            if(PREADY_i) begin
                
                 if(~pwrite_q) 
                    next_rdata = PREAD_i;
                 
                 next_state = IDLE;
                 next_read_from_slave_1 = 0;
            end       
            else     
                next_state = ACCESS; 
        
    
        default: next_state = IDLE; 
    
    endcase 
end 


assign apb_state_setup  = (state_q == SETUP) ;
assign apb_state_access =  (state_q == ACCESS); 

// Bu satýr muhtemelen silinecek. 
//assign {PSEL1_o,PSEL2_o} = ((state_q != IDLE) ? (PADDR_o[8] ? {1'b0,1'b1} : {1'b1,1'b0}) : 2'b0);

// PSEL1 için adres 8'0000_0010 = 2, PSEL 2 içina dres = 0001_0100 = 20 
assign PADDR_o =  (apb_state_setup |  apb_state_access) ?  (read_from_slave_1_q ? 9'b1000_0001_0 :  read_or_write == 2'b11 ?  9'b0000_1010_0 : 9'b0000_0000_0) : 9'b0000_0000_0; 

assign PSEL1_o = (apb_state_setup |  apb_state_access) & PADDR_o[8]; 
assign PSEL2_o = (apb_state_setup |  apb_state_access) & ~PADDR_o[8]; 

assign PENABLE_o =  apb_state_access &  (PSEL1_o | PSEL2_o) ; // PSEL_o baðlanmasa da olurdu. 


always_ff @(posedge PCLK or negedge PRESET_n) begin
    if(~PRESET_n) begin
        pwrite_q <= 1'b0;  
    end 
    
    else begin
        pwrite_q <= next_pwrite ;
    end 

end 

assign PWRITE_o = pwrite_q; 


// adder 
// read a valur from the slave at address 0xA0
// Increment that value 
// Send that value back during the write operation to address 0xA0

always_ff @ (posedge PCLK or negedge PRESET_n ) begin
    if(~PRESET_n) begin
        rdata_q <= 8'b0;
        data_o <= 8'b0;
    end 
    
    else begin
        rdata_q <= next_rdata; 
        data_o  <= next_rdata;
        
        read_from_slave_1_q <= next_read_from_slave_1;
    end 
end 
//assign PWDATA_o = {32{apb_state_access}} & (rdata_q + 32'h1 ); 
assign PWDATA_o = (PWRITE_o & apb_state_access) ? rdata_q + 8'd10 : 8'h0; 

endmodule
