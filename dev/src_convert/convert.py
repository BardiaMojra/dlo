import numpy as np
# from nbug import *
from pdb import set_trace as st




data = np.load("./state.npy")

# print(data)
print(data.shape)
st()
np.savetxt("./data_state.csv", data[0:1,:], delimiter=',')
