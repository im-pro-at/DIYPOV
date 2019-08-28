----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:20:38 03/21/2018 
-- Design Name: 
-- Module Name:    sendfifo - Behavioral 
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

entity sendfifo is
    Port ( clk: in STD_LOGIC;
	        reset: in STD_LOGIC;
	        do : out  STD_LOGIC;
           zerobit : in  STD_LOGIC;
           onebit : in  STD_LOGIC;
           bitselect : in  unsigned (4 downto 0);
           pixel_next : in  STD_LOGIC;
           pixel_write : in  STD_LOGIC;
           pixel : in  STD_LOGIC_VECTOR (23 downto 0));
end sendfifo;

architecture Behavioral of sendfifo is
	signal pixel1 :  STD_LOGIC_VECTOR (23 downto 0);
	signal pixel2 : STD_LOGIC_VECTOR (23 downto 0);

begin

-- next Process
process(clk)
begin
	if (clk'event and clk = '1') then
		if (reset = '1') then
			pixel1 <= (others => '0');
			pixel2 <= (others => '0');
		else
			pixel1 <= pixel1;
			pixel2 <= pixel2;
			if(pixel_write = '1') then 
				pixel2 <= pixel;
			end if;
			if(pixel_next = '1') then 
				pixel1 <= pixel2;
			end if;
		end if;
	end if;
end process;

-- output Process
process(zerobit,onebit,pixel1,bitselect)
begin
	if(zerobit = '1') then
		do<='0';
	elsif(onebit = '1') then
		do<='1';
	elsif(bitselect <= 23) then 
		do<=pixel1(to_integer(bitselect));	
	else
		do<='-';		
	end if;
end process;



end Behavioral;

