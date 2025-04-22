library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use ieee.math_real.all;

use work.cordic_pkg.all; -- include defined constants

entity cordic_rotation is
    generic(
		RESET_VALUE : std_logic := '1'
	);
    Port(
		rst : in  STD_LOGIC;
        clk : in  STD_LOGIC;
		i_x : in  STD_LOGIC_VECTOR (N_BIT-1 downto 0);
		i_y : in  STD_LOGIC_VECTOR (N_BIT-1 downto 0);
		i_z : in  STD_LOGIC_VECTOR (N_BIT-1 downto 0);
        i_valid : in  STD_LOGIC;

        o_x : out  STD_LOGIC_VECTOR (N_BIT-1 downto 0);
        o_y : out  STD_LOGIC_VECTOR (N_BIT-1 downto 0);
        o_z : out  STD_LOGIC_VECTOR (N_BIT-1 downto 0);
        o_ready : out  STD_LOGIC
	);
end cordic_rotation;

architecture Behavioral of cordic_rotation is
    type table_t is array(integer range <>) of integer;
	constant TABLE : table_t(0 to n-1)  := (6433, 3798, 2006, 1018, 511, 255, 127, 63, 31, 15); -- 2**13

	constant PI : signed(N_BIT-1 downto 0) := to_signed(integer(round(Z_SCALE * math_pi)), N_BIT);

	signal x_r, y_r, z_r : signed(N_BIT-1 downto 0);
	signal kx, ky: signed(N_BIT-1 downto 0);
	
	type sgn_array_t is array(integer range <>) of signed(N_BIT-1 downto 0);
	signal x, y, z : sgn_array_t(0 to n);
	
	signal xsh, ysh : sgn_array_t(0 to n-1);
	signal d : signed(0 to n-1);
	
	signal x_next, y_next, z_next : sgn_array_t(0 to n-1);
	
	signal x_res, y_res, z_res : signed(N_BIT-1 downto 0);
		
	signal ready_r, ready_res : std_logic;
	signal ready : std_logic_vector(0 to n);
	
	signal is_in_quadrant_2, is_in_quadrant_3 : std_logic;
	signal change_xy_sign: std_logic_vector(0 to n);
begin

	g0: for i in 0 to n-1 generate
		-- shifted version in each stage
		xsh(i) <= shift_right(x(i), i);
		ysh(i) <= shift_right(y(i), i);
		
		-- sign of z in each stage
		d(i) <= z(i)(z(i)'HIGH);
	end generate;
	
	g1: for i in 0 to n-1 generate
		u1 : entity work.add_sub(Behavioral)
			generic map(WIDTH => N_BIT)
			port map(a=> x(i), b=> ysh(i), d=>not d(i), res=>x_next(i));
		
		u2 : entity work.add_sub(Behavioral)
			generic map(WIDTH => N_BIT)
			port map(a=> y(i), b=> xsh(i), d=>d(i), res=>y_next(i));
		
		u3 : entity work.add_sub(Behavioral)
			generic map(WIDTH => N_BIT)
			port map(a=> z(i), b=> to_signed(TABLE(i), N_BIT), d=>not d(i), res=>z_next(i));
	end generate;

    u_kx : entity work.mult_by_K(Behavioral)
		port map(x=>x_r, res=>kx);
	u_ky : entity work.mult_by_K(Behavioral)
		port map(x=>y_r, res=>ky);

	is_in_quadrant_2 <= '1' when (z_r > (to_signed(integer(round(z_SCALE * math_pi / 2.0)), N_BIT)) ) else '0';
	is_in_quadrant_3 <= '1' when (z_r < (to_signed(integer(round(-z_SCALE * math_pi / 2.0)), N_BIT)) ) else '0';
	
	process(rst, clk, i_valid, x_r, y_r, z_r, kx, ky, x, y, z, d, xsh, ysh, x_next, y_next, z_next, change_xy_sign, is_in_quadrant_2, is_in_quadrant_3)
	begin
		if rst = RESET_VALUE then
			x_r <= (others => '0');
			y_r <= (others => '0');
			z_r <= (others => '0');
			
			x <= (others => (others => '0'));
			y <= (others => (others => '0'));
			z <= (others => (others => '0'));
			
			change_xy_sign <= (others => '0');
			
			ready_r <= '0';
			ready <= (others => '0');
			ready_res <= '0';
		elsif rising_edge(clk) then
			
			-- register inputs when i_valid = '1'
			if i_valid = '1' then
				x_r <= signed(i_x);
				y_r <= signed(i_y);
				z_r <= signed(i_z);
				
                ready_r <= '1';
			else
				ready_r <= '0';
			end if;
			
			ready(0) <= ready_r;
			
			-- x(0) <= x_r;
			-- y(0) <= y_r;
			-- z(0) <= z_r;
			
			x(0) <= kx;
			y(0) <= ky;
			
			z(0) <= z_r;
			if is_in_quadrant_2 = '1' then
				z(0) <= z_r - PI;
			end if;
			if is_in_quadrant_3 = '1' then
				z(0) <= z_r + PI;
			end if;

			change_xy_sign <= (is_in_quadrant_2 or is_in_quadrant_3) & change_xy_sign(0 to n-1);
			
			for i in 0 to n-1 loop
				x(i+1) <= x_next(i);
				y(i+1) <= y_next(i);
				z(i+1) <= z_next(i);
				
				ready(i+1) <= ready(i);
				-- case d(i) is
				-- 	when '0' =>
				-- 		x(i+1) <= x(i) - ysh(i);
				-- 		y(i+1) <= y(i) + xsh(i);
						
				-- 		z(i+1) <= z(i) - to_signed(TABLE(i), N_BIT);
				-- 	when others =>
				-- 		x(i+1) <= x(i) + ysh(i);
				-- 		y(i+1) <= y(i) - xsh(i);
						
				-- 		z(i+1) <= z(i) + to_signed(TABLE(i), N_BIT);
				-- end case;
			end loop;
			
			ready_res <= ready(n);
			if change_xy_sign(n) = '1' then
				x_res <= - x(n);
				y_res <= - y(n);
			else
				x_res <= x(n);
				y_res <= y(n);
			end if;
			z_res <= z(n);
			
		end if;
	end process;
	
	o_x <= std_logic_vector(x_res);
	o_y <= std_logic_vector(y_res);
	o_z <= std_logic_vector(z_res);
	o_ready <= ready_res;


end Behavioral;

