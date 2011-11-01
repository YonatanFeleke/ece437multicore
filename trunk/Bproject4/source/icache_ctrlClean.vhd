library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

entity icache_ctrl is 
	port(	clk, nrst: in std_logic; 
			hit: in std_logic; 
			ramstate: in std_logic_vector( 1 downto 0); 
			icache_en: out std_logic); 
end icache_ctrl;

architecture instr_cache_ctrl of icache_ctrl is 
type state_type is(state1, state2); 
signal state,nextstate: state_type; 

begin icache_state: process( clk, nrst) 
begin 
	if nrst= '0' then
		state <= state1; 
	elsif rising_edge( clk) then
		state <= nextstate; 
	end if; 
end process icache_state; 

nexttstate: process( hit,state,ramstate) begin
nextstate<=state; 
icache_en <= '0'; 
case state is 
	when state1 => 
		if (hit= '0' and  then
			nextstate <= state2; 
		end if; 
	when state2 => 
		if ramstate /= "01" then
			nextstate <= state1; 
			icache_en <= '1'; 
		end if; 
	end case; 
end process nexttstate; 
end;
