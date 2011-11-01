-- 32 bit version register file
-- evillase

library ieee;
use ieee.std_logic_1164.all;

entity instructionDecode is
	port
	(
		Instruction	:	in	std_logic_vector(31 downto 0);
		OpCode		:	out	std_logic_vector(5 downto 0);
		Rt			:	out	std_logic_vector(4 downto 0);
		Rs			:	out std_logic_vector(4 downto 0);
		Rd			:	out std_logic_vector(4 downto 0);
		Shamt		:	out	std_logic_vector(4 downto 0);
		Funct		:	out std_logic_vector(5 downto 0);
		Imm16		:	out std_logic_vector(15 downto 0);
		Jaddress	:	out	std_logic_vector(25 downto 0)
		);
end instructionDecode;

architecture instructionDecode_arch of instructionDecode is

type insType is(ITYPE,JTYPE,RTYPE);
signal instr	:	insType;
signal intRt	:	std_logic_vector(4 downto 0);
signal intOpCode	:	std_logic_vector(5 downto 0);

begin
	intOpCode <= Instruction(31 downto 26);
	OpCode <= intOpCode;

	--decode instruction type
	with intOpCode select instr<=
		RTYPE when "000000",
		JTYPE when "000010",
		JTYPE when "000011",
		ITYPE when others;--MIPS reference has coprocessor instruction type
	
	Jaddress <= Instruction(25 downto 0) when(instr = JTYPE) else "00000000000000000000000000";
	Imm16 <= Instruction(15 downto 0) when(instr = ITYPE) else x"0000";
	Funct <= Instruction(5 downto 0) when(instr = RTYPE) else "000000";
	Shamt <= Instruction(10 downto 6) when(instr = RTYPE) else "00000";
	Rd <= Instruction(15 downto 11) when(instr = RTYPE) else "00000";
	Rt <= Instruction(20 downto 16) when(not(instr = JTYPE)) else intRt;
	Rs <= Instruction(25 downto 21) when(not(instr = JTYPE)) else "00000";

with intOpCode select intRt <=
	"11111" when "000011",
	"00000" when others;	

end instructionDecode_arch;
