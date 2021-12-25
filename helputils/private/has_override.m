function [out, pyclass] = has_override(topic)
    % Finds out if the requested help topic is a class and if it is,
    % if it is a python wrapper (has a "classname" property and "get_helpref" method)
    out = []; 
    pyclass = [];
    try
        type_id = exist(topic);
    catch
        return
    end
    if type_id == 8
        clsinfo = meta.class.fromName(topic);
        ref_id = find(arrayfun(@(a) strcmp(a.Name, 'get_helpref'), clsinfo.MethodList), 1);
        cls_id = find(arrayfun(@(a) strcmp(a.Name, 'classname'), clsinfo.PropertyList), 1);
        if ~isempty(ref_id) && ~isempty(cls_id)
            cls = clsinfo.PropertyList(cls_id).DefaultValue;
            if ~isempty(cls)
                pyclass = cls;
                out = topic;
            end
        end
    else
        id_dot = strfind(topic, '.');
        if isempty(id_dot)
            return
        end
        [out, pyclass] = has_override(topic(1:(id_dot(end)-1)));
    end
end
