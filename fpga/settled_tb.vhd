--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:00:46 03/21/2018
-- Design Name:   
-- Module Name:   D:/Drive/Dokumente/Projekte/POV/fpga/main/settled_tb.vhd
-- Project Name:  main
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: settled
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
--USE ieee.numeric_std.ALL;
 
ENTITY settled_tb IS
END settled_tb;
 
ARCHITECTURE behavior OF settled_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT settled
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         input : IN  std_logic;
         settled : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal input : std_logic := '0';

 	--Outputs
   signal ssettled : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: settled PORT MAP (
          clk => clk,
          reset => reset,
          input => input,
          settled => ssettled
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

		input <= '1';
      wait for clk_period;
		input <= '0';
      wait for clk_period*2;
		input <= '1';
      wait for clk_period*3;
		input <= '0';
      wait for clk_period*4;
		input <= '1';
      wait for clk_period*5;
		input <= '0';
      wait for clk_period*6;
		input <= '1';

      wait;
   end process;

END;
