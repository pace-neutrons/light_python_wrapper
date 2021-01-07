# Light Python Wrapper

A Matlab package for wrapping Python classes to make them act just like Matlab classes.

To use it, subclass the `light_python_wrapper.light_python_wrapper` abstract base class, and define your own constructor.

An example is given by the `light_python_wrapper.generic_python_wrapper` class.

The derived Matlab class can access all properties and call all methods of the wrapped Python class with the standard dot notation.

In addition, the `help` method is overloaded so that `help(obj)` will return the Python (`pydoc`) help information for that object, method or property.
Note that `help obj` or `help class` will not work since this uses the in-built Matlab help system which does not know about the Python class.
