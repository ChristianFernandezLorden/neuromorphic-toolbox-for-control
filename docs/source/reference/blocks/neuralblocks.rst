=================
``Neural Blocks``
=================


.. attribute:: Neuron 
    
    :Input:
        * *I* -- Input current

    :Output:
        * *V* -- Output voltage
        * *E* -- Output events

    :Parameters:
        a

.. attribute:: Facilitation Synapse

    :Input:
        * *E* -- Input current

    :Input (alt):
        * *V* -- Input voltage

    :Output:
        * *I* -- Output current

    :Parameters:
        a

.. attribute:: Depression Synapse

    :Input:
        * *E* -- Input current

    :Input (alt):
        * *V* -- Input voltage

    :Output:
        * *I* -- Output current

    :Parameters:
        a

.. attribute:: Modulatory Synapse

    :Input:
        * *E*:sub:`+` -- Input positive events
        * *E*:sub:`-` -- Input negative events

    :Input (alt):
        * *V*:sub:`+` -- Input positive voltage
        * *V*:sub:`-` -- Input negative events

    :Output:
        * *p* -- Output parameter

    :Parameters:
        * g:sub:`s-`