function [out, docTopic] = help(varargin)
    % Customized overloaded help function
    % 1. If the class has a help method use that instead of the builtin
    % 2. Otherwise use the builtin help
    % This function assumes that the input is a string like the built-in function

    % Create a handle to the original Matlab help function
    persistent builtin_help;
    if isempty(builtin_help)
        builtin_help = get_builtin_handle('help');
    end

    if nargin == 0 && isscalar(dbstack)
        % Replicate Matlab behaviour where we get the help of the
        % previous command entered if user just types `help` on the CLI
        helpProcess = get_previous_help(nargout);
    elseif strcmpi(varargin{1}, 'help')
        % Show docstring for builtin help
        helpProcess = show_builtin_help(nargout);
    elseif nargin == 1
        [override_class, py_class] = has_override(varargin{1});
        if ~isempty(override_class)
            docTopic = varargin{1};
            [helptxt, class_summary] = python_help(override_class, py_class, docTopic);
            if ~all(cellfun(@isempty, class_summary))
                helptxt = [helptxt print_class_summary(class_summary, docTopic)];
            end
            if nargout == 0
                disp(docTopic);
                disp(helptxt);
            else
                out = helptxt;
            end
            return
        end
    end
    if ~exist('helpProcess', 'var') || isempty(helpProcess)
        % Calls the builtin help function
        if nargout == 0
            builtin_help(varargin{:});
        else
            [out, docTopic] = builtin_help(varargin{:});
        end
    else
        helpProcess.prepareHelpForDisplay;
        if nargout > 0
            out = helpProcess.helpStr;
            if nargout > 1
                docTopic = helpProcess.docLinks.referencePage;
                if isempty(docTopic)
                    docTopic = helpProcess.docLinks.productName;
                end
            end
        end
    end
end

function process = get_previous_help(n_out)
    process = helpUtils.helpProcess(n_out, 0, {});
    process.isAtCommandLine = true;
    process.getHelpText;
end

function process = show_builtin_help(n_out)
    list = which('help', '-all');
    f = strncmp(list, matlabroot, numel(matlabroot));
    if any(f)
        topic = list{find(f, 1, 'first')};
    else
        topic = 'help';
    end
    process = helpUtils.helpProcess(n_out, 1, {topic});
    process.getHelpText;
end

function out = print_class_summary(class_summary, topic)
    out = '';
    tstr = {'Property', 'Method'};
    undr = {'--------', '------'};
    for icl = 1:2
        if isempty(class_summary{icl}), continue; end
        lmax = max(cellfun(@numel, class_summary{icl}(:,1))) + 3;
        lstr = sprintf('%%%is', lmax);
        out = [out sprintf('\n   %s Summary\n   %s--------\n', tstr{icl}, undr{icl})];
        for ii = 1:size(class_summary{icl},1)
            name_str = class_summary{icl}{ii,1};
            sum_str = class_summary{icl}{ii,2};
            no_link = class_summary{icl}{ii,3};
            if ~isempty(sum_str) && ~no_link
                pstr = sprintf('%%%is', lmax - numel(name_str));
                name_str = sprintf([pstr '<a href="matlab:help %s.%s">%s</a>'], '', topic, name_str, name_str);
            end
            out = [out sprintf(['   ' lstr ' - %s\n'], name_str, sum_str)];
        end
    end
end
