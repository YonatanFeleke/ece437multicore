library ieee;
use ieee.std_logic_1164.all;

entity extender is
	port
	(	imm16:		IN STD_LOGIC_VECTOR(15 downto 0);
		ExtOp:		IN STD_LOGIC;
		imm32:		OUT STD_LOGIC_VECTOR(31 downto 0));
end extender;

architecture extender_arch of extender is
signal signExtended	:	STD_LOGIC_VECTOR(15 downto 0);
begin
	with imm16(15) select signExtended <=
		"1111111111111111" when '1',
		"0000000000000000" when others;
	with ExtOp select imm32 <=
		"0000000000000000" & imm16 when '0',
		signExtended & imm16 when others;

end extender_arch;
