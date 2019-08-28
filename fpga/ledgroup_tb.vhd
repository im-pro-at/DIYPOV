--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:29:10 03/23/2018
-- Design Name:   
-- Module Name:   D:/Drive/Dokumente/Projekte/POV/fpga/main/ledgroup_tb.vhd
-- Project Name:  main
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ledgroup
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
 
ENTITY ledgroup_tb IS
END ledgroup_tb;
 
ARCHITECTURE behavior OF ledgroup_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ledgroup
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         do : OUT  std_logic_vector(3 downto 0);
         bit_next : in  STD_LOGIC;
         bitscount : IN  unsigned(4 downto 0);
         pixel_next : OUT  std_logic;
         next_led : OUT  unsigned(6 downto 0);
         pixel_write : IN  std_logic;
         pixel : IN  std_logic_vector(23 downto 0);
         wing_select : IN  unsigned(1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
	signal bit_next : STD_LOGIC :='0';
   signal bitscount : unsigned(4 downto 0) := (others => '1');
   signal pixel_write : std_logic := '0';
   signal pixel : std_logic_vector(23 downto 0) := (others => '0');
   signal wing_select : unsigned(1 downto 0) := (others => '0');

 	--Outputs
   signal do : std_logic_vector(3 downto 0);
   signal pixel_next : std_logic;
   signal next_led : unsigned(6 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	signal clkcounter : integer;
 
BEGIN
  
	-- Instantiate the Unit Under Test (UUT)
   uut: ledgroup PORT MAP (
          clk => clk,
          reset => reset,
          do => do,
          bit_next => bit_next,
          bitscount => bitscount,
          pixel_next => pixel_next,
          next_led => next_led,
          pixel_write => pixel_write,
          pixel => pixel,
          wing_select => wing_select
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 



   bitscount_process :process(clk,reset)
   begin
		if(reset = '1') then
			clkcounter <= 3;
			bit_next <= '0';
			bitscount <= to_unsigned(31,bitscount'length);
		elsif (clk'event and clk='1') then 
			bit_next <= '0';
			if(clkcounter=0) then 
				clkcounter<=3;
				bit_next <= '1';
				if(bitscount = 0) then 
					bitscount <= to_unsigned(31,bitscount'length);
				else 
					bitscount <= bitscount-1;				
				end if;				
			else
				clkcounter <= clkcounter-1;
			end if;
		end if;
   end process;

   pixel_process :process
   begin
		for count in 0 to 200 loop
			wait until clk'event and clk='1' and pixel_next='1';
			wait until clk'event and clk='1';
			wait until clk'event and clk='1';
			wait until clk'event and clk='1';
			wait until clk'event and clk='1';
			for I in 0 to 3 loop
				pixel(23 downto 16) <= std_logic_vector(to_unsigned(to_integer(next_led),8));
				pixel(15 downto 8) <= std_logic_vector(to_unsigned(I,8));
				pixel(7 downto 0) <= std_logic_vector(to_unsigned(count,8));
				wing_select <= to_unsigned(I,wing_select'length);
				pixel_write <= '1';
				wait until clk'event and clk='1';
				pixel_write <= '0';				
			end loop;
		end loop;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		reset <= '1';
      wait for 100 ns;	
		reset <= '0';

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
