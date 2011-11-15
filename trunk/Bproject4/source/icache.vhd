library ieee;
 use ieee.std_logic_1164.all;
 use ieee.numeric_std.all;
 entity icache is 
 	port( clk, nrst		: in std_logic;
		icache_en				: in std_logic;
 		tag_in					: in std_logic_vector( 25 downto 0);
 		data_in					: in std_logic_vector( 31 downto 0);
 		index_in				: in std_logic_vector( 3 downto 0);
 		data_out				: out std_logic_vector(31 downto 0);
 		hit							: out std_logic); 				
 	end icache;

architecture instr_cache of icache is
   	type ramType is 						array( 15 downto 0) of std_logic_vector( 31 downto 0);-- array tracking the cached instructions
   	signal ram, nxt_ram         		: 	ramType;
    type tagg is 						array( 15 downto 0) of std_logic_vector( 25 downto 0);-- array of the different tags within the cache
    signal tag,nxt_tag         		: 	tagg;
    type valid is 					array( 15 downto 0) of std_logic; 										-- array tracking the valid bits of the 16 cache spots
    signal validBit, nxt_Valid  	: 	valid;    
-------------------------------------------------------------------------    
    begin regg: process( clk, nrst) 
    begin 
    	if nrst= '0' then 
 			validBit <= x"0000";
 			for i in 15 downto 0 loop
				tag(i) <= (others => '0');
				ram(i)  <= (others => '0');
			end loop;
	    elsif rising_edge( clk) then 
        validBit<=nxt_Valid;
        ram <=nxt_ram;
        tag <=nxt_tag;
		end if;
end process regg;
-------------------------------------------------------------------------------------------
	nextstate: process(clk,validBit,ram,tag,tag_in,data_in,icache_en,index_in) 
	variable   idx            : integer range 0 to 15;
    begin
      idx  := to_integer(unsigned(index_in));
      nxt_tag <= tag;
      nxt_ram <= ram;
      nxt_Valid <=validBit;
      if icache_en= '1' then
      	nxt_tag(idx) <= tag_in;
        nxt_ram(idx) <= data_in;
        nxt_Valid(idx) <= '1';
      end if;
      if tag_in=tag(idx) and validBit(idx)= '1' then 
      	hit <= '1';
      else hit <= '0';
      end if;
      data_out <=ram(idx); -- output cache value on bus always??
	end process nextstate;
 end;
