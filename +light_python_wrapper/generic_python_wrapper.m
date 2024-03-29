classdef generic_python_wrapper < light_python_wrapper.light_python_wrapper
    % Matlab wrapper around a generic Python object
    % To obtain help on this class and its methods please type help(class) or help(class.method) on the command line.
    % This will bring up the Python documentation
    properties(Access=protected)
        pyobj = [];     % Reference to python object
        classname = ''; % Full Python class name as a string 
                        % (e.g. "module.class", obtained from the Python "type" function)
    end
    methods
        % Constructor
        function obj = generic_python_wrapper(pyobj)
            if strncmp(class(pyobj), 'py.', 3)
                obj.pyobj = pyobj;
                obj.populate_props();
            else
                error('This class only wraps Python objects');
            end
        end
    end
end
