function [ histograma,histNorm ] = functionHistograma( data, rangos, marcasDeClase )

histograma = zeros(1,length(marcasDeClase));

for i=2:1:length(rangos)
    cotaInf = rangos(i-1);
    cotaSup = rangos(i);
    aux1 = data>=cotaInf;
    aux2 = data<cotaSup;
    cumplen = data(aux1&aux2);
    histograma(i-1)= length(cumplen);
end

%Normalizacion
histNorm = histograma./(max(histograma));

end

