library ieee;
use ieee.std_logic_1164.all;

entity mycpu is
		port ( 
			-- clock signal
			CLK							:		in	std_logic;
			-- reset for processor
			nReset					:		in	std_logic;
			-- halt for processor
			halt						:		out	std_logic;
			-- instruction memory address
			ramAddr				:		out	std_logic_vector(15 downto 0);
			-- instruction data read from memory
			ramData				:		out	std_logic_vector(31 downto 0);
			-- data memory address
			ramWen	:	out std_logic;
			ramRen	:	out std_logic;
			ramQ	:	in std_logic_vector(31 downto 0);
			ramState	:	in std_logic_vector(1 downto 0)
		);
end mycpu;

architecture mycpu_arch of mycpu is

--Internal Signals
SIGNAL Instruction_IF,Instruction_ID	:	std_logic_vector(31 downto 0);--32 bit output from iram
SIGNAL MemToReg,MemToReg_EX,MemToReg_MEM,MemToReg_WB:	STD_LOGIC;--Control Signal, set when reading from dram
SIGNAL MemWr, MemWr_EX,MemWr_MEM:		STD_LOGIC;--control signal, set when writing to memory
SIGNAL ALUOp,ALUOp_EX:		STD_LOGIC_VECTOR(2 downto 0);--control, alu op code
SIGNAL ALUSrc,ALUSrc_EX:		STD_LOGIC;--control signal to determine source of alu bus b
SIGNAL Shift,Shift_EX:		STD_LOGIC;--control signal. set to insert shift amount into alu
SIGNAL RegDst:		STD_LOGIC;--control signal to choose between rt and rd for write reg
SIGNAL RegWr,RegWr_EX,RegWr_MEM,RegWr_WB:		STD_LOGIC;--write enable for register
SIGNAL ExtOp:		STD_LOGIC;--control signal, determine sign or zero extend
SIGNAL LUI,LUI_EX,LUI_MEM,LUI_WB:	STD_LOGIC;--control signal used for JR instruction
SIGNAL PCtoReg,PCtoReg_EX,PCtoReg_MEM,PCtoReg_WB:		STD_LOGIC;--control signal used for JAL insruction
SIGNAL PCSrc:		STD_LOGIC_VECTOR(1 downto 0);--control signal used for next PC
SIGNAL SltSv,SltSv_EX:		STD_LOGIC;--control signal used on an SLT signal
SIGNAL Rt	:		STD_LOGIC_VECTOR(4 downto 0);--Rt register
SIGNAL Rs	:		STD_LOGIC_VECTOR(4 downto 0);--Rs register
SIGNAL Rd	:		STD_LOGIC_VECTOR(4 downto 0);--Rd register
SIGNAL Shamt	:	STD_LOGIC_VECTOR(4 downto 0);--shift amount
SIGNAL Shamt_EX,intShamt	:	STD_LOGIC_VECTOR(31 downto 0);--shift amount in execution stage
SIGNAL Imm16	:	STD_LOGIC_VECTOR(15 downto 0);--Immediate 16 bit value
SIGNAL Imm16ext,Imm16ext_EX, Imm16ext_MEM, Imm16ext_WB:	STD_LOGIC_VECTOR(31 downto 0);--Immediate value extended
SIGNAL Jaddress	:	std_logic_vector(25 downto 0);--Jump address going into PC block
SIGNAL A,B,A_EX,B_EX,B_MEM		:	std_logic_vector(31 downto 0);--read data from registers
SIGNAL PCplus4,PCplus4_ID,PCplus4_EX,PCplus4_MEM,PCplus4_WB	:	std_Logic_vector(31 downto 0);--PC + 4
SIGNAL Memwait,PCWait  :   std_logic;--control signal used to indicate a LW instruction
SIGNAL PCaddress	:	std_logic_vector(31 downto 0);--Next PC address
SIGNAL RwMux,Rw_EX,Rw_MEM,Rw_WB	:	std_logic_vector(4 downto 0);--output of Rd Rt Mux
SIGNAL JALMux	:	std_logic_vector(31 downto 0);--output of JAL Mux
SIGNAL OpCode, Opcode_EX,Opcode_MEM	:	std_logic_vector(5 downto 0);--Opcode from Instruction
SIGNAL Funct	:	std_logic_vector(5 downto 0);--Function from Instruction
SIGNAL ALUOut	:	std_logic_vector(31 downto 0);--output from ALU
SIGNAL Negative	:	std_logic;--Negative flag fro ALU
SIGNAL Zero		:	std_logic;--Zero flag from ALU
SIGNAL Equal	: std_logic;--output from compare block
SIGNAL Overflow :	std_logic;--Overflow flag fro ALU
SIGNAL readData,readData_WB	:	std_logic_vector(31 downto 0);--read data from dram
SIGNAL ShiftMux	:	std_logic_vector(31 downto 0);--output from shift mux, input to ALU B
SIGNAL ALUSrcMux	:	std_logic_vector(31 downto 0);--output from ALUSrc Mux
SIGNAL halt_ID,halt_EX, halt_MEM, halt_WB	:	std_logic;--halt signals for different stages
SIGNAL intHalt,fakeHalt		:	std_logic;--internal Halt signal
SIGNAL LUIMux	:	std_logic_vector(31 downto 0);--mux used for LUI instruction. output goes into JAL Mux
SIGNAL MemtoRegMux	:	std_logic_vector(31 downto 0);--Output of MemtoReg Mux. goes to LUI Mux
SIGNAL SLTMux	:	std_logic_vector(31 downto 0);--Mux used for SLT instructions
SIGNAL SltSvMux,SltSvMux_MEM,SltSvMux_WB	:	std_logic_vector(31 downto 0);--Mux used for SLT instructions
SIGNAL AddressControlMux	:	std_logic_vector(15 downto 0);--Mux used to interface with test bench
SIGNAL memFreeze	: std_logic;
SIGNAL bubble_IFID	:	std_logic;
--Components
COMPONENT PC
PORT(
	A			:	IN	std_logic_vector(31 downto 0);
	PCSrc		:	IN	std_logic_vector(1 downto 0);
	clk			:	IN	std_logic;
	nReset		:	IN	std_logic;
	imm16ext	:	IN	std_logic_vector(31 downto 0);
	jmpAddress	:	IN	std_logic_vector(25 downto 0);
	Halt		:	IN	std_logic;
	Memwait		:	IN  std_logic;
	PCplus4		:	OUT	std_logic_vector(31 downto 0);
	address		:	OUT	std_logic_vector(31 downto 0)
);
END COMPONENT;

COMPONENT registerFile
PORT(
	wdat		:	in	std_logic_vector (31 downto 0);
	wsel		:	in	std_logic_vector (4 downto 0);
	wen			:	in	std_logic;
	clk			:	in	std_logic;
	nReset		:	in	std_logic;
	rsel1		:	in	std_logic_vector (4 downto 0);
	rsel2		:	in	std_logic_vector (4 downto 0);
	rdat1		:	out	std_logic_vector (31 downto 0);
	rdat2		:	out	std_logic_vector (31 downto 0)	
);
END COMPONENT;

COMPONENT mainControl
PORT(
	clk		:		IN STD_LOGIC;
	nReset	:		IN STD_LOGIC;
	Instruction:	IN STD_LOGIC_VECTOR(31 downto 0);
	Zero	:		IN STD_LOGIC;
	Memwait :		OUT STD_LOGIC;
	MemToReg:		OUT STD_LOGIC;
	MemWr:			OUT STD_LOGIC;
	ALUOp:			OUT STD_LOGIC_VECTOR(2 downto 0);
	ALUSrc:			OUT STD_LOGIC;
	Shift:			OUT STD_LOGIC;
	RegDst:			OUT STD_LOGIC;
	RegWr:			OUT STD_LOGIC;
	ExtOp:			OUT STD_LOGIC;
	LUI:		OUT STD_LOGIC;
	PCtoReg:		OUT STD_LOGIC;
	PCSrc:			OUT	STD_LOGIC_VECTOR(1 downto 0);
	SltSv:			OUT STD_LOGIC;
	bubble_IFID:	OUT std_logic;
	Halt:			OUT STD_LOGIC
);
END COMPONENT;

COMPONENT instructionDecode
PORT(
	Instruction	:	in	std_logic_vector(31 downto 0);
	OpCode		:	out	std_logic_vector(5 downto 0);
	Rt			:	out	std_logic_vector(4 downto 0);
	Rs			:	out std_logic_vector(4 downto 0);
	Rd			:	out std_logic_vector(4 downto 0);
	Shamt		:	out	std_logic_vector(4 downto 0);
	Funct		:	out std_logic_vector(5 downto 0);
	Imm16		:	out std_logic_vector(15 downto 0);
	Jaddress	:	out	std_logic_vector(25 downto 0)
);
END COMPONENT;

COMPONENT alu
PORT(
	opcode:		IN STD_LOGIC_VECTOR(2 downto 0);
	A, B:		IN STD_LOGIC_VECTOR(31 downto 0);
	output:		OUT STD_LOGIC_VECTOR(31 downto 0);
	negative:	OUT STD_LOGIC;
	overflow:	OUT STD_LOGIC;
	zero:		OUT STD_LOGIC
);
END COMPONENT;

COMPONENT extender
PORT(
	imm16:		IN STD_LOGIC_VECTOR(15 downto 0);
	ExtOp:		IN STD_LOGIC;
	imm32:		OUT STD_LOGIC_VECTOR(31 downto 0)
);
END COMPONENT;

component reg_EXMEM
port(	
		RegWr_EX:		in std_logic;
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
		LUI_EX:			IN std_Logic;
		LUI_MEM:		out std_logic;
		Imm16Ext_EX:	in std_logic_vector(31 downto 0);
		Imm16Ext_MEM:	out std_logic_vector(31 downto 0);
		halt_EX:		in std_logic;
		halt_MEM:		out std_logic;
		PCplus4_EX:		in std_logic_vector(31 downto 0);
		PCplus4_MEM:	out std_logic_vector(31 downto 0);
		PCtoReg_EX:		in std_logic;
		PCtoReg_MEM:	out std_logic;
		freeze	:	in std_logic;
		nReset:			IN STD_LOGIC);
end component;

component reg_IDEX
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
		LUI_ID	:		in std_logic;
		LUI_EX	:		out std_logic;
		halt_ID:		in std_logic;
		halt_EX:		out std_logic;
		PCplus4_ID:		in std_logic_vector(31 downto 0);
		PCplus4_EX:	out std_logic_vector(31 downto 0);
		PCtoReg_ID:		in std_logic;
		PCtoReg_EX:	out std_logic;
		freeze	:	in std_logic;
		nReset	:		in std_logic);
end component;

component reg_IFID
	port
	(	Instruction_IF:		IN STD_LOGIC_VECTOR(31 downto 0);
		clk:				IN STD_LOGIC;
		nReset:				IN STD_LOGIC;
		PCplus4_IF:			IN std_logic_vector(31 downto 0);
		PCplus4_ID:			out std_logic_vector(31 downto 0);
		bubble_IFID:		in std_logic;
		freeze	:	in std_logic;
		Instruction_ID:		OUT STD_LOGIC_VECTOR(31 downto 0));
end component;

component reg_MEMWB
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
		halt_MEM	:	in std_logic;
		halt_WB	:		out std_logic;
		PCplus4_MEM:		in std_logic_vector(31 downto 0);
		PCplus4_WB:	out std_logic_vector(31 downto 0);
		PCtoReg_MEM:		in std_logic;
		PCtoReg_WB:	out std_logic;
		freeze	:	in std_logic;
		nReset:			IN STD_LOGIC);
end component;

component memControl 
	port(
		iAddress:	in std_logic_vector(15 downto 0);
		dAddress:	in std_logic_vector(15 downto 0);
		wData:		in std_logic_vector(31 downto 0);
		q:			in std_logic_vector(31 downto 0);
		MemWr: 		in std_logic;
		halt:		in std_logic;
		MemRd:		in std_logic;
		memState:	in std_logic_vector(1 downto 0);
		freeze:		out	std_logic;
		Instruction:	out std_logic_vector(31 downto 0);
		readData:		out std_logic_vector(31 downto 0);
		PCWait:			out std_logic;
		address:		out std_logic_vector(15 downto 0);
		data:			out std_logic_vector(31 downto 0);
		wrEn:			out std_logic;
		rdEn:			out std_logic);
end component;

component comparator
	port
        (
        A:	IN	std_logic_vector(31 downto 0);
		B:	IN	std_logic_vector(31 downto 0);
		Equal:	out std_logic
        );
end component;

component ForwardUnit
        port
        (
				Opcode_EX:		IN  std_logic_vector(5 downto 0);
				Opcode_MEM:		IN  std_logic_vector(5 downto 0);
                Data_EX:		IN	std_logic_vector(31 downto 0);
                Data_MEM:		IN	std_logic_vector(31 downto 0);
                Data_WB:		IN	std_logic_vector(31 downto 0);
                PCplus4_EX:		IN	std_logic_vector(31 downto 0);
                PCplus4_MEM:	IN	std_logic_vector(31 downto 0);
                Imm16Ext_EX:	IN	std_logic_vector(31 downto 0);
                Imm16Ext_MEM:	IN	std_logic_vector(31 downto 0);
				Rw_EX:			IN  std_logic_vector(4 downto 0);
				Rw_MEM:			IN  std_logic_vector(4 downto 0);
				Rw_WB:			IN  std_logic_vector(4 downto 0);
				Rs	:			IN std_logic_vector(4 downto 0);
				Rt	:			IN std_logic_vector(4 downto 0);
				RegWr_EX:		IN std_logic;
				RegWr_MEM:		IN std_logic;
				RegWr_WB:		IN std_logic;
				ForwardRs:		OUT std_logic_vector(31 downto 0);
				ForwardRt:		OUT std_logic_vector(31 downto 0);
				RsSel:			OUT std_logic;
				RtSel:			OUT std_logic
				
        );
end component;


begin
--Output Signals
--intHalt <= '1' when (Instruction_IF = x"FFFFFFFF" and nReset = '1') else '0';
halt <= halt_WB;



PCblock	:	PC
	PORT MAP(
		A => A,
		PCSrc => PCSrc,
		clk => clk,
		nReset => nReset,
		imm16ext => Imm16Ext,
		jmpAddress => Jaddress,
		Halt => halt_ID,
		Memwait => PCWait,
		PCplus4 => PCplus4,
		address => PCaddress
	);

RegisterBlock	:	registerFile
	PORT MAP(
		wdat => LUIMux,
		wsel => Rw_WB,
		wen => RegWr_WB,
		clk => clk,
		nReset => nReset,
		rsel1 => Rs,
		rsel2 => Rt,
		rdat1 => A,
		rdat2 => B
	);

CompareBlock	:	comparator
	PORT MAP(
		A => A,
		B => B,
		Equal => Equal
	);

DecodeBlock	:	instructionDecode
	PORT MAP(
		Instruction => Instruction_ID,
		OpCode => Opcode,
		Rt => Rt,
		Rs => Rs,
		Rd => Rd,
		Shamt => Shamt,
		Funct => Funct,
		Imm16 => Imm16,
		Jaddress => Jaddress
	);

SignExtendBlock	:	extender
	PORT MAP(
		imm16 => Imm16,
		ExtOp => ExtOp,
		imm32 => Imm16ext
	);

ControlBlock	:	mainControl
	PORT MAP(
		clk	=> clk,
		nReset => nReset,
		Instruction => Instruction_ID,
		Zero => Equal,
		Memwait => Memwait,
		MemToReg => MemToReg,
		MemWr => MemWr,
		ALUOp => ALUOp,
		ALUSrc => ALUSrc,
		Shift => Shift,
		RegDst => RegDst,
		RegWr => RegWr,
		ExtOp => ExtOp,
		LUI => LUI,
		PCtoReg => PCtoReg,
		PCSrc => PCSrc,
		SltSv => SltSv,
		bubble_IFID => bubble_IFID,
		Halt => halt_ID
	);

ALUBlock	:	alu
	PORT MAP(
		opcode => ALUOp_EX,
		A => A_EX,
		B => ShiftMux,
		output => ALUOut,
		negative => Negative,
		overflow => Overflow,
		zero => Zero
	);
MemoryController: memControl 
	port map(
		iAddress => PCaddress(15 downto 0),	
		dAddress => SltSvMux_MEM(15 downto 0),
		wData => B_MEM,
		q => ramQ,
		MemWr => MemWr_MEM,
		halt => halt_ID,
		MemRd => MemToReg_MEM,
		memState => ramState,
		freeze => memFreeze,
		Instruction => Instruction_IF,
		readData => readData,
		PCWait => PCWait,
		address => ramAddr,
		data => ramData,
		wrEn => ramWen,
		rdEn => ramRen
	);
Register_MEMWB: reg_MEMWB
	port map(
		RegWr_MEM => RegWr_MEM,
		MemToReg_MEM => MemToReg_MEM,
		SltSvMux_MEM => SltSvMux_MEM,
		readData_MEM => readData,
		Rw_MEM => Rw_MEM,
		RegWr_WB => RegWr_WB,
		MemToReg_WB => MemToReg_WB,
		SltSvMux_WB => SltSvMux_WB,
		readData_WB => readData_WB,
		Rw_WB => Rw_WB,
		clk => clk,
		LUI_MEM => LUI_MEM,
		LUI_WB => LUI_WB,
		Imm16Ext_MEM => Imm16Ext_MEM,
		Imm16Ext_WB => Imm16Ext_WB,
		halt_MEM => halt_MEM,
		halt_WB => halt_WB,
		PCplus4_MEM => PCplus4_MEM,
		PCplus4_WB => PCplus4_WB,
		PCtoReg_MEM => PCtoReg_MEM,
		PCtoReg_WB => PCtoReg_WB,
		freeze => memFreeze,
		nReset => nReset);

Register_IFID: reg_IFID
	port map(
		Instruction_IF => Instruction_IF,
		clk => clk,
		nReset => nReset,
		PCplus4_IF => PCplus4,
		PCplus4_ID => PCplus4_ID,
		bubble_IFID => bubble_IFID,
		freeze => memFreeze,
		Instruction_ID => Instruction_ID
	);
intShamt <= (x"000000" & "000" & Shamt);
Register_IDEX: reg_IDEX
	port map(
		RegWr_ID => RegWr,
		RegWr_EX => RegWr_EX,
		MemToReg_ID => MemToReg,
		MemToReg_EX => MemToReg_EX,
		MemWr_ID => MemWr,
		MemWr_EX => MemWr_EX,
		SltSv_ID => SltSv,
		SltSv_EX => SltSv_EX,
		Shift_ID => Shift,
		Shift_EX => Shift_EX,
		ALUOp_ID => ALUOp,
		ALUOp_EX => ALUOp_EX,
		ALUSrc_ID => ALUSrc,
		ALUSrc_EX => ALUSrc_EX,
		A_ID => A,
		A_EX => A_EX,
		B_ID => B,
		B_EX => B_EX,
		Shamt_ID => intShamt,
		Shamt_EX => Shamt_EX,
		Imm16Ext_ID => Imm16Ext,
		Imm16Ext_EX => Imm16Ext_EX,
		Rw_ID => RwMux,
		Rw_EX => Rw_EX,
		clk => clk,
		LUI_ID => LUI,
		LUI_EX => LUI_EX,
		halt_ID => halt_ID,
		halt_EX => halt_EX,
		PCplus4_ID => PCplus4_ID,
		PCplus4_EX => PCplus4_EX,
		PCtoReg_ID => PCtoReg,
		PCtoReg_EX => PCtoReg_EX,
		freeze => memFreeze,
		nReset => nReset);

Register_EXMEM: reg_EXMEM
	port map(	
		RegWr_EX => RegWr_EX,
		RegWr_MEM => RegWr_MEM,
		MemToReg_EX => MemToReg_EX,
		MemToReg_MEM => MemToReg_MEM,
		MemWr_EX => MemWr_EX,
		MemWr_MEM => MemWr_MEM,
		SltSvMux_EX => SltSvMux,
		SltSvMux_MEM => SltSvMux_MEM,
		B_EX => B_EX,
		B_MEM => B_MEM,
		Rw_EX => Rw_EX,
		Rw_MEM => Rw_MEM,
		clk => clk,
		LUI_EX => LUI_EX,
		LUI_MEM => LUI_MEM,
		Imm16Ext_EX => Imm16Ext_EX,
		Imm16Ext_MEM => Imm16Ext_MEM,
		halt_EX => halt_EX,
		halt_MEM => halt_MEM,
		PCplus4_EX => PCplus4_EX,
		PCplus4_MEM => PCplus4_MEM,
		PCtoReg_EX => PCtoReg_EX,
		PCtoReg_MEM => PCtoReg_MEM,
		freeze => memFreeze,
		nReset => nReset);

ForwardingUnit:  ForwardUnit
        port map(
				Opcode_EX:		IN  std_logic_vector(5 downto 0);
				Opcode_MEM:		IN  std_logic_vector(5 downto 0);
                Data_EX:		IN	std_logic_vector(31 downto 0);
                Data_MEM:		IN	std_logic_vector(31 downto 0);
                Data_WB:		IN	std_logic_vector(31 downto 0);
                PCplus4_EX:		IN	std_logic_vector(31 downto 0);
                PCplus4_MEM:	IN	std_logic_vector(31 downto 0);
                Imm16Ext_EX:	IN	std_logic_vector(31 downto 0);
                Imm16Ext_MEM:	IN	std_logic_vector(31 downto 0);
				Rw_EX:			IN  std_logic_vector(4 downto 0);
				Rw_MEM:			IN  std_logic_vector(4 downto 0);
				Rw_WB:			IN  std_logic_vector(4 downto 0);
				Rs	:			IN std_logic_vector(4 downto 0);
				Rt	:			IN std_logic_vector(4 downto 0);
				RegWr_EX:		IN std_logic;
				RegWr_MEM:		IN std_logic;
				RegWr_WB:		IN std_logic;
				ForwardRs:		OUT std_logic_vector(31 downto 0);
				ForwardRt:		OUT std_logic_vector(31 downto 0);
				RsSel:			OUT std_logic;
				RtSel:			OUT std_logic
				
        );

--Internal Muxes
RwMux <= Rd when(RegDst = '1') else Rt;
ALUSrcMux <= B_EX when (ALUSrc_EX = '0') else Imm16ext_EX;
ShiftMux <= ALUSrcMux when (Shift_EX = '0') else Shamt_EX;-- x"000000" & "000" & Shamt;
MemtoRegMux <= SltSvMux_WB when(MemtoReg_WB = '0') else readData_WB;
LUIMux <= JALMux when(LUI_WB = '0') else Imm16Ext_WB(15 downto 0) & x"0000";
JALMux <= PCplus4_WB when (PCtoReg_WB = '0') else MemtoRegMux;
SLTMux <= x"00000000" when (Negative = '0') else x"00000001";
SltSvMux <= SLTMUX when (SltSv_EX = '0') else ALUOut;
--AddressControlMux <= ALUOut(15 downto 0) when (intHalt = '0') else dumpAddr;

end mycpu_arch;
