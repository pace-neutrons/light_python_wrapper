function doc(varargin)
    % Customized overloaded doc function
    % 1. If the class has been wrapped by Python, use pydoc
    % 2. Otherwise use the builtin (Matlab) doc
    % This function assumes that the input is a string like the built-in function

    % Create a handle to the original Matlab help function
    persistent builtin_doc;
    if isempty(builtin_doc)
        builtin_doc = get_builtin_handle('doc');
    end

    if nargin == 1
        if strcmpi(varargin{1}, 'doc')
            % Open up the page for doc
            displayDocPage(struct('topic', '(matlab)/doc', 'isElement', 0));
        else
            [override_class, py_class] = has_override(varargin{1});
            if ~isempty(override_class)
                [helptxt, class_summary] = python_help(override_class, py_class, varargin{1});
                doc_python(helptxt, class_summary, varargin{1});
            end
        end
    end
    if ~exist('helptxt', 'var')
        % Calls the builtin doc function
        builtin_doc(varargin{:});
    end
end

function doc_python(helpStr, class_summary, topic)
    helpStr = regexprep(helpStr, ...
        '<a href="matlab:help ', '<a href="matlab:doc ');
    % Creates a blank html using Matlab internals
    dom = com.mathworks.xml.XMLUtils.createDocument('help-info');
    docRoot = com.mathworks.mlwidgets.help.DocCenterDocConfig.getInstance.getDocRoot;
    includesFile = char(docRoot.buildGlobalPageUrl('includes/product/css/helpwin.css').toString);
    child = dom.createElement('css-file');
    child.appendChild(dom.createTextNode(includesFile));
    dom.getDocumentElement.appendChild(child);    
    xslfile = fullfile(fileparts(which('help2html')),'private','helpwin.xsl');
    html = xslt(dom, xslfile, '-tostring');
    % Add the help string, and if it is a class the class summary
    html = regexprep(html, '(<title>)(</title>)', sprintf('$1%s - MATLAB File Help$2', topic));
    header = {'   <table border="0" cellspacing="0" width="100%%">';
              '      <tr class="subheader">';
              '         <td class="headertitle">%s - MATLAB File Help</td>';
              '      </tr>';
              '   <table>';
              '   <div class="title">%s</div>';
              '   <div class="helptxt">'};
    header = sprintf(cell2mat(join(header, newline)), topic, topic);
    html = regexprep(html, '<body></body>', ...
        sprintf('<body>\n%s<pre>%s</pre>\n</body>', header, regexptranslate('escape', helpStr)));
    if ~all(cellfun(@isempty, class_summary))
        h1 = '   <tr class="summary-item">';
        d1 = '      <td class="name">%s</td>';
        d2 = '      <td class="m-help">%s&nbsp;</td>';
        h2 = '   </tr>';
        tstr = {'Property', 'Method'};
        for icl = 1:2
            if isempty(class_summary{icl}), continue; end
            pstr = sprintf('<div class="sectiontitle"><a name="methods"></a>%s Summary</div>', tstr{icl});
            pstr = {pstr newline '<table class="summary-list">'};
            for ii = 1:size(class_summary{icl},1)
                name_str = class_summary{icl}{ii,1};
                sum_str = class_summary{icl}{ii,2};
                no_link = class_summary{icl}{ii,3};
                if ~isempty(sum_str) && ~no_link
                    name_str = sprintf('<a href="matlab:doc %s.%s">%s</a>', topic, name_str, name_str);
                end
                pstr = join([pstr {h1 sprintf(d1, name_str) sprintf(d2, sum_str) h2}], newline);
            end
            pstr = join([pstr '</table>'], newline);
            html = regexprep(html, '(</body>)', sprintf('%s\n$1', pstr{1}));
        end
    end
    web(['text://' html], '-helpbrowser');
end
