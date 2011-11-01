library ieee;
use ieee.std_logic_1164.all;

entity reg_IFID is
	port
	(	Instruction_IF:		IN STD_LOGIC_VECTOR(31 downto 0);
		clk:				IN STD_LOGIC;
		nReset:				IN STD_LOGIC;
		PCplus4_IF:			IN std_logic_vector(31 downto 0);
		PCplus4_ID:			OUT std_logic_vector(31 downto 0);
		bubble_IFID:		IN std_logic;
		freeze	:	in std_logic;
		Hazard :	in std_logic;
		Instruction_ID:		OUT STD_LOGIC_VECTOR(31 downto 0));
end reg_IFID;

architecture reg_IFID_arch of reg_IFID is
begin
registers : process (clk, nReset)
  begin
    -- one register if statement
	if (nReset = '0') then
		--reset Instruction to x00000000 (NOP)
		Instruction_ID <= x"00000000";
		PCplus4_ID <= x"00000000";
    elsif (rising_edge(clk) and freeze = '0' and Hazard = '0') then
		if(bubble_IFID = '0') then
			Instruction_ID <= Instruction_IF;
			PCplus4_ID <= PCplus4_IF;
		else
			Instruction_ID <= x"00000000";
			PCplus4_ID <= x"00000000";
		end if;
    end if;
  end process;
end reg_IFID_arch;
