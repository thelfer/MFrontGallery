f = fopen ("VanadiumAlloy_ShearModulus_SRMA-octave.res", "w");
for(T = [300:10:400])
  dlmwrite(f, [T,VanadiumAlloy_ShearModulus_SRMA(T)]," ")
endfor
fclose(f);
