library ieee;
use ieee.std_logic_1164.all;

entity memControl is 
	port(
		clk		:	in std_logic;
		nReset	:	in std_logic;
		iAddress:	in std_logic_vector(15 downto 0);
		dAddress:	in std_logic_vector(15 downto 0);
		wData:		in std_logic_vector(31 downto 0);
		q:			in std_logic_vector(31 downto 0);
		MemWr: 		in std_logic;
		halt:		in std_logic;
		MemRd:		in std_logic;
		InsRd:		in std_logic;
		memState:	in std_logic_vector(1 downto 0);
		iCacheWait: in std_logic;
		dcacheWait:	in std_logic;
		freeze:			out std_logic;
		Instruction:	out std_logic_vector(31 downto 0);
		readData:		out std_logic_vector(31 downto 0);--to MEM stage
		PCWait:			out std_logic;
		address:		out std_logic_vector(15 downto 0);
		data:			out std_logic_vector(31 downto 0);--to RAM
		wrEn:			out std_logic;
		rdEn:			out std_logic;
		memConflict	:	out std_logic);
end memControl;

architecture memControl_arch of memControl is
type state_type is(idle, busy,writeWait); 
signal state, nextstate : state_type;
signal freeze_int: std_logic;

        constant MEMFREE        : std_logic_vector              := "00";
        constant MEMBUSY        : std_logic_vector              := "01";
        constant MEMACCESS      : std_logic_vector              := "10";
        constant MEMERROR       : std_logic_vector              := "11";
begin 

memControl_state: process( clk, nreset) 
begin 
	if nreset= '0' then
		state <= idle; 
	elsif rising_edge(clk) then
		state <= nextstate; 
	end if; 
end process memControl_state;

memControl_nextstate: process(state, memState) begin
nextstate<=state;  
case state is 
	when idle => 
		if(memState = MEMBUSY) then
			freeze_int <= '1';
			nextstate <= busy;
		else freeze_int <= '0';
		end if;
	when busy =>
		if(memState = MEMACCESS) then
			if(MemWr = '1') then
				nextstate <= writeWait;
				freeze_int <= '1';
			else
				freeze_int <= '0';
				nextstate <= idle;
			end if;
		elsif (memState = MEMFREE) then
			nextstate <= idle;
			freeze_int <= '0';
		else
			freeze_int <= '1';
		end if;
	when writeWait => 
		if(memstate /= MEMACCESS) then
			freeze_int <= '0';
		else
			freeze_int <= '1';
		end if;
		nextstate <= idle;
end case;
end process memControl_nextstate;			


memConflict <= '1' when (MemRd = '1' or MemWr = '1') else '0';
--address <= iAddress when (MemWr = '0' and MemRd = '0') else dAddress;
address <= iAddress when (MemRd = '0' and MemWr = '0') else dAddress;--dAddress when (InsRd = '0') else iAddress;
wrEn <= '1' when MemWr = '1' else '0';-- and InsRd = '0' else '0';--assert RAM write enable when MEM write is asserted
--rdEn <= '1' when (MemWr = '0') else '0';--if not writing, then always reading
rdEn <= '1' when (MemRd = '1' or InsRd = '1') and MemWr = '0' else '0';--read on LW or icache miss
PCWait <= '1' when MemWr = '1' or MemRd = '1' or memState = MEMBUSY or iCacheWait = '1' or dcacheWait = '1' else '0';
data <= wData;
readData <= q when MemRd = '1' else x"00000000";
Instruction <= x"FFFFFFFF" when halt = '1' --halt signal asserted
			else q 		   when (MemWr = '0' and MemRd = '0' and memState = MEMACCESS)--MEM Stage not reading or writing, instruction ready from RAM
			else x"00000000";--NOP, RAM busy or MEM reading/writing
--freeze <= '1' when (memState = MEMBUSY or (memSTATE = MEMACCESS and MemWr = '1')) else '0';
--freeze <= '1' when memState = MEMBUSY or iCacheWait = '1' else '0';--freeze pipeline when MEM stage is reading or writing
freeze <= freeze_int or dcacheWait;
end memControl_arch;
		
