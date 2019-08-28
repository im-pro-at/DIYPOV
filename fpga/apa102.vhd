----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:56:52 03/24/2018 
-- Design Name: 
-- Module Name:    apa102 - Behavioral 
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

entity apa102 is
    Port ( ci : in  STD_LOGIC;
           di : in  STD_LOGIC;
           co : out  STD_LOGIC;
           do : out  STD_LOGIC;
			  data : out std_logic_vector(31 downto 0);
			  has_data : out std_logic
			  );
end apa102;

architecture Behavioral of apa102 is
	type STATE_T is (START, TRANSPARENT);
	signal state : STATE_T := START;
	signal count : integer :=31;

	function slv_to_string ( a: std_logic_vector) return string is
		 variable b : string (a'length-1 downto 1) := (others => NUL);
	begin
			  for i in a'length-1 downto 1 loop
			  b(i) := std_logic'image(a((i-1)))(2);
			  end loop;
		 return b;
	end function;

begin


	process(ci)
	begin 
		if(ci'event and ci='1') then 			
			has_data <= '0';
			case state is
				when START =>
					do <= '0';
					if(count = 31 and di = '1') then 
						count <= count -1;
						data(count) <= di;					
					elsif(count < 31 and count >= 0) then 
						count <= count -1;
						data(count) <= di;
						if(count = 0) then 
							has_data <= '1';
							state <= TRANSPARENT;
							count <= 31;
						end if;
					end if;
				when TRANSPARENT =>
					do <= di;
					if(di = '1') then 
						count <= 31;
					else 
						if(count <= 0) then 
							state<=START;
							count<=31;
						else 
							count <= count-1;							
						end if;
					end if;
			end case;
		end if;
	end process;


	co <= not ci;

end Behavioral;

