-- libraries
library ieee;
use ieee.std_logic_1164.all;

entity Add32 is				
    port( A32, B32	                  : in std_logic_vector(31 downto 0);
          Add32Out                  : out std_logic_vector(31 downto 0));
--          NEGATIVE, OVERFLOW, ZERO: out std_logic );
  end Add32;


architecture Add32_behav of Add32 is
	component bitadder is				
    port(											
    			CIN,A1, B1              : in std_logic; -- carry in , a , b
          bitOut,COUT             : out std_logic);
	end component;
	
  signal CarryAdder								: std_logic_vector(32 downto 0);
--  signal ovrAdd										: std_logic;
  signal addout										: std_logic_vector(31 downto 0);
	begin
	
		-- DATAFLOW ADD OUT
  	CarryAdder(0) <= '0';
  	genFullAdder :		for z in 0 to 31 generate
  			FA: bitAdder port map( CIN=>CarryAdder(z),A1=>A32(z),B1=>B32(z),bitOut=>addout(z),COUT=>CarryAdder(z+1));
  		end generate;  	
--  	ovrAdd <= (CarryAdder(32) xor CarryAdder(31));  	
  	Add32Out <= addout;
 end Add32_behav;
