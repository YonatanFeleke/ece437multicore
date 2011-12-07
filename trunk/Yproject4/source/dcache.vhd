-- VHDL Entity multiCore_lib.dcache.symbol
--
-- Created:
--          by - mg255.bin (cparch05.ecn.purdue.edu)
--          at - 16:06:07 12/07/11
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2010.2a (Build 7)
--
library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;

--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model
ENTITY dcache IS
   PORT( 
      CLK          : IN     std_logic;
      nReset       : IN     std_logic;
      Halt         : IN     std_logic;                       -- CPU side
      MemRead      : IN     std_logic;                       -- CPU side
      MemWrite     : IN     std_logic;                       -- CPU side
      MemWait      : OUT    std_logic;                       -- CPU side
      MemAddr      : IN     std_logic_vector (31 DOWNTO 0);  -- CPU side
      MemRdData    : OUT    std_logic_vector (31 DOWNTO 0);  -- CPU side
      MemWrData    : IN     std_logic_vector (31 DOWNTO 0);  -- CPU side
      aMemWait     : IN     std_logic;                       -- arbitrator side
      aMemState    : IN     std_logic_vector (1 DOWNTO 0);   -- arbitrator side
      aMemRead     : OUT    std_logic;                       -- arbitrator side
      aMemWrite    : OUT    std_logic;                       -- arbitrator side
      aMemAddr     : OUT    std_logic_vector (31 DOWNTO 0);  -- arbitrator side
      aMemRdData   : IN     std_logic_vector (31 DOWNTO 0);  -- arbitrator side
      aMemWrData   : OUT    std_logic_vector (31 DOWNTO 0);  -- arbitrator side
      --LL and SC
      LL           : IN     std_logic;
      --LL and SC
      SC           : IN     std_logic;
      -- Coherance signals
      cMemSnoopEn  : IN     std_logic;
      cMemAddr     : IN     std_logic_vector (31 DOWNTO 0);
      finalHalt    : OUT    STD_LOGIC;
      WB_Rw        : IN     std_logic_vector (4 DOWNTO 0);
      cRdX         : IN     std_logic;
      chrWaitDbusy : OUT    std_logic;
      cacheSnoopEn : OUT    std_logic;
      invld        : IN     std_logic;
      validSC      : OUT    std_logic
   );

-- Declarations

END dcache ;

--
-- VHDL Architecture multiCore_lib.dcache.struct
--
-- Created:
--          by - mg255.bin (cparch05.ecn.purdue.edu)
--          at - 16:06:07 12/07/11
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2010.2a (Build 7)
--
--  hds interface_end
-- 
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ARCHITECTURE struct OF dcache IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL wEN       : std_logic;
   SIGNAL readport  : STD_LOGIC_VECTOR(184 DOWNTO 0);
   SIGNAL addr      : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL writeport : STD_LOGIC_VECTOR(184 DOWNTO 0);
   SIGNAL LLWen     : std_logic;
   SIGNAL scvalid   : std_logic;
   SIGNAL AddrIn    : std_logic_vector(31 DOWNTO 0);


   -- Component Declarations
   COMPONENT dCacheCLU
   PORT (
      CLK          : IN     std_logic;
      Halt         : IN     std_logic;
      LL           : IN     std_logic;
      MemAddr      : IN     std_logic_vector (31 DOWNTO 0);
      MemRead      : IN     std_logic;
      MemWrData    : IN     std_logic_vector (31 DOWNTO 0);
      MemWrite     : IN     std_logic;
      SC           : IN     std_logic;
      aMemRdData   : IN     std_logic_vector (31 DOWNTO 0);
      aMemState    : IN     std_logic_vector (1 DOWNTO 0);
      aMemWait     : IN     std_logic;
      cMemAddr     : IN     std_logic_vector (31 DOWNTO 0);
      cMemSnoopEn  : IN     std_logic;
      cRdX         : IN     std_logic;
      nReset       : IN     std_logic;
      readport     : IN     STD_LOGIC_VECTOR (184 DOWNTO 0);
      valid        : IN     std_logic;
      LLWen        : OUT    std_logic;
      MemRdData    : OUT    std_logic_vector (31 DOWNTO 0);
      MemWait      : OUT    std_logic;
      aMemAddr     : OUT    std_logic_vector (31 DOWNTO 0);
      aMemRead     : OUT    std_logic;
      aMemWrData   : OUT    std_logic_vector (31 DOWNTO 0);
      aMemWrite    : OUT    std_logic;
      addr         : OUT    STD_LOGIC_VECTOR (3 DOWNTO 0);
      cacheSnoopEn : OUT    std_logic;
      chrWaitDbusy : OUT    std_logic;
      haltDone     : OUT    STD_LOGIC;
      wEN          : OUT    std_logic;
      writeport    : OUT    STD_LOGIC_VECTOR (184 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT data16x184
   PORT (
      addr      : IN     std_logic_vector (3 DOWNTO 0);
      clk       : IN     STD_LOGIC;
      nrst      : IN     STD_LOGIC;
      we        : IN     STD_LOGIC  := '1';
      writeport : IN     std_logic_vector (184 DOWNTO 0);
      readport  : OUT    std_logic_vector (184 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT linkregister
   PORT (
      AddrIn     : IN     std_logic_vector (31 DOWNTO 0);
      LLwen      : IN     std_logic;
      Regsel     : IN     std_logic_vector (4 DOWNTO 0);
      clk        : IN     std_logic;
      invalidate : IN     std_logic;
      nReset     : IN     std_logic;
      scvalid    : OUT    std_logic
   );
   END COMPONENT;

BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 LinkRegMux
   AddrIn <= MemAddr when (SC ='1' or LLWen ='1') else cMemAddr when invld = '1' else x"00000000";
   validSC <= '1' when SC='1' and scvalid ='1' else '0';
   
   


   -- Instance port mappings.
   dRamCLU : dCacheCLU
      PORT MAP (
         CLK          => CLK,
         nReset       => nReset,
         Halt         => Halt,
         MemRead      => MemRead,
         MemWrite     => MemWrite,
         MemWait      => MemWait,
         MemAddr      => MemAddr,
         MemRdData    => MemRdData,
         MemWrData    => MemWrData,
         aMemWait     => aMemWait,
         aMemState    => aMemState,
         aMemRead     => aMemRead,
         aMemWrite    => aMemWrite,
         aMemAddr     => aMemAddr,
         aMemRdData   => aMemRdData,
         aMemWrData   => aMemWrData,
         LL           => LL,
         SC           => SC,
         valid        => scvalid,
         cMemSnoopEn  => cMemSnoopEn,
         cRdX         => cRdX,
         cMemAddr     => cMemAddr,
         chrWaitDbusy => chrWaitDbusy,
         cacheSnoopEn => cacheSnoopEn,
         LLWen        => LLWen,
         wEN          => wEN,
         readport     => readport,
         addr         => addr,
         writeport    => writeport,
         haltDone     => finalHalt
      );
   -- Port Mapptings
   -- 
   dRam : data16x184
      PORT MAP (
         addr      => addr,
         clk       => CLK,
         nrst      => nReset,
         we        => wEN,
         writeport => writeport,
         readport  => readport
      );
   linkReg : linkregister
      PORT MAP (
         clk        => CLK,
         nReset     => nReset,
         AddrIn     => AddrIn,
         Regsel     => WB_Rw,
         LLwen      => LLWen,
         invalidate => invld,
         scvalid    => scvalid
      );

END struct;
