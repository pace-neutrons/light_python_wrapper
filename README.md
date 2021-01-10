# Light Python Wrapper

A Matlab package for wrapping Python classes to make them act just like Matlab classes.

To use it, subclass the `light_python_wrapper.light_python_wrapper` abstract base class, and define your own constructor.

An example is given by the `light_python_wrapper.generic_python_wrapper` class.

The derived Matlab class can access all properties and call all methods of the wrapped Python class with the standard dot notation.
Hidden Python properties (which starts with `_`) can be accessed using brace notation, e.g. `obj{'__str__'}()`

In addition, the `help` method is overloaded so that `help(obj)` will return the Python (`pydoc`) help information for that object, method or property.
Note that `help obj` or `help class` will not work since this uses the in-built Matlab help system which does not know about the Python class.

The `saveobj` and `loadobj` methods are also overloaded to serialise dependent Python objects using `pickle`,
so they can be saved as to a Matlab `mat` file.
Note that objects which cannot be pickled (which do not have a `__dict__` or `__[get/set]state__` methods) cannot be saved correctly.
In these cases a warning will be given and a `mat` file will still be generated but it will not correctly reload.

