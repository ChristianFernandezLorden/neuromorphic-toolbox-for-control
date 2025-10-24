Creating and Simulating a Model
===============================

Building a model always starts with starting 


.. mat:function:: CharBlock(cool, varargin)
    :module: NeuromorphicControlToolbox.mismatch

    A single-line text input. The following keyword arguments are accepted in addition to the standard ones:

    :param required: If true (the default), the field cannot be left blank.
    :param max_length: The maximum allowed length of the field.
    :param min_length: The minimum allowed length of the field.
    :param help_text: Help text to display alongside the field.
    :param validators: A list of validation functions for the field (see `Django Validators <https://docs.djangoproject.com/en/stable/ref/validators/>`__).
    :param form_classname: A value to add to the form field's ``class`` attribute when rendered on the page editing form.


.. automodule:: NeuromorphicControlToolbox.mismatch
    :show-inheritance:
    :members: