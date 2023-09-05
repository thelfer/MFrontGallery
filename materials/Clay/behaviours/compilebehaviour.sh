gfortran -O2 --shared -fPIC -DPIC umat.f -o libUmat.so
mfront -I $(pwd) --obuild --interface=generic HypoplasticClayModelWrapper.mfront \
--@Link='{"-L ../ -lUmat"}'



