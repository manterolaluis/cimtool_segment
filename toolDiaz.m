
%Apertura del archivo
clear all; close all; clc;
currentFolder = pwd;
%Archivo donde guardo la ultima direccion
inicFolderFile = strcat(currentFolder,'\lastUsedFolder.txt');
contentConfigFile = fileread(inicFolderFile);
contentConfigFile = strsplit(contentConfigFile,'\n')
inicFolder = contentConfigFile{1};
oldUser = contentConfigFile{2};

%Ingresar nombre de usuario
activeUser = functionChangeUser( oldUser );

segmentarStudies = true;

while segmentarStudies
    clearvars -except currentFolder inicFolderFile contentConfigFile contentConfigFile inicFolder oldUser segmentarStudies activeUser;

    close all; clc;
    nroFrameSelected = -1;
    
    [filename,PathName] = uigetfile({'*.avi;*.jpg;*.tif;*.png;*.bmp;*.gif','All Image Files';...
        '*.*','All Files' },'Abrir US Carotida',inicFolder);
    dirImg= strcat(PathName,filename);
    k = strfind(filename,'.avi');
    isImage = isempty(k)
    
    if isImage
        imgRGB = imread(dirImg);
        originalUS = double(imgRGB(:,:,1))/255;
        dirImg = strcat(dirImg,'_user_',activeUser);
    else
        [ frameSelected, nroFrameSelected ] = functionVideoBrowser( dirImg );
        
        originalUS = frameSelected(:,:,1);
        dirImg = strcat(dirImg,'_frame_',num2str(nroFrameSelected),'_user_',activeUser);
    end
    
    %Guardar en lastUsedFolder asi lo vuelve a abrir
    fid=fopen(inicFolderFile,'w');
    fprintf(fid,'%s\n%s',PathName,activeUser);
    fclose(fid);
    
    %dejar solo la parte util de la imagen
    parteUtilDeLaImagen = [246 125 460 485];
    originalUSCrop = imcrop(originalUS, parteUtilDeLaImagen);
    
    %%
    %PUNTOS DE LUMEN INTIMA ANTERIOR
    rehacer = true;
    close all;
    hFig1 = figure('Name','Segmentar arteria'); imshow(originalUSCrop);
    title('Seleccionar puntos de LI anterior y presionar Enter');
    while rehacer
        tic;
        [xLIAnteriorManual, yLIAnteriorManual] = getpts(hFig1);
        elapsedLIAnteriorPoints = toc;
        dibujar = false;
        zoomPared = medfilt2(originalUSCrop, [7 7],'symmetric');
        tic;
        [xLIAnterior,yLIAnterior,GsmoothAbs] = functionSegmentEdgeCarotid( xLIAnteriorManual, yLIAnteriorManual,...
            zoomPared, dibujar );
        timeAutoSegmentationLIAnterior = toc;
        hold on;
        hPlotActual = plot(xLIAnterior,yLIAnterior,'r');
        hold off;
        scriptQuestionMessage;
        if rehacer
            delete(hPlotActual);
        end
    end
    %functionDrawGradientMap( xLIAnteriorManual,yLIAnteriorManual,xLIAnterior,yLIAnterior,zoomPared,GsmoothAbs );
    
    %%
    %PUNTOS DE LUMEN INTIMA POSTERIOR
    rehacer = true;
    while rehacer
        title('Seleccionar puntos de LI posterior y presionar Enter');
        hold on;
        plot(xLIAnterior,yLIAnterior,'r');
        tic;
        [xLIPosteriorManual, yLIPosteriorManual] = getpts(hFig1);
        elapsedLIPosteriorPoints = toc;
        hold off;
        tic;
        [xLIPosterior,yLIPosterior,GsmoothAbs] = functionSegmentEdgeCarotid( xLIPosteriorManual, yLIPosteriorManual,...
            originalUSCrop, dibujar );
        timeAutoSegmentationLIPosterior = toc;
        hold on;
        hPlotActual = plot(xLIPosterior,yLIPosterior,'r');
        hold off;
        scriptQuestionMessage;
        if rehacer
            delete(hPlotActual);
        end
    end
        
    %Medicion diametro arterial
    scriptArterialDiameter;
    
    enoughMeditions = false;
    minMeditions = 170;
    
    while not(enoughMeditions)
        
        title('Seleccionar region a ampliar para IMT y doble click');
        
        rect = imrect;
        rectZoom = wait(rect);
        
        if rectZoom(3)>minMeditions
            enoughMeditions = true;
        else
            hMsg1 = msgbox('Medicion insuficiente','Advertencia');
            set(hMsg1, 'position', [800 400 200 50]);
            pause(1);
            
        end
        delete(rect);
    end
    
    %%
    zoomPared = imcrop(originalUSCrop,rectZoom);
    %Agrando la imagen proporcionalmente a sus dimensiones, que no la reescale
    [hRegion, wRegion] = size(zoomPared);
    %Seleccionar placa
    rehacer = true;
    close all;
    hFig = fig(5);
%    figure(hFig,'Name','Segmentacion pared arterial');%, 'Position',...
%        %[200, 500, wRegion*5, hRegion*5]);
    imshow(zoomPared,'InitialMagnification','fit');
    while rehacer
        
        title('Seleccionar puntos de LI y presionar Enter');
        tic;
        [xLIManual, yLIManual] = getpts(hFig);
        elapsedLIPoints = toc;
        dibujar = false;
        tic;
        [xLI,yLI,GsmoothAbs] = functionSegmentEdgeCarotid( xLIManual, yLIManual, zoomPared, dibujar );
        timeAutoSegmentationLI = toc;
        hold on; hPlotActual = plot(xLI,yLI,'r'); hold off;
        scriptQuestionMessage;
        if rehacer
            delete(hPlotActual);
        end
    end
    
    rehacer = true;
    while rehacer
        
        title('Seleccionar puntos de MA y presionar enter');
        tic;
        [xMAManual, yMAManual] = getpts(hFig);
        elapsedMAPoints = toc;
        
        tic;
        [xMA,yMA,GsmoothAbs] = functionSegmentEdgeCarotid( xMAManual, yMAManual, zoomPared, dibujar );
        timeAutoSegmentationMA = toc;
        hold on; hPlotActual=plot(xMA,yMA,'r'); hold off;
        scriptQuestionMessage;
        if rehacer
            delete(hPlotActual);
        end
    end
    %close all;
    
    %%
    scriptSegmentIntima;
    
    %%
    interfacePolarLI = functionInterfaceToImg( [xLI',yLI'] , hRegion, wRegion);
    maskLI = functionLabelizarPixelPolar( interfacePolarLI );
    
    interfacePolarMA = functionInterfaceToImg( [xMA',yMA'] , hRegion, wRegion);
    maskMA = functionLabelizarPixelPolar( interfacePolarMA );
    paredMask = xor(maskLI,maskMA);
    
    hFig = figure('Name','Features', 'Position', [50, 50, 1500, 300]);
    subplot(1,4,1),imshow(zoomPared);title('Pared');
    hold on;
    plot(xLI,yLI,'r');
    plot(xMA,yMA,'r');
    hold off;
    
    %Normalizacion como en Sztajzel2005 Loizou2012
    grayLumen = 0/255;
    grayAdventitia = 190/255;
    zoomParedNormalized = functionUSNormalization(zoomPared, maskLI, not(maskMA),...
        grayLumen, grayAdventitia);
    
    placa = zoomParedNormalized(paredMask);
    [hPlaca,wPlaca]=size(maskMA);
    
    %Histograma
    [ histogramaGray,histNormGray,rangosGray,marcasDeClaseGray ] = functionHistogramaGray( placa );
    functionDrawHistogram( histNormGray, marcasDeClaseGray, hFig, 2, 'Grises' );
    
    [ MNGs, MNGxLonja ] = functionCraiem2009PlacaIrregular( zoomParedNormalized, paredMask );
    Craiem2009 = MNGxLonja;
    subplot(1,4,3),plot(MNGxLonja);
    axis([0 length(MNGxLonja)+1 0/255 145/255]); %Ejes de la Fig 3 de Craiem 2009
    title('Curva de profundidad - Craiem 2009');
    
    %Sztajzel 2005
    [ canalR,canalG,canalB, isHomogenea, isHeterogenea ] = functionSztajzel2005( zoomParedNormalized, paredMask );
    subplot(1,4,4),imshow(cat(3,canalR,canalG,canalB));title('Sztajzel 2005');
    
    export_fig(strcat(dirImg,'_features.png'));
    
    %exportar bien
    
    %%
    %Medicion diametro arterial, movido aqui para que funcione más rapido
    [hRegion,wRegion] = size(originalUSCrop);
    
    interfacePolarAnterior = functionInterfaceToImg( [xLIAnterior',yLIAnterior'] , hRegion, wRegion);
    maskAnterior = functionLabelizarPixelPolar( interfacePolarAnterior );
    
    interfacePolarPosterior = functionInterfaceToImg( [xLIPosterior',yLIPosterior'] , hRegion, wRegion);
    maskPosterior = functionLabelizarPixelPolar( interfacePolarPosterior );
    paredMaskArtery = xor(maskAnterior,maskPosterior);
    
    %Tengo que tomar solo en cuenta los segmentos de inicio y fin validos
    validoArteria = round(xDiametroValido(1)):1:round(xDiametroValido(2));
    [diametroPxMedia, diametroPxMedian, diametroPxStd, diametroPxMin, diametroPxMax, medicionesDiametro,...
        diametroMedia, diametroMedian, diametroStd, diametroMin, diametroMax] =...
        functionIMT( xLIAnterior(validoArteria),yLIAnterior(validoArteria),xLIPosterior(validoArteria),...
        yLIPosterior(validoArteria),paredMaskArtery );
    
    clc;
    [imtPxMedia, imtPxMedian, imtPxStd, imtPxMin, imtPxMax, mediciones, imtMedia,...
        imtMedian, imtStd, imtMin, imtMax] =...
        functionIMT( xLI,yLI,xMA,yMA,paredMask );
    
    %%
    %Estadisticas
    
    meanPlaca = mean(placa(:)); stdPlaca = std(placa(:)); GSM = median(placa(:));
    
    strHomogenea = 'No';
    if isHomogenea
        strHomogenea = 'Sí';
    end
    
    strHeterogenea = 'No';
    if isHeterogenea
        strHeterogenea = 'Sí';
    end
    
    strEstadisticas = {strcat('GSM:', num2str(GSM)),...
        strcat('Sztajzel - Homogenea:',strHomogenea),...
        strcat('Sztajzel - Heterogenea:',strHeterogenea),...
        strcat('IMT px Media:',num2str(imtPxMedia)),...
        strcat('IMT px Std:',num2str(imtPxStd)),...
        strcat('IMT px Median:',num2str(imtPxMedian)),...
        strcat('IMT px Min:',num2str(imtPxMin)),...
        strcat('IMT px Max:',num2str(imtPxMax)),...
        strcat('IMT Media:',num2str(imtMedia),'mm'),...
        strcat('IMT Std:',num2str(imtStd)),...
        strcat('IMT Median:',num2str(imtMedian),'mm'),...
        strcat('IMT Min:',num2str(imtMin),'mm'),...
        strcat('IMT Max:',num2str(imtMax),'mm'),...
        strcat('Nro mediciones:',num2str(mediciones)),...
        strcat('Diametro px Media:',num2str(diametroPxMedia)),...
        strcat('Diametro px Std:',num2str(diametroPxStd)),...
        strcat('Diametro px Median:',num2str(diametroPxMedian))...
        strcat('Diametro Media:',num2str(diametroMedia),'mm'),...
        strcat('Diametro Std:',num2str(diametroStd)),...
        strcat('Diametro Median:',num2str(diametroMedian),'mm'),...
        strcat('-----------------------------'),...
        strcat('Time Select Points LI (s):',num2str(elapsedLIPoints)),...
        strcat('Time Select Points MA (s):',num2str(elapsedMAPoints)),...
        };
    
    conSaltoDeLinea = strjoin(strEstadisticas,'\n');
    
    hMsg = msgbox(strEstadisticas,'Estadistica');
    set(hMsg, 'position', [200 400 200 300]);
    pause(1);
    
    fid=fopen(strcat(dirImg,'_estadisticas.txt'),'w');
    fprintf(fid, [conSaltoDeLinea]);
    %fprintf(fid, '%f %f \n', [A B]');
    fclose(fid);
    
    %guardar variables workspace
    save(strcat(dirImg,'_features.mat'),'originalUS','originalUSCrop','parteUtilDeLaImagen',...
        'rectZoom','zoomPared','zoomParedNormalized','paredMask',...
        'xLIAnteriorManual', 'yLIAnteriorManual','xLIPosteriorManual', 'yLIPosteriorManual',...
        'xLIAnterior','yLIAnterior','xLIPosterior','yLIPosterior',...
        'xLIManual','yLIManual','xMAManual','yMAManual','xLI','yLI','xMA','yMA',...
        'imtPxMedia','imtPxMedian','imtPxStd','imtPxMin','imtPxMax','mediciones','GSM',...
        'xIntima','yIntima','xIntimaManual','yIntimaManual','isIntimaVisible',...
        'MNGs', 'MNGxLonja','canalR','canalG','canalB', 'isHomogenea', 'isHeterogenea','Craiem2009',...
        'elapsedLIPoints','elapsedMAPoints','elapsedLIAnteriorPoints','elapsedLIPosteriorPoints',...
        'elapsedIntimaPoints',...
        'timeAutoSegmentationLI','timeAutoSegmentationMA','timeAutoSegmentationIntima',...
        'activeUser','nroFrameSelected','xIntimaValida','filename','isImage','xDiametroValido',...
        'diametroPxMedia', 'diametroPxMedian', 'diametroPxStd', 'diametroPxMin', 'diametroPxMax',...
        'medicionesDiametro','xDiametroValido','diametroMedia','diametroMedian','diametroStd');
    
    %Iterar en mas estudios
    choice = MFquestdlg([0.3 0.3],'¿Segmentar otro estudio?', ...
        'Segmentar otro estudio', ...
        'Sí, continuar','No, finalizar','No, finalizar');
    % Handle response
    switch choice
        case 'Sí, continuar'
           segmentarStudies = true;
        case 'No, finalizar'
            segmentarStudies = false;
    end
    delete(hMsg);
end

clear all; close all; clc;