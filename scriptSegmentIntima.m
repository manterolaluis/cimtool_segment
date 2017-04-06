
choice = MFquestdlg([0.3 0.3],'¿Segmentar intima?', ...
    'Segmentar intima', ...
    'Sí, continuar','No es posible segmentar','No es posible segmentar');
% Handle response
switch choice
    case 'Sí, continuar'
        rehacer = true;
        isIntimaVisible = true;
    case 'No es posible segmentar'
        rehacer = false;
        isIntimaVisible = false;
end

xIntima = []; yIntima = []; xIntimaManual = []; yIntimaManual=[];
elapsedIntimaPoints = -1; timeAutoSegmentationIntima=-1; xIntimaValida =[-1 -1];

if rehacer
    
    while rehacer
        
        title('Seleccionar inicio y fin del segmento valido');
        [xInicIntima, yInicIntima]= ginput(1);
        a = yLI(round(xInicIntima));
        b = yMA(round(xInicIntima));
        hold on;
        p1 = plot([xInicIntima,xInicIntima],[a,b],'y');
        hold off;
        
        [xFinIntima, yFinIntima]= ginput(1);
        a = yLI(round(xFinIntima));
        b = yMA(round(xFinIntima));
        hold on;
        p2 = plot([xFinIntima,xFinIntima],[a,b],'y');
        hold off;
        xIntimaValida = sort([xInicIntima,xFinIntima]);
        
        choice = MFquestdlg([0.3 0.3],'¿Satisfactorio?', ...
            'Segmento visible de intima', ...
            'Sí, continuar','No, rehacer','No, rehacer');
        % Handle response
        switch choice
            case 'Sí, continuar'
                rehacer = false;
            case 'No, rehacer'
                rehacer = true;
                delete(p1);delete(p2);
        end
        
    end
    
    rehacer = true;
    
    while rehacer
        
        title('Seleccionar puntos en el borde de la Intima y presionar enter');
        tic;
        [xIntimaManual, yIntimaManual] = getpts(hFig);
        elapsedIntimaPoints = toc;
        
        tic
        [xIntima,yIntima,GsmoothAbs] = functionSegmentLMCarotid( xIntimaManual, yIntimaManual, zoomPared, false );
        timeAutoSegmentationIntima = toc;
        hold on; hPlotActual=plot(xIntima(xInicIntima:xFinIntima),...
            yIntima(xInicIntima:xFinIntima),'g'); hold off;
        scriptQuestionMessageIntima;
        if rehacer
            delete(hPlotActual);
        end
    end
    
end
