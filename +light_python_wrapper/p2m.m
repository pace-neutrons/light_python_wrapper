% brillem -- a MATLAB interface for brille
% Copyright 2020 Greg Tucker
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

function m = p2m(p)
    persistent is_old_version;
    ptype = lower(class(p));
    if strcmp(ptype,'py.numpy.ndarray')
        if isempty(is_old_version)
            is_old_version = verLessThan('matlab', '9.6'); % before 2018a(?) For sure by 2018b=9.5
            if is_old_version
                warning('light_python_wrapper:p2m','Fast conversion of numpy.ndarrays not supported by this version of MATLAB. Consider upgrading.');
            end
        end
        if is_old_version
            ndim = int64(p.ndim);
            nmel = int64(p.size);
            if ndim>1
                toshape = zeros(1, ndim);
                for i=1:ndim
                    toshape(i) = int64(p.shape{i});
                end
                p = p.reshape(nmel);
            else
                toshape = [1,nmel];
            end
            m = zeros(toshape);
            if contains(string(p.dtype.name),'complex')
                m = complex(m,0);
            end
            plist = p.tolist();
            for i=1:numel(m)
                m(i) = plist{i};
            end
        else
            eltype = lower(string(p.dtype.name));
            if contains(eltype,'float')
                m = ndarray_to_double(p);
            elseif contains(eltype,'complex')
                rp = py.numpy.array(p.real);
                ip = py.numpy.array(p.imag);
                eltype = lower(string(rp.dtype.name));
                if contains(eltype,'uint')
                    rp = ndarray_to_uint(rp);
                    ip = ndarray_to_uint(ip);
                elseif contains(eltype,'int')
                    rp = ndarray_to_int(rp);
                    ip = ndarray_to_int(ip);
                else
                    rp = ndarray_to_double(rp);
                    ip = ndarray_to_double(ip);
                end
                m = complex( rp, ip );
            elseif contains(eltype,'uint')
                m = ndarray_to_uint( p );
            elseif contains(eltype,'int')
                m = ndarray_to_int(p);
            elseif contains(eltype,'str')
                ndim = ndarray_to_int(p.ndim);
                nmel = ndarray_to_int(p.size);
                if ndim>1
                    toshape = zeros(1,ndim);
                    for i=1:ndim
                        toshape(i) = ndarray_to_int(p.shape{i});
                    end
                    p = p.reshape(nmel);
                else
                    toshape = [1,nmel];
                end
                m = cell(toshape);
                plist = p.tolist();
                for i=1:numel(m)
                    m{i} = char(plist{i});
                end
            else
                m = ndarray_to_double(p);
            end
        end
    elseif strcmp(ptype,'py.complex') % a scalar
        m = py.numpy.array(p).tolist(); % MATLAB converts the one element list to a complex number automatically
    elseif contains(ptype,'uint')
        m = uint64(p);
    elseif contains(ptype,'int')
        m = int64(p);
    elseif strcmp(ptype,'light_python_wrapper.light_python_wrapper')
        m = light_python_wrapper.p2m(p.pyobj);
    elseif strcmp(ptype,'py.tuple') || strcmp(ptype,'py.list')
        m = cell(p);
        for ii = 1:numel(m)
            m{ii} = light_python_wrapper.p2m(m{ii});
        end
    elseif strcmp(ptype,'py.set')
        m = light_python_wrapper.p2m(py.list(p));
    elseif isnumeric(p)
        m = p;
    elseif strcmp(ptype,'py.str')
        m = char(p);
    else
        m = light_python_wrapper.generic_python_wrapper(p);
    end
end

function out = ndarray_to_double(in)
    try
        out = double(in);
    catch
        out = double(py.array.array('d', in));
    end
end

function out = ndarray_to_int(in)
    try
        out = int64(in);
    catch
        out = int64(py.array.array('i', in));
    end
end

function out = ndarray_to_uint(in)
    try
        out = uint64(in);
    catch
        out = uint64(py.array.array('I', in));
    end
end
