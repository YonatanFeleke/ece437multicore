-- 32 bit version register file
-- evillase

library ieee;
use ieee.std_logic_1164.all;

entity add1 is
	port
	(	A, B:		IN STD_LOGIC;
		output:		OUT STD_LOGIC;
		cin:	IN STD_LOGIC;
		cout:	OUT STD_LOGIC);
end add1;

architecture add1_arch of add1 is
begin
	output <= cin xor (A xor B);
	cout <= (not cin and B and A) or (cin and (B or A));

end add1_arch;
