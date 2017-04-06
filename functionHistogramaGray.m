function [ histograma,histNorm,rangos,marcasDeClase ] = functionHistogramaGray( placa )
%FUNCTIONHISTOGRAMAGRAY Summary of this function goes here
%   Detailed explanation goes here
placa = placa(:);
rangos = [0 25 50 75 100 125 150 175 200 225 255]./255;

marcasDeClase = (rangos + circshift(rangos,[0 1]))/2;
marcasDeClase = marcasDeClase(2:end);

%marcasDeClase = [25 75 125 175 225]./255;
[ histograma,histNorm ] = functionHistograma( placa, rangos, marcasDeClase );

end

