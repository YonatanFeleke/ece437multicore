-- libraries
library ieee;
use ieee.std_logic_1164.all;

entity FwdUnit is				
    port( 						              						
          --EX_Rs,EX_Rt,
          ID_Rs,ID_Rt  : in std_logic_vector(4 downto 0);

          EX_Rw                     : in std_logic_vector(4 downto 0);
          EX_REGWR				: in std_logic;              -- if mem2reg set bubble and get from wb
          EX_Out									: in std_logic_vector(31 downto 0);

          MEM_Rw                  	: in std_logic_vector(4 downto 0);
          MEM_REGWR			: in std_logic;              -- if mem2reg set bubble and get from wb
          MEM_dataIn										: in std_logic_vector(31 downto 0);      
                   
          ID_ASel,ID_BSel           : out std_logic;
          ID_FwdA,ID_FwdB                    : out std_logic_vector(31 downto 0)
         );
  end FwdUnit;

architecture FwdUnit_behav of FwdUnit is
  begin
			ID_ASel <= '1' when (EX_REGWR = '1' and not(EX_Rw="00000") and (ID_RS=EX_Rw)) else --ex_rs = mem_rw
								 '1' when (MEM_REGWR = '1' and not(MEM_Rw="00000") and (ID_RS=MEM_Rw) ) else -- ID_RS = mem_rw or ex_rs= wb_rw
									'0';
			ID_BSel <= '1' when (EX_REGWR = '1' and not(EX_Rw="00000") and (ID_Rt=EX_Rw))   else --ex_rt = mem_rw
								 '1' when (MEM_REGWR = '1' and not(MEM_Rw="00000") and (ID_Rt=MEM_Rw))  else -- ID_Rt = mem_rw or ex_rt= wb_rw
									'0';
			ID_FwdA <= EX_Out when (ID_RS=EX_Rw and not(EX_Rw="00000")) else 
			           MEM_dataIn when (ID_RS=MEM_Rw and not(MEM_Rw="00000")) else 
			           x"00000000"; -- returns the execute output or ram output to register
			ID_FwdB <= EX_Out when (ID_Rt=EX_Rw and not(EX_Rw="00000")) else 
			           MEM_dataIn when (ID_Rt=MEM_Rw and not(MEM_Rw="00000"))else 
			           x"00000000"; -- returns the execute output or ram output to register					
	end FwdUnit_behav;  	
