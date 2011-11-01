library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
entity icache is 
	port( 	clk, nrst: in std_logic; 
		  	tag_in: in std_logic_vector( 25 downto 0); 
		  	data_in: in std_logic_vector( 31 downto 0); 
			data_out: out std_logic_vector(31 downto 0); 
			index_in: in std_logic_vector( 3 downto 0); 
			hit: out std_logic;
			icache_en: in std_logic); 
end icache; 

architecture instr_cache of icache is

type ram is array( 15 downto 0) of std_logic_vector( 31 downto 0); 
type tagg is array( 15 downto 0) of std_logic_vector( 25 downto 0); 
type validd is array( 15 downto 0) of std_logic; 
signal valid1, valid2: validd; 
signal ram1,ram2: ram; 
signal tagg1,tagg2: tagg; 

begin 
regg: process( clk, nrst) 
begin 
	if nrst= '0' then 
		for i in 0 to 2 loop
			valid1( i) <= '0'; 
		end loop; 
		for i in 11 to 15 loop
			valid1( i) <= '0'; 
		end loop; 
		for i in 3 to 5 loop
			valid1( i) <= '0'; 
		end loop; 
		for i in 6 to 8 loop
			valid1( i) <= '0'; 
		end loop; 
		for i in 9 to 10 loop
			valid1( i) <= '0'; 
		end loop; 
	elsif rising_edge( clk) then 
		for i in 0 to 3 loop
			valid1( i) <= valid2( i);
			ram1( i) <= ram2( i);
			tagg1( i) <= tagg2( i); 
		end loop; 
		for i in 4 to 8 loop
			valid1( i) <= valid2( i);
			ram1( i) <= ram2( i);
			tagg1( i) <=tagg2( i); 
		end loop; 
		for i in 9 to 10 loop
			valid1( i) <=valid2( i);
			ram1( i) <=ram2( i);
			tagg1( i) <=tagg2( i); 
		end loop; 
		for i in 11 to 12 loop
			valid1( i) <=valid2( i);
			ram1( i) <=ram2( i);
			tagg1( i) <=tagg2( i); 
		end loop; 
		for i in 13 to 15 loop
			valid1( i) <=valid2( i);
			ram1( i) <=ram2( i);
			tagg1( i) <=tagg2( i); 
		end loop; 
	end if; 
end process 

regg; nextstate: process(valid1,ram1,tagg1, tag_in, data_in, icache_en, index_in) 
variable var1: integer range 0 to 15; 

begin
	var1:= to_integer( unsigned( index_in)); 
	for i in 0 to 5 loop
		tagg2( i) <=tagg1( i);
		ram2( i) <=ram1( i);
		valid2( i) <=valid1( i); 
	end loop; 
	for i in 6 to 8 loop
		tagg2( i) <=tagg1( i);
		ram2( i) <=ram1( i);
		valid2( i) <=valid1( i); 
	end loop; 
	for i in 9 to 12 loop
		tagg2( i) <=tagg1( i);
		ram2( i) <=ram1( i);
		valid2( i) <=valid1( i); 
	end loop; 
	for i in 13 to 15 loop
		tagg2( i) <=tagg1( i);
		ram2( i) <=ram1( i);
		valid2( i) <=valid1( i); 
	end loop; 
	if icache_en= '1' then
		tagg2(var1) <= tag_in;
		ram2(var1) <= data_in;
		valid2(var1) <= '1'; 
	end if; 
	data_out <= ram1(var1); 
	if tag_in=tagg1(var1) and valid1(var1)= '1' then 
		hit <= '1'; 
	else hit <= '0'; 
	end if; 
end process nextstate; 
end;
