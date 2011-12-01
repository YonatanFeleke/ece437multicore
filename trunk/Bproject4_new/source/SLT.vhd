-- libraries
library ieee;
use ieee.std_logic_1164.all;

entity SLT is				
    port( Opcode            : in std_logic_vector(5 downto 0);
					Fx								:	in std_logic_vector(5 downto 0);
					A, B							:	in std_logic_vector(31 downto 0);
					Negative,Overflow	:	in std_logic;
					SLTvalue					:	out std_logic);
  end SLT;

architecture SLT_arch of SLT is


  signal SLTunsigned, SLTsigned : std_logic;
	signal diff: std_logic;
  begin    
	unsignedCompare: process(A,B,Opcode,Fx)
	variable diff : std_logic;
  begin
		SLTunsigned <= '0';
		diff := '0';
		for i in 31 downto 0 loop
			if(((A(i) xor B(i)) = '1') and diff = '0') then
				SLTunsigned <= not(A(i));
				diff := '1';
			end if;
		end loop;
	end process unsignedCompare;
  --SLTunsigned <= '1' when (A < B) else '0';
	SLTsigned <= Negative when Overflow = '0' else A(31);--Negative flag unless there is overflow. else sign bit of A
	SLTvalue <= SLTunsigned when (Opcode = "001011") or (Opcode = "000000" and Fx = "101011") else
							SLTsigned when (Opcode = "001010") or (Opcode = "000000" and Fx = "101010") else
							'0';
		
end SLT_arch;
