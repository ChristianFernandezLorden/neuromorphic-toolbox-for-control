Installation
============

The toolbox can be added to a |matlab_simulink| installation in two ways. 
Either by using the built-in add-on manager (recommended) or by manual installation.

Add-On Installation (recommended)
----------------------------------

Installing the toolbox as an add-on is the recommended way of using the toolbox and can be done in two valid ways.
Either directly by using the *Add-On Explorer* panel in |matlab| or by using an add-on installation file.

Add-On Explorer
***************

Installing the toolbox in |matlab_simulink| using the integrated *Add-On Explorer* is done by the following procedure :

#. Open the Add-On Explorer window.
#. Type *Neuromorphic Toolbox for Control* in the search bar and click on the toolbox.
#. On the toolbox page, click on the *Add* button.

.. only:: html
    
    .. card:: Add-On Explorer Installation

        .. image:: images/addon_manager.png

.. only:: latex

    +------------------------------------------------+
    | Add-On Explorer Installation                   |
    +================================================+
    | .. image:: images/addon_manager.png            | 
    +------------------------------------------------+

.. _toolbox-file-install:

Toolbox Installation File
*************************

Installing the toolbox by using the add-on installation file requires downloading the ``Neuromorphic Toolbox for Control.mltbx`` file from |github-link| in the realease asset or |mathworks-file-exchange-link| using the toolbox download button.

.. only:: html

    .. grid:: 2

        .. grid-item-card::  |github| Download

            .. image:: images/toolbox_installer_github.png

        .. grid-item-card::  |mathworks-file-exchange| Download
            :class-item: sd-align-minor-start

            .. image:: images/toolbox_installer_matlab.png

.. only:: latex

    +------------------------------------------------+------------------------------------------------+
    | GitHub Download                                | Mathworks Download                             |
    +================================================+================================================+
    | .. image:: images/toolbox_installer_github.png | .. image:: images/toolbox_installer_matlab.png |
    +------------------------------------------------+------------------------------------------------+


Then double clicking the add-on installation file will launch the installation process.

Or, alternatively, the add-on can be installed from the |matlab| command line with the following command :

.. code::

    matlab.addons.install("Neuromorphic Toolbox for Control.mltbx")


.. note:: 
    Older version of the toolbox can be downloaded by searching earlier releases in |github| or by going to the *Version History* tab on the toolbox |mathworks-file-exchange| page (online or in the Add-On Explorer).

Manual Installation
-------------------

Doing a manual installation of the toolbox is not recommended except if you plan to modify the toolbox for your application. In that case it becomes the best option. 
This method will also download useless files for the toolbox such as this documentation, they can be removed without impacting the toolbox operations.

A manual installation requires downloading the source code from |github-link| by cloning it or downloading the zip or |mathworks-file-exchange-link| using the zip download button.
Then unpack the source code and place the directories ``blocks``, ``code`` and ``icons`` as well as their subdirectories in the |matlab| `path <https://nl.mathworks.com/help/matlab/matlab_env/what-is-the-matlab-search-path.html>`_.
Alternatively, you can repackage the toolbox into a ``.mltbx`` file using the toolbox project file ``toolbox_package/neuromorphic-toolbox-for-control.prj``, and install it according to :ref:`toolbox-file-install`.



    
