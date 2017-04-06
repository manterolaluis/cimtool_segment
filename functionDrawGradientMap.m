function [ output_args ] = functionDrawGradientMap( xLIManual,yLIManual,xLI,yLI,zoomPared,GsmoothAbs )
%FUNCTIONDRAWGRADIENTMAP Summary of this function goes here
%   Detailed explanation goes here

[h,w]=size(zoomPared);
yLIManual_ = abs(yLIManual-h);
yLI_ = abs(yLI-h);

paso0 = figure('Name','Manual points segmentation','Position',[100 100 600 400]);
imshow(zoomPared,'InitialMagnification','fit');
set(gcf, 'Color', 'w');
hold on; scatter(xLIManual,yLIManual,'g','filled');hold off;

%export_fig(strcat(dirImg,'_manualPoints.png'));

paso1 = figure('Name','Manual segmentation','Position',[100 100 600 400]);
imshow(zoomPared,'InitialMagnification','fit');
set(gcf, 'Color', 'w');
hold on; plot(xLIManual,yLIManual,'g','LineWidth',3); hold off;

paso2 = figure('Name','Manual segmentation en gradiente','Position',[100 100 600 400]);
[redColorMap,greenColorMap,blueColorMap] = functionLevantarDivergingMapFromCSV();
colorMap = [redColorMap, greenColorMap, blueColorMap]./256;
colormap(colorMap);
[C,h] = contourf(flipud(GsmoothAbs),120);
set(gcf, 'Color', 'w');
set(h,'LineColor','none');
set(gca, 'DataAspectRatio', [1 1 1]);
hold on; plot(xLIManual,yLIManual_+1,'g','LineWidth',3); hold off;
set(gca, 'YTick', []); set(gca, 'XTick', []);

paso3 = figure('Name','Segmentacion final en gradiente','Position',[100 100 600 400]);
colormap(colorMap);
[C,h] = contourf(flipud(GsmoothAbs),120);
set(h,'LineColor','none');
set(gcf, 'Color', 'w');
set(gca, 'DataAspectRatio', [1 1 1]);
hold on; plot(xLI,yLI_+1,'g','LineWidth',3); hold off;
set(gca, 'YTick', []); set(gca, 'XTick', []);

end

