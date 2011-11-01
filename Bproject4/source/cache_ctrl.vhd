-- cache tempalte
-- this is provided as a guide to build your cache. It is by no means unfallable.
-- you may need to update vector bit ranges to match specifications in lab handout.
--
-- THIS IS NOT ERROR FREE CODE, YOU MUST UPDATE AND VERIFY SANITY OF LOGIC/INTERFACES
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity cache_ctrl is
	port(
		CLK					:	in	std_logic;
		nReset				:	in	std_logic;
		Hit					:	in	std_logic;
		memRd				:	in	std_logic;
		LRUdirty			:	in  std_logic;
		memWr				:	in	std_logic;
		wbTag				:	in std_logic_vector(24 downto 0);
		RamState			:	in	std_logic_vector (01 downto 0);
		memAddr				:	in	std_logic_vector (31 downto 0);
		RamWord				:	in	std_logic_vector (31 downto 0);
		CPUWord				:	in	std_logic_vector (31 downto 0);
		CacheBlockI			:	in	std_logic_vector (63 downto 0);
		CacheBlockO			:	out	std_logic_vector (63 downto 0);
		WordAddr			:	out	std_logic_vector (31 downto 0);
		RamData				:	out	std_logic_vector(31 downto 0);
		clean				:	out std_logic;
		RdEn				:	out	std_logic;
		dcache_en			:	out	std_logic;
		WrEn				:	out	std_logic	
	);
end cache_ctrl;

architecture struct of cache_ctrl is 
-- setup data types here i.e. state
        constant MEMFREE        : std_logic_vector              := "00";
        constant MEMBUSY        : std_logic_vector              := "01";
        constant MEMACCESS      : std_logic_vector              := "10";
        constant MEMERROR       : std_logic_vector              := "11";
type state_type is(idle, MissClean0, MissDirty0,MissClean1,MissDirty1, writeWait0,writeWait1); 
signal state,nextstate: state_type; 
begin

cctrl_state: process(CLK, nReset)
begin
	if nReset = '0' then
		-- set state to idle
		state <= idle;
	elsif rising_edge(CLK) then
		-- set state to next state
		state <= nextstate;
	end if;
end process cctrl_state;

cctrl_ns: process(RamState, state, hit, memRd, memWr)
begin
	nextstate <= state;
	dcache_en <= '0';
	wrEn <= '0';
	rdEn <= '0';
	clean <= '0';
	case state is
		when idle =>
			if(memWr = '1') then--SW instruction
				if(hit = '1') then --hit
					if(memAddr(2) = '1') then
						CacheBlockO(63 downto 32) <= CPUWord;
					else
						CacheBlockO(31 downto 0) <= CPUWord;
					clean <= '0';
					dcache_en <= '1';--cache write enable signal
					end if;
				else--miss
					dcache_en <= '0';--
					if(LRUdirty = '0') then--clean block
						nextstate <= MissClean0;
					else--dirty block
						nextstate <= MissDirty0;
					end if;
				end if;
			end if;
			if(memRd = '1') then--lw instruction
				if(hit = '0') then--clean
					if(LRUdirty = '0') then
						nextstate <= MissClean0;
					else
						nextstate <= MissDirty0;
					end if;
				end if;
			end if;

		when MissDirty0 =>
			WordAddr <= wbTag & memAddr(6 downto 3) & "000";
			RamData <= CacheBlockI(31 downto 0);
			wrEn <= '1';
			if ramstate = MEMACCESS then
				nextstate <= writeWait0;
			else
				nextstate <= MissDirty0;
			end if;

		when writeWait0 =>
			nextstate <= MissDirty1;

		when MissDirty1 =>
			WordAddr <= wbTag & memAddr(6 downto 3) & "100";
			RamData <= CacheBlockI(63 downto 32);
			wrEn<= '1';
			if ramstate = MEMACCESS then
				nextstate <= writeWait1;
			else
				nextstate <= MissDirty1;
			end if;

		when writeWait1 =>
			nextstate <= MissClean0;
		when MissClean0 =>
			rdEn <= '1';
			WordAddr <= memAddr(31 downto 3) & "000";
			CacheBlockO(31 downto 0) <= RamWord;
			if ramstate = MEMACCESS then
				--dcache_en <= '1';
				nextstate <= MissClean1;
			end if;
		when MissClean1=>
			rdEn <= '1';
			WordAddr <= memAddr(31 downto 3) & "100";
			CacheBlockO(63 downto 32) <= RamWord;
			if ramstate = MEMACCESS then
				clean <= '1';
				dcache_en <= '1';
				nextstate <= idle;
			end if;



		-- read data from memory to fill cache block
		-- write data from cache block to memory when dirty
	end case;
end process cctrl_ns;

end;

