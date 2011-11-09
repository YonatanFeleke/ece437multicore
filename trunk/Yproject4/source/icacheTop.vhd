library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

--entity IcacheTop is
--		port(	

--			PC		      :	in	std_logic_vector(31 downto 0);
--			instrOut		:	in	std_logic_vector(31 downto 0);
--			ramState  	:	in	std_logic_vector(1 downto 0);
			
--			hit     		:	out	std_logic;

--			not(hit)		:	out	std_logic;
--			IF_Instr		:	out	std_logic_vector(31 downto 0);
--		);
--end IcacheTop;
entity IcacheTop is
		port(
			clk					:	in	std_logic;
			nReset			: in	std_logic;			
			iMemRead		:	in	std_logic;--not(stop):	in	std_logic;
			iMemWait		:	out	std_logic;--not(hit):	in	std_logic;
      
			iMemAddr		:	in	std_logic_vector(31 downto 0);--PC:	out	std_logic_vector(31 downto 0)
			iMemData		:	out	std_logic_vector(31 downto 0);--the IF_Instr
      
			aiMemState	:	in	std_logic_vector(1 downto 0); -- ram State
			aiMemData		:	in	std_logic_vector(31 downto 0);-- IstrOut
      
			aiMemRead		:	out	std_logic;-- not hit
			aiMemAddr		:	out	std_logic_vector(31 downto 0)--PC
		);
end IcacheTop;

architecture IcacheTopComb of icacheTop is

   COMPONENT icache
   PORT (
      clk       : IN     std_logic;
      data_in   : IN     std_logic_vector ( 31 DOWNTO 0);
      icache_en : IN     std_logic;
      index_in  : IN     std_logic_vector ( 3 DOWNTO 0);
      nrst      : IN     std_logic;
      tag_in    : IN     std_logic_vector ( 25 DOWNTO 0);
      data_out  : OUT    std_logic_vector (31 DOWNTO 0);
      hit       : OUT    std_logic
   );
   END COMPONENT;
   COMPONENT icache_ctrl
   PORT (
      clk       : IN     std_logic;
      hit       : IN     std_logic;
      nrst      : IN     std_logic;
      ramstate  : IN     std_logic_vector ( 1 DOWNTO 0);
      stop      : IN     std_logic;
      icache_en : OUT    std_logic
   );
   END COMPONENT;

	-- signals here
--  signal iMemAddr   : std_logic_vector(31 downto 0);
  signal tag_in     : std_logic_vector( 25 downto 0); 
  signal idx_in     : std_logic_vector(3 downto 0);
  signal hit,icache_en,stop :std_logic;
begin
-- CPU interface code
   tag_in <= iMemAddr(31 downto 6);
   idx_in <= iMemAddr(5 downto 2);
   iMemWait <= not(hit);
-- Memory Interface
    aiMemRead <= not(hit);
    aiMemAddr <= iMemAddr;
    stop <= not(iMemRead);-- enable the icache, currently not correct
   icacheBlk : icache
      PORT MAP (
         clk       => CLK,
         nrst      => nReset,
         tag_in    => tag_in,
         data_in   => aiMemData,
         data_out  => iMemData,
         index_in  => idx_in,
         hit       => hit,
         icache_en => icache_en
      );
   IcacheCLU : icache_ctrl
      PORT MAP (
         clk       => CLK,
         nrst      => nReset,
         stop      => stop,
         hit       => hit,
         ramstate  => aiMemState,
         icache_en => icache_en
      );
end IcacheTopComb;