module glb;
reg [25:0] PC; // addresss
reg [31:0] memory  [0:31]; /// this is my instruction memory 
reg [31:0] reg_memory[0:31];/// this is my register memory
reg [31:0] data_memory[0:31];//this is my data memory    
endmodule

module Mux_5bit2 (a,b,S,out);
input [4:0]a,b;
input S;
output reg[4:0]out ;
always @(*) begin
    case(S)
  0: out = a;
  1: out = b;
endcase
end


endmodule


module Mux_26bit (a,b,S,out);
input [25:0]a,b;
input S;
output reg[25:0]out ;
always @(*) begin
    case(S)
  0: out = a;
  1: out = b;
endcase
end


endmodule

module Mux_32bit (a,b,S,out);
input [31:0]a,b;
input S;
output reg[31:0]out ;
always @(*) begin
    case(S)
  0: out <= a;
  1: out <= b;
endcase
end
endmodule


module Veda_memory (clk, reset, data_in, write_enable, mode, data_out);
input clk, reset, write_enable, mode;
input [31:0] data_in;
output reg [31:0] data_out;

    initial begin
        glb.memory [0] = {6'd15,5'd1,5'd2,16'd14};    // first 

        glb.memory [1] = {6'd5,5'd2,5'd3,16'd1 };//addi

        glb.memory [2] = {6'd15,5'd1,5'd3,16'd12};    //beq $t3,$t1,endloop2

        glb.memory [3] = {6'd1,5'd0,5'd2,5'd4,11'd0}; // simple add

        glb.memory [4]= {6'd13,5'd4,5'd6,16'd0 };//load word 

        glb.memory [5] = {6'd1,5'd0,5'd3,5'd5,11'd0};// simple add 

        glb.memory [6]= {6'd13,5'd5,5'd7,16'd0 };// load word

        glb.memory [7]= {6'd19,5'd6,5'd7,16'd10 };

        glb.memory [8]= {6'd14,5'd4,5'd7,16'd0 };

        glb.memory [9]= {6'd14,5'd5,5'd6,16'd0 };

        glb.memory [10] = {6'd5,5'd3,5'd3,16'd1 };// add 1 in j 

        glb.memory [11]= {6'd21,26'd2 };// jump to address = 2

        glb.memory [12] = {6'd5,5'd2,5'd2,16'd1 }; //add 1 in i 

        glb.memory [13]={6'd21,26'd0}; 
    
    end


    integer  i;

    always @(*) begin
        if(reset) begin
        for (i = 0; i < 32; i = i + 1) begin 
        glb.memory[i] <= 0;
        end
        end
        else if (write_enable && mode == 0) begin
        glb.memory[glb.PC] <= data_in;
        data_out <= data_in;
        end
        else if (mode == 1) begin
        data_out <= glb.memory[glb.PC];
        end
    end

endmodule

module Instruction_memory_module(clk,Instruction_Reg );
    output [31:0]  Instruction_Reg;
    input clk;

    Veda_memory f1(clk,0, 0, 0, 1, Instruction_Reg );

endmodule

module decode_instruction(clk, result);
  
    wire [31:0] in_1  ;
    input clk;
    output reg [31:0]result;
    wire [31:0] r1,r2;
    wire [31:0] result_1;


    reg [25:0] jump_address, branch_address;

 wire regdst;
 wire jump;
 wire branch;
 wire memread;
 wire memtoreg;

 wire memwrite;
 wire alusrc;
 wire regwrite; 

    wire [31:0] write_data;
    wire zero;

    wire branchi;    
    wire [25:0] pc,b_out;

    Instruction_memory_module f2(clk,in_1 );
   



    always @(in_1) begin
        jump_address <= in_1[25:0];
        branch_address <={ 10'b0,in_1[15:0]};
    end

    controller f15(in_1[31:26],regdst,jump,branch,memread, memtoreg , memwrite ,alusrc, regwrite);
    reg_memory f4(in_1[25:21], in_1[20:16], r1 , r2 ,WriteReg, regwrite , write_data);

    wire [31:0] Read2_32;
    sign_extended f45(in_1[15:0], Read2_32);

    wire[31:0] rd2 ;
    Mux_32bit f46(r2,Read2_32,alusrc,rd2);


    ALU f8(r1, rd2 , in_1[31:26] , result_1 ,zero);
    wire [4:0] WriteReg; 
   
    Mux_5bit2 f10(in_1[20:16],in_1[15:11],regdst , WriteReg); //

    and a1 (branchi,branch,zero);
    Mux_26bit f87(glb.PC ,branch_address, branchi, b_out );
    Mux_26bit f85(b_out , jump_address, jump ,pc);
    always @(pc) begin
       glb.PC <= pc; 
    end 

    wire [31:0]mux_in1 ;
   
    data_mem f56(result_1,r2,mux_in1,memwrite,memread);

    Mux_32bit f89(result_1, mux_in1 ,memtoreg, write_data);



    always @(glb.reg_memory[WriteReg] )begin
        // $display("%d", WriteReg);
        result <= glb.reg_memory[WriteReg];
    end



endmodule

module sign_extended(in_15_0 ,in_31_0 );
input [15:0] in_15_0;
output reg[31:0] in_31_0;

always @(in_15_0)begin
     in_31_0 <= {16'b0,in_15_0};
end
endmodule

module data_mem (address_d ,write_data,read_data,memwrite,memread);
input [31:0]address_d;
input [31:0] write_data;
input memwrite,memread;

output reg [31:0] read_data;



always @( address_d)begin 
       if(memwrite) begin
          glb.data_memory[address_d]= write_data;
        end

end
always @(*)begin 


        if(memread) begin
  
            read_data = glb.data_memory[address_d];
        end

end

initial begin
glb.data_memory[0]= 32'd15;
glb.data_memory[1]= 32'd12;
glb.data_memory[2]= 32'd10;
glb.data_memory[3]= 32'd11;
glb.data_memory[4]= 32'd75;
glb.data_memory[5]= 32'd30;

end

endmodule


module ALU(
    input [31:0] operand1,
    input [31:0] operand2,
    input [5:0] op,
    output reg [31:0] result,
    output reg zero
);


always @(op or operand1 or operand2) begin
 
    case(op)
        6'd1,6'd5,6'd13,6'd14: result <= operand1 + operand2; 
        6'd2: result <= operand1 - operand2; 
        6'd15: zero <= (operand1==operand2);
        6'd19: zero <= operand1<operand2?1:0;

        //
        6'd3 : result<=operand1+operand2;
        6'd4 : result<=operand1-operand2;
        6'd6 : result<=operand1+operand2;
        6'd7: result<=operand1&operand2;
        6'd8 : result<=operand1|operand2;
        6'd9 : result<=operand1&operand2;
        6'd10 : result<=operand1|operand2;
        6'd11 : result<=operand1<<operand2;
        6'd12 : result<=operand1>>operand2;
        6'd16 : result<=(operand1==operand2 ? 32'd1:32'd0);
        6'd17 : result<=(operand1<=operand2  ? 32'd1:32'd0);
        6'd18 : result<=(operand1<operand2  ? 32'd1:32'd0);
        6'd20 : result<=(operand1>operand2 ? 32'd1:32'd0);
        6'd24 : result<=(operand1<operand2 ? 32'd1:32'd0);
        6'd25 : result<=(operand1<operand2 ? 32'd1:32'd0);
          
        
    endcase
end



endmodule

module controller (op,regdst,jump,branch,memread,memtoreg,memwrite,alusrc,regwrite);
    input [5:0] op;
    output reg regdst,jump,branch,memread,memtoreg,memwrite,alusrc,regwrite;
    
    always @(op)begin
  case(op)
  6'd1,6'd2:begin       //add and sub
    regdst<=1'b1;
    jump<=1'b0;
    branch<=1'b0;
    memread<=1'b0;
    memtoreg<=1'b0;
    memwrite<=1'b0;
    alusrc<=1'b0;
    regwrite<=1'b1;

  end
  6'd13:begin            // load word
    regdst<=1'b0;
    jump<=1'b0;
    branch<=1'b0;
    memread<=1'b1;
    memtoreg<=1'b1;
    memwrite<=1'b0;
    alusrc<=1'b1;
    regwrite<=1'b1;

  end 
  6'd5:begin            // addi
    regdst<=1'b0;
    jump<=1'b0;
    branch<=1'b0;
    memread<=1'b0;
    memtoreg<=1'b0;
    memwrite<=1'b0;
    alusrc<=1'b1;
    regwrite<=1'b1;

  end 
  6'd14:begin          // store word
    regdst<=1'b0;
    jump<=1'b0;
    branch<=1'b0;
    memread<=1'b0;
    memtoreg<=1'b0;
    memwrite<=1'b1;
    alusrc<=1'b1;
    regwrite<=1'b0;

  end 
  6'd15:begin          // branch equal
    regdst<=1'b0;
    jump<=1'b0;
    branch<=1'b1;
    memread<=1'b0;
    memtoreg<=1'b0;
    memwrite<=1'b0;
    alusrc<=1'b0;
    regwrite<=1'b0;

  end   
  6'd21:begin          // jump
    regdst<=1'b0;
    jump<=1'b1;
    branch<=1'b0;
    memread<=1'b0;
    memtoreg<=1'b0;
    memwrite<=1'b0;
    alusrc<=1'b0;
    regwrite<=1'b0;

  end 
  6'd19:begin          // branch less than
    regdst<=1'b0;
    jump<=1'b0;
    branch<=1'b1;
    memread<=1'b0;
    memtoreg<=1'b0;
    memwrite<=1'b0;
    alusrc<=1'b0;
    regwrite<=1'b0;

  end     
  6'd3 : begin
      regdst<=1'b1;
      regwrite<=1'b1;
      alusrc<=1'b0;
      memread<=1'b0;
      memwrite<=1'b0;
      memtoreg<=1'b0;
      branch<=1'b0;
      jump<=1'b0;
  end
  6'd4 : begin
      regdst<=1'b1;
      regwrite<=1'b1;
      alusrc<=1'b0;
      memread<=1'b0;
      memwrite<=1'b0;
      memtoreg<=1'b0;
      branch<=1'b0;
      jump<=1'b0;
  end

  6'd6 : begin
      regdst<=1'b0;
      regwrite<=1'b1;
      alusrc<=1'b0;
      memread<=1'b0;
      memwrite<=1'b0;
      memtoreg<=1'b0;
      branch<=1'b0;
      jump<=1'b0;
  end
  6'd7 : begin
      regdst<=1'b1;
      regwrite<=1'b1;
      alusrc<=1'b0;
      memread<=1'b0;
      memwrite<=1'b0;
      memtoreg<=1'b0;
      branch<=1'b0;
      jump<=1'b0;
  end
  6'd8 : begin
      regdst<=1'b1;
      regwrite<=1'b1;
      alusrc<=1'b0;
      memread<=1'b0;
      memwrite<=1'b0;
      memtoreg<=1'b0;
      branch<=1'b0;
      jump<=1'b0;
  end
  6'd9 : begin
      regdst<=1'b0;
      regwrite<=1'b1;
      alusrc<=1'b1;
      memread<=1'b0;
      memwrite<=1'b0;
      memtoreg<=1'b0;
      branch<=1'b0;
      jump<=1'b0;
  end
  6'd10 : begin
      regdst<=1'b0;
      regwrite<=1'b1;
      alusrc<=1'b1;
      memread<=1'b0;
      memwrite<=1'b0;
      memtoreg<=1'b0;
      branch<=1'b0;
      jump<=1'b0;
  end
  6'd11 : begin
      regdst<=1'b0;
      regwrite<=1'b1;
      alusrc<=1'b1;
      memread<=1'b0;
      memwrite<=1'b0;
      memtoreg<=1'b0;
      branch<=1'b0;
      jump<=1'b0;
  end
  6'd12 : begin
      regdst<=1'b0;
      regwrite<=1'b1;
      alusrc<=1'b1;
      memread<=1'b0;
      memwrite<=1'b0;
      memtoreg<=1'b0;
      branch<=1'b0;
      jump<=1'b0;
  end

  6'd16 : begin
      regdst<=1'b1;
      regwrite<=1'b0;
      alusrc<=1'b0;
      memread<=1'b0;
      memwrite<=1'b0;
      memtoreg<=1'b0;
      branch<=1'b1;
      jump<=1'b0;
  end
  6'd17 : begin
      regdst<=1'b1;
      regwrite<=1'b0;
      alusrc<=1'b0;
      memread<=1'b0;
      memwrite<=1'b0;
      memtoreg<=1'b1;
      branch<=1'b1;
      jump<=1'b0;
  end
  6'd18 : begin
      regdst<=1'b1;
      regwrite<=1'b0;
      alusrc<=1'b0;
      memread<=1'b0;
      memwrite<=1'b0;
      memtoreg<=1'b1;
      branch<=1'b1;
      jump<=1'b0;
  end
  
  6'd20 : begin
      regdst<=1'b1;
      regwrite<=1'b0;
      alusrc<=1'b0;
      memread<=1'b0;
      memwrite<=1'b0;
      memtoreg<=1'b1;
      branch<=1'b1;
      jump<=1'b0;
  end

  6'd22 : begin
      regdst<=1'b0;
      regwrite<=1'b0;
      alusrc<=1'b0;
      memread<=1'b0;
      memwrite<=1'b0;
      memtoreg<=1'b1;
      branch<=1'b0;
      jump<=1'b1;
  end
  6'd23 : begin
      regdst<=1'b0;
      regwrite<=1'b0;
      alusrc<=1'b0;
      memread<=1'b0;
      memwrite<=1'b0;
      memtoreg<=1'b1;
      branch<=1'b0;
      jump<=1'b1;
  end
  6'd24 : begin
      regdst<=1'b1;
      regwrite<=1'b1;
      alusrc<=1'b0;
      memread<=1'b0;
      memwrite<=1'b0;
      memtoreg<=1'b0;
      branch<=1'b0;
      jump<=1'b0;
  end
  6'd25 : begin
      regdst<=1'b0;
      regwrite<=1'b1;
      alusrc<=1'b1;
      memread<=1'b0;
      memwrite<=1'b0;
      memtoreg<=1'b0;
      branch<=1'b0;
      jump<=1'b0;
  end  

  
  endcase
end


endmodule
module reg_memory(read_reg1,read_reg2,read_data1,read_data2, write_address, regwrite, write_data );
    input [4:0] read_reg1;
    input [4:0] read_reg2;
    output reg [31:0] read_data1;
    output reg [31:0] read_data2;
    input [31:0] write_data;
    input regwrite;
    input [4:0] write_address;


initial begin
    glb.reg_memory[1]=6;
    glb.reg_memory[2]=0;
    glb.reg_memory[0]=0;

end

    always @(write_data) begin
        if(regwrite) begin
        glb.reg_memory[write_address] <= write_data ;
        end 
    end

    always@( read_reg2 or read_reg1) begin
        read_data2 = glb.reg_memory[read_reg2];
        read_data1 = glb.reg_memory[read_reg1];
    end


endmodule



module tb;
reg clk;
wire [31:0]result;
decode_instruction uut(clk,result);

initial begin 
    clk <= 1;
end
always #2 begin
     clk <= ~clk;
end
initial glb.PC = 0;

always #4 glb.PC = glb.PC + 26'd1;


initial $monitor(" sorting array :  %d %d %d %d %d %d " ,glb.data_memory[0],glb.data_memory[1],glb.data_memory[2],glb.data_memory[3],glb.data_memory[4],glb.data_memory[5] );


initial #1000 $finish;

    
endmodule

