function handle = get_builtin_handle(fn_name)
    % Gets the handle to the builtin help function
    list = which(fn_name, '-all');
    outer_dir = fileparts(fileparts(mfilename('fullpath')));
    curfil = strcmp(list, [outer_dir filesep fn_name '.m']);
    ishelp = cellfun(@(x)contains(x, [fn_name '.m']), list);
    notmt = ~cellfun(@(x)contains(x, '@'), list);
    % Find first non-method function mfile in list which is not current file
    f = xor(curfil, ishelp) & notmt;
    if any(f)
        [funcpath, ~] = fileparts(list{find(f, 1, 'first')});
        here = cd(funcpath);              % temporarily switch to the containing folder
        cleanup = onCleanup(@()cd(here)); % go back to where we came from
        handle = str2func(fn_name);       % grab a handle to the function
        clear('cleanup');
    else
        error('Cannot find built-in help function!');
    end
end
