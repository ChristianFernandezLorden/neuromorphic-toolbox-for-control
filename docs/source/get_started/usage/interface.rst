Interface
=========

Installing the toolbox will not make any addition to the |matlab| window. 
The changes will be a new library in the |simulink| Library Browser and new functions |matlab| under the ``NeuromorphicControlToolbox`` namespace.

|simulink| Interface
--------------------

In |simulink| the new library packaged in the toolbox will appear in the Library Browser as follows :

.. only:: html

    .. card:: Library Browser view

        .. image:: images/toolbox_in_simulink.png

.. only:: latex

    +------------------------------------------------+
    | Library Browser view                           |
    +================================================+
    | .. image:: images/toolbox_in_simulink.png      | 
    +------------------------------------------------+

Adding a block can be done view the usual way of dragging from the Library Browser or double clicking. 
Most of the block are located in sublibraries taht can be acessed by double clicking or by the Library Browser sidebar.


As for classical libraries, the blocks can be accessed and placed programatically using standard |matlab| commands (see |matlabsimulinkaddblockdoc|_ for details).
A general example of adding a library block to a model is the following |matlab| command : 

.. |matlabsimulinkaddblockdoc| replace:: ``add_block`` documentation
.. _matlabsimulinkaddblockdoc: https://nl.mathworks.com/help/simulink/slref/add_block.html

.. code:: matlab

    add_block("neuromorphic_blocks/{path_to_block_in_library}","{target_model}/{path_in_target_model}")

|matlab| Interface
------------------

The |matlab| additions of the toolbox are a set of function under the ``NeuromorphicControlToolbox`` namespace. 
They can be accessed directly using the full path of the function like so :

.. code:: matlab

    NeuromorphicControlToolbox.{subnamespace}.{func}({func_args}) 

To avoid writing such long functions, the |matlabimportcommand|_ allows to call the full namespace once then either only call the function by name or use only a subnamespace depending on the ``import`` call.

.. |matlabimportcommand| replace:: ``import`` command 
.. _matlabimportcommand: https://nl.mathworks.com/help/matlab/ref/import.html

.. code:: matlab

    import NeuromorphicControlToolbox.{subnamespace}.{func} % Import only the specified function
    import NeuromorphicControlToolbox.{subnamespace}.*      % Import all functions in the subnamespaces
    import NeuromorphicControlToolbox.*                     % Import all subnamespaces