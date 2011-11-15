-- 32 bit version register file
-- evillase

library ieee;
use ieee.std_logic_1164.all;

entity alu is
	port
	(	opcode:		IN STD_LOGIC_VECTOR(2 downto 0);
		A, B:		IN STD_LOGIC_VECTOR(31 downto 0);
		output:		OUT STD_LOGIC_VECTOR(31 downto 0);
		negative:	OUT STD_LOGIC;
		overflow:	OUT	std_logic;
		zero:	OUT STD_LOGIC);
end alu;

architecture alu_arch of alu is

--Add Component
component add32
port(
	A, B: IN STD_LOGIC_VECTOR(31 downto 0);
	output:	OUT STD_LOGIC_VECTOR(31 downto 0);
	Overflow:	OUT STD_LOGIC);
end component;

--Subtract Component
component subtract32
port(
	A, B: IN STD_LOGIC_VECTOR(31 downto 0);
	output:	OUT STD_LOGIC_VECTOR(31 downto 0);
	Overflow:	OUT STD_LOGIC);
end component;

--SLL Component
component shiftleft
port(
		A, B:		IN STD_LOGIC_VECTOR(31 downto 0);
		output:		OUT STD_LOGIC_VECTOR(31 downto 0));
end component;

--SRL Component
component shiftright
port(
		A, B:		IN STD_LOGIC_VECTOR(31 downto 0);
		output:		OUT STD_LOGIC_VECTOR(31 downto 0));
end component;
signal outAdd, outSubtract, outSLL, outSRL, outAnd, outOr, outNor, outXor, outputInternal	:	std_logic_Vector(31 downto 0);
signal overflowAdd, overflowSubtract	:	std_logic;
begin
	--Add
	U0: add32 port map(A, B, outAdd, overflowAdd);
	--Subtract
	U1: subtract32 port map(A, B, outSubtract, overflowSubtract);
	--SLL
	U2: shiftleft port map(A, B, outSLL);
	--SRL
	U3: shiftright port map(A, B, outSRL);
	
	--And
	outAnd <= A and B;
	--Or
	outOr <= A or B;
	--Nor
	outNor <= not(A or B);
	--Xor
	outXor <= A xor B;

	--Output mux logic using opcode
	with opcode select outputInternal <= 
		outSLL when "000",
		outSRL when "001",
		outAdd when "010",
		outSubtract when "011",
		outAnd when "100",
		outNor when "101",
		outOr when "110",
		outXor when "111",
		x"00000000" when others;

		output <= outputInternal;
	
	--Overflow logic. Overflow = 0 when not add or subtract
	with opcode select overflow <=
		overflowAdd when "010",
		overflowSubtract when "011",
		'0' when others;

	--Negative Logic. Set negative flag to sign bit of output
	negative <= outputInternal(31);

	--Zero Logic
	zero <= '1' when (outputInternal = x"00000000") else '0';



end alu_arch;
