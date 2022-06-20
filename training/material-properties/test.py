import os
# from materiallaw import YoungModulus as E
from vanadiumalloy import VanadiumAlloy_YoungModulus_SRMA2008 as E

# help(E)

print(E(600))

# os.environ["PYTHON_OUT_OF_BOUNDS_POLICY"] = "WARNING"
# os.environ["PYTHON_OUT_OF_BOUNDS_POLICY"] = "STRICT"

print(E(1000))
print(E(-1))
