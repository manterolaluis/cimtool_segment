function [ output_args ] = functionDrawHistogram( histograma, Xs, handleFigure, posSubplot, nombre )
%FUNCTIONDRAWHISTOGRAM Summary of this function goes here
%   Detailed explanation goes here

labelsX = cellstr(num2str(Xs(:),1));
figure(handleFigure);
subplot(1,4,posSubplot),bar(histograma); title(strcat('Hist ',nombre));
axis([0 length(Xs)+1 0 max(histograma)]);
set(gca,'XTick',1:length(Xs),'XTickLabel',labelsX);

end

