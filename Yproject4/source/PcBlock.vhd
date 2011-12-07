 -- libraries
library ieee;
use ieee.std_logic_1164.all;

entity PcBlock is				
    port( clk,nReset,pid		         			: in std_logic; --proccesor ID
			    ID_PcSrc,ID_JR,JMP,IF_PCSkip		: in std_logic;
          BusA,ID_Imm16L2              		: in std_logic_vector(31 downto 0);
          JAddr26           : in std_logic_vector(25 downto 0);
          PC                : out std_logic_vector(31 downto 0);
          PC_4              : out std_logic_vector(31 downto 0)
         );
  end PcBlock;

architecture behav_pc of PcBlock is
	component Add32 is				
    port( A32, B32	                  : in std_logic_vector(31 downto 0);
          Add32Out                 		: out std_logic_vector(31 downto 0));
	end component;
	
	signal nxtPc,AddOut,PcInt 		: std_logic_vector(31 downto 0);
	signal JRout,Add2Pc						: std_logic_vector(31 downto 0);	
  constant four 								: std_logic_vector(31 downto 0) := x"00000004";
	begin
	
  PC_rstNclk: process(nReset,clk,IF_PCSkip,PcInt,nxtPc,ID_PcSrc,pid) -- Async reset --Freeze put back in
    begin
      if (nReset = '0') then
        if pid = '1' then -- core one start at 200
            PcInt <= x"00000200";
            Pc <= x"00000200";
        else 
            PcInt <= x"00000000";
            Pc <= x"00000000";
        end if;
      elsif(rising_edge(clk) and IF_PCSkip = '0') then 
        PcInt <= nxtPc;
        PC <= nxtPc;        
      end if;
    end process PC_rstNclk;
 	-----------------------------------------------------
  
-- PC_4 is wrong on BEQ and BNE which is not when it is used!!!!!
Add2Pc <=  ID_Imm16L2  when (ID_PcSrc = '1') else four;
Pcn4_plus_add2pc: Add32 port map(A32=>PcInt,B32=>Add2Pc,Add32Out=>AddOut);   --AddOut <= Pcn4 + Add2Pc;
PC_4 <= AddOut; -- If PcSrc won't be PC+4 so not taken predict beq followed by JAL =>

JRout <=  BusA when (ID_JR = '1') else AddOut;
nxtPc <=  PcInt(31 downto 28) & JAddr26 & "00" when (JMP = '1') else  JRout;-- J/JAL AND NORMAL OPERATION
end behav_pc;




-- Older code--
-- Halt taken care of in PCskip			    
--Freeze   : in std_logic;
--  signal CarryAdder												: std_logic_vector(32 downto 0);
-- elsif (IF_PCSkip = '1' and ID_PcSrc ='0') then --DON'T DO ANYTHING
			-- squash one on branch taken implemented in PC 
			-- However MOVE TO NEW BLOCK!!!! 
			-- PCSKIP = '0' when Id_PcSrc = '1' for one clock cycle
	--Current	     elsif (IF_PCSkip = '1' )then --and ID_PcSrc ='0') then  --hit=0 or ID_flush ='1'
  -- However if in Branch update PC to branch
  --       IF_PCSkip(miss and loadstore) do not lose PC, done in icachectrl And IF_INSTR is 0
  --      elsif(Freeze ='0' and rising_edge(clk) and HALT='0') then
  
  --      elsif (Freeze = '1' or (IF_PCSkip = '1' and ID_PcSrc ='0')) then 
--      elsif (IF_PCSkip = '1' )then --and ID_PcSrc ='0') then
