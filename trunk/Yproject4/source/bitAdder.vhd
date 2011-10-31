-- libraries
library ieee;
use ieee.std_logic_1164.all;

entity bitadder is				
    port(											
    			CIN,A1, B1                : in std_logic; -- carry in , a , b
          bitOut,COUT             	: out std_logic);
  end bitadder;

architecture dataflow_Adder of bitadder is
begin
	cout <= (A1 and B1) or (a1 and CIN) or (b1 and CIN);
	bitOut <= A1 xor B1 xor CIN;	
end dataflow_Adder;
