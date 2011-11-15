library ieee;
use ieee.std_logic_1164.all;

entity mainControl is
	port
	(	
		clk		:		IN std_logic;
		nReset	:		IN std_logic;
		Instruction:	IN STD_LOGIC_VECTOR(31 downto 0);
		Zero	:	IN	std_logic;
		Memwait	:	OUT std_logic;
		MemToReg:	OUT STD_LOGIC;
		MemWr:		OUT STD_LOGIC;
		ALUOp:		OUT STD_LOGIC_VECTOR(2 downto 0);
		ALUSrc:		OUT STD_LOGIC;
		Shift:		OUT STD_LOGIC;
		RegDst:		OUT STD_LOGIC;
		RegWr:		OUT STD_LOGIC;
		ExtOp:		OUT STD_LOGIC;
		LUI:	OUT STD_LOGIC;
		PCtoReg:	OUT STD_LOGIC;
		PCSrc:		OUT	STD_LOGIC_VECTOR(1 downto 0);
		SltSv:		OUT STD_LOGIC;
		bubble_IFID:	out std_logic;
		Halt :		OUT STD_LOGIC);
end mainControl;

architecture mainControl_arch of mainControl is

type state_type is (idle, PCFreeze);
signal   state, nextState : state_type;
signal OpCode, funct	:	std_logic_vector(5 downto 0);
signal RtypeALUop		:	std_logic_vector(2 downto 0);
signal intALUSrc	:	std_logic;
signal intPCSrc	:	std_logic_vector(1 downto 0);
signal intBNE, intBEQ : std_logic_vector(1 downto 0);
begin

	state_machine : process(clk,nReset)
	begin
		if(nReset = '0') then
			state <= idle;
		elsif (falling_edge(clk)) then
			state <= nextState;
		end if;
	end process;

	nextstate_logic : process(state,Opcode)
	begin
		case state is
			when idle =>
				if(Opcode = "100011")then
					nextState <= PCFreeze;
					Memwait <= '1';
				else
					nextState <= idle;
					Memwait <= '0';
				end if;
			when PCFreeze =>
					Memwait <= '0';
					nextState <= idle;
		end case;
	end process;
	OpCode <= Instruction(31 downto 26);
	funct <= Instruction(5 downto 0);

	--set internal ALU op based on function bits of Instruction
	with funct select RtypeALUop <=
		"000" when "000000",--SLL
		"001" when "000010",--SRL
		"010" when "100001",--ADDU
		"011" when "101010",--SLT
		"011" when "101011",--SLTU
		"011" when "100011",--SUBU
		"100" when "100100",--AND
		"101" when "100111",--NOR
		"110" when "100101",--OR
		"111" when "100110",--XOR
		"010" when others; --????? JR

	--set ALUop based on opcode from instruction
	with OpCode select ALUOp <=
		RtypeALUop when "000000",--r-type OP code
		"010" when "001001", --ADDIU
		"100" when "001100", --ANDI
		"011" when "000100", --BEQ
		"011" when "000101", --BNE
		"010" when "100011", --LW
		"110" when "001101", --ORI
		"011" when "001010", --SLTI
		"011" when "001011", --SLTIU
		"010" when "101011", --SW
		"111" when "001110", --XORI
		"010" when others; --Dont Care
	
	--ALUSrc = '1' when I-Type Instruction and not (BEQ or BNE) else '0'
	ALUSrc <= intALUSrc;
	intALUSrc <= '1' when (not(OpCode = "000000") and not(OpCode(5 downto 1) = "00001") and not(OpCode(5 downto 2) = "0100") and not(OpCode(5 downto 1) = "00010")) else '0';

	--MemToReg = 1 on a LW, 0 else
	MemToReg <= '1' when (OpCode = "100011") else '0';
	
	--MemWr = 1 on a SW, 0 else
	MemWr <= '1' when (OpCode = "101011") else '0';

	--Set Write Register to Rd on R-Type instruction, else set to Rt
	RegDst <= '1' when (OpCode = "000000") else '0';
	
	--RegWr = 1 when instruction is (R-Type and not JR), (I-Type and not BEQ, BNE, or SW), or JAL. Else 0
	RegWr <=
		'0' when Instruction <= x"00000000" else 
		'1' when(
		(OpCode = "000000" and not(funct = "001000"))--R-Type, not JR
	 or (
			(
				not(OpCode = "000000") 
		 		and not(OpCode(5 downto 1) = "00001") 
		 		and not(OpCode(5 downto 2) = "0100")
			) 
			and not(OpCode(5 downto 1) = "00010")--not BEQ or BNE 
		 	and not(OpCode = "101011")--not SW
		)
	 or (OpCode = "000011")) --JAL
	else '0';

	--ExtOp = 1 when I type and op = (ADDIU, LW, SLTI, SLTIU, SW, BEQ, BNE)00100 00101 else 0
	ExtOp <= '1' when ((intALUSrc = '1' or opcode = "000100" or opcode = "000101") and (not(OpCode(5 downto 1) = "00110") and not(OpCode = "001110"))) else '0';

	--Set ImmToReg to 1 on a LUI instruction, else 0
	LUI <= '1' when (OpCode = "001111") else '0';
	
	--Set PCtoReg to 0 on a JAL instruction, else 1
	PCtoReg <= '0' when (OpCode = "000011") else '1';


	--Set SltSv to '0' on any SLT instruction
	SltSv <= '0' when (
		(OpCode = "000000" --R-Type
			and(
				funct = "101010" or--SLT
				funct = "101011"--SLTU
			   )
		)
		or OpCode = "001010"--SLTI
		or OpCode = "001011")--SLTIU
	else '1';
	
	with funct select intPCSrc <=
		"10" when "001000",--JR Instruction Function
		"00" when others;--Not JR Instruction Function
	with Zero select intBEQ <=
		"00" when '0',--BEQ, Equality condition not met = PC+4
		"01" when others;--BEQ, Equality condition met = Branch
	with Zero select intBNE <=
		"00" when '1',--BNE, Equality condition not met = PC+4
		"01" when others;--BEQ, Equality condition met = Branch
	with OpCode select PCSrc <=
		intBEQ when "000100",--BEQ
		intBNE when "000101",--BNE
		"11" when "000010",--J
		"11" when "000011",--JAL
		intPCSrc when "000000",--R-TYPE
		"00" when others;--PC+4

	--Shift = 1 when RTYPE and SLL or SRL, else 0
	Shift <= '1' when (OpCode = "000000" and (funct = "000000" or funct = "000010")) else '0';
	--Place a bubble after a jump insruction to allow jump destination to be read
	bubble_IFID <= '1' when ((OpCode = "000010" or OpCode = "000011") or--J or JAL
							 (OpCode = "000000" and funct = "001000") or--JR
							 (OpCode = "000100" and Zero = '1') or --BEQ with branch taken
							 (OpCode = "000101" and Zero = '0'))--BNE with branch taken
						else '0';
	Halt <= '1' when (Instruction = x"FFFFFFFF" and nReset = '1') else '0';
end mainControl_arch;
