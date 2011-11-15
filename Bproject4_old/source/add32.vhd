-- 32 bit version register file
-- evillase

library ieee;
use ieee.std_logic_1164.all;

entity add32 is
	port
	(	A, B:		IN STD_LOGIC_VECTOR(31 downto 0);
		output:		OUT STD_LOGIC_VECTOR(31 downto 0);
		Overflow:	OUT STD_LOGIC);
end add32;

architecture add32_arch of add32 is
	component add1
	port(
		A, B, cin:	in std_logic;
		output, cout:	out	std_logic);
	end component;
	signal carry: std_logic_vector(31 downto 0);
	begin
		A0	:	add1 port map (A(0), B(0), '0', output(0), carry(0));
		ADD:
		for I in 1 to 31 generate
			AI	:	add1 port map(A(I), B(I), carry(I-1),output(I), carry(I));
		end generate; 
		Overflow <= carry(31) xor carry(30);
end add32_arch;
