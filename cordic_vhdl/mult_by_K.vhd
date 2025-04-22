library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

-- multiplying by cordic constant
entity mult_by_K is
	generic(
		N_BIT : integer := 16;
		N_BIT_FRAC : integer := 14
	);
    Port(
		x : in  signed(N_BIT-1 downto 0);
        res : out  signed(N_BIT-1 downto 0)
	);
end mult_by_K;

architecture Behavioral of mult_by_K is		
	signal u, ku : signed(2*N_BIT-1 downto 0);
begin
	
	u <= resize(x, 2*N_BIT);
	ku <= shift_left(u, 13) + shift_left(u, 11) + shift_left(u, 0) - shift_left(u, 8) - shift_left(u, 5) - shift_left(u, 2);
	
	res <= ku(ku'HIGH-(N_BIT-N_BIT_FRAC) downto N_BIT_FRAC);
	-- 2*N_BIT - 1 - (N_BIT-N_BIT_FRAC) = N_BIT + N_BIT_FRAC - 1
end Behavioral;

