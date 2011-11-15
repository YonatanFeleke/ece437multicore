library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
entity dcache_data is 
	port( 	clk, nrst: in std_logic;
			clean: in std_logic; 
		  	tag_in: in std_logic_vector( 24 downto 0);
		  	data_in: in std_logic_vector( 63 downto 0); 
			data_out: out std_logic_vector(63 downto 0); 
			index_in: in std_logic_vector(3 downto 0); 
			hit: out std_logic;
			wbTag : out std_logic_vector(24 downto 0);
			LRUdirty: out std_logic;
			dcache_en: in std_logic;
			dumpIndex: in std_logic_vector(3 downto 0);
			dumpWay	:  in std_logic_vector(1 downto 0);
			dumpBlock	:	out std_logic_vector(63 downto 0);
			dumpTag	:	out std_logic_vector(24 downto 0);
			dirtyout : out std_logic		
	); 
end dcache_data; 

architecture instr_cache of dcache_data is

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

type LRU is array(15 downto 0) of std_logic;

signal validPrev, validNext: valid2way; 
signal dataPrev,dataNext: data2way; 
signal taggPrev,taggNext: tagg2way;
signal wordPrev, wordNext: wordOffset2way;
signal dirtyPrev, dirtyNext: dirty2way; 
signal LRUtablePrev, LRUtableNext : LRU;


begin 
regg: process( clk, nrst) 
begin 
	if nrst= '0' then
		for i in 0 to 1 loop
			for j in 0 to 15 loop
				validPrev(i)(j) <= '0';
				dirtyPrev(i)(j) <= '0';
			end loop;
 		end loop;
		for i in 0 to 15 loop
			LRUtablePrev(i) <= '0';
		end loop;
	elsif rising_edge( clk) then 
		for i in 0 to 1 loop
			for j in 0 to 15 loop
				validPrev(i)(j) <= validNext(i)(j);
				dataPrev(i)(j)<= dataNext(i)(j);
				taggPrev(i)(j) <= taggNext(i)(j);
				wordPrev(i)(j) <= wordNext(i)(j);
				dirtyPrev(i)(j) <= dirtyNext(i)(j);
			end loop;
		end loop;
		for i in 0 to 15 loop
			LRUtablePrev(i) <= LRUtableNext(i);
		end loop;
	end if; 
end process 

regg; nextstate: process(validPrev,dataPrev,taggPrev,wordPrev, tag_in, data_in, dcache_en, index_in, dumpWay, dumpIndex) 
variable var1: integer range 0 to 15; 
variable notLRU: std_logic;
variable writeWay: integer range 0 to 1;
variable indexcount_int,waycount_int : integer range 0 to 15;

begin
	waycount_int := to_integer( unsigned( dumpWay));
	indexcount_int:= to_integer( unsigned( dumpIndex));
	dumpBlock <= dataPrev(waycount_int)(indexcount_int);
	dumpTag <= taggPrev(waycount_int)(indexcount_int);
	dirtyout <= dirtyPrev(waycount_int)(indexcount_int);
	writeWay := 0;
	var1:= to_integer( unsigned( index_in)); 
	notLRU := not(LRUtablePrev(var1));
	for i in 0 to 1 loop
		for j in 0 to 15 loop
			taggNext(i)(j) <= taggPrev(i)(j);
			dataNext(i)(j) <= dataPrev(i)(j);
			validNext(i)(j) <= validPrev(i)(j);
			wordNext(i)(j) <= wordPrev(i)(j);
			dirtyNext(i)(j) <= dirtyPrev(i)(j);
		end loop;
	end loop;
		for i in 0 to 15 loop
			LRUtableNext(i) <= LRUtablePrev(i);
		end loop;

	--on read, check valid and tag of both ways. return if match and set hit
	if tag_in = taggPrev(0)(var1) and validPrev(0)(var1) = '1' then
		data_out <= dataPrev(0)(var1);
		hit <= '1';
		LRUtableNext(var1) <= '1';
		--LRUtableNext(var1) <= notLRU;
		--dirty <= dirtyPrev(0)(var1);
	elsif tag_in = taggPrev(1)(var1) and validPrev(1)(var1) = '1' then
		data_out <= dataPrev(1)(var1);
		hit <= '1';
		writeWay := 1;
		--LRUtableNext(var1) <= notLRU;
		LRUtableNext(var1) <= '0';
		--dirty <= dirtyPrev(1)(var1);
	else--miss
		hit <= '0';
		if(LRUtablePrev(var1) = '0') then
			data_out <= dataPrev(0)(var1);
			wbTag <= taggPrev(0)(var1);
		else
			data_out <= dataPrev(1)(var1);
			wbTag <= taggPrev(1)(var1);
		end if;
		--dirty <= '0';
	end if;

	--set dirty signal to value of LRU dirty bit
	if(LRUtablePrev(var1) <= '0') then
		LRUdirty <= dirtyPrev(0)(var1);
	else
		LRUdirty <= dirtyPrev(1)(var1);
	end if;
	--cache write. 
	if dcache_en= '1' then
		if clean = '0' then--writing a drity block from CPU
			taggNext(writeWay)(var1) <= tag_in;
			dataNext(writeWay)(var1) <= data_in;
			validNext(writeWay)(var1) <= '1';
			if writeWay = 1 then
				LRUtableNext(var1) <= '0';
			else
				LRUtableNext(var1) <= '1';
			end if;
			dirtyNext(writeWay)(var1) <= not(clean);			
		elsif LRUtablePrev(var1) = '0' then--clean block replacing way0
			taggNext(0)(var1) <= tag_in;
			dataNext(0)(var1) <= data_in;
			validNext(0)(var1) <= '1';
			LRUtableNext(var1) <= '1';
			dirtyNext(0)(var1) <= not(clean);
		else--clean block replacing way1
			taggNext(1)(var1) <= tag_in;
			dataNext(1)(var1) <= data_in;
			LRUtableNExt(var1) <= '0';
			validNext(1)(var1) <= '1';
			dirtyNext(1)(var1) <= not(clean);
		end if;
	end if; 
end process nextstate; 
end;
