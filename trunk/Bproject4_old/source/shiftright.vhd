-- 32 bit version register file
-- evillase

library ieee;
use ieee.std_logic_1164.all;

entity shiftright is
	port
	(	A, B:		IN STD_LOGIC_VECTOR(31 downto 0);
		output:		OUT STD_LOGIC_VECTOR(31 downto 0));
end shiftright;

architecture shiftright_arch of shiftright is
signal out1,out2,out3,out4:	std_logic_vector(31 downto 0);

begin

	with B(0) select
		out1 <= '0' & A(31 downto 1) when '1',
				A(31 downto 0) when others;

	with B(1) select
		out2 <= "00" & out1(31 downto 2) when '1',
				out1(31 downto 0) when others;

	with B(2) select
		out3 <= "0000" & out2(31 downto 4) when '1',
				out2(31 downto 0) when others;

	with B(3) select
		out4 <= "00000000" & out3(31 downto 8) when '1',
				out3(31 downto 0) when others;

	with B(4) select
		output <= "0000000000000000" & out4(31 downto 16) when '1',
				out4(31 downto 0) when others;



end shiftright_arch;
