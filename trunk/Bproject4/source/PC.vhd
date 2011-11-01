-- 32 bit version register file
-- evillase

library ieee;
use ieee.std_logic_1164.all;

entity PC is
	port
	(
		-- Data from Rs for JR instruction
		A	:	in	std_logic_vector (31 downto 0);
		-- Control Signal for PC mux
		PCSrc	:	in	std_logic_vector(1 downto 0);
		-- clock, positive edge triggered
		clk		:	in	std_logic;
		-- REMEMBER: nReset-> '0' = RESET, '1' = RUN
		nReset	:	in	std_logic;
		-- Immediate 16 bit value sign extended to 32 bits 
		imm16ext:	in	std_logic_vector (31 downto 0);
		--Jump Address
		jmpAddress: in std_logic_vector (25 downto 0);
		Halt	:	in std_logic;
		Memwait :   in std_logic;
		freeze  :	in std_logic;
		PCplus4	:	out std_logic_vector(31 downto 0);
		-- Address for next instruction
		address	:	out	std_logic_vector(31 downto 0)
		);
end PC;

architecture PC_arch of PC is

	component add32
	port(
		A, B: IN STD_LOGIC_VECTOR(31 downto 0);
		output:	OUT STD_LOGIC_VECTOR(31 downto 0);
		Overflow:	OUT STD_LOGIC);
	end component;
	signal	nextAddress, currentAddress	:	std_logic_vector(31 downto 0);
	signal	shiftedImm	:	std_logic_vector(31 downto 0);
	signal  temp		:	std_logic;
	signal  stopProgram :	std_logic;
	signal	PCBranch, PCN, PCJmp	:	std_logic_vector(31 downto 0);

begin

	-- registers process
	registers : process (clk, nReset)
  begin
    -- one register if statement
		if (nReset = '0') then
			-- Reset here
			--reset PC address to x00000000
				address <= x"00000000";
				--nextAddress <= x"00000000";
				currentAddress <= x"00000000";
				stopProgram <= '0';
		elsif (Halt = '1' or stopProgram = '1') then
			stopProgram <= '1';
    	elsif (rising_edge(clk)) then
			if(Memwait = '0' and freeze = '0') then
				address <= nextAddress;
				currentAddress <= nextAddress;
			end if;
    end if;
  end process;
	shiftedImm <= imm16ext(29 downto 0) & "00";
	PCplus4 <= PCN;
	A0: add32 port map(x"00000004", currentAddress, PCN, temp);
	A1:	add32 port map(currentAddress, shiftedImm, PCBranch, temp);
	PCJmp <= PCN(31 downto 28) & jmpAddress & "00";
	with PCSrc select nextAddress <=
		PCN when "00",
		PCBranch when "01",
		A when "10",
		PCJmp when others;



end PC_arch;
