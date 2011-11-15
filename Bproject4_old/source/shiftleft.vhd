-- 32 bit version register file
-- evillase

library ieee;
use ieee.std_logic_1164.all;

entity shiftleft is
	port
	(	A, B:		IN STD_LOGIC_VECTOR(31 downto 0);
		output:		OUT STD_LOGIC_VECTOR(31 downto 0));
end shiftleft;

architecture shiftleft_arch of shiftleft is
signal out1,out2,out3,out4:	std_logic_vector(31 downto 0);

begin

	with B(0) select
		out1 <= A(30 downto 0) & '0' when '1',
				A(31 downto 0) when others;

	with B(1) select
		out2 <= out1(29 downto 0) & "00" when '1',
				out1(31 downto 0) when others;

	with B(2) select
		out3 <= out2(27 downto 0) & "0000" when '1',
				out2(31 downto 0) when others;

	with B(3) select
		out4 <= out3(23 downto 0) & "00000000" when '1',
				out3(31 downto 0) when others;

	with B(4) select
		output <=out4(15 downto 0) & "0000000000000000" when '1',
				out4(31 downto 0) when others;



end shiftleft_arch;
