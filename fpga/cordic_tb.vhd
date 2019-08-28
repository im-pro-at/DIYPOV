--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:18:30 03/28/2018
-- Design Name:   
-- Module Name:   D:/Drive/Dokumente/Projekte/POV/fpga/main/cordic_tb.vhd
-- Project Name:  main
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cordic
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
 
ENTITY cordic_tb IS
END cordic_tb;
 
ARCHITECTURE behavior OF cordic_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cordic
    PORT(
         x_in : IN  std_logic_vector(13 downto 0);
         y_in : IN  std_logic_vector(13 downto 0);
         phase_in : IN  std_logic_vector(13 downto 0);
         nd : IN  std_logic;
         x_out : OUT  std_logic_vector(9 downto 0);
         y_out : OUT  std_logic_vector(9 downto 0);
         rdy : OUT  std_logic;
         rfd : OUT  std_logic;
         clk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal x_in : std_logic_vector(13 downto 0) := (others => '0');
   signal y_in : std_logic_vector(13 downto 0) := (others => '0');
   signal phase_in : std_logic_vector(13 downto 0) := (others => '0');
   signal nd : std_logic := '0';
   signal clk : std_logic := '0';

 	--Outputs
   signal x_out : std_logic_vector(9 downto 0);
   signal y_out : std_logic_vector(9 downto 0);
   signal rdy : std_logic;
   signal rfd : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	signal A : integer;
	signal H : integer;
	signal X : integer;
	signal Y : integer;
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cordic PORT MAP (
          x_in => x_in,
          y_in => y_in,
          phase_in => phase_in,
          nd => nd,
          x_out => x_out,
          y_out => y_out,
          rdy => rdy,
          rfd => rfd,
          clk => clk
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
		variable angle : integer range 0 to 1023;
		variable height: integer range 0 to 65;
   begin		
      wait for clk_period*10;
		for J in 65 to 65 loop
			height := J;
			for I in 0 to 1023 loop
				wait for clk_period*5;
				angle := I;
				x_in<= std_logic_vector(to_unsigned(height,8))&"000000"; -- 0 to 65
				H <= height;
				phase_in<= std_logic_vector(to_signed(angle -511,12))&"00"; -- 0 to 1023
				A <= angle;
				nd <= '1';
				wait for clk_period*1;
				wait until rfd = '1' ;
				wait for clk_period*1;
				nd <= '0';
				wait until rdy = '1' ;
				wait until rdy = '0' ;
				wait until rdy = '1' ;
				X <= to_integer(signed(x_out(9 downto 2)));
				Y <= to_integer(signed(y_out(9 downto 2)));			
				report ";"&integer'image(A)&";"&integer'image(H)&";"&integer'image(X) & ";"&integer'image(Y)&";";
			end loop;
		end loop;
      -- insert stimulus here 

      wait;
   end process;

END;
