--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:39:32 03/21/2018
-- Design Name:   
-- Module Name:   D:/Drive/Dokumente/Projekte/POV/fpga/main/sendfifo_tb.vhd
-- Project Name:  main
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sendfifo
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
 
ENTITY sendfifo_tb IS
END sendfifo_tb;
 
ARCHITECTURE behavior OF sendfifo_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT sendfifo
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         do : OUT  std_logic;
         zerobit : IN  std_logic;
         onebit : IN  std_logic;
         bitselect : IN  unsigned(4 downto 0);
         pixel_next : IN  std_logic;
         pixel_write : IN  std_logic;
         pixel : IN  std_logic_vector(23 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal zerobit : std_logic := '0';
   signal onebit : std_logic := '0';
   signal bitselect : unsigned(4 downto 0) := (others => '0');
   signal pixel_next : std_logic := '0';
   signal pixel_write : std_logic := '0';
   signal pixel : std_logic_vector(23 downto 0) := (others => '0');

 	--Outputs
   signal do : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: sendfifo PORT MAP (
          clk => clk,
          reset => reset,
          do => do,
          zerobit => zerobit,
          onebit => onebit,
          bitselect => bitselect,
          pixel_next => pixel_next,
          pixel_write => pixel_write,
          pixel => pixel
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
      reset <= '1';
		wait for 100 ns;	
      reset <= '0';
		
      wait for clk_period*10;
		
		pixel_write <= '1';
		pixel <= "101010101010101010101011";
      wait for clk_period*1;
		pixel_write <= '0';
		
      wait for clk_period*10;

		for I in 0 to 23 loop
			bitselect <= to_unsigned(I,bitselect'length);
			wait for clk_period*1;
		end loop;
		
      wait for clk_period*10;
		
		pixel_next<='1';		
		for I in 0 to 23 loop
			bitselect <= to_unsigned(I,bitselect'length);
			wait for clk_period*1;
			pixel_next<='0';		
		end loop;
 
      -- insert stimulus here 

      wait;
   end process;

END;
