-- 32 bit version register file
-- evillase
-- Yonatan Feleke

library ieee;
use ieee.std_logic_1164.all;
entity linkregister is
	port
	(
		clk					:	in	std_logic;		-- clock, positive edge triggered
		nReset			 :	in	std_logic;		-- REMEMBER: nReset-> '0' = RESET, '1' = RUN
		AddrIn				:	in	std_logic_vector (31 downto 0);		-- Address to be stored by LL or to be invalidated
		Regsel				:	in	std_logic_vector (4 downto 0);		-- Select which register to write to
		LLwen					:	in	std_logic;												-- Write Enable for entire register file
		invalidate	: in	std_logic;												-- invalidate the value in the wsel
		scvalid				:	out	std_logic													-- the validity of the link
		);
end linkregister;

architecture regfile_arch of linkregister is

	constant BAD1	:	std_logic_vector		:= x"BAD1BAD1";

	type REGISTER32 is array (31 downto 1) of std_logic_vector(31 downto 0);
	signal reg_int	:	REGISTER32;				-- registers as an array

  -- enable lines... use en(x) to select
  -- individual lines for each register
	signal en		:	std_logic_vector(31 downto 0);
	signal addr		:	std_logic_vector(31 downto 0);

begin

	-- registers process
	registers : process (clk, nReset, en)
  begin    
		if (nReset = '0') then			-- Reset here
		  for i in 1 to 31 loop
        reg_int(i) <= x"00000000";        --exit when buf(i) = NUL;
      end loop;				
      
    elsif (rising_edge(clk)) then			-- Set register here
			for i in 1 to 31 loop
			  if (en(i) = '1' and LLwen ='1') then
			    reg_int(i) <= AddrIn;
			  elsif (reg_int(i) = AddrIn and invalidate ='1') then -- invalidate all adress entries: on sc or sw
			    reg_int(i) <= (others=> '0');
			  end if;		  
			end loop;			
    end if;
  end process;
-----------------------------------------------------------------------------------  
	scvalid <= '1' when addr = AddrIn else '0'; -- check register location for address
	with RegSel select
	 en <= x"00000000" when "00000",
			        "00000000000000000000000000000010" when "00001",
			        "00000000000000000000000000000100" when "00010",
			        "00000000000000000000000000001000" when "00011",
			        "00000000000000000000000000010000" when "00100",
			        "00000000000000000000000000100000" when "00101",
			        "00000000000000000000000001000000" when "00110",
			        "00000000000000000000000010000000" when "00111",
			        "00000000000000000000000100000000" when "01000",
			        "00000000000000000000001000000000" when "01001",
			        "00000000000000000000010000000000" when "01010",
			        "00000000000000000000100000000000" when "01011",
			        "00000000000000000001000000000000" when "01100",
			        "00000000000000000010000000000000" when "01101",
			        "00000000000000000100000000000000" when "01110",
			        "00000000000000001000000000000000" when "01111",
			        "00000000000000010000000000000000" when "10000",
			        "00000000000000100000000000000000" when "10001",
			        "00000000000001000000000000000000" when "10010",
			        "00000000000010000000000000000000" when "10011",
			        "00000000000100000000000000000000" when "10100",
			        "00000000001000000000000000000000" when "10101",
			        "00000000010000000000000000000000" when "10110",
			        "00000000100000000000000000000000" when "10111",
			        "00000001000000000000000000000000" when "11000",
			        "00000010000000000000000000000000" when "11001",
			        "00000100000000000000000000000000" when "11010",
			        "00001000000000000000000000000000" when "11011",
			        "00010000000000000000000000000000" when "11100",
			        "00100000000000000000000000000000" when "11101",
			        "01000000000000000000000000000000" when "11110",
			        "10000000000000000000000000000000" when "11111",
			        "00000000000000000000000000000000" when others;

	--rsel muxes:
	with Regsel select
		addr <=	x"00000000" when "00000",
		        reg_int(1) when "00001",
		        reg_int(2) when "00010",
		        reg_int(3) when "00011",
		        reg_int(4) when "00100",
		        reg_int(5) when "00101",
		        reg_int(6) when "00110",
		        reg_int(7) when "00111",
		        reg_int(8) when "01000",
		        reg_int(9) when "01001",
		        reg_int(10) when "01010",
		        reg_int(11) when "01011",
		        reg_int(12) when "01100",
		        reg_int(13) when "01101",
		        reg_int(14) when "01110",
		        reg_int(15) when "01111",
		        reg_int(16) when "10000",
		        reg_int(17) when "10001",
		        reg_int(18) when "10010",
		        reg_int(19) when "10011",
		        reg_int(20) when "10100",
		        reg_int(21) when "10101",
		        reg_int(22) when "10110",
		        reg_int(23) when "10111",
		        reg_int(24) when "11000",
		        reg_int(25) when "11001",
		        reg_int(26) when "11010",
		        reg_int(27) when "11011",
		        reg_int(28) when "11100",
		        reg_int(29) when "11101",
		        reg_int(30) when "11110",
		        reg_int(31) when "11111",		        
            BAD1 when others;
end regfile_arch;
