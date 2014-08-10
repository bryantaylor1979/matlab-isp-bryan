function DisplayMsg(Str,h)
if ~isempty(h)
    set(h,'String',Str);
    drawnow;
end