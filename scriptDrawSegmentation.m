[h,w]=size(zoomPared);
yLIManual_ = abs(yLIManual-h);
yLI_ = abs(yLI-h);
yMAManual_ = abs(yMAManual-h);
yMA_ = abs(yMA-h);

paso0 = figure('Name','Manual points segmentation','Position',[100 100 1500 900]);
imshow(zoomPared,'InitialMagnification','fit');
set(gcf, 'Color', 'w');
hold on; scatter(xLIManual,yLIManual,'g','filled');
scatter(xMAManual,yMAManual,'g','filled'); hold off;

export_fig(strcat(dirImg,'_manualPoints.png'));


paso1 = figure('Name','Manual segmentation','Position',[100 100 1500 900]);
imshow(zoomPared,'InitialMagnification','fit');
set(gcf, 'Color', 'w');
hold on; plot(xLIManual,yLIManual,'g','LineWidth',3); plot(xMAManual,yMAManual,'g','LineWidth',3); hold off;

export_fig(strcat(dirImg,'_manualSeg.png'));

paso2 = figure('Name','Manual segmentation en gradiente','Position',[100 100 1500 900]);
[redColorMap,greenColorMap,blueColorMap] = functionLevantarDivergingMapFromCSV();
colorMap = [redColorMap, greenColorMap, blueColorMap]./256;
colormap(colorMap);
[C,h] = contourf(flipud(GsmoothAbs),120);
set(gcf, 'Color', 'w');
set(h,'LineColor','none');
set(gca, 'DataAspectRatio', [1 1 1]);
hold on; plot(xLIManual,yLIManual_+1,'g','LineWidth',3); plot(xMAManual,yMAManual_+1,'g','LineWidth',3); hold off;
set(gca, 'YTick', []); set(gca, 'XTick', []);

export_fig(strcat(dirImg,'_manualSegGrad.png'));

paso3 = figure('Name','Segmentacion final en gradiente','Position',[100 100 1500 900]);
colormap(colorMap);
[C,h] = contourf(flipud(GsmoothAbs),120);
set(h,'LineColor','none');
set(gcf, 'Color', 'w');
set(gca, 'DataAspectRatio', [1 1 1]);
hold on; plot(xLI,yLI_+1,'g','LineWidth',3); plot(xMA,yMA_+1,'g','LineWidth',3); hold off;
set(gca, 'YTick', []); set(gca, 'XTick', []);

export_fig(strcat(dirImg,'_autoSegGrad.png'));

paso4 = figure('Name','Final segmentation','Position',[100 100 1500 900]);
imshow(zoomPared,'InitialMagnification','fit');
set(gcf, 'Color', 'w');
hold on; plot(xLI,yLI,'g','LineWidth',3); plot(xMA,yMA,'g','LineWidth',3); hold off;

export_fig(strcat(dirImg,'_autoSeg.png'));