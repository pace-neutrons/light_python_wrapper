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
    if py.hasattr(p, 'dtype')
        vers = version();
        is_old_version = sscanf(vers(1:3), '%f') < 9.4; % before 2018a(?) For sure by 2018b=9.5
        if is_old_version
            warning('light_python_wrapper:p2m','Fast conversion of numpy.ndarrays not supported by this version of MATLAB. Consider upgrading.');
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
                m = double(p);
            elseif contains(eltype,'complex')
                rp = py.numpy.array(p.real);
                ip = py.numpy.array(p.imag);
                eltype = lower(string(rp.dtype.name));
                if contains(eltype,'uint')
                    rp = uint64(rp);
                    ip = uint64(ip);
                elseif contains(eltype,'int')
                    rp = int64(rp);
                    ip = int64(ip);
                else
                    rp = double(rp);
                    ip = double(ip);
                end
                m = complex( rp, ip );
            elseif contains(eltype,'uint')
                m = uint64( p );
            elseif contains(eltype,'int')
                m = int64(p);
            elseif contains(eltype,'str')
                ndim = int64(p.ndim);
                nmel = int64(p.size);
                if ndim>1
                    toshape = zeros(1,ndim);
                    for i=1:ndim
                        toshape(i) = int64(p.shape{i});
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
                m = double(p);
            end
        end
    elseif isa(p,'py.complex') % a scalar
        m = py.numpy.array(p).tolist(); % MATLAB converts the one element list to a complex number automatically
    elseif contains(class(p),'uint','IgnoreCase',true)
        m = uint64(p);
    elseif contains(class(p),'int','IgnoreCase',true)
        m = int64(p);
    elseif isa(p, 'light_python_wrapper.light_python_wrapper')
        m = light_python_wrapper.p2m(p.pyobj);
    elseif isa(p, 'py.tuple') || isa(p, 'py.list')
        m = cell(p);
        for ii = 1:numel(m)
            m{ii} = light_python_wrapper.p2m(m{ii});
        end
    elseif isa(p, 'py.set')
        m = light_python_wrapper.p2m(py.list(p));
    elseif isnumeric(p)
        m = p;
    elseif isa(p, 'py.str')
        m = char(p);
    else
        m = light_python_wrapper.generic_python_wrapper(p);
    end
end
