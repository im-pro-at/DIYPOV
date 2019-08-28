----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:46:25 03/17/2018 
-- Design Name: 
-- Module Name:    main - Behavioral 
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

entity main is
    Port ( reset_ext : in  STD_LOGIC;
           clk_ext : in  STD_LOGIC;
			  led : out std_logic_vector(3 downto 0);
           data_clk : in  STD_LOGIC;
           data_syn : in  STD_LOGIC;
           data_open : in  STD_LOGIC;
           data : in   STD_LOGIC_VECTOR (7 downto 0);
           trigger : in  STD_LOGIC;
           do : out  STD_LOGIC_VECTOR (15 downto 0);
           co : out  STD_LOGIC_VECTOR (15 downto 0));
end main;

architecture Behavioral of main is

	component pll
	port
	 (-- Clock in ports
	  CLK_IN           : in     std_logic;
	  -- Clock out ports
	  CLK_OUT          : out    std_logic
	 );
	end component;


	COMPONENT frameDPRAM
	  PORT (
		 clka : IN STD_LOGIC;
		 wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		 addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
		 dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 clkb : IN STD_LOGIC;
		 addrb : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
		 doutb : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	  );
	END COMPONENT;

	COMPONENT synchronise is
		 Generic(S : integer; RESET_VAL : std_logic); 
		 Port ( clk : in STD_LOGIC;
				  reset : in STD_LOGIC;
				  input : in  STD_LOGIC;
				  output : out  STD_LOGIC);
	end COMPONENT;

	COMPONENT settled is
		 Generic(S : integer); 
		 Port ( clk : in STD_LOGIC;
				  reset : in STD_LOGIC;
				  input : in  STD_LOGIC;
				  settled : out  STD_LOGIC);
	end COMPONENT;
	

   COMPONENT ledgroup
		 Generic(
 			START_LED: integer := 1;
			END_LED: integer := 5
 		 );
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
	 
	component div
		port (
		clk: in std_logic;
		rfd: out std_logic;
		dividend: in std_logic_vector(31 downto 0);
		divisor: in std_logic_vector(19 downto 0);
		quotient: out std_logic_vector(31 downto 0);
		fractional: out std_logic_vector(19 downto 0));
	end component;


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


	signal clk : STD_LOGIC;
	signal reset : STD_LOGIC;

	signal data_clk_int : STD_LOGIC;
	signal data_clk_settled : STD_LOGIC;
	signal data_syn_int : STD_LOGIC;
	signal data_data_int : STD_LOGIC_VECTOR (7 downto 0);

	signal data_address : unsigned(13 downto 0);
	signal data_clk_last : std_logic;
	signal data_step: integer range 0 to 2 :=0;
	signal data_last_data: std_logic_vector(7 downto 0); 

	signal data_ram_wea : std_logic_vector(0 downto 0);
	signal data_ram_address : std_logic_vector(13 downto 0);
	signal data_ram_data : std_logic_vector(11 downto 0);
	
	constant rotation_prescale_C : integer := 2**3;
	constant rotation_tigger_lock_C : integer := 2**15;

	signal trigger_int : std_logic;
	signal rotation_prescale : integer range 0 to rotation_prescale_C-1;
	signal rotation_tigger_lock : integer range 0 to rotation_tigger_lock_C-1;
	signal rotation_counter : unsigned(19 downto 0);
	signal rotation_counter_last : unsigned(19 downto 0);
	
	type integer_array_t is ARRAY(0 to 3) of integer range 1 to 33;
	type unsigned_array_t is ARRAY(0 to 3) of unsigned(6 downto 0);
	constant START_LED_ARRAY :  integer_array_t := (1, 6 , 12, 20);
	constant END_LED_ARRAY   :  integer_array_t := (5, 11, 19, 33);
	signal ledgroup_wing_slect : unsigned(1 downto 0);
	signal ledgroup_pixel_write : std_logic_vector(3 downto 0);
	signal ledgroup_pixel : std_logic_vector(23 downto 0);
	signal ledgroup_pixel_next : std_logic_vector(3 downto 0);
	signal ledgroup_next_led : unsigned_array_t;

	constant BITCOUNT_COUNTER_MAX : integer := 6; -- MAX update rate 10MHz => 4
	signal bitcounter_counter : integer range 0 to BITCOUNT_COUNTER_MAX-1;
	signal bitcounter_bitscount : unsigned(4 downto 0);
	signal bitcounter_bit_next : std_logic;
	
	
	signal calc_div_dividend: std_logic_vector(31 downto 0);
	signal calc_div_divisor: std_logic_vector(19 downto 0);
	signal calc_div_quotient: std_logic_vector(31 downto 0);
	signal calc_rotcount1 : unsigned(5 downto 0) := (others => '-');
	signal calc_rotcount2 : unsigned(19 downto 0):= (others => '-');
	signal calc_rotcount3 : unsigned(19 downto 0):= (others => '-');
	signal calc_div_result: unsigned(11 downto 0):= (others => '-');		
   signal calc_cordic_x_in :  std_logic_vector(13 downto 0);
   signal calc_cordic_phase_in :  std_logic_vector(13 downto 0);
   signal calc_cordic_nd :  std_logic := '0';
   signal calc_cordic_rfd :  std_logic;
   signal calc_cordic_rdy :  std_logic;
   signal calc_cordic_x_out :  std_logic_vector(9 downto 0);
   signal calc_cordic_y_out :  std_logic_vector(9 downto 0);

	type calc_state_T is (
		CACLC_SELECT1,
		CACLC_SELECT2, 
		CALC_HEIGHTANDANGLE, 
		CALC_CORDIC_START, 
		CALC_CORDIC_DONE,
		CALC_ADDRESS,
		CALC_READ,
		CALC_WRITE );

	signal calc_state: calc_state_T;
	signal calc_groupstrigger: std_logic_vector(3 downto 0);
	signal calc_selected : integer range 0 to 3;
	signal calc_wing_even_odd : std_logic;
	signal calc_height : unsigned(6 downto 0);
	signal calc_angle : signed(13 downto 0);
	signal calc_wing : integer range 0 to 3;
	signal calc_cordic_x : signed(7 downto 0); 
	signal calc_cordic_y : signed(7 downto 0); 
	signal calc_ram_addrb : STD_LOGIC_VECTOR(13 DOWNTO 0);
	signal calc_ram_doutb : STD_LOGIC_VECTOR(11 DOWNTO 0);
	
	type scale_t is array(1 to 33) of unsigned(15 downto 0);
	
	function init_scale return scale_t is
		variable scale : scale_t;
	begin 
		-- LEDS: 33 32 ..... 2 1 
		-- LED 1 Max SCALE => 2^16 /2^4 = 4096
		
		for I in 1 to 33 loop
			scale(I) := to_unsigned( natural( 4096.0 / 33.0 *real(34-I))  ,16);
		end loop;
		return scale;
	end function init_scale;
	
	constant scale : scale_t := init_scale;

begin 
	--DEBUG:
	led(0) <= reset;
	led(1) <= data_open;
	led(2) <= data_clk_int;
	led(3) <= trigger_int;

	------------------------------------------------------------------------------
	-- "Output    Output      Phase     Duty      Pk-to-Pk        Phase"
	-- "Clock    Freq (MHz) (degrees) Cycle (%) Jitter (ps)  Error (ps)"
	------------------------------------------------------------------------------
	-- CLK_OUT1____40.000______0.000______50.0______607.088____150.000
	--
	------------------------------------------------------------------------------
	-- "Input Clock   Freq (MHz)    Input Jitter (UI)"
	------------------------------------------------------------------------------
	-- __primary___________8.000____________0.010
	pll1 : pll
	  port map
		(-- Clock in ports
		 CLK_IN => clk_ext,
		 -- Clock out ports
		 CLK_OUT => clk);


	-- reset handling
	synch0: synchronise
				  generic map (S   => 3, RESET_VAL => '1') 
				  port map    (clk  => clk,
									reset => '0',
									input => reset_ext,
									output => reset);
	--DPRAM
	-- 131*131*8bit => 17161 * 8bit
	-- IDEA 131*131*12bit -4*19*19*12bit  => 15717*12bit 
	frameram : frameDPRAM
	  PORT MAP (
		 clka => clk,
		 clkb => clk,
		 --write port
		 wea => data_ram_wea,
		 addra => data_ram_address,
		 dina => data_ram_data,
		 --read port
		 addrb => calc_ram_addrb,
		 doutb => calc_ram_doutb
	  );


	-- data input synching
	synch1: synchronise
				  generic map (S   => 3, RESET_VAL => '0') 
				  port map    (clk  => clk,
									reset => reset,
									input => data_clk,
									output => data_clk_int);
	settled1 : settled
				  generic map (S   => 5) 
				  port map    (clk  => clk,
									reset => reset,
									input => data_clk_int,
									settled => data_clk_settled);
	synch2: synchronise
				  generic map (S   => 3, RESET_VAL => '0') 
				  port map    (clk  => clk,
									reset => reset,
									input => data_syn,
									output => data_syn_int);
	synch_data: 
		for I in 0 to 7 generate 
			synch3 :synchronise
				  generic map (S   => 3, RESET_VAL => '0') 
				  port map    (clk  => clk,
									reset => reset,
									input => data(I),
									output => data_data_int(I));
		end generate synch_data;



	-- data input address calulcation and write enable
	--   -> X
	--  | 0     1     2     ..... 128 129 130
	--  v 131   132   133   ..... 259 260 261
	--    262   ......                 
	--  Y :
	--    :
	--		.............................       17160 


	process (clk)
	begin  
		if (clk'event and clk = '1') then
			if (reset = '1') then
				data_address <= (others => '0');
				data_clk_last <= '0';
				data_step <= 0;
				data_last_data <= (others => '0');
			else
				data_ram_wea <= (others => '0');
				if(data_clk_settled = '1' and data_clk_last /= data_clk_int) then  --data_clk edge
					data_clk_last <= data_clk_int;
					if(data_clk_int = '0') then --data_clk falling edge
						if(data_syn_int = '1') then --first pixsel sync!
							data_address <= to_unsigned(0,data_address'length);			
							data_step <= 1;
						else
							if(data_step = 0) then
								data_step <= 1;
							elsif(data_step = 1) then 
								data_step <= 2;
								data_ram_data <= data_last_data & data_data_int(7 downto 4);
								data_ram_address <= std_logic_vector(data_address);
								data_address <= data_address +1;
								data_ram_wea <= (others => '1');
							else 
								data_step <= 0;							
								data_ram_data <= data_last_data(3 downto 0) & data_data_int;
								data_ram_address <= std_logic_vector(data_address);
								data_address <= data_address +1;
								data_ram_wea <= (others => '1');
							end if;
						end if;
						data_last_data <= data_data_int;							
					end if;
				end if;
			end if;
		end if;
	end process;


	synch4: synchronise
				  generic map (S   => 3, RESET_VAL => '1') 
				  port map    (clk  => clk,
									reset => reset,
									input => trigger,
									output => trigger_int);
	-- rotation count
	-- possible rotation frequence is 8 to 40 rotation per secound
	-- @40Mhz => 1 to 5*10^6 clocks per rotation
	-- log2(5*10^6) ~= 23 bit
	-- use prescaler 8 => 20 bit counter!
	-- block tigger for rotation_tigger_lock_C clocks!

	process (clk)
	begin  
		if (clk'event and clk = '1') then		
			if (reset = '1') then
				rotation_prescale <= 0;
				rotation_tigger_lock <= 0;
				rotation_counter <= to_unsigned(0,rotation_counter'length);
				rotation_counter_last <= (others => '1');
			else
				if(rotation_prescale = 0) then  --count up
					rotation_prescale <= rotation_prescale_C-1;		
					rotation_counter <= rotation_counter+1;
				else
					rotation_prescale <= rotation_prescale-1;
				end if;
				if(rotation_tigger_lock /= 0) then 
					rotation_tigger_lock <= rotation_tigger_lock-1;
				end if;	
				if(trigger_int='0') then  --tigger 
					if(rotation_tigger_lock=0) then 
						rotation_tigger_lock <= rotation_tigger_lock_C-1;
						rotation_prescale <= rotation_prescale_C-1;
						rotation_counter_last <= rotation_counter;
						rotation_counter <= to_unsigned(0,rotation_counter'length);			
					else 
						rotation_tigger_lock <= rotation_tigger_lock_C-1;			
					end if;
				end if;
			end if;
		end if;
	end process;

	--ledgroups 4x
	ledgroups: 
		for I in 0 to 3 generate
			ledgroup1 :ledgroup
				  generic map (START_LED   => START_LED_ARRAY(I),
									END_led		=> END_LED_ARRAY(I)) 
				  port map    (clk  => clk,
									reset => reset,
									do => do((I+1)*4-1 downto I*4),
									bit_next => bitcounter_bit_next,
									bitscount => bitcounter_bitscount,
									pixel_next =>ledgroup_pixel_next(I),
									next_led => ledgroup_next_led(I),
									pixel_write => ledgroup_pixel_write(I),
									pixel =>ledgroup_pixel,
									wing_select =>ledgroup_wing_slect);
		end generate ledgroups;

	--bit count
	--globla counter for all LEDs
	--counts form 31 to 0 and repeats
	--the count speed is 2MHz 
	--also co is generated
	process(clk)
	begin 
		if(clk'event and clk='1') then 
			if(reset = '1') then 
				bitcounter_counter <= BITCOUNT_COUNTER_MAX-1;
				bitcounter_bitscount <= (others => '1');
				bitcounter_bit_next <= '0';
				co <= (others => '0');
			else
				bitcounter_bit_next <= '0';
				if(bitcounter_counter=0) then 
					co <= (others => '0');
					bitcounter_counter <= BITCOUNT_COUNTER_MAX-1;
					bitcounter_bit_next <= '1';
					if(to_integer(bitcounter_bitscount) = 0) then 
						bitcounter_bitscount <= (others => '1');					
					else
						bitcounter_bitscount <= bitcounter_bitscount -1;
					end if;
				else
					bitcounter_counter <= bitcounter_counter -1;
				end if;
							
				if(bitcounter_counter = BITCOUNT_COUNTER_MAX/2) then 
					co <= (others => '1');
				end if;
			end if;
		end if;
	end process;

	-- predict angle 
	-- 1) calc rotation count for the pixcel output time  					
	-- 2) calc angle new rotation count / last rotation count *1024  		

	process(clk)
	begin 
		if(clk'event and clk='1') then 
			calc_rotcount1 <= to_unsigned(32 + to_integer(bitcounter_bitscount),calc_rotcount1'length);
			calc_rotcount2 <= to_unsigned((to_integer(calc_rotcount1)*BITCOUNT_COUNTER_MAX+35)/rotation_prescale_C,calc_rotcount2'length);
			calc_rotcount3 <= calc_rotcount2+rotation_counter;
		end if;
	end process;
	
	calc_div_dividend <= std_logic_vector(calc_rotcount3)&"000000000000";
	calc_div_divisor <= std_logic_vector(rotation_counter_last(19 downto 0));
	calc_div_result <= unsigned(calc_div_quotient(11 downto 0));
	div1 : div
		port map (
			clk => clk,
			rfd => open,
			dividend => calc_div_dividend,
			divisor => calc_div_divisor,
			quotient => calc_div_quotient,
			fractional => open);


			
	--     Calc next pixsel value
	-- 0) select a group 																2  clk
	-- repeat 3-6 for all wings maybe save some clocks by symetry       
	-- 3) calc pixel height                                              
	--	4) calc pixel codinates from angle and hight. 
	-- 5) load pixel form memroy 
	-- 6) scale pixel 
	-- all have to be done in BITCOUNT_COUNTER_MAX *32 /4 clock cicles
	

	calc_cordic_phase_in <= std_logic_vector(calc_angle);
	calc_cordic_x_in <= std_logic_vector(to_unsigned(to_integer(calc_height),8))&"000000";
   cordic1: cordic PORT MAP (
          clk => clk,
          x_in => calc_cordic_x_in,
          y_in => (others => '0'),
          phase_in => calc_cordic_phase_in,
          nd => calc_cordic_nd,
          rfd => calc_cordic_rfd, 
          rdy => calc_cordic_rdy,
          x_out => calc_cordic_x_out,
          y_out => calc_cordic_y_out
        );


	process(clk)
		variable scale_V : integer;
		variable x : integer;
		variable y : integer;		
	begin 
		if(clk'event and clk='1') then 
			if(reset ='1') then 
				calc_groupstrigger <= (others => '0');
				calc_state <= CACLC_SELECT1;
				calc_selected <= 0;
				calc_wing_even_odd <= '0';
				calc_height <= (others => '0');
				calc_angle <= (others => '0');
				calc_cordic_nd <= '0';
				calc_wing <= 0;
				calc_cordic_x <= (others => '0');
				calc_cordic_y <= (others => '0');
				calc_ram_addrb <= (others => '0');
				ledgroup_pixel_write <= (others => '0');
				ledgroup_wing_slect <= (others => '0');
			else
				calc_cordic_nd <= '0';
				ledgroup_pixel_write <= (others => '0');
				ledgroup_wing_slect <= (others => '0');

				for I in 0 to 3 loop
					if(ledgroup_pixel_next(I) = '1') then 
						calc_groupstrigger(I) <= '1'; 
					end if;
				end loop;
				
				case calc_state is
					when CACLC_SELECT1 =>
						if(calc_selected = 3) then 
							calc_selected <= 0;
						else
							calc_selected <= calc_selected+1;
						end if;
						calc_state <= CACLC_SELECT2;
					when CACLC_SELECT2 =>
						if(calc_groupstrigger(calc_selected) = '1') then 
							calc_state <= CALC_HEIGHTANDANGLE;		
							calc_wing_even_odd <= '0';
						else 
							calc_state <= CACLC_SELECT1;					
						end if;
					when CALC_HEIGHTANDANGLE =>
						if(calc_wing_even_odd = '0') then 
							calc_height <= to_unsigned(66 - to_integer(ledgroup_next_led(calc_selected))*2,calc_height'length);
							calc_angle  <= to_signed(((0-to_integer(calc_div_result)) mod 4096) -2047,calc_angle'length);
						else 
							calc_height <= to_unsigned(67 - to_integer(ledgroup_next_led(calc_selected))*2,calc_height'length);										
							calc_angle  <= to_signed(((0-to_integer(calc_div_result)+1024) mod 4096) -2047,calc_angle'length);
						end if;
						calc_state <= CALC_CORDIC_START;	
					when CALC_CORDIC_START =>
						if(calc_cordic_rfd = '1') then 
							calc_cordic_nd <= '1';
							if(calc_wing_even_odd = '0') then 
								calc_wing_even_odd <= '1';
								calc_state <= CALC_HEIGHTANDANGLE;									
							else 
								calc_state <= CALC_CORDIC_DONE;	
								calc_wing <= 0;
							end if;
						end if;
					when CALC_CORDIC_DONE =>
						if(calc_cordic_rdy = '1') then 
							if(signed(calc_cordic_x_out(9 downto 2)) < -65) then 
								calc_cordic_x <= to_signed( -65,calc_cordic_x'length);						
							elsif(signed(calc_cordic_x_out(9 downto 2)) > 65) then 
								calc_cordic_x <= to_signed(65,calc_cordic_x'length);												
							else
								calc_cordic_x <= to_signed(to_integer(signed(calc_cordic_x_out(9 downto 2))),calc_cordic_x'length);												
							end if;
							if(signed(calc_cordic_y_out(9 downto 2)) < -65) then 
								calc_cordic_y <= to_signed(-65,calc_cordic_y'length);						
							elsif(signed(calc_cordic_y_out(9 downto 2)) > 65) then 
								calc_cordic_y <= to_signed(65,calc_cordic_y'length);												
							else
								calc_cordic_y <= to_signed(to_integer(signed(calc_cordic_y_out(9 downto 2))),calc_cordic_y'length);												
							end if;
							calc_state <= CALC_ADDRESS;	
						end if;
					when CALC_ADDRESS =>
						--calc_ram_addrb <= std_logic_vector(to_unsigned((65 + to_integer(calc_cordic_x))+(65 + to_integer(calc_cordic_y))*131,calc_ram_addrb'length));
						x:= 65 + to_integer(calc_cordic_x);
						y:= 65 + to_integer(calc_cordic_y);
						if(x <19) then 
							calc_ram_addrb <= std_logic_vector(to_unsigned(y-19+x*(131-19*2),calc_ram_addrb'length));
						elsif(x >= 131-19) then 
							calc_ram_addrb <= std_logic_vector(to_unsigned(y-19+x*(131-19*2)+(131-19*2)*19*2,calc_ram_addrb'length));		
						else
							calc_ram_addrb <= std_logic_vector(to_unsigned(y+x*131-19*19*2,calc_ram_addrb'length));						
						end if;
						calc_state <= CALC_READ;	
					when CALC_READ =>
						calc_state <= CALC_WRITE;	
					when CALC_WRITE =>
						--if(calc_wing=0) then
							--Bit    11 10  9  8  7  6  5  4  3  2  1  0
							--Data    R  R  R  R  G  G  G  G  B  B  B  B
 							if (data_open = '1') then  
								scale_V := to_integer(scale(to_integer(ledgroup_next_led(calc_selected))));
								-- BLUE
								ledgroup_pixel(23 downto 16) <= std_logic_vector(to_unsigned((scale_V*to_integer(unsigned(calc_ram_doutb( 3 downto 0))))/256,8));
								-- GREEN
								ledgroup_pixel(15 downto  8) <= std_logic_vector(to_unsigned((scale_V*to_integer(unsigned(calc_ram_doutb( 7 downto 4))))/256,8));
								-- RED
								ledgroup_pixel( 7 downto  0) <= std_logic_vector(to_unsigned((scale_V*to_integer(unsigned(calc_ram_doutb(11 downto 8))))/256,8));
							else -- not data => show grid:
								-- BLUE
								ledgroup_pixel(23 downto 16) <= std_logic_vector(to_unsigned((65 + to_integer(calc_cordic_x)),8));--calc_ram_doutb
								-- GREEN
								ledgroup_pixel(15 downto  8) <= std_logic_vector(to_unsigned((65 + to_integer(calc_cordic_y)),8));--calc_ram_doutb				
								-- RED
								ledgroup_pixel( 7 downto  0) <= std_logic_vector(to_unsigned(to_integer(calc_height)*3,8));--calc_ram_doutb						
							end if;
						--else
						--	ledgroup_pixel <= (others => '0');						
						--end if;

						ledgroup_wing_slect <= to_unsigned(calc_wing,2);
						ledgroup_pixel_write(calc_selected) <= '1';	
						
						if(calc_wing = 0) then 
							calc_state <= CALC_ADDRESS;	
							calc_cordic_x <= -calc_cordic_x;
							calc_cordic_y <= -calc_cordic_y;
							calc_wing <= 2;
						elsif(calc_wing = 2) then 
							calc_state <= CALC_CORDIC_DONE;	
							calc_wing <= 1;
						elsif(calc_wing = 1) then 
							calc_state <= CALC_ADDRESS;	
							calc_cordic_x <= -calc_cordic_x;
							calc_cordic_y <= -calc_cordic_y;
							calc_wing <= 3;
						else
							calc_state <= CACLC_SELECT1;
							calc_groupstrigger(calc_selected) <= '0';
						end if;
				end case;
			end if;
		end if;
	end process;
	


end Behavioral;

