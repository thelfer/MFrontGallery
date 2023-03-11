# required libraries
import numpy as np
import matplotlib.pyplot as plt
import std
import tfel.tests
from mtest import *
from rich import print
import mtest

# using triax result as ExternalStateVariables
evolution = np.loadtxt('Triax-x_test.txt')
time = evolution[0]
temperature = {}
suction = {}

for i in range(len(evolution)):
    temperature[evolution[i][0]] = evolution[i][13]
    suction[evolution[i][0]] = evolution[i][8]*-1

# running mtest

m = mtest.MTest();
m.setBehaviour('generic', './src/libBehaviour.so', 'BentoniteBehaviour')
m.setScalarInternalStateVariableInitialValue('e',  0.53)
m.setScalarInternalStateVariableInitialValue('em', 0)
m.setScalarInternalStateVariableInitialValue('eM', 0)
m.setScalarInternalStateVariableInitialValue('SrM', 0)
m.setScalarInternalStateVariableInitialValue('a_scan', 0)
m.setScalarInternalStateVariableInitialValue('re', 0)

# initial value of the gradients (strain+suction)
m.setGradientsInitialValues([0, 0, 0, 0, 0, 0, -110000])
# initial values of the thermodynamic forces (total stress+Saturation)
m.setThermodynamicForcesInitialValues([-0.00001,-0.00001,-0.00001, 0, 0, 0, 0.3449716351])

# // Imposing the strain in each direction. The shear strain will be given
# // by the the mechanical equilibrium, i.e. SXY=0, SXZ=0, SYZ=0
ep_a = {0: 0}
m.setImposedGradient('StrainXX', {0: 0})
# m.setImposedGradient('StrainYY', '(ep_v-ep_a)/2')
# m.setImposedGradient('StrainZZ', '(ep_v-ep_a)/2')
m.setImposedGradient('StrainXY', 0)
m.setImposedGradient('StrainXZ', 0)
m.setImposedGradient('StrainYZ', 0)
# 
m.setExternalStateVariable('AirPressure', 0)
m.setExternalStateVariable('Temperature', temperature)
m.setImposedGradient('LiquidPressure', suction)
# 
# // Imposing the time
m.setTimes(time)
m.execute()
