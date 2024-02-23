`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
* Copyright (c) 2023, Shiv Nadar University, Delhi NCR, India. All Rights
* Reserved. Permission to use, copy, modify and distribute this software for
* educational, research, and not-for-profit purposes, without fee and without a
* signed license agreement, is hereby granted, provided that this paragraph and
* the following two paragraphs appear in all copies, modifications, and
* distributions.
*
* IN NO EVENT SHALL SHIV NADAR UNIVERSITY BE LIABLE TO ANY PARTY FOR DIRECT,
* INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST
* PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE.
*
* SHIV NADAR UNIVERSITY SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT
* NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
* PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS PROVIDED "AS IS". SHIV
* NADAR UNIVERSITY HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
* ENHANCEMENTS, OR MODIFICATIONS.
*
* Revision History:
*            Date                       By                                Change Notes
* ----------------------- ---------------------- ------------------------------------------
*  7th October 2023       Devyam Seal            default values were changed to 'zzz'
*   
*  8th October 2023       Aditi Sharma           default cases were added to case 
*                                                statements                  
*                                      
*  22nd February 2024     Aditi Sharma           Made calculations asynchronous
*/
//////////////////////////////////////////////////////////////////////////////////


module ALU(
    input clk,
    //input rst,
    output [7:0] Out,
    output [3:0] Flag,
    input [7:0] RN,
    input [7:0] OD,
    input [7:0] AC,
    input [7:0] opcode
);

reg [7:0] A, B;
reg [2:0] inst;  
        
        

parameter [2:0] CP = 3'b000;
parameter [2:0] AND = 3'b001;
parameter [2:0] OR = 3'b010;
parameter [2:0] XOR = 3'b011;
parameter [2:0] CM = 3'b100;
parameter [2:0] ADD = 3'b101;
parameter [2:0] SUB = 3'b110;

reg Carry, Zero, Parity, Sign;
wire carry2;

initial
begin
    Carry <=0;
    Zero <= 0;
    Parity <= 0;
    Sign <= 0;
    //Out <= 0;
end


always @(posedge clk)
begin

    $monitor("%t, ALU RN in = is %b" , $time, RN);
    $monitor("%t, ALU OD in = is %b" , $time, OD);
    $monitor("%t, ALU out = is %b" , $time, Out);
    $monitor("%t, carry = is %b" , $time, carry2);
    $monitor("%t, inst = is %b" , $time, inst);
    $monitor("%t, A = is %b" , $time, A);
    $monitor("%t, B = is %b" , $time, B);
    
    
    Sign <= 1'b0;
    
    if(opcode[7:3] == 5'b00001)
        begin
            inst <= opcode[2:0];
        end
        
    else if(opcode[7:6] == 2'b01)
        begin
            inst <= opcode[5:3]; 
        end
        
    else
        begin
            inst <= 3'bzzz;
        end

    
     if (opcode[7:3] == 5'b00001)
        begin
            A <= AC;
            B <= OD;
        end
        
     else if (opcode[7:5] == 3'b010)
        begin
            A <= RN;
            B <= AC;
        end
        
     else if (opcode[7:5] == 3'b011)
        begin
            A <= RN;
            B <= OD;
        end
        
     else
        begin
            A <= 8'b0;
            B <= 8'b0;
        end
end

    

 assign {carry2,Out}=  (inst == CM) ? {1'b0,~A} : (
                       (inst == AND)? {1'b0,A & B} : (
                       (inst == OR) ? {1'b0,A | B} : (
                       (inst == XOR)? {1'b0,A ^ B} : (
                       (inst == ADD)?  (A + B) : (
                       (inst == SUB)?  (A - B) : (
                       (opcode[7:3] == 5'b01111)? {1'b0,RN + AC} : (
                       (opcode == 8'h6)? {1'b0,AC << OD} : (
                       (opcode == 8'h7)? {1'b0,AC >> OD} : {1'b0,8'b0} ))))))));
                                              
                       
                        
 
    always @(posedge clk)
    begin
        case (inst)
        
        CP:
            begin
                if(B<A)
                    begin
                        Carry <= 1'b1;
                        Sign <= 1'b0;
                    end
                else if(A==B)
                    begin
                        Sign <= 1'b1;
                        Carry <= 1'b0;
                    end
                else
                    begin
                        Sign <= 1'b0;
                        Carry <= 1'b0;
                    end
            end
    endcase

    Parity <= ^Out;
    Zero <= ~(|Out);
    

end

assign Flag = {(Carry||carry2), Zero, Sign, Parity};

endmodule
