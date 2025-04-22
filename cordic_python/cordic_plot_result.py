import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv(r'.\..\cordic_vhdl\tb_cordic_sin_cos_out.txt')
# df = pd.read_csv(r'.\..\cordic_vhdl\tb_cordic_rotation_out.txt')
# print(df)

# nd = N_ITER + REGISTER_INPUT + Nth_REGISTER + RESULT_REGISTER
nd = 13

angle = df['angle'][:-nd]
x = df['x'][nd:]
y = df['y'][nd:]

angle_d = np.rad2deg(angle)
plt.plot(angle_d, x, 'b', lw=4, label='CORDIC: cos')
plt.plot(angle_d, np.cos(angle), 'r--', lw=4, label='NUMPY: cos')

plt.plot(angle_d, y, 'c', lw=4, label='CORDIC: sin')
plt.plot(angle_d, np.sin(angle), 'm--', lw=4, label='NUMPY: sin')

plt.axvline(-90, c='k', linestyle='--')
plt.axvline(90, c='k', linestyle='--')

plt.axvline(-180, c='k', linestyle='--')
plt.axvline(180, c='k', linestyle='--')

# plt.xlim([-180, 180])

plt.legend()
plt.grid()
plt.show()
