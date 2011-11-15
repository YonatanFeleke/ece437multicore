library ieee;
use ieee.std_logic_1164.all;

entity reg_IDEX is
	port
	(	RegWr_ID:		IN STD_LOGIC;
		RegWr_EX:		OUT STD_LOGIC;
		MemToReg_ID:	IN STD_LOGIC;
		MemToReg_EX:	OUT STD_LOGIC;
		MemWr_ID:		IN	STD_LOGIC;
		MemWr_EX:		OUT	STD_LOGIC;
		SltSv_ID:		IN STD_LOGIC;
		SltSv_EX:		OUT STD_LOGIC;
		Shift_ID:		IN STD_LOGIC;
		Shift_EX:		OUT std_logic;
		ALUOp_ID:		IN STD_LOGIC_VECTOR(2 downto 0);
		ALUOp_EX:		OUT STD_LOGIC_VECTOR(2 downto 0);
		ALUSrc_ID:		IN STD_LOGIC;
		ALUSrc_EX:		OUT STD_LOGIC;
		A_ID:			IN std_logic_vector(31 downto 0);
		A_EX:			out std_logic_Vector(31 downto 0);
		B_ID:			in std_logic_vector(31 downto 0);
		B_EX:			out std_logic_vector(31 downto 0);	
		Shamt_ID:		in std_logic_vector(31 downto 0);
		Shamt_EX:		out std_logic_vector(31 downto 0);
		Imm16Ext_ID:	in std_logic_vector(31 downto 0);
		Imm16Ext_EX:	out std_logic_vector(31 downto 0);
		Rw_ID:			in std_logic_vector(4 downto 0);
		Rw_EX:			out std_logic_vector(4 downto 0);
		clk		:		in std_logic;
		LUI_ID:			in std_logic;
		LUI_EX:			out std_logic;
		halt_ID:		in std_logic;
		halt_EX:		out std_logic;
		PCplus4_ID:		in std_logic_vector(31 downto 0);
		PCplus4_EX:		out std_logic_vector(31 downto 0);
		PCtoReg_ID:		in std_logic;
		PCtoReg_EX:	out std_logic;
		Opcode_ID:		in std_logic_vector(5 downto 0);
		Opcode_EX:		out std_logic_vector(5 downto 0);
		Hazard:		in std_logic;
		freeze	:	in std_logic;
		nReset	:		in std_logic);
end reg_IDEX;

architecture reg_IDEX_arch of reg_IDEX is
begin
registers : process (clk, nReset)
  begin
    -- one register if statement
	if (nReset = '0') then
		--reset Instruction to x00000000 (NOP)
		RegWr_EX <= '0';
		MemToReg_EX <= '0';
		MemWr_EX <= '0';
		SltSv_EX <= '1';
		Shift_EX <= '0';
		ALUOp_EX <= "000";
		ALUSrc_EX <= '0';
		LUI_EX <= '0';
		A_EX <= x"00000000";
		B_EX <= x"00000000";
		Shamt_EX <= x"00000000";
		Imm16Ext_EX <= x"00000000";
		Rw_EX <= "00000";
		PCplus4_EX <= x"00000000";
		halt_EX <= '0';
		PCtoReg_EX <= '0';
		Opcode_EX <= "000000";
    elsif (rising_edge(clk) and freeze = '0') then
		if(Hazard = '0') then
			RegWr_EX <= RegWr_ID;
			MemToReg_EX <= MemToReg_ID;
			MemWr_EX <= MemWr_ID;
			SltSv_EX <= SltSv_ID;
			Shift_EX <= Shift_ID;
			ALUOp_EX <= ALUOp_ID;
			ALUSrc_EX <= ALUSrc_ID;
			A_EX <= A_ID;
			B_EX <= B_ID;
			Shamt_EX <= Shamt_ID;
			Imm16Ext_EX <= Imm16Ext_ID;
			Rw_EX <= Rw_ID;
			LUI_EX <= LUI_ID;
			halt_EX <= halt_ID;
			PCplus4_EX <= PCplus4_ID;
			PCtoReg_EX <= PCtoReg_ID;
			Opcode_EX <= Opcode_ID;
		else
			RegWr_EX <= '0';
			MemToReg_EX <= '0';
			MemWr_EX <= '0';
			SltSv_EX <= '1';
			Shift_EX <= '0';
			ALUOp_EX <= "000";
			ALUSrc_EX <= '0';
			LUI_EX <= '0';
			A_EX <= x"00000000";
			B_EX <= x"00000000";
			Shamt_EX <= x"00000000";
			Imm16Ext_EX <= x"00000000";
			Rw_EX <= "00000";
			PCplus4_EX <= x"00000000";
			halt_EX <= '0';
			PCtoReg_EX <= '0';
			Opcode_EX <= "000000";
		end if;
    end if;
  end process;
end reg_IDEX_arch;
