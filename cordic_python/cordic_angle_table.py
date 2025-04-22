import numpy as np

n = 10 # number of iterations

THETA = np.arctan(1 / (2 ** np.arange(0, n)))

K = np.cumprod(np.cos(THETA))[-1] # cordic constant
print(K)

N_BIT = 16
N_BIT_FRAC = N_BIT - 3

Z_SCALE = 2 ** N_BIT_FRAC # angle scale

# clac Table values
TABLE = (THETA * Z_SCALE).astype(int)
print(*TABLE, sep=', ')
