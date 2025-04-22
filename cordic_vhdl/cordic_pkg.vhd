--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

use ieee.math_real.all;

package cordic_pkg is
	
	constant n : integer := 10;
	constant N_BIT : integer := 16;
	
	constant XY_SCALE : real := (2.0 ** (N_BIT-2));
	constant Z_SCALE : real := (2.0 ** (N_BIT-3));
	
end cordic_pkg;

package body cordic_pkg is

end cordic_pkg;
