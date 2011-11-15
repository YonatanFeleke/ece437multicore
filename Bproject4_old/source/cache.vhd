-- cache tempalte
-- this is provided as a guide to build your cache. It is by no means unfallable.
-- you may need to update vector bit ranges to match specifications in lab handout.
--
-- THIS IS NOT ERROR FREE CODE, YOU MUST UPDATE AND VERIFY SANITY OF LOGIC/INTERFACES
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
	port(
		CLK					:	in	std_logic;
		nReset			:	in	std_logic;
		WrEn				:	in	std_logic;
		Tag					:	in	std_logic_vector (24 downto 0);
		Index				:	in	std_logic_vector (03 downto 0);
		CacheBlockI	:	in 	std_logic_vector (63 downto 0);
		CacheBlockO	:	out std_logic_vector (63 downto 0);
		Dirty				:	out	std_logic;
		Hit					:	out	std_logic
  );
end cache;

architecture struct of cache is 

type data is array( 15 downto 0) of std_logic_vector( 63 downto 0);
type data2way is array(1 downto 0) of data; 

type tagg is array( 15 downto 0) of std_logic_vector( 24 downto 0); 
type tagg2way is array(1 downto 0) of tagg;

type validd is array( 15 downto 0) of std_logic; 
type valid2way is array(1 downto 0) of validd;

type dirty is array(15 downto 0) of std_logic;
type dirty2way is array(1 downto 0) of dirty;

type wordOffset is array(15 downto 0) of std_logic;
type wordOffset2way is array(1 downto 0) of wordOffset;

type LRU is array(15 donwto 0) of std_logic;

signal validPrev, validNext: validd2way; 
signal dataPrev,dataNext: data2way; 
signal taggPrev,taggNext: tagg2way;
signal wordPrev, wordNext: wordOffset2way;
signal dirtyPrev, dirtyNext: dirty2way; 
signal LRUtable : LRU;

begin

-- If you use an external ram file for the cache you do not need this cache_reg.
cache_reg: process(CLK, nReset, WrEn)
begin 
	if nReset = '0' then
		for way in 0 to 1 loop
			for set in 0 to 15 loop 
				-- reset cache valid, dirty, and replacement bits here
				validPrev(i)(j) <= '0';
				dirtyPrev(i)(j) <= '0';
			end loop;
 		end loop;
		for i in 0 to 15 loop
			LRUtable(i) <= '0';
		end loop;
	elsif rising_edge(CLK) then
		if WrEn = '1' then
		 	for set in 0 to 15 loop
				-- update valid, tag, dirty, data, and replacement bits here
		 	end loop;
		end if;
	end if;
end process cache_reg;

cache_lookup: process(Fill_me_in)
begin
	-- check ways valid and tag bits,
	-- on match select cache block to return.
	-- update replacement bits
	-- update dirty valid on write. This depends on write policy.
end process cache_lookup;
end struct;

