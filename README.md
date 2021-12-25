# Light Python Wrapper

A Matlab package for wrapping Python classes to make them act just like Matlab classes.

To use it, subclass the `light_python_wrapper.light_python_wrapper` abstract base class, and define your own constructor.
In particular, the subclass must define the `pyobj` and `classname` properties.
`pyobj` is a reference to the constructed Python object and `classname` is a string being the full class name as returned by `type(obj)` in Python.
For example, to wrap a class `Bar` in module `foo.py` which is on the Python path,
the Matlab constructor could specify `obj.pyobj = py.foo.Bar()` and `classname = 'foo.Bar'`.
The constructor should then call the `obj.populate_props()` method to create dummy Matlab properties so that tab-completion will work.

An example is given by the `light_python_wrapper.generic_python_wrapper` class.

The derived Matlab class can access all properties and call all methods of the wrapped Python class with the standard dot notation.
Hidden Python properties (which starts with `_`) can be accessed using brace notation, e.g. `obj{'__str__'}()`

The wrapper also performs some simple type conversions between Matlab and Python,
but this is one area where many isses arise as Matlab and Python data types do not exactly match.
Thus, you should carefully check the data transfered to Python and returned to Matlab are what you expect.

In particular the wrapper assumes `numpy` is installed and will convert Matlab numeric arrays to `numpy` arrays,
in order to take advantage of features which ensure that fewer data copies are made (at least for an "in-process" Python environment).
However, the conversion from Matlab to `numpy` array is done internally by matlab and can sometimes result in 
numpy arrays which are automatically "squeezed" (missing singleton dimensions) or transposed.
If you find issues with the type conversion, please create an issue here.

Finally, the wrapper provides a `help` method so that `help(obj)` will return the Python (`pydoc`) help information for that object, method or property.
There are also overloaded `help` and `doc` functions in the `helputils` folder which will work with the `help class` / `doc class` syntax
(e.g. without the brackets and without needing to construct an object), 
but these are not part of the `light_python_wrapper` class and so the `helputils` folder needs to be added to the path separately.

The `saveobj` and `loadobj` methods of the wrapper are also overloaded to serialise dependent Python objects using `pickle`,
so they can be saved as to a Matlab `mat` file.
Note that objects which cannot be pickled (which do not have a `__dict__` or `__[get/set]state__` methods) cannot be saved correctly.
In these cases a warning will be given and a `mat` file will still be generated but it will not correctly reload.

