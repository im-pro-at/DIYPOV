----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:02:17 03/21/2018 
-- Design Name: 
-- Module Name:    group - Behavioral 
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

entity ledgroup is
		Generic(
			START_LED: integer := 1;
			END_LED: integer := 5
		);
		Port ( 
			clk : in  STD_LOGIC;
         reset : in  STD_LOGIC;
         do : out  STD_LOGIC_VECTOR (3 downto 0);
         bit_next : in  STD_LOGIC;
         bitscount : in  unsigned (4 downto 0);
         pixel_next : out  STD_LOGIC;
         next_led : out  unsigned (6 downto 0);
         pixel_write : in  STD_LOGIC;
         pixel : in  STD_LOGIC_VECTOR (23 downto 0);
         wing_select : in  unsigned (1 downto 0)
		);
end ledgroup;

architecture Behavioral of ledgroup is
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

	signal zerobit : std_logic;
	signal onebit : std_logic;
	signal pixel_next_int : std_logic;
	signal pixel_write_int :  std_logic_vector(3 downto 0);

	type bal_state_T is (BAL_RESET,BAL_START,BAL_LEDFRAME_START, BAL_LEDFRAME_DATA);

	signal bal_state, bal_state_next: bal_state_T;
	signal bal_count, bal_count_next: integer range 0 to 31;
	signal bal_ledcount, bal_ledcount_next: integer range START_LED to END_LED+1;

begin

	process(wing_select,pixel_write)
	begin
		pixel_write_int <= (others => '0');
		pixel_write_int(to_integer(wing_select)) <= pixel_write;
	end process;

 	wings: for I in 0 to 3 generate
		sendfifo1 :sendfifo
			  port map    (clk  => clk,
								reset => reset,
								do => do(I),
								zerobit => zerobit,
								onebit => onebit,
								bitselect => bitscount,
								pixel_next => pixel_next_int,
								pixel_write => pixel_write_int(I),								
								pixel => pixel);
	end generate wings;
	
	
	--Bit  &  Led count process
	-- Data to send:
	--    <START 32x0> <LED1 32xX> ... <LEDX 32xX><END(LEDX/2+1)x1>
	-- 	The END part is not needed if we immediately start over!
	-- Led Frame: 
	--    <3x1><GLOBAL 5x1><BLUE 8xX><GREEN 8xX><RED 8xX>
	--

	process(clk)
	begin
		if (clk'event and clk = '1') then 
			if (reset= '1') then 
				bal_state <= BAL_RESET;
				bal_ledcount <= START_LED;
			else
				bal_state <= bal_state_next;
				bal_ledcount <= bal_ledcount_next;
			end if;
		end if;
	end process;

	process(bal_state, bal_ledcount, bitscount, bit_next)
	begin
		bal_state_next <= bal_state;
		bal_ledcount_next <= bal_ledcount;
		
		pixel_next_int <= '0'; -- to sendfifo
		pixel_next <= '0';	 -- extern 
		zerobit <= '0';
		onebit <= '0';

		case bal_state is
			when BAL_RESET =>
				--Idle for some time ...
				if (bitscount = 31 and bit_next = '1') then 
					zerobit <= '1';
					bal_state_next <= BAL_START;
					bal_ledcount_next <= START_LED;
					pixel_next <= '1';					
				else
					zerobit <= '1';				
				end if;
			when BAL_START =>
				if (bitscount = 31 and bit_next = '1') then 
					onebit <= '1';
					bal_state_next <= BAL_LEDFRAME_START;
					bal_ledcount_next <= START_LED+1;
					pixel_next_int <= '1';
					pixel_next <= '1';	
				else
					zerobit <= '1';				
				end if;
			when BAL_LEDFRAME_START =>
				if (bitscount = 31-8 and bit_next = '1') then 
					bal_state_next <= BAL_LEDFRAME_DATA;
				else
					onebit <= '1';				
				end if;
			when BAL_LEDFRAME_DATA =>
				if (bitscount = 31 and bit_next = '1') then 
					bal_ledcount_next <= bal_ledcount+1;
					if (bal_ledcount = END_LED+1) then
						zerobit <= '1';
						bal_state_next <= BAL_START;
						bal_ledcount_next <= START_LED;
						pixel_next <= '1';
					elsif (bal_ledcount = END_LED) then 
						onebit <= '1';
						bal_state_next <= BAL_LEDFRAME_START;
						pixel_next_int <= '1';
					else 
						bal_state_next <= BAL_LEDFRAME_START;					
						onebit <= '1';
						pixel_next <= '1';					
						pixel_next_int <= '1';
					end if;
				end if;
			when others => 
				bal_state_next <= BAL_RESET;
		end case;
	end process;

	next_led <= to_unsigned(bal_ledcount_next,next_led'length);


end Behavioral;

