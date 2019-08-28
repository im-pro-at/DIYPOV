----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:22:41 03/17/2018 
-- Design Name: 
-- Module Name:    synchronise - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity settled is
    Generic(S : integer := 3); 
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
	        input : in  STD_LOGIC;
           settled : out  STD_LOGIC);
end settled;

architecture Behavioral of settled is
	type T_stages is array (0 to S) of std_logic;
	signal stages: T_stages;
begin
	
process(clk)
begin
	if (clk'event and clk = '1') then
		if (reset = '1') then
			stages <= (others => '0');
		else
			for I in 1 to S loop
				stages(I-1) <= stages(I);
			end loop;
			stages(S) <= input;
		end if;
	end if;
end process;

process(stages, input)
begin
	settled <= '1';
	for I in 1 to S loop
		if(stages(I-1) /= stages(I) or stages(S) /= input) then
			settled <= '0';				
		end if;
	end loop;			
end process;

end Behavioral;

