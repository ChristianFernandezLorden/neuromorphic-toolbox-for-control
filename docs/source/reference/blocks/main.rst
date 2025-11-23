======
Blocks
======

.. toctree::
    :maxdepth: 1
    :caption: Sublibraries:
        
    neuralblocks
    auxiliaryblocks
    eventblocks
    quickstartblocks

.. attribute:: Tunable Sigmoid 

    .. grid:: 2

        .. grid-item::
            :columns: 4
            :child-align: center

            .. only:: html

                .. image:: images/sigmoid.png
                    :width: 100%
                    :align: center
                    :alt: Tunable Sigmoid Block Image

            .. only:: latex

                .. image:: images/sigmoid.png
                    :width: 50%
                    :align: center
                    :alt: Tunable Sigmoid Block Image

        .. grid-item::
            :columns: 8

            Block performing a sigmoid transformation on an analog signal. The blocks can be mathematically described as:

            .. math:: 

                y = g\sigma(ax - d)

            where :math:`g` is the gain, :math:`a` the slope, and :math:`d` the bias of the sigmoid function.
            The gain :math:`g` can optionnaly be set as an input.

    :Input:
        **In** (*analog*) -- Input signal :math:`x`.

    :Optional Input:
        **g** (*analog*) -- The gain of the sigmoid :math:`g` as described in the parameter section.

    :Output:
        **Out** (*analog*) -- Output signal :math:`y`.

    :Parameters:
        * Type -- The type of sigmoid function. Can be set to 'Sigmoid' or 'Tanh'. Default value is 'Sigmoid'.
        * Gain -- The gain :math:`g`. Default value is 1.
        * Gain Source -- Where to get the gain value from. Can be set to 'Internal' or 'External'. Default value is 'Internal'.
        * Bias -- The bias :math:`d`. Default value is 0.
        * Slope -- The slope :math:`a`. Default value is 1.

.. attribute:: First Order Lag
    
    .. grid:: 2

        .. grid-item::
            :columns: 4
            :child-align: center

            .. only:: html

                .. image:: images/lowpass.png
                    :width: 100%
                    :align: center
                    :alt: First Order Lag Block Image

            .. only:: latex

                .. image:: images/lowpass.png
                    :width: 50%
                    :align: center
                    :alt: First Order Lag Block Image

        .. grid-item::
            :columns: 8

            Block filtering an analog signal with a first order lag. The blocks can be mathematically described as:

            .. math:: 

                \tau\tau_r\dot{y} = gx - y

            where :math:`\tau` is the timescale, :math:`\tau_r` the relative timescale, and :math:`g` the gain.

    :Input:
        **In** (*analog*) -- Input signal :math:`x`.

    :Output:
        **Out** (*analog*) -- Output signal :math:`y`.

    :Parameters:
        * Gain -- The gain :math:`g`. Default value is 1.
        * Timescale -- The timescale :math:`\tau`. Default value is 0.004.
        * Relative Timescale -- The relative timescale :math:`\tau_r`. Default value is 1.