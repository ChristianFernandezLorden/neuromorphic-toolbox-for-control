/*  File    : facilitation_synapse.c
 *  Abstract:
 *
 *      Implements a synapse with facilitation built using the mixed feedback theory.
 *
 *  Copyright 2025 Université de Liège, Author: Christian Fernandez Lorden
 */

#define S_FUNCTION_NAME facilitation_synapse
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"


/* IDS */
#define GSYN_IDX 0
#define GSYN_IN_IDX 1

#define GSYN_SOURCE_IDX 2

#define DSYN_IDX 3
#define DSYN_IN_IDX 4

#define MSYN_IDX 5
#define MSYN_IN_IDX 6

#define TIMESCALE_IDX 7
#define REL_TIMESCALE_IDX 8

#define VOLTAGE_INPUT_IDX 9

/* PARAMS */
#define GSYN_PARAM(S) ssGetSFcnParam(S,GSYN_IDX)
#define GSYN_IN_PARAM(S) ssGetSFcnParam(S,GSYN_IN_IDX)

#define GSYN_SOURCE_PARAM(S) ssGetSFcnParam(S,GSYN_SOURCE_IDX)

#define DSYN_PARAM(S) ssGetSFcnParam(S,DSYN_IDX)
#define DSYN_IN_PARAM(S) ssGetSFcnParam(S,DSYN_IN_IDX)

#define MSYN_PARAM(S) ssGetSFcnParam(S,MSYN_IDX)
#define MSYN_IN_PARAM(S) ssGetSFcnParam(S,MSYN_IN_IDX)

#define TIMESCALE_PARAM(S) ssGetSFcnParam(S,TIMESCALE_IDX)
#define REL_TIMESCALE_PARAM(S) ssGetSFcnParam(S,REL_TIMESCALE_IDX)

#define VOLTAGE_INPUT_PARAM(S) ssGetSFcnParam(S,VOLTAGE_INPUT_IDX)

/* FIXED SIZES */ 
#define NPARAMS 10

#define NSTATES 1


/*====================*
 * S-function methods *
 *====================*/
 
#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    Validate our parameters to verify they are okay.
   */
  static void mdlCheckParameters(SimStruct *S)
  {
    // Checks at mask level
    UNUSED_ARG(S); 
  }
#endif /* MDL_CHECK_PARAMETERS */
 


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NPARAMS);  /* Number of expected parameters */
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Parameter mismatch will be reported by Simulink */
    }
#endif

    {
        int iParam = 0;
        int nParam = ssGetNumSFcnParams(S);

        for ( iParam = 0; iParam < nParam; iParam++ )
        {
            ssSetSFcnParamTunable( S, iParam, SS_PRM_NOT_TUNABLE  );
        }
    }

    ssSetNumContStates(S, (int_T)NSTATES);
    ssSetNumDiscStates(S, 0);


    {
        int_T  i;
        int_T  nInputPorts = 1;
        int_T  nOutputPorts = 1;
        //char_T str[sizeof("External")];
    
    
        /* Input */
        real_T gsyn_source = *mxGetDoubles(GSYN_SOURCE_PARAM(S));
        if (gsyn_source==2) {
            nInputPorts = 2;
        } else {
            nInputPorts = 1;
        }
    
        if (!ssSetNumInputPorts(S, nInputPorts)) return;
        for (i = 0; i < nInputPorts; i++) {
            ssSetInputPortWidth(S, i, 1);
            ssSetInputPortComplexSignal(S, i, COMPLEX_NO);
        }
        
        ssSetInputPortDirectFeedThrough(S, 0, 0);
        real_T voltage_input = *mxGetDoubles(VOLTAGE_INPUT_PARAM(S));
        if (voltage_input == 0) {
            ssSetInputPortDataType(S, 0, SS_BOOLEAN);
        } else {
            ssSetInputPortDataType(S, 0, SS_DOUBLE);
        }

        if (nInputPorts == 2) {
            ssSetInputPortDataType(S, 1, SS_DOUBLE);
            ssSetInputPortDirectFeedThrough(S, 1, 1);
        }
    

        /* Output */
        if (!ssSetNumOutputPorts(S, 1)) return;
        ssSetOutputPortWidth(S, 0, 1);
        ssSetOutputPortComplexSignal(S, 0, COMPLEX_NO);
        ssSetOutputPortDataType(S, 0, SS_DOUBLE);
    }

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 1);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    ssSetOperatingPointCompliance(S, USE_DEFAULT_OPERATING_POINT);

    /* Set this S-function as runtime thread-safe for multicore execution */
    ssSetRuntimeThreadSafetyCompliance(S, RUNTIME_THREAD_SAFETY_COMPLIANCE_TRUE);
   
    ssSetOptions(S, SS_OPTION_CALL_TERMINATE_ON_EXIT);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    S-function is comprised of only continuous sample time elements
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
    
}



#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ========================================
 * Abstract:
 *    Set the initial conditions to all V0
 */
static void mdlInitializeConditions(SimStruct *S)
{
    /* Initialize low-pass state */
    real_T *x0 = ssGetContStates(S);
    int_T nStates = ssGetNumContStates(S);
    int_T  i;
 
    for (i = 0; i < nStates; i++) {
        x0[i] = 0;
    }
    
    /* Initialize Rwork timescale param */
    const real_T timescale       = *mxGetDoubles(TIMESCALE_PARAM(S));
    const real_T rel_timescale   = *mxGetDoubles(REL_TIMESCALE_PARAM(S));
    ssSetRWorkValue(S, 0, 1.0/(timescale*rel_timescale));
}


// Algo based on use of lambert's fraction (https://varietyofsound.wordpress.com/2011/02/14/efficient-tanh-computation-using-lamberts-continued-fraction/)
inline real_T fast_tanh(real_T x)
{
    // Clip output when it goes above 1 or below -1
    if (x < -4.971786858528029) {
        return -1;
    }
    if (x > 4.971786858528029) {
        return 1;
    }
    real_T x2 = x * x;
    real_T a = x * (135135.0 + x2 * (17325.0 + x2 * (378.0 + x2)));
    real_T b = 135135.0 + x2 * (62370.0 + x2 * (3150.0 + x2 * 28.0));
    return a / b;
}



/* Function: mdlOutputs =======================================================
 * Abstract:
 *      y = Cx + Du
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    UNUSED_ARG(tid); /* not used in single tasking mode */

    real_T         *current     = ssGetOutputPortRealSignal(S,0);
    real_T         *x           = ssGetContStates(S);

    /* Params */
    real_T            gsyn        = *mxGetDoubles(GSYN_PARAM(S));
    const real_T      dsyn        = *mxGetDoubles(DSYN_PARAM(S));
    const real_T      msyn        = *mxGetDoubles(MSYN_PARAM(S));
    const real_T      gsyn_source = *mxGetDoubles(GSYN_SOURCE_PARAM(S));
    
    if (gsyn_source == 2) {
        InputRealPtrsType gsyn_ext = ssGetInputPortRealSignalPtrs(S,1);
        gsyn = *gsyn_ext[0];
    }

    *current = gsyn*(fast_tanh(2*(msyn*x[0] - dsyn))+1)/2;
}

#define MDL_DERIVATIVES
/* Function: mdlDerivatives =================================================
 * Abstract:
 *      xdot = Ax + Bu
 */
static void mdlDerivatives(SimStruct *S)
{
    real_T            *dx     = ssGetdX(S);
    real_T            *x      = ssGetContStates(S);

    /* Params */
    const real_T voltage_input       = *mxGetDoubles(VOLTAGE_INPUT_PARAM(S));
    const real_T tau_inv             = ssGetRWorkValue(S, 0);
    
    real_T InV;
    if (voltage_input == 0) {
        InputBooleanPtrsType Ev_in   = (InputBooleanPtrsType) ssGetInputPortSignalPtrs(S,0);
        InV = (real_T) (*Ev_in[0]);
    } else {
        InputRealPtrsType Iapp_in    = ssGetInputPortRealSignalPtrs(S,0);
        const real_T      gsyn_in    = *mxGetDoubles(GSYN_IN_PARAM(S));
        const real_T      dsyn_in    = *mxGetDoubles(DSYN_IN_PARAM(S));
        const real_T      msyn_in    = *mxGetDoubles(MSYN_IN_PARAM(S));

        InV = gsyn_in*(fast_tanh(2*(msyn_in*(*Iapp_in[0]) - dsyn_in))+1)/2;
    }

    dx[0] = tau_inv * (InV - x[0]);
}
 
 
 
/* Function: mdlTerminate =====================================================
 * Abstract:
 *    Free the allocated run-time parameters.
 */
static void mdlTerminate(SimStruct *S)
{
    // No Free Necessary
    UNUSED_ARG(S); 
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
