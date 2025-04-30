///////////////////////////// ALU //////////////////////////
module ALU(clk, Reset, Imm7, Op1, Op2, Opcode, ALUSave, ZflagSave, CflagSave, Zflag, Cflag, ALUout);
  
  input clk, Reset, ZflagSave, ALUSave, CflagSave;
  input [4:0] Opcode;
  input [7:0] Op1;
  input [7:0] Op2;
  input Imm7;
  
  output reg Zflag, Cflag;
  output reg [7:0] ALUout;
  
  wire [31:0] I;
  assign I = {1'b0, 1'b0, 1'b0, Imm7, Imm7, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
  
  wire M;
  Mux32to1_1bit Mux32to1_1bit_inst1(Opcode, I, M);
    
  wire [7:0] Sum;
  wire Cout;
  
  wire [7:0] M_8;
//   assign M_8 = {M, M, M, M, M, M, M, M};
    
//   wire [7:0] Op2_XOR_M;
//   xor_8bit xor_inst1(Op2_XOR_M, Op2, M_8);
  
  wire Overflow;
  
  Adder_Subtractor Adder_Subtractor_inst1(Op1, Op2, M, Sum, Cout, Overflow);
  
  wire [7:0] ANDAnswer;
  and_8bit and_8bit_inst1(ANDAnswer, Op1, Op2);
  
  wire [7:0] ORAnswer;
  or_8bit or_8bit_inst1(ORAnswer, Op1, Op2);
  
  wire [7:0] ExORAnswer;
  xor_8bit xor_8bit_inst2(ExORAnswer, Op1, Op2);
  
  wire [7:0] LShiftAnswer;
  wire [7:0] RShiftAnswer;
  
  wire [2:0] ShiftAmt;
  assign ShiftAmt = Op2[2:0];
    
  USReightbit_with_ShiftAmt USR_inst2(Op1, Reset, clk, 2'b10, ShiftAmt, LShiftAnswer);
  USReightbit_with_ShiftAmt USR_inst1(Op1, Reset, clk, 2'b01, ShiftAmt, RShiftAnswer);
  
  wire [7:0] In [0:31];
  assign In[0]  = 8'b00000000;
  assign In[1]  = ANDAnswer;
  assign In[2]  = ORAnswer;
  assign In[3]  = ExORAnswer;
  assign In[4]  = Sum;
  assign In[5]  = ANDAnswer;
  assign In[6]  = ORAnswer;
  assign In[7]  = ExORAnswer;
  assign In[8]  = Sum;
  assign In[9]  = Sum;
  assign In[10] = Sum;
  assign In[11] = 8'b00000000;
  assign In[12] = Sum;
  assign In[13] = 8'b00000000;
  assign In[14] = 8'b00000000;
  assign In[15] = 8'b00000000;
  assign In[16] = 8'b00000000;
  assign In[17] = 8'b00000000;
  assign In[18] = Sum;
  assign In[19] = 8'b00000000;
  assign In[20] = 8'b00000000;
  assign In[21] = Sum;
  assign In[22] = 8'b00000000;
  assign In[23] = Sum;
  assign In[24] = Sum;
  assign In[25] = RShiftAnswer;
  assign In[26] = LShiftAnswer;
  assign In[27] = Sum;
  assign In[28] = Sum;
  assign In[29] = 8'b00000000;
  assign In[30] = 8'b00000000;
  assign In[31] = 8'b00000000;
    
  wire [255:0] In_flat;
  assign In_flat = {In[31], In[30], In[29], In[28], In[27], In[26], In[25], In[24], In[23], In[22], In[21], In[20], In[19], In[18], In[17], In[16], In[15], In[14], In[13], In[12], In[11], In[10], In[9], In[8], In[7], In[6], In[5], In[4], In[3], In[2], In[1], In[0]};

  wire [7:0] Mux_out;
  MUX32to1_8bit_withE ALU_Mux(Opcode, 1'b1, In_flat, Mux_out);
  
  eightbitRegwithLoad reg_8bit_inst1(clk, Mux_out, Reset, ALUSave, ALUout);
  
  wire [7:0] ALUout_D1;
  eightbitRegwithLoad reg_8bit_inst2(clk, ALUout, Reset, 1'b1, ALUout_D1);
  
  wire [31:0] Carry_In;
  wire CarryFlagMux_out;
  
  wire Rx0, Rx7;
  assign Rx0 = Op1[0];
  assign Rx7 = Op1[7];
    
  assign Carry_In = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, Rx7, Rx0, Cout, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, Cout, 1'b0, 1'b0, 1'b0, Cout, 1'b0, 1'b0, 1'b0, 1'b0};
  
  Mux32to1_1bit Mux32to1_1bit_inst2(Opcode, Carry_In, CarryFlagMux_out);
  DFFwithSynResetAndEnable DFF_inst1(clk, CarryFlagMux_out, Reset, CflagSave, Cflag);
  
  wire nor_out;
//   assign xnor_out = ~(Mux_out[0] ^ Mux_out[1] ^ Mux_out[2] ^ Mux_out[3] ^ Mux_out[4] ^ Mux_out[5] ^ Mux_out[6] ^ Mux_out[7]);
  
  assign nor_out = (Mux_out == 8'b00000000);
  DFFwithSynResetAndEnable DFF_inst2(clk, nor_out, Reset, ZflagSave, Zflag);
  
  
endmodule

////////////////////// Mux32to1_1bit //////////////////
module Mux32to1_1bit(Sel, In, Out);
  
  input [4:0] Sel;         // 5-bit selection input (32 options)
  input [31:0] In;         // 32-bit input vector
  output reg Out;          // 1-bit output

  always @(*) begin
    case (Sel)
      5'b00000: Out = In[0];
      5'b00001: Out = In[1];
      5'b00010: Out = In[2];
      5'b00011: Out = In[3];
      5'b00100: Out = In[4];
      5'b00101: Out = In[5];
      5'b00110: Out = In[6];
      5'b00111: Out = In[7];
      5'b01000: Out = In[8];
      5'b01001: Out = In[9];
      5'b01010: Out = In[10];
      5'b01011: Out = In[11];
      5'b01100: Out = In[12];
      5'b01101: Out = In[13];
      5'b01110: Out = In[14];
      5'b01111: Out = In[15];
      5'b10000: Out = In[16];
      5'b10001: Out = In[17];
      5'b10010: Out = In[18];
      5'b10011: Out = In[19];
      5'b10100: Out = In[20];
      5'b10101: Out = In[21];
      5'b10110: Out = In[22];
      5'b10111: Out = In[23];
      5'b11000: Out = In[24];
      5'b11001: Out = In[25];
      5'b11010: Out = In[26];
      5'b11011: Out = In[27];
      5'b11100: Out = In[28];
      5'b11101: Out = In[29];
      5'b11110: Out = In[30];
      5'b11111: Out = In[31];
      default: Out = 1'b0;  // Default to 0
    endcase
  end

endmodule

///////////////// 8 Bit Register with Load ///////////////////////
module eightbitRegwithLoad(clk, Datain, Rst, L, Dataout);
input clk, L, Rst;
input [7:0] Datain;
output reg [7:0] Dataout;

wire [7:0] Y;

assign Y = (L == 1'b1)? Datain: Dataout; //represents 2to1MUX_8-bit 

//////////with synchronous reset//////////////
always @(posedge clk)
	begin
			if(Rst == 1'b1)
				Dataout<=8'b0000_0000;
			else
				Dataout<=Y;
	end
endmodule

//////////////////// Decoder3to8: ////////////////////
module Decoder3to8_withoutE(A, D);
  
  input [2:0] A;
  output [7:0] D;
  
  assign D[0] = ~A[2] & ~A[1] & ~A[0];
  assign D[1] = ~A[2] & ~A[1] & A[0];
  assign D[2] = ~A[2] & A[1] & ~A[0];
  assign D[3] = ~A[2] & A[1] & A[0];
  
  assign D[4] = A[2] & ~A[1] & ~A[0];
  assign D[5] = A[2] & ~A[1] & A[0];
  assign D[6] = A[2] & A[1] & ~A[0];
  assign D[7] = A[2] & A[1] & A[0];
  
endmodule

/////////////////// Mux8to1 //////////////////////////
module Mux8to1_withoutE(S, I, Y);
  input [2:0] S;
  input [7:0] I;
  output Y;
  
  wire [7:0] temp;
  
  assign temp[0] = I[0] & ~S[2] & ~S[1] & ~S[0];
  assign temp[1] = I[1] & ~S[2] & ~S[1] & S[0];
  assign temp[2] = I[2] & ~S[2] & S[1] & ~S[0];
  assign temp[3] = I[3] & ~S[2] & S[1] & S[0];
  
  assign temp[4] = I[4] & S[2] & ~S[1] & ~S[0];
  assign temp[5] = I[5] & S[2] & ~S[1] & S[0];
  assign temp[6] = I[6] & S[2] & S[1] & ~S[0];
  assign temp[7] = I[7] & S[2] & S[1] & S[0];
  
  assign Y = temp[0] | temp[1] | temp[2] | temp[3] | temp[4] | temp[5] | temp[6] | temp[7];
  
endmodule

///////////////// Full Adder ////////////////////////
module FullAdder_using_Mux(A, B, Cin, S, Cout);
  input A, B, Cin;
  output S, Cout;
  
  // Sum:
  wire [7:0] D; // o/p from decoder
  wire [7:0] SumInputs;
  wire [7:0] CarryInputs;
  wire SumTemp;
  
  Decoder3to8_withoutE inst1({A, B, Cin}, D);
  
  assign SumInputs = 8'b10010110;
  assign CarryInputs = 8'b11101000;
  
  or inst2(SumTemp, 
           D[0] & SumInputs[0], D[1] & SumInputs[1],
           D[2] & SumInputs[2], D[3] & SumInputs[3],
           D[4] & SumInputs[4], D[5] & SumInputs[5],
           D[6] & SumInputs[6], D[7] & SumInputs[7]);
  
  assign S = SumTemp;
  
  Mux8to1_withoutE inst3({A, B, Cin}, CarryInputs, Cout);
  
endmodule

// Ripple Carry Adder:
module Ripple_Carry_Adder(A, B, Cin, S, Cout, C7);
  
  input [7:0] A;
  input [7:0] B;
  input Cin;
  
  output [7:0] S;
  output Cout;
  
  // For Adder_Subtractor Module:
  output C7;
  
  wire [6:0] temp;
  
  FullAdder_using_Mux FA_inst1(A[0], B[0], Cin, S[0], temp[0]);
  FullAdder_using_Mux FA_inst2(A[1], B[1], temp[0], S[1], temp[1]);
  FullAdder_using_Mux FA_inst3(A[2], B[2], temp[1], S[2], temp[2]);
  FullAdder_using_Mux FA_inst4(A[3], B[3], temp[2], S[3], temp[3]);
  FullAdder_using_Mux FA_inst5(A[4], B[4], temp[3], S[4], temp[4]);
  FullAdder_using_Mux FA_inst6(A[5], B[5], temp[4], S[5], temp[5]);
  FullAdder_using_Mux FA_inst7(A[6], B[6], temp[5], S[6], temp[6]);
  FullAdder_using_Mux FA_inst8(A[7], B[7], temp[6], S[7], Cout);
  
  assign C7 = temp[6];
//   buf(C7, temp[6]);
  
endmodule


/////////////////// Adder_Subtractor //////////////////////////
module Adder_Subtractor(A, B, M, S, Cout, Overflow);
  
  input [7:0] A;
  input [7:0] B;
  input M;
 
  output [7:0] S;
  output Cout, Overflow;
  
  wire [7:0] Btemp;
  wire C7;
  assign Btemp = B ^ {8{M}};  // Correct way to XOR with M
  
  // Btemp_7:0 = B_7:0 xor M;
  
  Ripple_Carry_Adder RCA_inst(A, Btemp, M, S, Cout, C7);
  
  xor overflow_inst(Overflow, Cout, C7);
  
endmodule

/////////////////////////// XOR_8bits /////////////////////
module xor_8bit(Y, A, B);
  input [7:0] A;       
  input [7:0] B;       
  output [7:0] Y; 
  assign Y = A ^ B;

endmodule

/////////////////////////// AND_8bits /////////////////////
module and_8bit(Y, A, B);
  input [7:0] A;      
  input [7:0] B;       
  output [7:0] Y; 
  assign Y = A & B;

endmodule

/////////////////////////// OR_8bits /////////////////////
module or_8bit(Y, A, B);
  input [7:0] A;       
  input [7:0] B;       
  output [7:0] Y; 
  assign Y = A | B;

endmodule

////////////////////// Universal Shift Register with Shift Amount //////////////////
module USReightbit_with_ShiftAmt(Datain, Rst, clk, Sel, ShiftAmt, Dataout);

  input [7:0] Datain;         
  input Rst, clk;             
  input [1:0] Sel;            
  input [2:0] ShiftAmt;       

  output reg [7:0] Dataout;   

  reg [7:0] shifted_data;     

  always @(posedge clk or posedge Rst) begin
    if (Rst)
      Dataout <= 8'b00000000;
    else begin
      case (Sel)
        2'b00: Dataout <= Dataout; // Hold
        2'b01: Dataout <= Dataout >> ShiftAmt; // Shift right by ShiftAmt
        2'b10: Dataout <= Dataout << ShiftAmt; // Shift left by ShiftAmt
        2'b11: Dataout <= Datain; // Load new data
        default: Dataout <= Dataout; // Default to hold
      endcase
    end
  end

endmodule

////////////////////// Mux4to1_withoutE ////////////////////////
module Mux4to1_withoutE(I, S, Y);
  
  input [3:0] I;
  input [1:0] S;
  
  output reg Y;
  
  assign Y = (~S[0] & ~S[1] & I[0]) | (S[0] & ~S[1] & I[1]) | (~S[0] & S[1] & I[2]) | (S[0] & S[1] & I[3]);
  
endmodule
  

///////////////////// DFFwithSynReset ///////////////////////////
module DFFwithSynReset(clk, D, Rst, Q);
  
  input clk, D, Rst;
  output reg Q;
  
  always @(posedge clk)
    
    begin
      if (Rst == 1'b1)
        Q <= 1'b0;
      else 
        Q <= D;
    end
  
endmodule

///////////////////// DFFwithSynResetAndEnable ///////////////////////////
module DFFwithSynResetAndEnable(clk, D, Rst, En, Q);
  
  input clk, D, Rst, En;
  output reg Q;
  
  always @(posedge clk) begin
    if (Rst)           // Synchronous reset
      Q <= 1'b0;
    else if (En)       // Enable condition
      Q <= D;          // Load D into Q when enabled
  end

endmodule


/////////////////////// Program Counter //////////////////////////////////
module ProgCounter (
    input clk,
    input Reset,
    input PCenable,
    input PCupdate,
    input [7:0] CAddress,
    output reg [7:0] PC,
    output reg [7:0] PC_D1,
    output reg [7:0] PC_D2
);

always @(posedge clk or posedge Reset) begin
    if (Reset) begin
        PC <= 8'b0;  
        PC_D1 <= 8'b0;
        PC_D2 <= 8'b0;
    end
  else begin  
    PC_D2 <= PC_D1;
    PC_D1 <= PC; 
  
    if (PCenable) begin
            if (PCupdate)
                PC <= CAddress;
            else
                PC <= PC + 1;
     end
  end
end

endmodule

/////////////////////////// IN-Port ///////////////////////////////
// Design

module PriorityEncoder (
    input [7:0] InpExtWorld1,
    input [7:0] InpExtWorld2,
    input [7:0] InpExtWorld3,
    input [7:0] InpExtWorld4,
    output reg [1:0] Selectline
);
    always @(*) begin
      
      
      //priotity is given to Input 1 from Ext world, then Input 2 , 3 , 4 and so on.
      	
     	if (InpExtWorld1 != 8'b00000000)
            Selectline = 2'b00;
      
        else if (InpExtWorld2 != 8'b00000000)
            Selectline = 2'b01;
      
        else if (InpExtWorld3 != 8'b00000000)
            Selectline = 2'b10;
      
        else if (InpExtWorld4 != 8'b00000000)
            Selectline = 2'b11;
      
        else
            Selectline = 2'b00;    // Default case = 00, when no input from Ext world
    end
endmodule



module MUX4to1_8bit (
    input [7:0] in0, in1, in2, in3,
    input [1:0] sel,
    output reg [7:0] out
);
    always @(*) begin
       
      if (sel == 2'b00)
            out = in0;
      else if (sel == 2'b01)
            out = in1;
      else if (sel == 2'b10)
            out = in2;
      else if (sel == 2'b11)
            out = in3;
          else 
            out = 8'b00000000; 
          
       
    end
endmodule

module INport (
    input clk,
    input rst,
    input INportRead,
    input [7:0] InpExtWorld1,
    input [7:0] InpExtWorld2,
    input [7:0] InpExtWorld3,
    input [7:0] InpExtWorld4,
    output reg [7:0] Dataout
);
    wire [1:0] Selectline;
    wire [7:0] mux_out;

    
  PriorityEncoder encoder_inst (      // Priority Encoder to get select line
        .InpExtWorld1(InpExtWorld1),
        .InpExtWorld2(InpExtWorld2),
        .InpExtWorld3(InpExtWorld3),
        .InpExtWorld4(InpExtWorld4),
        .Selectline(Selectline)
    );

    
  MUX4to1_8bit mux_inst ( // MUX to select the input based on priority
        .in0(InpExtWorld1),
        .in1(InpExtWorld2),
        .in2(InpExtWorld3),
        .in3(InpExtWorld4),
        .sel(Selectline),
        .out(mux_out)
    );

    always @(posedge clk or posedge rst) begin
        if (rst)
            Dataout <= 8'b00000000;
        else if (INportRead)
            Dataout <= mux_out;
    end
endmodule

//////////////////// Register File /////////////////////////////
module registerfile(Datain, AdrsW, AdrsR1, AdrsR2, R, W, clk, Rst, Dataout1, Dataout2);
  
  input [7:0] Datain;
  
  input [3:0] AdrsW;
  input [3:0] AdrsR1;
  input [3:0] AdrsR2;
  
  input R, W, clk, Rst;
  
  output reg [7:0] Dataout1;
  output reg [7:0] Dataout2;
  
  wire [15:0] Decoder_out;
  Decoder4to16_withE_method3 Decoder_inst1(AdrsW, W, Decoder_out);
  
  wire [7:0] Register1_out;
  wire [7:0] Register2_out;
  wire [7:0] Register3_out;
  wire [7:0] Register4_out;
  wire [7:0] Register5_out;
  wire [7:0] Register6_out;
  wire [7:0] Register7_out;
  wire [7:0] Register8_out;
  
  wire [7:0] Register9_out;
  wire [7:0] Register10_out;
  wire [7:0] Register11_out;
  wire [7:0] Register12_out;
  wire [7:0] Register13_out;
  wire [7:0] Register14_out;
  wire [7:0] Register15_out;
  wire [7:0] Register16_out;
  
  eightbitRegwithLoad inst1(clk, Datain, Rst, Decoder_out[0], Register1_out);
  eightbitRegwithLoad inst2(clk, Datain, Rst, Decoder_out[1], Register2_out);
  eightbitRegwithLoad inst3(clk, Datain, Rst, Decoder_out[2], Register3_out);
  eightbitRegwithLoad inst4(clk, Datain, Rst, Decoder_out[3], Register4_out);
  eightbitRegwithLoad inst5(clk, Datain, Rst, Decoder_out[4], Register5_out);
  eightbitRegwithLoad inst6(clk, Datain, Rst, Decoder_out[5], Register6_out);
  eightbitRegwithLoad inst7(clk, Datain, Rst, Decoder_out[6], Register7_out);
  eightbitRegwithLoad inst8(clk, Datain, Rst, Decoder_out[7], Register8_out);
  
  eightbitRegwithLoad inst9(clk, Datain, Rst, Decoder_out[8], Register9_out);
  eightbitRegwithLoad inst10(clk, Datain, Rst, Decoder_out[9], Register10_out);
  eightbitRegwithLoad inst11(clk, Datain, Rst, Decoder_out[10], Register11_out);
  eightbitRegwithLoad inst12(clk, Datain, Rst, Decoder_out[11], Register12_out);
  eightbitRegwithLoad inst13(clk, Datain, Rst, Decoder_out[12], Register13_out);
  eightbitRegwithLoad inst14(clk, Datain, Rst, Decoder_out[13], Register14_out);
  eightbitRegwithLoad inst15(clk, Datain, Rst, Decoder_out[14], Register15_out);
  eightbitRegwithLoad inst16(clk, Datain, Rst, Decoder_out[15], Register16_out);
  
  wire [7:0] Mux1_out;
  wire [7:0] Mux2_out;
  
  Mux16to1_8bit_withoutE Mux_inst1(Register1_out, Register2_out, Register3_out, Register4_out, Register5_out, Register6_out, Register7_out, Register8_out, Register9_out, Register10_out, Register11_out, Register12_out, Register13_out, Register14_out, Register15_out, Register16_out, AdrsR1, Mux1_out);
  
  Mux16to1_8bit_withoutE Mux_inst2(Register1_out, Register2_out, Register3_out, Register4_out, Register5_out, Register6_out, Register7_out, Register8_out, Register9_out, Register10_out, Register11_out, Register12_out, Register13_out, Register14_out, Register15_out, Register16_out, AdrsR2, Mux2_out);
  
//   eightbitRegwithLoad inst17(clk, Mux1_out, Rst, R, Dataout1);
//   eightbitRegwithLoad inst18(clk, Mux2_out, Rst, R, Dataout2);
  
  // Synchronous output update
  always @(posedge clk) begin
    if (Rst) begin
      Dataout1 <= 8'b0000_0000;
      Dataout2 <= 8'b0000_0000;
    end else if (R) begin
      Dataout1 <= Mux1_out;
      Dataout2 <= Mux2_out;
    end
  end
  
endmodule

/////////////////////// Decoder 4 to 16 with E ///////////////////////
module Decoder4to16_withE_method3(A, E, D);
  input [3:0] A;
  input E;
  output reg [15:0] D;
  
  always @(*) begin
    if (E) begin
      case (A)
        4'b0000: D = 16'b0000_0000_0000_0001;
        4'b0001: D = 16'b0000_0000_0000_0010;
        4'b0010: D = 16'b0000_0000_0000_0100;
        4'b0011: D = 16'b0000_0000_0000_1000;
        4'b0100: D = 16'b0000_0000_0001_0000;
        4'b0101: D = 16'b0000_0000_0010_0000;
        4'b0110: D = 16'b0000_0000_0100_0000;
        4'b0111: D = 16'b0000_0000_1000_0000;
        4'b1000: D = 16'b0000_0001_0000_0000;
        4'b1001: D = 16'b0000_0010_0000_0000;
        4'b1010: D = 16'b0000_0100_0000_0000;
        4'b1011: D = 16'b0000_1000_0000_0000;
        4'b1100: D = 16'b0001_0000_0000_0000;
        4'b1101: D = 16'b0010_0000_0000_0000;
        4'b1110: D = 16'b0100_0000_0000_0000;
        4'b1111: D = 16'b1000_0000_0000_0000;
      endcase
    end else begin
      D = 16'b0000_0000_0000_0000; // When E = 0, output should be all 0s
    end
  end
endmodule
////////////////////////////////////////////////////////////////////


///////////////////// Mux16to1_8bit_withoutE ///////////////////////
module Mux16to1_8bit_withoutE(I0, I1, I2, I3, I4, I5, I6, I7, I8, I9, IA, IB, IC, ID, IE, IF, S, Y);
  
  // 16 * (8 bits input)
  input [7:0] I0;
  input [7:0] I1;
  input [7:0] I2;
  input [7:0] I3;
  input [7:0] I4;
  input [7:0] I5;
  input [7:0] I6;
  input [7:0] I7;
  input [7:0] I8;
  input [7:0] I9;
  input [7:0] IA;
  input [7:0] IB;
  input [7:0] IC;
  input [7:0] ID;
  input [7:0] IE;
  input [7:0] IF;
  
  input [3:0] S; // 4 bit Select line
  
  output reg [7:0] Y;
  
  always@(*)
    begin
      case(S)
        4'b0000: Y = I0;
        4'b0001: Y = I1;
        4'b0010: Y = I2;
        4'b0011: Y = I3;
        4'b0100: Y = I4;
        4'b0101: Y = I5;
        4'b0110: Y = I6;
        4'b0111: Y = I7;
        4'b1000: Y = I8;
        4'b1001: Y = I9;
        4'b1010: Y = IA;
        4'b1011: Y = IB;
        4'b1100: Y = IC;
        4'b1101: Y = ID;
        4'b1110: Y = IE;
        4'b1111: Y = IF;
        
        default:
          Y = 8'b0000_0000;
        
      endcase
    end
endmodule
  
///////////////////////////////// OUTport ////////////////////////////////////
module OUTport(
    input clk,
    input Reset,
    input [7:0] Address,
    input [7:0] Datain,
    input OUTportWrite,
    output reg [7:0] OutExtWorld1,
    output reg [7:0] OutExtWorld2,
    output reg [7:0] OutExtWorld3,
    output reg [7:0] OutExtWorld4
);

always @(posedge clk or posedge Reset) begin
    if (Reset) begin
        OutExtWorld1 <= 8'b0;
        OutExtWorld2 <= 8'b0;
        OutExtWorld3 <= 8'b0;
        OutExtWorld4 <= 8'b0;
    end
    else if (OUTportWrite) begin
        case (Address)
            8'h00: OutExtWorld1 <= Datain;
            8'h01: OutExtWorld2 <= Datain;
            8'h02: OutExtWorld3 <= Datain;
            8'h03: OutExtWorld4 <= Datain;
            default: begin
                OutExtWorld1 <= OutExtWorld1;
                OutExtWorld2 <= OutExtWorld2;
                OutExtWorld3 <= OutExtWorld3;
                OutExtWorld4 <= OutExtWorld4;
            end
        endcase
    end
end

endmodule

/////////////////////////// SRAM Module ///////////////////////////////////////
module SRAM (
    input clk,
    input Reset,
    input [7:0] Address,
    input SRAMRead,
    input SRAMWrite,
    input [7:0] Datain,
    output reg [7:0] Dataout
);
    
    reg [7:0] datamem [0:255]; // 256 x 8-bit memory array
    
    // Initialize memory with zeros on reset
    always @(posedge clk or posedge Reset) begin
        if (Reset) begin
            integer i;
            for (i = 0; i < 256; i = i + 1)
                datamem[i] <= 8'b0;
        end
        else if (SRAMWrite) begin
            datamem[Address] <= Datain; // Write operation
        end
    end
    
    // Read Logic
  always @(posedge clk) begin
        if (SRAMRead) begin
            Dataout = datamem[Address]; // Read operation
        end
        else begin
            Dataout = 8'b0; // Default to zero if not reading
        end
    end
endmodule
  

  ////////////////////////////////// Stack ////////////////////////////////////
module Stack (
    input clk,
    input reset,
    input StackRead,
    input StackWrite,
    input [7:0] Datain,
    output reg [7:0] Dataout
);

  reg [7:0] stack_pointer;  // 4-bit pointer for stack indexing
    wire [7:0] sram_out;

    // SRAM instance for storing stack data
    SRAM stack_memory (
        .clk(clk),
        .Reset(reset),
        .Address(stack_pointer),
        .SRAMRead(StackRead),
        .SRAMWrite(StackWrite),
        .Datain(Datain),
        .Dataout(sram_out)
    );

    // Stack Pointer Control Logic
    always @(posedge clk or posedge reset) begin
        if (reset)
            stack_pointer <= 8'b00000000;  // Reset pointer to 0
      else if (StackWrite && stack_pointer < 8'b11111111)
            stack_pointer <= stack_pointer + 1;  // Increment on write
        else if (StackRead && stack_pointer > 0)
            stack_pointer <= stack_pointer - 1;  // Decrement on read
    end

    // Output the read data from SRAM
    always @(posedge clk) begin
        if (StackRead)
            Dataout <= sram_out;
        else
            Dataout <= 8'b0;
    end

endmodule

module InstMEM (
    input clk,
    input Reset,
    input [7:0] Address,  // 8-bit address for 256x25-bit memory
    input InstRead,        // Signal to read instruction
    output reg [24:0] Dataout,  // 25-bit instruction output
    output reg [4:0] Opcode,     // 5-bit Opcode extracted from instruction
    output reg [3:0] Destin,     // 4-bit Destination Register
    output reg [3:0] Source1,    // 4-bit Source1 Register
    output reg [3:0] Source2,    // 4-bit Source2 Register
    output reg [7:0] Imm        // 8-bit Immediate value
);

    // Define 256 x 25-bit instruction memory
    reg [24:0] instmemory [0:255]; // 256 locations, each 25-bits wide
    
    // Load instructions from an external file (inst.mem)
    initial begin
        $readmemb("inst.mem", instmemory);  // Load instruction memory from file
    end
    
    // Synchronous block for read operation with reset condition
    always @(posedge clk or posedge Reset) begin
        if (Reset) begin
            // Reset all outputs to zero on reset
            Dataout  <= 25'b0;
            Opcode   <= 5'b0;
            Destin   <= 4'b0;
            Source1  <= 4'b0;
            Source2  <= 4'b0;
            Imm      <= 8'b0;
        end else if (InstRead) begin
            // Read instruction only if InstRead is high
//             if (Address < 8'd256) begin
//                 // Valid address range check (0 to 255)
//                 Dataout  <= instmemory[Address];  // Get the instruction
//                 Opcode   <= instmemory[Address][24:20];  // Extract the Opcode (5 bits)
//                 Destin   <= instmemory[Address][19:16];  // Extract Destination (4 bits)
//                 Source1  <= instmemory[Address][15:12];  // Extract Source1 (4 bits)
//                 Source2  <= instmemory[Address][11:8];   // Extract Source2 (4 bits)
//                 Imm      <= instmemory[Address][7:0];    // Extract Immediate (8 bits)
//             end else begin
//                 // Handle invalid address (if address is outside 0-255)
//                 Dataout  <= 25'b0;  // Set instruction to zero
//                 Opcode   <= 5'b0;    // Set Opcode to zero
//                 Destin   <= 4'b0;    // Set Destination to zero
//                 Source1  <= 4'b0;    // Set Source1 to zero
//                 Source2  <= 4'b0;    // Set Source2 to zero
//                 Imm      <= 8'b0;    // Set Immediate to zero
//             end
          
          Dataout  <= instmemory[Address];  // Get the instruction
                Opcode   <= instmemory[Address][24:20];  // Extract the Opcode (5 bits)
                Destin   <= instmemory[Address][19:16];  // Extract Destination (4 bits)
                Source1  <= instmemory[Address][15:12];  // Extract Source1 (4 bits)
                Source2  <= instmemory[Address][11:8];   // Extract Source2 (4 bits)
                Imm      <= instmemory[Address][7:0];    // Extract Immediate (8 bits)
        end
    end

endmodule

module MUX32to1_1bit_withE(
    input [4:0] sel,  // 5-bit selection input (for selecting one of the 32 inputs)
    input enable,     // Enable input
    input [31:0] in,  // 32-bit input
    output reg out    // 1-bit output
);
    
    always @(*) begin
        if (enable) begin
            // Select the appropriate bit based on the 'sel' value (0 to 31)
            out = in[sel]; 
        end
        else begin
            out = 0;  // When enable is low, output is 0
        end
    end

endmodule

module ControlLogic(
    input clk,
    input Reset,
    input T1, T2, T3, T4, T5, // Added T5
    input Zflag, Cflag,
    input [4:0] Opcode,
    output reg PCupdate,
    output reg SRAMRead,
    output reg SRAMWrite,
    output reg StackRead,
    output reg StackWrite,
    output reg ALUSave,
    output reg ZflagSave,
    output reg CflagSave,
    output reg INportRead,
    output reg OUTportWrite,
    output reg RegFileRead,
    output reg RegFileWrite
);

  MUX32to1_1bit_withE MUX32to1_1bit_withE_inst_SRAM_W (
    .sel(Opcode),  // 5-bit selection input (for selecting one of the 32 inputs)
    .enable(T3),     // Enable input
    .in(32'b00000000100000000001000000000000),  // 32-bit input
    .out(SRAMWrite)    // 1-bit output
  );
  
  MUX32to1_1bit_withE MUX32to1_1bit_withE_inst_SRAM_R (
    .sel(Opcode),  // 5-bit selection input (for selecting one of the 32 inputs)
    .enable(T3),     // Enable input
    .in(32'b00000000010000000000100000000000),  // 32-bit input
    .out(SRAMRead)    // 1-bit output
  );
  
  MUX32to1_1bit_withE MUX32to1_1bit_withE_inst_RegFileRead (
    .sel(Opcode),  // 5-bit selection input (for selecting one of the 32 inputs)
    .enable(T1),     // Enable input
    .in(32'b00000111111001000001001111111110),  // 32-bit input
    .out(RegFileRead)    // 1-bit output
  );
  
  MUX32to1_1bit_withE MUX32to1_1bit_withE_inst_RegFileWrite (
    .sel(Opcode),  // 5-bit selection input (for selecting one of the 32 inputs)
    .enable(T4),     // Enable input
    .in(32'b00000111010110000000111111111110),  // 32-bit input
    .out(RegFileWrite)    // 1-bit output
  );
  
  MUX32to1_1bit_withE MUX32to1_1bit_withE_inst_ALUSave (
    .sel(Opcode),  // 5-bit selection input (for selecting one of the 32 inputs)
    .enable(T2),     // Enable input
    .in(32'b00011111101001000001011111111110),  // 32-bit input
    .out(ALUSave)    // 1-bit output
  );
  
  MUX32to1_1bit_withE MUX32to1_1bit_withE_inst_ZflagSave (
    .sel(Opcode),  // 5-bit selection input (for selecting one of the 32 inputs)
    .enable(T2),     // Enable input
    .in(32'b00000111000000000000000111111110),  // 32-bit input
    .out(ZflagSave)    // 1-bit output
  );
  
  MUX32to1_1bit_withE MUX32to1_1bit_withE_inst_CflagSave (
    .sel(Opcode),  // 5-bit selection input (for selecting one of the 32 inputs)
    .enable(T2),     // Enable input
    .in(32'b00000111000000000000000100010000),  // 32-bit input
    .out(CflagSave)    // 1-bit output
  );
  
  MUX32to1_1bit_withE MUX32to1_1bit_withE_inst_StackWrite (
    .sel(Opcode),  // 5-bit selection input (for selecting one of the 32 inputs)
    .enable(T3),     // Enable input
    .in(32'b00000000000001000000000000000000),  // 32-bit input
    .out(StackWrite)    // 1-bit output
  );
  
  MUX32to1_1bit_withE MUX32to1_1bit_withE_inst_StackRead (
    .sel(Opcode),  // 5-bit selection input (for selecting one of the 32 inputs)
    .enable(T3),     // Enable input
    .in(32'b00000000000010000000000000000000),  // 32-bit input
    .out(StackRead)    // 1-bit output
  );
  
  MUX32to1_1bit_withE MUX32to1_1bit_withE_inst_INportRead (
    .sel(Opcode),  // 5-bit selection input (for selecting one of the 32 inputs)
    .enable(T3),     // Enable input
    .in(32'b00000000000100000000000000000000),  // 32-bit input
    .out(INportRead)    // 1-bit output
  );
  
  MUX32to1_1bit_withE MUX32to1_1bit_withE_inst_OUTportWrite (
    .sel(Opcode),  // 5-bit selection input (for selecting one of the 32 inputs)
    .enable(T3),     // Enable input
    .in(32'b00000000001000000000000000000000),  // 32-bit input
    .out(OUTportWrite)    // 1-bit output
  );
  
  MUX32to1_1bit_withE MUX32to1_1bit_withE_inst_PCupdate (
    .sel(Opcode),  // 5-bit selection input (for selecting one of the 32 inputs)
    .enable(T4),     // Enable input
    .in({1'b0, 1'b0, 1'b0, ~Zflag, Zflag, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, ~Cflag, Cflag, ~Zflag, Zflag, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}),  // 32-bit input
    .out(PCupdate)    // 1-bit output
  );
    
  
endmodule


module MUX32to1_8bit_withE (
  input [4:0] sel,           // Select 1 out of 32 inputs
  input enable,              // Enable line
  input [255:0] in,          // 32 inputs × 8 bits = 256-bit input bus
  output reg [7:0] out       // Selected 8-bit output
);
  
  always @(*) begin
    if (enable) begin
      out = in[sel*8 +: 8];  // Select 8-bit chunk based on sel
    end else begin
      out = 8'b0;
    end
  end

endmodule


// Timing Generator Module
module TimingGen (
    input clk,
    input Reset,
    output reg T0,
    output reg T1,
    output reg T2,
    output reg T3,
    output reg T4
);
    
    reg [2:0] state;
    
    always @(posedge clk or posedge Reset) begin
        if (Reset) begin
            state <= 3'b000;
        end
        else if (state == 3'b100) begin
            state <= 3'b000;
        end
        else begin
            state <= state + 1;
        end
    end
    
    always @(*) begin
        T0 = (state == 3'b000);
        T1 = (state == 3'b001);
        T2 = (state == 3'b010);
        T3 = (state == 3'b011);
        T4 = (state == 3'b100);
    end
endmodule