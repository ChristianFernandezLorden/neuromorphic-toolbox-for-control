``Auxiliary Blocks``
====================


.. py:attribute:: Bistable Relay

    :Input:
        * *E*:sub:`+` -- Input positive events
        * *E*:sub:`-` -- Input negative events

    :Output:
        * *s* -- Output signal

    :Parameters:
        a


.. py:attribute:: Directional Event Generator

    :Input:
        * *s* -- Input signal

    :Output:
        * *E* -- Output events

    :Parameters:
        a


.. py:attribute:: Binary Event-Analog Signal Multiplier

    :Input:
        * *E* -- Input events
        * *s* -- Input signal

    :Output:
        * *E*:sub:`+` -- Output positive events
        * *E*:sub:`-` -- Output negative events

    :Parameters:
        a


.. py:attribute:: Binary Event-Analog Signal Concatenator

    :Input:
        * *E*:sub:`+` -- Input positive events
        * *E*:sub:`-` -- Input negative events
        * *s* -- Input signal

    :Output:
        * *E* -- Output events

    :Parameters:
        a


.. py:attribute:: Noise on Signal

    :Input:
        * *s* -- Input signal

    :Output:
        * *s* -- Output signal

    :Parameters:
        a