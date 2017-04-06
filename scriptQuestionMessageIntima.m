
choice = MFquestdlg([0.3 0.3],'¿La segmentación es satisfactoria?', ...
    'Validacion segmentacion', ...
    'Sí, continuar','No, rehacer','No es posible segmentar','No, rehacer');
% Handle response
switch choice
    case 'Sí, continuar'
        rehacer = false;
        isIntimaVisible = true;
    case 'No, rehacer'
        rehacer = true;
        isIntimaVisible = true;
    case 'No es posible segmentar'
        rehacer = false;
        isIntimaVisible = false;
end
