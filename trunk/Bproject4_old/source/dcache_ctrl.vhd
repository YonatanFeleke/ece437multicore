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
use ieee.numeric_std.all; 

entity dcache_ctrl is
	port(
		CLK					:	in	std_logic;
		nReset				:	in	std_logic;
		Hit					:	in	std_logic;
		halt				:	in std_logic;
		memRd				:	in	std_logic;
		LRUdirty			:	in  std_logic;
		dirty				:   in std_logic;
		memWr				:	in	std_logic;
		wbTag				:	in std_logic_vector(24 downto 0);
		RamState			:	in	std_logic_vector (01 downto 0);
		memAddr				:	in	std_logic_vector (31 downto 0);
		RamWord				:	in	std_logic_vector (31 downto 0);
		CPUWord				:	in	std_logic_vector (31 downto 0);
		CacheBlockI			:	in	std_logic_vector (63 downto 0);
		dumpBlock			:	in std_logic_vector(63 downto 0);
		dumpTag				:   in std_logic_vector(24 downto 0);
		CacheBlockO			:	out	std_logic_vector (63 downto 0);
		WordAddr			:	out	std_logic_vector (31 downto 0);
		RamData				:	out	std_logic_vector(31 downto 0);
		dumpIndex			:	out std_logic_vector(3 downto 0);
		dumpWay				:	out std_logic_vector(1 downto 0);
		clean				:	out std_logic;
		RdEn				:	out	std_logic;
		dcache_en			:	out	std_logic;
		WrEn				:	out	std_logic;
		dcacheWait			:	out std_logic;
		halt_out			:	out std_logic
	);
end dcache_ctrl;

architecture struct of dcache_ctrl is 
-- setup data types here i.e. state
        constant MEMFREE        : std_logic_vector              := "00";
        constant MEMBUSY        : std_logic_vector              := "01";
        constant MEMACCESS      : std_logic_vector              := "10";
        constant MEMERROR       : std_logic_vector              := "11";
type state_type is(idle, MissClean0, MissDirty0,MissClean1,MissDirty1, writeWait0,writeWait1,haltdump, haltwrite0,haltwrite1,haltcomplete,haltwait0,haltwait1); 
signal state,nextstate: state_type; 
signal saveWord: std_logic;
signal waycount, nextwaycount: std_logic_vector(1 downto 0);
signal indexcount, nextindexcount: std_logic_vector(3 downto 0);
signal nextCacheWord,prevCacheWord : std_logic_vector(31 downto 0);
begin
cctrl_state: process(CLK, nReset)
begin
	if nReset = '0' then
		-- set state to idle
		state <= idle;
		prevCacheWord <= x"00000000";
		indexcount <= "0000";
		waycount <= "00";
	elsif rising_edge(CLK) then
		-- set state to next state
		state <= nextstate;
		indexcount <= nextindexcount;
		waycount <= nextwaycount;
		if saveWord = '0' then
			prevCacheWord <= nextCacheWord;
		end if;
	end if;
end process cctrl_state;

cctrl_ns: process(RamState, state, hit, memRd, memWr, RamWord,memAddr, indexcount, waycount,dumpBlock,dumpTag,prevCacheWord,CacheBlockI)
variable indexcount_int,waycount_int : integer range 0 to 15;
begin
	nextstate <= state;
	nextindexcount <= indexcount;
	nextwaycount <= waycount;
	waycount_int := to_integer( ieee.NUMERIC_STD.UNSIGNED( waycount));
	indexcount_int := to_integer( ieee.NUMERIC_STD.UNSIGNED( indexcount));
	nextCacheWord <= prevCacheWord;
	CacheBlockO <= CacheBlockI;
	dumpWay <= waycount;
	dumpIndex <= indexcount;
	dcache_en <= '0';
	saveWord <= '0';
	wrEn <= '0';
	rdEn <= '0';
	clean <= '0';
	halt_out <= '0';
	dcacheWait <= '1';
	WordAddr <= x"00000000";
	RamData <= x"00000000";
	case state is
		when idle =>
			dcacheWait <= '0';
			if halt = '1' then
				dcacheWait <= '1';
				nextstate <= haltdump;
			else
				if(memWr = '1') then--SW instruction
					if(hit = '1') then --hit
						if(memAddr(2) = '1') then
							CacheBlockO <= CPUWord & CacheBlockI(31 downto 0);
						else
							CacheBlockO <= CacheBlockI(63 downto 32) & CPUWord;
						end if;
						clean <= '0';
						dcache_en <= '1';--cache write enable signal
	
					else--miss
						dcacheWait <= '1';
						dcache_en <= '0';--
						if(LRUdirty = '0') then--clean block
							rdEn <= '1';
							nextstate <= MissClean0;
						else--dirty block
							wrEn <= '1';
							nextstate <= MissDirty0;
						end if;
					end if;
				end if;
				if(memRd = '1') then--lw instruction
					if(hit = '0') then--clean
						rdEn <= '1';
						dcacheWait <= '1';
						if(LRUdirty = '0') then
							nextstate <= MissClean0;
						else
							nextstate <= MissDirty0;
						end if;
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
			--saveWord <= '1';
			rdEn <= '1';
			WordAddr <= memAddr(31 downto 3) & "000";
			nextCacheWord <= RamWord;
			if ramstate = MEMACCESS then
				--dcache_en <= '1';
				nextstate <= MissClean1;
			end if;
		when MissClean1=>
			saveWord <= '1';
			rdEn <= '1';
			WordAddr <= memAddr(31 downto 3) & "100";
			CacheBlockO <= RamWord & prevCacheWord;
			if ramstate = MEMACCESS then
				clean <= '1';
				dcache_en <= '1';
				nextstate <= idle;
			end if;

		when haltdump =>
			wrEn <= '0';
			dcachewait <= '1';
			if(dirty = '1') then
				wrEn <= '1';
				nextstate <= haltwrite0;
				WordAddr <= dumpTag & indexcount & "000";
				RamData <= dumpBlock(31 downto 0);
			else
				if( indexcount = 15) then
					if (waycount = 1) then
						nextstate <= haltcomplete;
					else
						nextwaycount <= waycount + 1;
						nextindexcount <= "0000";
					end if;
				else
					nextindexcount <= indexcount + 1;
				end if;
			end if;

		when haltwrite0 =>
			wrEn <= '1';
			WordAddr <= dumpTag & indexcount & "000";
			RamData <= dumpBlock(31 downto 0);
			if ramstate = MEMACCESS then
				nextstate <= haltwait0;
			end if;
		when haltwait0 =>
			wrEn <= '1';
			WordAddr <= dumpTag & indexcount & "000";
			RamData <= dumpBlock(31 downto 0);
			nextstate <= haltwrite1;
		when haltwrite1 =>
			wrEn <= '1';
			WordAddr <= dumpTag & indexcount & "100";
			RamData <= dumpBlock(63 downto 32);
			if ramstate = MEMACCESS then
				nextstate <= haltwait1;
			end if;
		when haltwait1 =>
			wrEn <= '1';
			WordAddr <= dumpTag & indexcount & "100";
			RamData <= dumpBlock(63 downto 32);			
			if( indexcount = 15) then
				if (waycount = 1) then
					nextstate <= haltcomplete;
				else
					nextwaycount <= waycount + 1;
					nextindexcount <= "0000";
					nextstate <= haltdump;
				end if;
			else
				nextindexcount <= indexcount + 1;
				nextstate <= haltdump;
			end if;		
		when haltcomplete =>
			halt_out <= '1';
			dcachewait <= '1';	


		-- read data from memory to fill cache block
		-- write data from cache block to memory when dirty
	end case;
end process cctrl_ns;

end;

