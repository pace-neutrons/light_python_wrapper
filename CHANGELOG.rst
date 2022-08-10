`Unreleased <https://github.com/pace-neutrons/light_python_wrapper/compare/v0.3.0...HEAD>`_
----------

`v0.3.0 <https://github.com/pace-neutrons/light_python_wrapper/compare/v0.2.2...v0.3.0>`_
------

- Bug fixes

  - Check for correct Matlab version (``>=2019a``) when converting Numpy arrays with
    ``double``. Converting with ``double`` works for Numpy arrays with ``>=2019a``,
    but only works for native `py.array.array` arrays in ``2018a/b``.

- Improvements

  - Only warn once if converting a Numpy array in an old Matlab version (less than ``2019a``)
  - Only determine Matlab version once for increased performance

`v0.2.2 <https://github.com/pace-neutrons/light_python_wrapper/compare/v0.1.1...v0.2.2>`_
------

This release changes the API - now in addition to the pyobj property, subclasses must declare a ``classname`` which is a string being the Python class name of the wrapped class, obtained from ``type(obj)`` in Python.

This change enables the new overloaded ``help`` and ``doc`` functions to obtain a reference to the Python objects to get docstrings using the ``pydoc`` system. In addition it means that users no longer have to define the helpobj property as this can now be obtained from the classname.

`v0.1.1 <https://github.com/pace-neutrons/light_python_wrapper/compare/v0.1...v0.1.1>`_
------

Adds a static method to direct Python warnings to sys.stdout which is mirrored by Matlab, unlike sys.stderr.


`v0.1 <https://github.com/pace-neutrons/light_python_wrapper/compare/43a2ab4...v0.1>`_
----

First alpha release.

- Allows Matlab to wrap arbitrary Python classes.
- Allows saving Python classes to mat files (data is pickled so any classes which cannot be pickled will not be saved correctly).
- Overloads help command to print pydoc help text in Matlab.
