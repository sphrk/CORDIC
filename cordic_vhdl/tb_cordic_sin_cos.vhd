LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;

use ieee.math_real.all;

use work.cordic_pkg.all; -- include defined constants

library std;
use std.textio.all;

ENTITY tb_cordic_sin_cos IS
END tb_cordic_sin_cos;
 
ARCHITECTURE behavior OF tb_cordic_sin_cos IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cordic_sin_cos
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         i_z : IN  std_logic_vector(15 downto 0);
         i_valid : IN  std_logic;
         o_x : OUT  std_logic_vector(15 downto 0);
         o_y : OUT  std_logic_vector(15 downto 0);
         o_z : OUT  std_logic_vector(15 downto 0);
         o_ready : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal i_z : std_logic_vector(15 downto 0) := (others => '0');
   signal i_valid : std_logic := '0';

 	--Outputs
   signal o_x : std_logic_vector(15 downto 0);
   signal o_y : std_logic_vector(15 downto 0);
   signal o_z : std_logic_vector(15 downto 0);
   signal o_ready : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;

	
	signal i_zr : real; -- i_xr, i_yr, --signed(N_BIT-1 downto 0);
	signal o_xr, o_yr, o_zr : real;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cordic_sin_cos PORT MAP (
          rst => rst,
          clk => clk,
          i_z => i_z,
          i_valid => i_valid,
          o_x => o_x,
          o_y => o_y,
          o_z => o_z,
          o_ready => o_ready
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
--	i_x <= std_logic_vector(to_signed(integer(round(i_xr * XY_SCALE)), N_BIT));
--	i_y <= std_logic_vector(to_signed(integer(round(i_yr * XY_SCALE)), N_BIT));
	i_z <= std_logic_vector(to_signed(integer(round(i_zr * Z_SCALE)), N_BIT));
	
	o_xr <= real(to_integer(signed(o_x))) / XY_SCALE;
	o_yr <= real(to_integer(signed(o_y))) / XY_SCALE;
	o_zr <= real(to_integer(signed(o_z))) / Z_SCALE; 

   -- Stimulus process
   stim_proc: process
		file out_file : text open write_mode is ".\tb_cordic_sin_cos_out.txt";
		variable line_v : line;
		
		variable angle : real := -math_pi; --:= -math_pi / 2.0;
		variable step : integer := 200;
		variable angle_inc : real := 2.0 * math_pi / real(step);
   begin		
		write(line_v, "angle,x,y");
		writeline(out_file, line_v);
		
		rst <= '1';
--		wait until rising_edge(clk);
		wait for 3 ns;
		rst <= '0';
		
		i_valid <= '1';
		
--		x <= to_signed(integer(round(1.0 * xy_SCALE)), N_BIT);
--		y <= to_signed(integer(round(0.0 * xy_SCALE)), N_BIT);
--		i_xr <= 1.0; --to_signed(integer(round(1.0 * xy_SCALE)), N_BIT);
--		i_yr <= 0.0; --to_signed(integer(round(0.0 * xy_SCALE)), N_BIT);

		for i in 0 to step + 12 loop
			i_zr <= angle; --to_signed(integer(round(angle * z_scale)), N_BIT);
			
			wait until rising_edge(clk);
			
			write(line_v, angle);
			write(line_v, ",");
			write(line_v, o_xr);
			write(line_v, ",");
			write(line_v, o_yr);
			writeline(out_file, line_v);
			
			angle := angle + angle_inc;
		end loop;

   
		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
