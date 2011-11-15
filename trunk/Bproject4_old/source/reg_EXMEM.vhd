library ieee;
use ieee.std_logic_1164.all;

entity reg_EXMEM is
	port
	(	RegWr_EX:		in std_logic;
		RegWr_MEM:		out std_logic;
		MemToReg_EX:		in std_logic;
		MemToReg_MEM:	out std_logic;
		MemWr_EX	:	in	std_logic;
		MemWr_MEM	:	out std_logic;
		SltSvMux_EX:	in std_logic_vector(31 downto 0);
		SltSvMux_MEM:	out std_logic_vector(31 downto 0);
		B_EX	:		in std_logic_vector(31 downto 0);
		B_MEM	:		out std_logic_vector(31 downto 0);
		Rw_EX	:		in std_logic_vector(4 downto 0);
		Rw_MEM	:		out std_logic_vector(4 downto 0);
		clk:			IN STD_LOGIC;
		LUI_EX:			in std_logic;
		LUI_MEM:		out std_logic;
		Imm16Ext_EX:	in std_logic_vector(31 downto 0);
		Imm16Ext_MEM:	out std_logic_vector(31 downto 0);
		halt_EX:		in std_logic;
		halt_MEM:		out std_logic;
		PCplus4_EX:		in std_logic_vector(31 downto 0);
		PCplus4_MEM:	out std_logic_vector(31 downto 0);
		PCtoReg_EX:		in std_logic;
		PCtoReg_MEM:	out std_logic;
		Opcode_EX:		in std_logic_vector(5 downto 0);
		Opcode_MEM:		out std_logic_vector(5 downto 0);
		freeze	:	in std_logic;
		nReset:			IN STD_LOGIC);
end reg_EXMEM;

architecture reg_EXMEM_arch of reg_EXMEM is
begin
registers : process (clk, nReset)
  begin
    -- one register if statement
	if (nReset = '0') then
		--reset Instruction to x00000000 (NOP)
		RegWr_MEM <= '0';
		MemToReg_MEM <= '0';
		MemWr_MEM <= '0';
		SltSvMux_MEM <= x"00000000";
		B_MEM <= x"00000000";
		Rw_MEM <= "00000";	
		LUI_MEM <= '0';
		Imm16Ext_MEM <= x"00000000";
		halt_MEM <= '0';	
		PCplus4_MEM <= x"00000000";
		PCtoReg_MEM <= '0';
		Opcode_MEM <= "000000";
    elsif (rising_edge(clk) and freeze = '0') then
		RegWr_MEM <= RegWr_EX;
		MemToReg_MEM <= MemToReg_EX;
		MemWr_MEM <= MemWr_EX;
		SltSvMux_MEM <= SltSvMux_EX;
		B_MEM <= B_EX;
		Rw_MEM <= Rw_EX;
		LUI_MEM <= LUI_EX;
		Imm16Ext_MEM <= Imm16Ext_EX;
		halt_MEM <= halt_EX;
		PCplus4_MEM <= PCplus4_EX;
		PCtoReg_MEM <= PCtoReg_EX;
		Opcode_MEM <= Opcode_EX;
    end if;
  end process;
end reg_EXMEM_arch;
