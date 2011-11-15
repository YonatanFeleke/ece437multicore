library ieee;
use ieee.std_logic_1164.all;

entity reg_MEMWB is
	port
	(	RegWr_MEM	:	IN std_logic;
		MemToReg_MEM:	in std_logic;
		SltSvMux_MEM:	in std_logic_vector(31 downto 0);
		readData_MEM:	in std_logic_vector(31 downto 0);
		Rw_MEM:			in std_logic_vector(4 downto 0);
		RegWr_WB	:	out std_logic;
		MemToReg_WB:	out std_logic;
		SltSvMux_WB:	out std_logic_vector(31 downto 0);
		readData_WB:	out std_logic_vector(31 downto 0);
		Rw_WB:			out std_logic_vector(4 downto 0);
		clk:			IN STD_LOGIC;
		LUI_MEM:		in std_logic;
		LUI_WB:			out std_logic;
		Imm16Ext_MEM:	in std_logic_vector(31 downto 0);
		Imm16Ext_WB:	out std_logic_vector(31 downto 0);
		halt_MEM:		in std_logic;
		halt_WB:		out std_logic;
		PCplus4_MEM:	in std_logic_vector(31 downto 0);
		PCplus4_WB:		out std_logic_vector(31 downto 0);
		PCtoReg_MEM:		in std_logic;
		PCtoReg_WB:	out std_logic;
		freeze	:	in std_logic;
		nReset:			IN STD_LOGIC);
end reg_MEMWB;

architecture reg_MEMWB_arch of reg_MEMWB is
begin
registers : process (clk, nReset)
  begin
    -- one register if statement
	if (nReset = '0') then
		--reset Instruction to x00000000 (NOP)
		RegWr_WB <= '0';
		MemToReg_WB <= '0';
		SltSvMux_WB <= x"00000000";
		readData_WB <= x"00000000";
		Rw_WB <= "00000";
		LUI_WB <= '0';
		Imm16Ext_WB <= x"00000000";
		halt_WB <= '0';
		PCplus4_WB <= x"00000000";
		PCtoReg_WB <= '0';
    elsif (rising_edge(clk) and freeze = '0') then
		RegWr_WB <= RegWr_MEM;
		MemToReg_WB <= MemToReg_MEM;
		SltSvMux_WB <= SltSvMux_MEM;
		readData_WB <= readData_MEM;
		Rw_WB <= Rw_MEM;
		LUI_WB <= LUI_MEM;
		Imm16Ext_WB <= Imm16Ext_MEM;
		halt_WB <= halt_MEM;
		PCplus4_WB <= PCplus4_MEM;
		PCtoReg_WB <= PCtoReg_MEM;
    end if;
  end process;
end reg_MEMWB_arch;
