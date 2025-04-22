library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity add_sub is
	generic(
		WIDTH : integer := 8
	);
    Port ( a : in  signed (WIDTH-1 downto 0);
           b : in   signed(WIDTH-1 downto 0);
           d : in  STD_LOGIC;
           res : out  signed(WIDTH-1 downto 0));
end add_sub;

architecture Behavioral of add_sub is
begin

	res <= (a + b) when d = '0' else (a - b);
	
end Behavioral;

