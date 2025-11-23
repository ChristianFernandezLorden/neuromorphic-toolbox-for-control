:mod:`Event Handling Blocks`
============================

.. attribute:: Continuous to Event
    
    .. grid:: 2

        .. grid-item::
            :columns: 4
            :child-align: center

            .. only:: html

                .. image:: images/conttoevent.png
                    :width: 100%
                    :align: center
                    :alt: Continuous to Event Block Image

            .. only:: latex

                .. image:: images/conttoevent.png
                    :width: 50%
                    :align: center
                    :alt: Continuous to Event Block Image

        .. grid-item::
            :columns: 8

            Block converting an analog signal to an event signal. The blocks can be mathematically described as:

            .. math:: 

                \begin{align}
                    \delta &= H(x - d)\\
                \end{align}

            where :math:`H` is the Heaviside step function and :math:`d` is the threshold parameter.

    :Input:
        * **In** (*analog*) -- Input signal :math:`x`.

    :Output:
        * **Out** (*boolean*) -- Output events signal :math:`\delta`.

    :Parameters:
        * Threshold -- The threshold :math:`d` of the event generation. Default value is 0.0.

.. attribute:: Event to Continuous
    
    .. grid:: 2

        .. grid-item::
            :columns: 4
            :child-align: center

            .. only:: html

                .. image:: images/conttoevent.png
                    :width: 100%
                    :align: center
                    :alt: Event to Continuous Block Image

            .. only:: latex

                .. image:: images/conttoevent.png
                    :width: 50%
                    :align: center
                    :alt: Event to Continuous Block Image

        .. grid-item::
            :columns: 8

            Block converting an event signal to an analog signal. The blocks can be mathematically described as:

            .. math:: 

                \begin{align}
                    x &= g\delta\\
                \end{align}

            where :math:`g` is the gain parameter.

    :Input:
        * **In** (*boolean*) -- Input events signal :math:`\delta`.

    :Output:
        * **Out** (*analog*) -- Output signal :math:`x`.

    :Parameters:
        * Gain -- The gain :math:`g` of the event to continuous conversion. Default value is 1.0.

.. attribute:: Event to Fixed Width Pulse
    
    .. grid:: 2

        .. grid-item::
            :columns: 4
            :child-align: center

            .. only:: html

                .. image:: images/eventtopulse.png
                    :width: 100%
                    :align: center
                    :alt: Event to Fixed Width Pulse Block Image

            .. only:: latex

                .. image:: images/eventtopulse.png
                    :width: 50%
                    :align: center
                    :alt: Event to Fixed Width Pulse Block Image

        .. grid-item::
            :columns: 8

            Block transforming incoming events into fixed width events. The blocks can be mathematically described as:
            
            .. math:: 

                \begin{align}
                    \delta_\text{out} &= H(T + t_{\delta_\text{in},i} - t)\delta_\text{in}\\
                \end{align}

            where :math:`T` is the fixed pulse width parameter, :math:`t_{\delta_\text{in},i}` is the rising edge time of the incoming event and :math:`t` is the current time.

    :Input:
        * **In** (*boolean*) -- Input events signal :math:`\delta_\text{in}`.

    :Output:
        * **Out** (*boolean*) -- Output events signal :math:`\delta_\text{out}`.

    :Parameters:
        * Pulse Width -- The fixed width :math:`T` of the output events in seconds. Default value is 0.0 seconds.

.. attribute:: Event Loss
    
    .. grid:: 2

        .. grid-item::
            :columns: 4
            :child-align: center

            .. only:: html

                .. image:: images/eventloss.png
                    :width: 100%
                    :align: center
                    :alt: Event Loss Block Image

            .. only:: latex

                .. image:: images/eventloss.png
                    :width: 50%
                    :align: center
                    :alt: Event Loss Block Image

        .. grid-item::
            :columns: 8

            Block stochastically losing events according to a specified probability :math:`p`. The blocks can be mathematically described as: 

            .. math:: 

                \begin{align}
                    \delta_\text{out} &= H(X[i] - p)\delta_\text{in}\\
                \end{align}

            where :math:`p` is the loss probability parameter and :math:`X[i]` is a random number uniformly drawn in :math:`[0, 1]` for each incoming event.

    :Input:
        * **In** (*boolean*) -- Input events signal :math:`\delta_\text{in}`.

    :Output:
        * **Out** (*boolean*) -- Output events signal :math:`\delta_\text{out}`.

    :Parameters:
        * Loss Probability -- Probability :math:`p` of losing an event. Default value is 0.0.
        * Seed -- The seed of the random number generator, a value of -1 specifies a random seed. Default value is -1.
