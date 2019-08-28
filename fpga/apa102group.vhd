----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:01:19 03/24/2018 
-- Design Name: 
-- Module Name:    apa102group - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity apa102group is
		Generic(
			START_LED: integer := 1;
			END_LED: integer := 5;
			WING: integer := 0
		);
    Port ( ci : in  STD_LOGIC;
           di : in  STD_LOGIC);
end apa102group;

architecture Behavioral of apa102group is
	COMPONENT apa102 
		 Port ( ci : in  STD_LOGIC;
				  di : in  STD_LOGIC;
				  co : out  STD_LOGIC;
				  do : out  STD_LOGIC;
					data : out std_logic_vector(31 downto 0);
					has_data : out std_logic
			  );
	end COMPONENT;
	
	constant LEDCOUNT : integer := END_LED - START_LED +1;
	signal ci_int : std_logic_vector(LEDCOUNT downto 0);
	signal di_int : std_logic_vector(LEDCOUNT downto 0);
	signal co_int : std_logic_vector(LEDCOUNT -1 downto 0);
	signal do_int : std_logic_vector(LEDCOUNT -1 downto 0);
	type std_logic_vector_array_t is ARRAY(0 to LEDCOUNT-1) of std_logic_vector(31 downto 0);
	signal data_int : std_logic_vector_array_t;
	signal has_data_int : std_logic_vector(LEDCOUNT -1 downto 0);
begin

	ci_int(0) <= ci;
	di_int(0) <= di;
	leds:  
		for I in 0 to LEDCOUNT-1 generate
			led :apa102
				  port map(
						ci  => ci_int(I),
						di => di_int(I),
						co => co_int(I),
						do => do_int(I),
						data => data_int(I),
						has_data => has_data_int(I)
				 );
			
			ci_int(I+1) <= co_int(I);
			di_int(I+1) <= do_int(I);
		end generate;

	process(has_data_int)
	begin 
		for I in 0 to LEDCOUNT-1 loop
			if(has_data_int'event and has_data_int(I)='1') then
				if(START_LED+I<=5 and WING=0) then 
					report "LED "&integer'image(START_LED+I)&" WING "&integer'image(WING)&" RED "&integer'image(to_integer(unsigned(data_int(I)(7 downto  0))))&" GREEN "&integer'image(to_integer(unsigned(data_int(I)(15 downto  8))))&" BLUE "&integer'image(to_integer(unsigned(data_int(I)(23 downto 16))));
				end if;
			end if;
		end loop;
	end process;
	


end Behavioral;

