:mod:`Auxiliary Blocks`
=======================

.. attribute:: Event-Analog Signal Multiplier
    
    .. grid:: 2

        .. grid-item::
            :columns: 4
            :child-align: center

            .. only:: html

                .. image:: images/eventmul.png
                    :width: 100%
                    :align: center
                    :alt: Event-Analog Signal Multiplier Block Image

            .. only:: latex

                .. image:: images/eventmul.png
                    :width: 50%
                    :align: center
                    :alt: Event-Analog Signal Multiplier Block Image

        .. grid-item::
            :columns: 8

            Block performing a "multiplication" between an events signal and a selection signal. The blocks can be mathematically described as:

            .. math:: 

                \begin{align}
                    \text{Out}_+ &= f(a_+s - d_+)\text{In}\\
                    \text{Out}_- &= f(a_-s - d_-)\text{In}
                \end{align}

            where :math:`f` is either a Heaviside step function :math:`H` or a sigmoid function :math:`\sigma` depending on the input-output type, and :math:`a_{\pm}` are the slopes and :math:`d_{\pm}` the biases of the selection function.

    :Inputs:
        * **Ev** (*boolean*) -- Input events signal :math:`\text{Ev}` such that :math:`\text{In} = \text{Ev}`.
        * **s** (*analog*) -- Input selection signal :math:`s`.

    :Alternative Inputs:
        * **V** (*analog*) -- Input voltage signal :math:`\text{V}` such that :math:`\text{In} = g_{\text{in}\pm}\sigma(a_{\text{in}\pm}\text{V} - d_{\text{in}\pm})`.
        * **s** (*analog*) -- Input selection signal :math:`s`.
    :Outputs:
        * **Ev+** (*boolean*) -- Output positive events signal :math:`\text{Out}_+` such that :math:`f \equiv H`.
        * **Ev-** (*boolean*) -- Output negative events signal :math:`\text{Out}_-` such that :math:`f \equiv H`.

    :Alternative Outputs:
        * **V+** (*analog*) -- Output positive voltage signal :math:`\text{Out}_+` such that :math:`f \equiv \sigma`.
        * **V-** (*analog*) -- Output negative voltage signal :math:`\text{Out}_-` such that :math:`f \equiv \sigma`.

    :Parameters:
        * Differentiate Positive and Negative -- Whether to differentiate positive and negative parameters or set the. Can be set to 'True' or 'False'. Default value is 'False'.
        * Signal Biases -- The biases :math:`d_{\pm}` of the selection function. Default value is 0.
        * Signal Slopes -- The slopes :math:`a_{\pm}` of the selection function. Default value is 1.
        * Input-Output Type --  The exposed input-output channels. Can be set to 'Events' or 'Voltage'. Default value is 'Events'.
        * Input Conductances -- The input conductances :math:`g_{\text{in}\pm}` used if voltage input is selected. Default value is 1.
        * Input Biases -- The input biases :math:`d_{\text{in}\pm}` used if voltage input is selected. Default value is 0.
        * Input Slopes -- The input slopes :math:`a_{\text{in}\pm}` used if voltage input is selected. Default value is 1.

.. attribute:: Event-Analog Signal Selector
    
    .. grid:: 2

        .. grid-item::
            :columns: 4
            :child-align: center

            .. only:: html

                .. image:: images/eventsel.png
                    :width: 100%
                    :align: center
                    :alt: Event-Analog Signal Selector Block Image

            .. only:: latex

                .. image:: images/eventsel.png
                    :width: 50%
                    :align: center
                    :alt: Event-Analog Signal Selector Block Image

        .. grid-item::
            :columns: 8

            Block performing a "selection" between two incoming events signals using a selection signal. The blocks can be mathematically described as:

            .. math:: 

                \begin{align}
                    \text{Out} &= f(a_+s - d_+)\text{In}_+ + f(a_-s - d_-)\text{In}_-
                \end{align}

            where :math:`f` is either a Heaviside step function :math:`H` or a sigmoid function :math:`\sigma` depending on the input-output type, and :math:`a_{\pm}` are the slopes and :math:`d_{\pm}` the biases of the selection functions.

    :Inputs:
        * **Ev+** (*boolean*) -- Input positive events signal :math:`\text{Ev}_+` such that :math:`\text{In}_+ = \text{Ev}_+`.
        * **Ev-** (*boolean*) -- Input negative events signal :math:`\text{Ev}_-` such that :math:`\text{In}_- = \text{Ev}_-`.
        * **s** (*analog*) -- Input selection signal :math:`s`.

    :Alternative Inputs:
        * **V+** (*analog*) -- Input positive voltage signal :math:`\text{V}_+` such that :math:`\text{In}_+ = g_{\text{in}+}\sigma(a_{\text{in}+}\text{V}_+ - d_{\text{in}+})`.
        * **V-** (*analog*) -- Input negative voltage signal :math:`\text{V}_-` such that :math:`\text{In}_- = g_{\text{in}-}\sigma(a_{\text{in}-}\text{V}_- - d_{\text{in}-})`.
        * **s** (*analog*) -- Input selection signal :math:`s`.
    :Output:
        **Ev** (*boolean*) -- Output positive events signal :math:`\text{Out}` such that :math:`f \equiv H`.

    :Alternative Output:
        **V** (*analog*) -- Output positive voltage signal :math:`\text{Out}` such that :math:`f \equiv \sigma`.

    :Parameters:
        * Differentiate Positive and Negative -- Whether to differentiate positive and negative parameters or set the. Can be set to 'True' or 'False'. Default value is 'False'.
        * Signal Biases -- The biases :math:`d_{\pm}` of the selection function. Default value is 0.
        * Signal Slopes -- The slopes :math:`a_{\pm}` of the selection function. Default value is 1.
        * Input-Output Type --  The exposed input-output channels. Can be set to 'Events' or 'Voltage'. Default value is 'Events'.
        * Input Conductances -- The input conductances :math:`g_{\text{in}\pm}` used if voltage input is selected. Default value is 1.
        * Input Biases -- The input biases :math:`d_{\text{in}\pm}` used if voltage input is selected. Default value is 0.
        * Input Slopes -- The input slopes :math:`a_{\text{in}\pm}` used if voltage input is selected. Default value is 1.

.. attribute:: Directional Threshold Detector
    
    .. grid:: 2

        .. grid-item::
            :columns: 4
            :child-align: center

            .. only:: html

                .. image:: images/threshold.png
                    :width: 100%
                    :align: center
                    :alt: Directional Threshold Detector Block Image

            .. only:: latex

                .. image:: images/threshold.png
                    :width: 50%
                    :align: center
                    :alt: Directional Threshold Detector Block Image

        .. grid-item::
            :columns: 8

            Block generating an event when the input signal crosses a threshold from a certain direction (above to below or below to above). The block is compose of an input block that generates a current to an internal type III :attr:`Neuron`. The input block can be mathematically described as:

            .. math:: 

                \begin{align}
                    I &= g\sigma(as - d)\\
                \end{align}

            where :math:`g` is the gain, :math:`a` the slope, and :math:`d` the bias of the input and :math:`I` is the current sent to the internal type III neuron.

    :Input:
        **s** (*analog*) -- Input selection signal :math:`s`.

    :Output:
        **Ev** (*boolean*) -- Output positive events signal. See :attr:`Neuron` for details.

    :Alternative Output:
        **V** (*analog*) -- Output positive voltage signal. Output is computed from volatage :math:`V_n` of neuron by :math:`\text{V} = g_{\text{out}}\sigma(a_{\text{out}}V_n- - d_{\text{out}})`. See :attr:`Neuron` for details.

    :Parameters:
        * Input Gain -- The gain :math:`g`. Default value is -0.5.
        * Input Bias -- The bias :math:`d`. Default value is 0.
        * Input Slope -- The slope :math:`a`. Default value is 10.
        * Timescale -- The timescale :math:`\tau` of the internal neuron. Default value is 0.004.
        * Output Type --  The exposed output channel. Can be set to 'Events' or 'Voltage'. Default value is 'Events'.
        * Output Conductance -- The output conductance :math:`g_{\text{out}}` used if voltage output is selected. Default value is 1.
        * Output Bias -- The output bias :math:`d_{\text{out}}` used if voltage output is selected. Default value is 0.
        * Output Slope -- The output slope :math:`a_{\text{out}}` used if voltage output is selected. Default value is 1.

.. attribute:: Bistable Relay
    
    .. grid:: 2

        .. grid-item::
            :columns: 4
            :child-align: center

            .. only:: html

                .. image:: images/eventrelay.png
                    :width: 100%
                    :align: center
                    :alt: Bistable Relay Block Image

            .. only:: latex

                .. image:: images/eventrelay.png
                    :width: 50%
                    :align: center
                    :alt: Bistable Relay Block Image

        .. grid-item::
            :columns: 8

            Block capable of storing the polarity of the last event received. The blocks can be mathematically described as:

            .. math:: 

                \begin{align}
                    \tau\tau_r\dot{v} &= s + g_+\text{In}_+ + g_-\text{In}_- - v\\
                    s &= g\sigma(av - d)
                \end{align}

            where :math:`\tau` is the timescale, :math:`\tau_r` the relative timescale, :math:`g_+` the positive input gain, :math:`g_-` the negative input gain and :math:`g` the gain, :math:`a` the slope, and :math:`d` the bias of the feedback function.

    :Inputs:
        * **Ev+** (*boolean*) -- Input positive events signal :math:`\text{Ev}_+` such that :math:`\text{In}_+ = \text{Ev}_+`.
        * **Ev-** (*boolean*) -- Input negative events signal :math:`\text{Ev}_-` such that :math:`\text{In}_- = \text{Ev}_-`.

    :Alternative Inputs:
        * **V+** (*analog*) -- Input positive voltage signal :math:`\text{V}_+` such that :math:`\text{In}_+ = \sigma(a_{\text{in}+}\text{V}_+ - d_{\text{in}+})`.
        * **V-** (*analog*) -- Input negative voltage signal :math:`\text{V}_-` such that :math:`\text{In}_- = \sigma(a_{\text{in}-}\text{V}_- - d_{\text{in}-})`.

    :Optional Inputs:
        * **gsyn_p** (*analog*)-- The gain :math:`g_+` as described in the parameter section.
        * **gsyn_m** (*analog*)-- The gain :math:`g_-` as described in the parameter section.

    :Output:
        * **s** (*analog*) -- Input selection signal :math:`s`.

    :Parameters:
        * Feedback Gain -- The gain :math:`g` of the feedback function. Default value is 1.
        * Feedback Biases -- The biases :math:`d` of the feedback function. Default value is 0.
        * Feedback Slopes -- The slopes :math:`a` of the feedback function. Default value is 1.
        * Positive Input Gain -- The positive input gain :math:`g_+`. Default value is 1.
        * Negative Input Gain -- The negative input gain :math:`g_-`. Default value is 1.
        * Timescale -- The timescale :math:`\tau`. Default value is 0.004.
        * Relative Timescale -- The relative timescale :math:`\tau_r`. Default value is 0.01.
        * Input-Output Type --  The exposed input-output channels. Can be set to 'Events' or 'Voltage'. Default value is 'Events'.
        * Input Biases -- The input biases :math:`d_{\text{in}\pm}` used if voltage input is selected. Default value is 0.
        * Input Slopes -- The input slopes :math:`a_{\text{in}\pm}` used if voltage input is selected. Default value is 1.

.. attribute:: Noise on Signal
    
    .. grid:: 2

        .. grid-item::
            :columns: 4
            :child-align: center

            .. only:: html

                .. image:: images/noise.png
                    :width: 100%
                    :align: center
                    :alt: Noise on Signal Block Image

            .. only:: latex

                .. image:: images/noise.png
                    :width: 50%
                    :align: center
                    :alt: Noise on Signal Block Image

        .. grid-item::
            :columns: 8

            Block adding band-limited white noise to the input signal. The blocks can be mathematically described as:

            .. math:: 

                \begin{align}
                    y &= x + W(t)\\
                \end{align}

            where :math:`W(t)` is a band-limited white noise process with zero mean, standard deviation :math:`\sigma`, and a correlation time :math:`\tau\tau_r` with :math:`\tau` the timescale and :math:`\tau_r` the relative timescale.

    :Input:
        * **In** (*analog*) -- Input signal :math:`x`.

    :Output:
        * **Out** (*analog*) -- Output signal :math:`y`.

    :Parameters:
        * Noise Power -- The square of the standard deviation :math:`P = \sigma^2` of the noise. Default value is 1.
        * Timescale -- The timescale :math:`\tau`. Default value is 0.004.
        * Relative Timescale -- The relative timescale :math:`\tau_r`. Default value is 1.
        * Seed -- The seed of the random number generator, a value of -1 specifies a random seed. Default value is -1.