:mod:`Neural Blocks`
====================

.. attribute:: Neuron 

    .. grid:: 2

        .. grid-item::
            :columns: 4
            :child-align: center

            .. only:: html

                .. image:: images/neuron.png
                    :width: 100%
                    :align: center
                    :alt: Neuron Block Image

            .. only:: latex

                .. image:: images/neuron.png
                    :width: 50%
                    :align: center
                    :alt: Neuron Block Image

        .. grid-item::
            :columns: 8

            Block implementing a neuron based on the mixed-feedback theory inspired by :footcite:t:`ribar_neuromodulation_2019`. The block can be mathematically described as:

            .. math:: 

                \begin{align}
                    \tau\tau_m\dot{V} &= I + V_0 + I_0 + i_{f-} - i_{s+} + i_{s-} - i_{u+} + i_{u-} - V\label{eq:neur_start}\\
                    i_{f-} &= g_{f-}\left(\tanh\left(a_{f+}v_f-d_{f-}\right) - \tanh\left(a_{f-}V_0-d_{f-}\right)\right)\\ 
                    i_{s+} &= g_{s+}\left(\tanh\left(a_{s-}v_s-d_{s+}\right) - \tanh\left(a_{s+}V_0-d_{s+}\right)\right)\\ 
                    i_{s-} &= g_{s-}\left(\tanh\left(a_{s+}v_s-d_{s-}\right) - \tanh\left(a_{s-}V_0-d_{s-}\right)\right)\\ 
                    i_{u+} &= g_{u+}\left(\tanh\left(a_{u-}v_u-d_{u+}\right) - \tanh\left(a_{u+}V_0-d_{u+}\right)\right)\\ 
                    i_{u-} &= g_{u-}\left(\tanh\left(a_{u+}v_u-d_{u-}\right) - \tanh\left(a_{u-}V_0-d_{u-}\right)\right)\\ 
                    \tau\tau_f\dot{v_f} &= v - v_f\\
                    \tau\tau_s\dot{v_s} &= v - v_s\\
                    \tau\tau_u\dot{v_u} &= v - v_u\\
                    \delta &= \mathop{H}(V-d_\delta).
                \end{align}

            where :math:`g_*` are the conductances, :math:`a_*` the slopes, :math:`d_*` the biases, :math:`d_\delta` the event threshold, :math:`\tau` the timescale, :math:`\tau_*` the relative timescales, :math:`V_0` the resting potential, :math:`I_0` the bias current, and :math:`\mathop{H}` the Heaviside step function. The conductances :math:`g_*` can optionnaly be set as an input.

    :Input:
        **Iapp** (*analog*) -- Input current :math:`I`.

    :Optional Input:
        **g__** (*analog*)-- The one or multiple conductances :math:`g_*` as described in the parameter section.

    :Output(s):
        * **Ev** (*boolean*) -- Output events :math:`\delta`.
        * **V** (*analog*) -- Output voltage :math:`V`

    :Parameters:
        * Gains -- The conductances :math:`g_*`. Default value is 1 for all.
        * Gains Source -- Where to get the conductances value from. Can be set to 'Internal' or 'External'. Default value is 'Internal'.
        * Biases -- The biases :math:`d_*`. Default value is 0 for all.
        * Slopes -- The slopes :math:`a_*`. Default value is 1 for all.
        * Timescale -- The timescale :math:`\tau`. Default value is 0.004.
        * Relative Membrane Timescale -- The relative timescale :math:`\tau_f`. Default value is 0.1.
        * Relative Fast Timescale -- The relative timescale :math:`\tau_m`. Default value is 0.1.
        * Relative Slow Timescale -- The relative timescale :math:`\tau_s`. Default value is 4.
        * Relative Ultra-Slow Timescale -- The relative timescale :math:`\tau_u`. Default value is 200.
        * Base Applied Current -- The base applied current :math:`I_0`. Default value is 0.
        * Base Voltage -- The base voltage :math:`V_0`. Default value is 0.
        * Base Event Threshold -- The base event threshold :math:`d_\delta`. Default value is 0. Value is ignored if Output is set to 'Voltage'.
        * Output -- The exposed output channel(s). Can be set to 'Events', 'Voltage' or 'Both'. Default value is 'Events'.

.. attribute:: Synapse with Facilitation

    .. grid:: 2

        .. grid-item::
            :columns: 4
            :child-align: center

            .. only:: html

                .. image:: images/synapsefacilitation.png
                    :width: 100%
                    :align: center
                    :alt: Synapse with Facilitation Block Image

            .. only:: latex

                .. image:: images/synapsefacilitation.png
                    :width: 50%
                    :align: center
                    :alt: Synapse with Facilitation Block Image

        .. grid-item::
            :columns: 8

            Block implementing a synapse with a facilitation mechanism. The blocks can be mathematically described as:

            .. math:: 

                \begin{align}
                    \tau\tau_r\dot{v} &= \text{In} - v\\
                    I &= g\sigma(av - d)
                \end{align}

            where :math:`\tau` the timescale, :math:`\tau_r` the relative timescale, :math:`g` is the conductance, :math:`a` the slope, and :math:`d` the bias.
            The conductance :math:`g` can optionnaly be set as an input.

    :Input:
        **Ev** (*boolean*) -- Input events signal :math:`\text{Ev}` such that :math:`\text{In} = \text{Ev}`.

    :Alternative Input:
        **V** (*analog*) -- Input voltage :math:`\text{V}` such that :math:`\text{In} = g_\text{in}\sigma(a_\text{in}\text{V} - d_\text{in})`.

    :Optional Input:
        **gsyn** (*analog*)-- The conductances :math:`g` as described in the parameter section.

    :Output:
        **Isyn** (*analog*) -- Output current :math:`I`.

    :Parameters:
        * Conductance -- The conductance :math:`g`. Default value is 0.
        * Conductance Source -- Where to get the conductance value from. Can be set to 'Internal' or 'External'. Default value is 'Internal'.
        * Bias -- The bias :math:`d`. Default value is 0.
        * Slope -- The slope :math:`a`. Default value is 1.
        * Timescale -- The timescale :math:`\tau`. Default value is 0.004.
        * Relative Timescale -- The relative timescale :math:`\tau_r`. Default value is 10.
        * Input Type -- The exposed input channel. Can be set to 'Events' or 'Voltage'. Default value is 'Events'.
        * Input Conductance -- The input conductance :math:`g_\text{in}` used if voltage input is selected. Default value is 1.
        * Input Bias -- The input bias :math:`d_\text{in}` used if voltage input is selected. Default value is 0.
        * Input Slope -- The input slope :math:`a_\text{in}` used if voltage input is selected. Default value is 1.

.. attribute:: Synapse with Depression
    
    .. grid:: 2

        .. grid-item::
            :columns: 4
            :child-align: center

            .. only:: html

                .. image:: images/synapsedepression.png
                    :width: 100%
                    :align: center
                    :alt: Synapse with Depression Block Image

            .. only:: latex

                .. image:: images/synapsedepression.png
                    :width: 50%
                    :align: center
                    :alt: Synapse with Depression Block Image

        .. grid-item::
            :columns: 8

            Block implementing a synapse with a depression mechanism on top of a facilitation mechanism. The blocks can be mathematically described as:

            .. math:: 

                \begin{align}
                    \tau\tau_r\dot{v} &= \text{In} - v\\
                    \tau\tau_d\dot{v_d} &= \text{In} - v_d\\
                    g_d(v_d) &= g\sigma(a_dv_d - d_d)\\
                    I &= g_d(v_d)\sigma(av - d)
                \end{align}

            where :math:`\tau` the timescale, :math:`\tau_r` the relative timescale, :math:`\tau_d` the relative depression timescale, :math:`g` is the conductance, :math:`a` the slope, :math:`d` the bias, :math:`a_d` the depression slope, and :math:`d_d` the depression bias.
            The conductance :math:`g` can optionnaly be set as an input.

    :Input:
        **Ev** (*boolean*) -- Input events signal :math:`\text{Ev}` such that :math:`\text{In} = \text{Ev}`.

    :Alternative Input:
        **V** (*analog*) -- Input voltage :math:`\text{V}` such that :math:`\text{In} = g_\text{in}\sigma(a_\text{in}\text{V} - d_\text{in})`.

    :Optional Input:
        **gsyn** (*analog*)-- The conductances :math:`g` as described in the parameter section.

    :Output:
        **Isyn** (*analog*) -- Output current :math:`I`.

    :Parameters:
        * Conductance -- The conductance :math:`g`. Default value is 0.
        * Conductance Source -- Where to get the conductance value from. Can be set to 'Internal' or 'External'. Default value is 'Internal'.
        * Bias -- The bias :math:`d`. Default value is 0.
        * Depression Bias -- The depression bias :math:`d_d`. Default value is 0.
        * Slope -- The slope :math:`a`. Default value is 1.
        * Depression Slope -- The depression slope :math:`a_d`. Default value is 1.
        * Timescale -- The timescale :math:`\tau`. Default value is 0.004.
        * Relative Timescale -- The relative timescale :math:`\tau_r`. Default value is 0.
        * Relative Depression Timescale -- The relative depression timescale :math:`\tau_d`. Default value is 100.
        * Input Type -- The exposed input channel. Can be set to 'Events' or 'Voltage'. Default value is 'Events'.
        * Input Conductance -- The input conductance :math:`g_\text{in}` used if voltage input is selected. Default value is 1.
        * Input Bias -- The input bias :math:`d_\text{in}` used if voltage input is selected. Default value is 0.
        * Input Slope -- The input slope :math:`a_\text{in}` used if voltage input is selected. Default value is 1.

.. attribute:: Modulatory Synapse

    .. grid:: 2

        .. grid-item::
            :columns: 4
            :child-align: center

            .. only:: html

                .. image:: images/synapsemodulation.png
                    :width: 100%
                    :align: center
                    :alt: Modulatory Synapse Block Image

            .. only:: latex

                .. image:: images/synapsemodulation.png
                    :width: 50%
                    :align: center
                    :alt: Modulatory Synapse Block Image

        .. grid-item::
            :columns: 8

            Block implementing a synapse emulating a modulation mechanism. The blocks can be mathematically described as:

            .. math:: 

                \begin{align}
                    \tau\tau_r\dot{p} &= \bar{p} + g_+\text{In}_+ - g_-\text{In}_- - p
                \end{align}

            where :math:`\tau` the timescale, :math:`\tau_r` the relative timescale, :math:`\bar{p}` the base parameter value, :math:`g_+` the positive conductance, and :math:`g_-` the negative conductance.
            The conductance :math:`g_+` and :math:`g_-` can optionnaly be set as an input.

    :Inputs:
        * **Ev+** (*boolean*) -- Input events signal :math:`\text{Ev+}` such that :math:`\text{In}_+ = \text{Ev+}`.
        * **Ev-** (*boolean*) -- Input events signal :math:`\text{Ev-}` such that :math:`\text{In}_- = \text{Ev-}`.

    :Alternative Inputs:
        * **V+** (*analog*) -- Input positive voltage :math:`\text{V+}` such that :math:`\text{In}_+ = \sigma(a_\text{in+}\text{V+} - d_\text{in+})`.
        * **V-** (*analog*) -- Input negative voltage :math:`\text{V-}` such that :math:`\text{In}_- = \sigma(a_\text{in-}\text{V-} - d_\text{in-})`.

    :Optional Inputs:
        * **gsyn_p** (*analog*)-- The conductances :math:`g_+` as described in the parameter section.
        * **gsyn_m** (*analog*)-- The conductances :math:`g_-` as described in the parameter section.

    :Output:
        **p** (*analog*) -- Output parameter :math:`p`.

    :Parameters:
        * Base Parameter Value -- The base parameter value :math:`\bar{p}`. Default value is 0.
        * Positive Conductance -- The positive conductance :math:`g_+`. Default value is 0.
        * Negative Conductance -- The negative conductance :math:`g_-`. Default value is 0.
        * Positive Conductance Source -- Where to get the conductances value from. Can be set to 'Internal' or 'External'. Default value is 'Internal'.
        * Negative Conductance Source -- Where to get the conductances value from. Can be set to 'Internal' or 'External'. Default value is 'Internal'.
        * Timescale -- The timescale :math:`\tau`. Default value is 0.004.
        * Relative Timescale -- The relative timescale :math:`\tau_r`. Default value is 1000.
        * Input Type -- The exposed input channels. Can be set to 'Events' or 'Voltage'. Default value is 'Events'.
        * Input Positive Bias -- The input positive bias :math:`d_\text{in+}` used if voltage input is selected. Default value is 0.
        * Input Negative Bias -- The input negative bias :math:`d_\text{in-}` used if voltage input is selected. Default value is 0.
        * Input Positive Slope -- The input positive slope :math:`a_\text{in+}` used if voltage input is selected. Default value is 1.
        * Input Negative Slope -- The input negative slope :math:`a_\text{in-}` used if voltage input is selected. Default value is 1.


.. footbibliography::