function [helptxt, class_summary] = python_help(ml_class, py_class, topic)
    % Uses the Python documentation system to get the help text
    get_ref = str2func(join([ml_class '.get_helpref'], ''));
    parent_class = py_class;
    classname = regexprep(py_class, '.*\.', '');
    if ~strcmp(ml_class, topic)
        % The Python and Matlab class names can be different but
        % the method / properties after that should be the same.
        part_topic = extractAfter(topic, ml_class);
        py_class = join([py_class part_topic], '');
    end
    py_ref = get_ref(py_class);
    helptxt = light_python_wrapper.get_help(py_ref);
    % Add hyperlinks to class properties
    parent_ref = get_ref(parent_class);
    props = cellfun(@(m) char(m), cell(py.dir(parent_ref)), 'UniformOutput', false);
    [~, isrt] = sort(cellfun(@(m) numel(m), props), 'descend');
	props = props(isrt);
    idx = find(cellfun(@(m) ~startsWith(m, '_'), cell(props)));
    blurb = cell(1, numel(idx));
    ismethod = zeros(1, numel(idx));
    for ii = 1:numel(idx)
        child_ref = py.getattr(parent_ref, props{idx(ii)});
        child_docstr = py.getattr(child_ref, '__doc__');
        if ~isa(child_docstr, 'py.NoneType')
            helptxt = regexprep(helptxt, sprintf('(%s)(\\s*[\\(:])', props{idx(ii)}), ...
                                sprintf('<a href="matlab:help %s.$1">$1</a>$2', ml_class));
            helptxt = strrep(helptxt, sprintf(' %s.%s ', classname, props{idx(ii)}), ...
                             sprintf(' <a href="matlab:help %s.%s">%s.%s</a> ', ml_class, props{idx(ii)}, classname, props{idx(ii)}));
            blurb{ii} = strtrim(strtok(char(child_docstr), newline));
            ismethod(ii) = py.hasattr(child_ref, '__call__');
        end
    end
    class_summary = cell(1,2);
    if strcmp(parent_class, py_class)
        [~, isrt] = sort(cellfun(@(m) m(1), props(idx)));
        for ii = 1:numel(isrt)
            if ~isempty(blurb{isrt(ii)}), docstr = blurb{isrt(ii)}; else, docstr = ''; end
            if ismethod(isrt(ii)), icl = 2; else, icl = 1; end
            class_summary{icl} = cat(1, class_summary{icl}, [props(idx(isrt(ii))) {docstr}]);
        end
    end
end
