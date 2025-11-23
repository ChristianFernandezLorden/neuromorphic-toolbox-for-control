Interface
=========

Installing the toolbox will not make any addition to the |matlab| window. 
The changes will be a new library in the |simulink| Library Browser and new functions in |matlab| under the :mod:`NeuroCont` namespace.

|simulink| Interface
--------------------

In |simulink| the new library packaged in the toolbox will appear in the Library Browser as follows :

.. only:: html

    .. card:: Library Browser view

        .. image:: images/toolbox_in_simulink.png
            :width: 100%

.. only:: latex

    +------------------------------------------------+
    | Library Browser view                           |
    +================================================+
    | .. image:: images/toolbox_in_simulink.png      | 
    |     :width: 50%                                | 
    +------------------------------------------------+

Adding a block can be done via the usual way of dragging from the Library Browser or double clicking. 
Most of the block are located in sublibraries that can be accessed by double clicking or by using the Library Browser sidebar.


Similar to classical libraries, the blocks can be accessed and placed programatically using standard |matlab| commands (see |matlabsimulinkaddblockdoc|_ for details).
A general example of adding a library block to a model is the following |matlab| command : 

.. |matlabsimulinkaddblockdoc| replace:: :func:`add_block` documentation
.. _matlabsimulinkaddblockdoc: https://nl.mathworks.com/help/simulink/slref/add_block.html

.. code:: matlab

    add_block("neuromorphic_blocks/{path_to_block_in_library}","{target_model}/{path_in_target_model}")

|matlab| Interface
------------------

The |matlab| additions of the toolbox are a set of functions under the :mod:`NeuroCont` namespace. 
They can be accessed directly using the full path of the function like so :

.. code:: matlab

    NeuroCont.{subnamespace}.{func}({func_args}) 

To avoid writing such long function calls, the |matlabimportcommand|_ allows to specify the full namespace once then either only call the function by name or by only using a subnamespace depending on the :attr:`import` statement.

.. |matlabimportcommand| replace:: :attr:`import` statement 
.. _matlabimportcommand: https://nl.mathworks.com/help/matlab/ref/import.html

.. code:: matlab

    import NeuroCont.{subnamespace}.{func} % Import only the specified function
    import NeuroCont.{subnamespace}.*      % Import all functions in the subnamespace
    import NeuroCont.*                     % Import all subnamespaces