library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 

entity comparator is
        port
        (
                A:	IN	std_logic_vector(31 downto 0);
				B:	IN	std_logic_vector(31 downto 0);
				Equal:	out std_logic
        );
end comparator;

architecture comparator_arch of comparator is
signal diff: std_logic_vector(31 downto 0);
begin
	diff <= A xor B;
	Equal <= '1' when diff = x"00000000" else '0';

end comparator_arch;
