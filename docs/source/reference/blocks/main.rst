======
Blocks
======

These sections list the differents blocks grouped by sublibraries.

.. toctree::
    :maxdepth: 6
    :caption: Sublibraries:
        
    neuralblocks
    auxiliaryblocks
    eventblocks
    quickstartblocks


.. index:: Sigmoid

.. attribute:: Sigmoid 
    
    :Input:
        * *I* -- Input current

    :Output:
        * *V* -- Output voltage
        * *E* -- Output events

    :Parameters:
        a

.. attribute:: Low-pass filter

    :Input:
        * *E* -- Input current

    :Input (alt):
        * *V* -- Input voltage

    :Output:
        * *I* -- Output current

    :Parameters:
        a