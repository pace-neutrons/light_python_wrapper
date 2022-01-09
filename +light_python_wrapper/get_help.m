function out = get_help(ref)
    assert(strncmp(class(ref), 'py.', 3), 'Reference is not a Python object');
    out = char(py.getattr(ref, '__doc__'));
    if isa(out, 'py.NoneType')
        out = py.pydoc.render_doc(ref);
    end
    if py.inspect.isclass(ref)
        % Adds constructor help text if it's a class
        constructor = py.getattr(ref, '__init__');
        init_hp = char(py.getattr(constructor, '__doc__'));
        if ~isa(out, 'py.NoneType')
            sig = get_signature_str(constructor);
            out = sprintf('%s\n\n    Constructor\n    -----------\n\n%s\n%s', out, sig, init_hp);
        end
    elseif py.inspect.isroutine(ref)
        out = sprintf('%s\n%s', get_signature_str(ref), out);
    end
end

function sig = get_signature_str(ref)
    sig = sprintf('    %s%s', char(py.getattr(ref, '__name__')), py.inspect.signature(ref));
    sig = strrep(sig, ',', sprintf(',\n'));
    if contains(sig, '[')
        [re0, re1] = regexp(sig, '(\[.*?\])');
        idx = cell2mat(arrayfun(@(a,b) a:b, re0, re1, 'UniformOutput', false));
        sig(idx(sig(idx) == newline)) = [];
    end
    sig = strrep(sig, newline, sprintf('\n            '));
end