--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:21:55 03/21/2018
-- Design Name:   
-- Module Name:   D:/Drive/Dokumente/Projekte/POV/fpga/main/main_tb.vhd
-- Project Name:  main
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: main
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY main_tb IS
END main_tb;
 
ARCHITECTURE behavior OF main_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT main
    PORT(
         reset_ext : IN  std_logic;
         clk_ext : IN  std_logic;
         led : out std_logic_vector(3 downto 0);
         data_clk : IN  std_logic;
         data_syn : IN  std_logic;
         data_open : IN  std_logic;
         data : IN  std_logic_vector(7 downto 0);
         trigger : IN  std_logic;
         do : OUT  std_logic_vector(15 downto 0);
         co : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;

	 
    
	COMPONENT apa102group
			Generic(
				START_LED: integer := 1;
				END_LED: integer := 5;
				WING: integer := 0
			);
		 Port ( ci : in  STD_LOGIC;
				  di : in  STD_LOGIC);
	end COMPONENT;
	

   --Inputs
   signal reset_ext : std_logic := '0';
   signal clk_ext : std_logic := '0';
   signal data_clk : std_logic := '0';
   signal data_syn : std_logic := '0';
   signal data_open : std_logic := '0';
   signal data : std_logic_vector(7 downto 0) := (others => '0');
   signal trigger : std_logic := '1';

 	--Outputs
	signal led : std_logic_vector(3 downto 0);
   signal do : std_logic_vector(15 downto 0);
   signal co : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 125 ns;

	type integer_array_t is ARRAY(0 to 3) of integer range 1 to 33;
	constant START_LED_ARRAY :  integer_array_t := (1, 6 , 12, 20);
	constant END_LED_ARRAY   :  integer_array_t := (5, 11, 19, 33);

 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: main PORT MAP (
          reset_ext => reset_ext,
          clk_ext => clk_ext,
			 led => led,
          data_clk => data_clk,
          data_syn => data_syn,
          data_open => data_open,
          data => data,
          trigger => trigger,
          do => do,
          co => co
        );


	ledgroups:
	for GROUPS in 0 to 3 generate
	begin
		wings:
		for WING in 0 to 3 generate
		begin
			ledgroup:  apa102group
			generic map(
				START_LED => START_LED_ARRAY(GROUPS),
				END_LED => END_LED_ARRAY(GROUPS),
				WING => WING
			)	
			port map(
				ci => co(WING+4*GROUPS),
				di => do(WING+4*GROUPS)
			);
		end generate;
	end generate;


   -- Clock process definitions
   clk_process :process
   begin
		clk_ext <= '0';
		wait for clk_period/2;
		clk_ext <= '1';
		wait for clk_period/2;
   end process;
  

   -- Stimulus process
   stim_proc: process
   begin		
		reset_ext <= '1';
      wait for clk_period*100;
		reset_ext <= '0';

      wait for clk_period*10;
		
		--for J in 0 to 2 loop
			--data_syn <= '1';
			--for I in 0 to 131*131 loop
				--data_clk <= '1';
				--data <= std_logic_vector(to_unsigned(I,data'length));
				--wait for clk_period*20;
				--data_clk <= '0';
				--wait for clk_period*20;
				--data_syn <= '0';
				--wait for 1 ns;
			--end loop;
		--end loop;

      wait;
   end process;


   -- Stimulus process
   stim_proc2: process
   begin		
	
		wait for (1 ns)*(10**6);
		for I in 10 to 40 loop
			wait for (1 ns)*(10**9)/24;
--			trigger <= '0';
			wait for (1 ns)*(10**6);
--			trigger <= '1';
		end loop;
	
   end process;

END;
