library ieee;
use ieee.std_logic_1164.all;

entity icacheInterface is 
	port( 
		  	iAddress: in std_logic_vector( 31 downto 0); 
			halt: in std_logic;
			hit	:	in std_logic;
			CacheData:	in std_logic_vector(31 downto 0);
			PCWait:			in std_logic;
			Instruction:	out std_logic_vector(31 downto 0);
			tag	:	out std_logic_vector(25 downto 0);
			index:	out	std_logic_vector(3 downto 0);
			icacheWait: out	std_logic;
			rdEn:	out std_logic);
end icacheInterface;

architecture icacheInterface_arch of icacheInterface is

begin

Instruction <= CacheData when PCWait = '0'
			else	x"FFFFFFFF" when halt = '1' 
			else x"00000000";
rdEn <= '0' when hit = '1' else '1';
icacheWait <= '1' when hit = '0' else '0';
tag <= iAddress(31 downto 6);
index <= iAddress(5 downto 2);

end icacheInterface_arch;
