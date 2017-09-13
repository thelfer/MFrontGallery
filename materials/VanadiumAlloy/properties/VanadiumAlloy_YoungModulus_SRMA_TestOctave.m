f = fopen ("VanadiumAlloy_YoungModulus_SRMA-octave.res", "w");
for(T = [300:10:400])
  dlmwrite(f, [T,VanadiumAlloy_YoungModulus_SRMA(T)]," ")
endfor
fclose(f);
