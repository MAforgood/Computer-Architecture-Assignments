library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is
	port (
		Op0, Op1, Op2, Op3, Op4, Op5 : in std_logic;
		RegDest, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp0, ALUOp1 : out std_logic
	);
end control_unit;

architecture behave of control_unit is
  signal Rformat :std_logic;
  signal lw : std_logic;
  signal sw : std_logic;
  signal beq : std_logic;

	begin
		
	Rformat<=(not(Op0)) and (not(Op1)) and (not(Op2)) and (not(Op3)) and (not(Op4)) and (not(Op5));
	lw<=Op0 and Op1 and (not(Op2)) and (not(Op3)) and (not(Op4)) and Op5;	 
	sw<=Op0 and Op1 and (not(Op2)) and Op3 and (not(Op4)) and Op5;
	beq<=(not(Op0)) and (not(Op1)) and Op2 and (not(Op3)) and (not(Op4)) and (not(Op5));		
	
	RegDest<=Rformat;
	ALUSrc<=lw or sw;
	MemtoReg<=lw;
	RegWrite<=Rformat or lw;
	MemRead<=lw;
	MemWrite<=sw;
	Branch<=beq;
	ALUOp1<=Rformat;
	ALUOp0<=beq;
	end behave;	   