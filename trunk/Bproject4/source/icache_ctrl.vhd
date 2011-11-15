library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity icache_ctrl is 
	port( clk, nrst,stop     					: in std_logic;
				hit						              : in std_logic;
				ramstate			        			: in std_logic_vector( 1 downto 0);
				icache_en			       	      : out std_logic);
	end icache_ctrl;

architecture instr_cache_ctrl of icache_ctrl is 
	type state_type is(zero, one);
	signal state,nextstate : state_type;
    begin 
        icache_state: process( clk, nrst,stop,nextstate) 
    	begin 
         	if nrst= '0' then
         		state<= zero;
        	elsif (rising_edge( clk) and stop ='0') then
        		state<=nextstate;
        	end if;
        end process icache_state;        
        nexttstate: process( hit,state, stop,ramstate) begin
        	nextstate<=state;
        	icache_en <= '0';
        	case state is 
        		when zero => 
        				if hit= '0' then
        					nextstate<= one;
        				 end if;
        		when one =>
        				if (ramstate /= "01" and stop='0') then -- if miss and on iMemRead available
            				nextstate<= zero; -- this says that if waiting on a memRW to finish and we have a miss do not latch nxtdata
            				icache_en <= '1';
        				end if;
        		end case;
        end process nexttstate;
 end;
