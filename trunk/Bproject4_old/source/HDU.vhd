library ieee;
use ieee.std_logic_1164.all;

entity HDU is
	port(	
		Opcode_EX:		IN STD_LOGIC_VECTOR(5 downto 0);
		Opcode_MEM:		IN STD_LOGIC_VECTOR(5 downto 0);
		Rt:				IN STD_LOGIC_VECTOR(4 downto 0);
		Rs:				IN STD_LOGIC_VECTOR(4 downto 0);
		Rt_EX:			IN STD_LOGIC_VECTOR(4 downto 0);
		Rt_MEM:			IN STD_LOGIC_VECTOR(4 downto 0);
		Hazard:			OUT STD_LOGIC);
end HDU;

architecture HDU_arch of HDU is
    constant LOAD       : std_logic_vector              := "100011";
begin
Hazard <= '1' when (Opcode_EX = LOAD and (Rt_EX = Rt or Rt_EX = Rs)) or
				   (Opcode_MEM = LOAD and (Rt_MEM = Rt or Rt_MEM = Rs))
			  else '0';

end HDU_arch;
