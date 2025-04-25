/*  File    : neuron.c
 *  Abstract:
 *
 *      Implements a neuron built using the mixed feedback theory.
 *
 *  Copyright 2025 Université de Liège, Author: Christian Fernandez Lorden
 */

#define S_FUNCTION_NAME neuron
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */


/* IDS */
#define GFM_IDX 0
#define GSP_IDX 1
#define GSM_IDX 2
#define GUP_IDX 3
#define GUM_IDX 4

#define GFM_SOURCE_IDX 5
#define GSP_SOURCE_IDX 6
#define GSM_SOURCE_IDX 7
#define GUP_SOURCE_IDX 8
#define GUM_SOURCE_IDX 9

#define DFM_IDX 10
#define DSP_IDX 11
#define DSM_IDX 12
#define DUP_IDX 13
#define DUM_IDX 14

#define MFM_IDX 15
#define MSP_IDX 16
#define MSM_IDX 17
#define MUP_IDX 18
#define MUM_IDX 19

#define TIMESCALE_IDX 20
#define REL_MEMBRANE_IDX 21
#define REL_FAST_IDX 22
#define REL_SLOW_IDX 23
#define REL_ULTRASLOW_IDX 24

#define IAPP_BASE_IDX 25
#define V0_IDX 26
#define TRESH_IDX 27
#define MEMBRANE_EXPOSED_IDX 28

/* PARAMS */
#define GFM_PARAM(S) ssGetSFcnParam(S,GFM_IDX)
#define GSP_PARAM(S) ssGetSFcnParam(S,GSP_IDX)
#define GSM_PARAM(S) ssGetSFcnParam(S,GSM_IDX)
#define GUP_PARAM(S) ssGetSFcnParam(S,GUP_IDX)
#define GUM_PARAM(S) ssGetSFcnParam(S,GUM_IDX)

#define GFM_SOURCE_PARAM(S) ssGetSFcnParam(S,GFM_SOURCE_IDX)
#define GSP_SOURCE_PARAM(S) ssGetSFcnParam(S,GSP_SOURCE_IDX)
#define GSM_SOURCE_PARAM(S) ssGetSFcnParam(S,GSM_SOURCE_IDX)
#define GUP_SOURCE_PARAM(S) ssGetSFcnParam(S,GUP_SOURCE_IDX)
#define GUM_SOURCE_PARAM(S) ssGetSFcnParam(S,GUM_SOURCE_IDX)

#define DFM_PARAM(S) ssGetSFcnParam(S,DFM_IDX)
#define DSP_PARAM(S) ssGetSFcnParam(S,DSP_IDX)
#define DSM_PARAM(S) ssGetSFcnParam(S,DSM_IDX)
#define DUP_PARAM(S) ssGetSFcnParam(S,DUP_IDX)
#define DUM_PARAM(S) ssGetSFcnParam(S,DUM_IDX)

#define MFM_PARAM(S) ssGetSFcnParam(S,MFM_IDX)
#define MSP_PARAM(S) ssGetSFcnParam(S,MSP_IDX)
#define MSM_PARAM(S) ssGetSFcnParam(S,MSM_IDX)
#define MUP_PARAM(S) ssGetSFcnParam(S,MUP_IDX)
#define MUM_PARAM(S) ssGetSFcnParam(S,MUM_IDX)

#define TIMESCALE_PARAM(S) ssGetSFcnParam(S,TIMESCALE_IDX)
#define REL_MEMBRANE_PARAM(S) ssGetSFcnParam(S,REL_MEMBRANE_IDX)
#define REL_FAST_PARAM(S) ssGetSFcnParam(S,REL_FAST_IDX)
#define REL_SLOW_PARAM(S) ssGetSFcnParam(S,REL_SLOW_IDX)
#define REL_ULTRASLOW_PARAM(S) ssGetSFcnParam(S,REL_ULTRASLOW_IDX)

#define IAPP_BASE_PARAM(S) ssGetSFcnParam(S,IAPP_BASE_IDX)
#define V0_PARAM(S) ssGetSFcnParam(S,V0_IDX)
#define TRESH_PARAM(S) ssGetSFcnParam(S,TRESH_IDX)
#define MEMBRANE_EXPOSED_PARAM(S) ssGetSFcnParam(S,MEMBRANE_EXPOSED_IDX)
 
 
#define NPARAMS 29

#define NSTATES 4

#define IS_PARAM_DOUBLE(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsDouble(pVal))

#define OK_EMPTY_DOUBLE_PARAM(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\
!mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsDouble(pVal)) 


typedef struct {
    real_T *tau_inv_membrane;
    real_T *tau_inv_fast;
    real_T *tau_inv_slow;
    real_T *tau_inv_ultraslow;
    boolean_T *membrane_exposed;
    boolean_T *gfm_external;
    boolean_T *gsp_external;
    boolean_T *gsm_external;
    boolean_T *gup_external;
    boolean_T *gum_external;
} runtime_param_pack;

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
      return;
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
        char_T str[sizeof("External")];
    
    
        mxGetString(GFM_SOURCE_PARAM(S),str,sizeof(str));
        if (strcmp(str,"External")==0) {
            nInputPorts += 1;
        }
        mxGetString(GSP_SOURCE_PARAM(S),str,sizeof(str));
        if (strcmp(str,"External")==0) {
            nInputPorts += 1;
        }
        mxGetString(GSM_SOURCE_PARAM(S),str,sizeof(str));
        if (strcmp(str,"External")==0) {
            nInputPorts += 1;
        }
        mxGetString(GUP_SOURCE_PARAM(S),str,sizeof(str));
        if (strcmp(str,"External")==0) {
            nInputPorts += 1;
        }
        mxGetString(GUM_SOURCE_PARAM(S),str,sizeof(str));
        if (strcmp(str,"External")==0) {
            nInputPorts += 1;
        }
    
        if (!ssSetNumInputPorts(S, nInputPorts)) return;
        for (i = 0; i < nInputPorts; i++) {
            ssSetInputPortWidth(S, i, 1);
            ssSetInputPortDirectFeedThrough(S, i, 0);
            ssSetInputPortDataType(S, i, SS_DOUBLE);
            ssSetInputPortComplexSignal(S, i, COMPLEX_NO);
        }

        mxGetString(MEMBRANE_EXPOSED_PARAM(S),str,sizeof(str));
        if (strcmp(str,"off")==0) {
            nOutputPorts = 1;
        } else {
            nOutputPorts = 2;
        }
    
        if (!ssSetNumOutputPorts(S, nOutputPorts)) return;
        for (i = 0; i < nOutputPorts; i++) {
            ssSetOutputPortWidth(S, i, 1);
            ssSetOutputPortComplexSignal(S, i, COMPLEX_NO);
        }

        ssSetOutputPortDataType(S, 0, SS_BOOLEAN);
        if (nOutputPorts == 2) {
            ssSetOutputPortDataType(S, 1, SS_DOUBLE);
        } 
    }

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    ssSetOperatingPointCompliance(S, USE_DEFAULT_OPERATING_POINT);

    /* Set this S-function as runtime thread-safe for multicore execution */
    ssSetRuntimeThreadSafetyCompliance(S, RUNTIME_THREAD_SAFETY_COMPLIANCE_TRUE);
   
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_CALL_TERMINATE_ON_EXIT);
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


#define MDL_SET_WORK_WIDTHS   /* Change to #undef to remove function */
#if defined(MDL_SET_WORK_WIDTHS) && defined(MATLAB_MEX_FILE)
/* Function: mdlSetWorkWidths ===============================================
 * Abstract:
 *      Set up run-time parameters of inverse timescales and boolean checks.
 */
static void mdlSetWorkWidths(SimStruct *S)
{
    /* Set number of run-time parameters  */
    if (!ssSetNumRunTimeParams(S, 10)) return;

    ssParamRec p; /* Initialize an ssParamRec structure */
    int               dlg_tau[2]; /* Stores dialog indices */
    int               dlg_bool[1]; /* Stores dialog indices */
    char_T str[sizeof("External")];
    real_T timescale      = *mxGetDoubles(TIMESCALE_PARAM(S));
    real_T rel_membrane   = *mxGetDoubles(REL_MEMBRANE_PARAM(S));
    real_T rel_fast       = *mxGetDoubles(REL_FAST_PARAM(S));
    real_T rel_slow       = *mxGetDoubles(REL_SLOW_PARAM(S));
    real_T rel_ultraslow  = *mxGetDoubles(REL_ULTRASLOW_PARAM(S));
    real_T *tau_inv_membrane;
    real_T *tau_inv_fast;
    real_T *tau_inv_slow;
    real_T *tau_inv_ultraslow;
    boolean_T *membrane_exposed;
    boolean_T *gfm_external;
    boolean_T *gsp_external;
    boolean_T *gsm_external;
    boolean_T *gup_external;
    boolean_T *gum_external;
    runtime_param_pack *runtime_params;
    
    /* Initialize dimensions for the run-time parameter as a
     * local variable. The Simulink engine makes a copy of this
     * information to store in the run-time parameter. */
    int_T  paramDims[2] = {1,1};
    
    /* Allocate memory for the run-time parameter data. The S-function
     * owns this memory location. The Simulink engine does not copy the data.*/
    if ((tau_inv_membrane=(real_T*)malloc(sizeof(real_T))) == NULL) {
        ssSetErrorStatus(S,"Memory allocation error");
        return;
    }
    if ((tau_inv_fast=(real_T*)malloc(sizeof(real_T))) == NULL) {
        ssSetErrorStatus(S,"Memory allocation error");
        return;
    }
    if ((tau_inv_slow=(real_T*)malloc(sizeof(real_T))) == NULL) {
        ssSetErrorStatus(S,"Memory allocation error");
        return;
    }
    if ((tau_inv_ultraslow=(real_T*)malloc(sizeof(real_T))) == NULL) {
        ssSetErrorStatus(S,"Memory allocation error");
        return;
    }


    if ((membrane_exposed=(boolean_T*)malloc(sizeof(boolean_T))) == NULL) {
        ssSetErrorStatus(S,"Memory allocation error");
        return;
    }
    if ((gfm_external=(boolean_T*)malloc(sizeof(boolean_T))) == NULL) {
        ssSetErrorStatus(S,"Memory allocation error");
        return;
    }
    if ((gsp_external=(boolean_T*)malloc(sizeof(boolean_T))) == NULL) {
        ssSetErrorStatus(S,"Memory allocation error");
        return;
    }
    if ((gsm_external=(boolean_T*)malloc(sizeof(boolean_T))) == NULL) {
        ssSetErrorStatus(S,"Memory allocation error");
        return;
    }
    if ((gup_external=(boolean_T*)malloc(sizeof(boolean_T))) == NULL) {
        ssSetErrorStatus(S,"Memory allocation error");
        return;
    }
    if ((gum_external=(boolean_T*)malloc(sizeof(boolean_T))) == NULL) {
        ssSetErrorStatus(S,"Memory allocation error");
        return;
    }


    if ((runtime_params=(runtime_param_pack*)malloc(sizeof(runtime_param_pack))) == NULL) {
        ssSetErrorStatus(S,"Memory allocation error");
        return;
    }

    /* Store the pointer to the memory location in the S-function 
     * userdata. Since the S-function owns this data, it needs to
     * free the memory during mdlTerminate */
    runtime_params->tau_inv_membrane = tau_inv_membrane;
    runtime_params->tau_inv_fast = tau_inv_fast;
    runtime_params->tau_inv_slow = tau_inv_slow;
    runtime_params->tau_inv_ultraslow = tau_inv_ultraslow;
    runtime_params->membrane_exposed = membrane_exposed;
    runtime_params->gfm_external = gfm_external;
    runtime_params->gsp_external = gsp_external;
    runtime_params->gsm_external = gsm_external;
    runtime_params->gup_external = gup_external;
    runtime_params->gum_external = gum_external;
    ssSetUserData(S, (void*)runtime_params);
    
    /* Call a local function to initialize the run-time 
     * parameter data. The Simulink engine checks that the data is not
     * empty so an initial value must be stored. */
    *tau_inv_membrane = 1/(timescale*rel_membrane);
    *tau_inv_fast = 1/(timescale*rel_fast);
    *tau_inv_slow = 1/(timescale*rel_slow);
    *tau_inv_ultraslow = 1/(timescale*rel_ultraslow);
    
    mxGetString(MEMBRANE_EXPOSED_PARAM(S),str,sizeof(str));
    *membrane_exposed = strcmp(str,"off")!=0;
    mxGetString(GFM_SOURCE_PARAM(S),str,sizeof(str));
    *gfm_external = strcmp(str,"External")==0;
    mxGetString(GSP_SOURCE_PARAM(S),str,sizeof(str));
    *gsp_external = strcmp(str,"External")==0;
    mxGetString(GSM_SOURCE_PARAM(S),str,sizeof(str));
    *gsm_external = strcmp(str,"External")==0;
    mxGetString(GUP_SOURCE_PARAM(S),str,sizeof(str));
    *gup_external = strcmp(str,"External")==0;
    mxGetString(GUM_SOURCE_PARAM(S),str,sizeof(str));
    *gum_external = strcmp(str,"External")==0;
    

    
    /* Configure general run-time parameter information for taus. */
    dlg_tau[0]         = TIMESCALE_IDX;
    p.nDimensions      = 2;
    p.dimensions       = paramDims;
    p.dataTypeId       = SS_DOUBLE;
    p.complexSignal    = COMPLEX_NO;
    p.dataAttributes   = NULL;
    p.nDlgParamIndices = 2;
    p.transformed      = RTPARAM_TRANSFORMED;
    p.outputAsMatrix   = false;
    
    /* Configure specific run-time parameter information. */
    dlg_tau[1] = REL_MEMBRANE_IDX;
    p.name             = "Tau Inv Membrane";
    p.data             = tau_inv_membrane;
    p.dlgParamIndices  = &dlg_tau;
    /* Set run-time parameter information */
    if (!ssSetRunTimeParamInfo(S,0,&p)) return;

    /* Configure specific run-time parameter information. */
    dlg_tau[1] = REL_FAST_IDX;
    p.name             = "Tau Inv Fast";
    p.data             = tau_inv_fast;
    p.dlgParamIndices  = &dlg_tau;
    /* Set run-time parameter information */
    if (!ssSetRunTimeParamInfo(S,1,&p)) return;

    /* Configure specific run-time parameter information. */
    dlg_tau[1] = REL_SLOW_IDX;
    p.name             = "Tau Inv Slow";
    p.data             = tau_inv_slow;
    p.dlgParamIndices  = &dlg_tau;
    /* Set run-time parameter information */
    if (!ssSetRunTimeParamInfo(S,2,&p)) return;

    /* Configure specific run-time parameter information. */
    dlg_tau[1] = REL_ULTRASLOW_IDX;
    p.name             = "Tau Inv Ultra-Slow";
    p.data             = tau_inv_ultraslow;
    p.dlgParamIndices  = &dlg_tau;
    /* Set run-time parameter information */
    if (!ssSetRunTimeParamInfo(S,3,&p)) return;


    /* Configure general run-time parameter information for booleans. */
    p.nDimensions      = 2;
    p.dimensions       = paramDims;
    p.dataTypeId       = SS_BOOLEAN;
    p.complexSignal    = COMPLEX_NO;
    p.dataAttributes   = NULL;
    p.nDlgParamIndices = 1;
    p.transformed      = RTPARAM_TRANSFORMED;
    p.outputAsMatrix   = false;
    
    /* Configure specific run-time parameter information. */
    dlg_bool[0] = MEMBRANE_EXPOSED_IDX;
    p.name             = "Membrane Exposed";
    p.data             = membrane_exposed;
    p.dlgParamIndices  = &dlg_bool;
    /* Set run-time parameter information */
    if (!ssSetRunTimeParamInfo(S,4,&p)) return;
    
    /* Configure specific run-time parameter information. */
    dlg_bool[0] = GFM_SOURCE_IDX;
    p.name             = "gfm External";
    p.data             = gfm_external;
    p.dlgParamIndices  = &dlg_bool;
    /* Set run-time parameter information */
    if (!ssSetRunTimeParamInfo(S,5,&p)) return;
    
    /* Configure specific run-time parameter information. */
    dlg_bool[0] = GSP_SOURCE_IDX;
    p.name             = "gsp External";
    p.data             = gsp_external;
    p.dlgParamIndices  = &dlg_bool;
    /* Set run-time parameter information */
    if (!ssSetRunTimeParamInfo(S,6,&p)) return;
    
    /* Configure specific run-time parameter information. */
    dlg_bool[0] = GSM_SOURCE_IDX;
    p.name             = "gsm External";
    p.data             = gsm_external;
    p.dlgParamIndices  = &dlg_bool;
    /* Set run-time parameter information */
    if (!ssSetRunTimeParamInfo(S,7,&p)) return;
    
    /* Configure specific run-time parameter information. */
    dlg_bool[0] = GUP_SOURCE_IDX;
    p.name             = "gup External";
    p.data             = gup_external;
    p.dlgParamIndices  = &dlg_bool;
    /* Set run-time parameter information */
    if (!ssSetRunTimeParamInfo(S,8,&p)) return;
    
    /* Configure specific run-time parameter information. */
    dlg_bool[0] = GUM_SOURCE_IDX;
    p.name             = "gum External";
    p.data             = gum_external;
    p.dlgParamIndices  = &dlg_bool;
    /* Set run-time parameter information */
    if (!ssSetRunTimeParamInfo(S,9,&p)) return;
}
#endif /* MDL_SET_WORK_WIDTHS */



#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ========================================
 * Abstract:
 *    Set the initial conditions to all V0
 */
static void mdlInitializeConditions(SimStruct *S)
{
    real_T *x0 = ssGetContStates(S);
    const real_T *V0 = mxGetDoubles(V0_PARAM(S));
    int_T nStates = ssGetNumContStates(S);
    int_T  i;
 
    for (i = 0; i < nStates; i++) {
        x0[i] = *V0;
    }
}



/* Function: mdlOutputs =======================================================
 * Abstract:
 *      y = Cx + Du
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    boolean_T *membrane_exposed  = (boolean_T *)((ssGetRunTimeParamInfo(S,4))->data);
    boolean_T         *event     = (boolean_T *) ssGetOutputPortSignal(S,0);
    real_T            *voltage;
    if (*membrane_exposed) {
                      voltage    = ssGetOutputPortRealSignal(S,1);
    }
    real_T            *x         = ssGetContStates(S);
    const real_T      *tresh     = mxGetDoubles(TRESH_PARAM(S));
 
    UNUSED_ARG(tid); /* not used in single tasking mode */

    /* Heavyside of voltage */
    *event = x[0] > *tresh;
    if (*membrane_exposed) {
        *voltage = x[0];
    }
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

#define MDL_DERIVATIVES
/* Function: mdlDerivatives =================================================
 * Abstract:
 *      xdot = Ax + Bu
 */
static void mdlDerivatives(SimStruct *S)
{
    real_T            *dx     = ssGetdX(S);
    real_T            *x      = ssGetContStates(S);

    /* Inputs */
    InputRealPtrsType Iapp_in   = ssGetInputPortRealSignalPtrs(S,0);
    InputRealPtrsType gfm_ext;
    InputRealPtrsType gsp_ext;
    InputRealPtrsType gsm_ext;
    InputRealPtrsType gup_ext;
    InputRealPtrsType gum_ext;

    /* Condition Input Booleans */
    boolean_T *gfm_external  = (boolean_T *)((ssGetRunTimeParamInfo(S,5))->data);
    boolean_T *gsp_external  = (boolean_T *)((ssGetRunTimeParamInfo(S,6))->data);
    boolean_T *gsm_external  = (boolean_T *)((ssGetRunTimeParamInfo(S,7))->data);
    boolean_T *gup_external  = (boolean_T *)((ssGetRunTimeParamInfo(S,8))->data);
    boolean_T *gum_external  = (boolean_T *)((ssGetRunTimeParamInfo(S,9))->data);

    real_T      gfm    = *mxGetDoubles(GFM_PARAM(S));
    real_T      gsp    = *mxGetDoubles(GSP_PARAM(S));
    real_T      gsm    = *mxGetDoubles(GSM_PARAM(S));
    real_T      gup    = *mxGetDoubles(GUP_PARAM(S));
    real_T      gum    = *mxGetDoubles(GUM_PARAM(S));

    const real_T      dfm    = *mxGetDoubles(DFM_PARAM(S));
    const real_T      dsp    = *mxGetDoubles(DSP_PARAM(S));
    const real_T      dsm    = *mxGetDoubles(DSM_PARAM(S));
    const real_T      dup    = *mxGetDoubles(DUP_PARAM(S));
    const real_T      dum    = *mxGetDoubles(DUM_PARAM(S));

    const real_T      mfm    = *mxGetDoubles(MFM_PARAM(S));
    const real_T      msp    = *mxGetDoubles(MSP_PARAM(S));
    const real_T      msm    = *mxGetDoubles(MSM_PARAM(S));
    const real_T      mup    = *mxGetDoubles(MUP_PARAM(S));
    const real_T      mum    = *mxGetDoubles(MUM_PARAM(S));

    real_T tau_inv_membrane  = *(real_T *)((ssGetRunTimeParamInfo(S,0))->data);
    real_T tau_inv_fast  = *(real_T *)((ssGetRunTimeParamInfo(S,1))->data);
    real_T tau_inv_slow  = *(real_T *)((ssGetRunTimeParamInfo(S,2))->data);
    real_T tau_inv_ultraslow  = *(real_T *)((ssGetRunTimeParamInfo(S,3))->data);

    const real_T      Iapp_base    = *mxGetDoubles(IAPP_BASE_PARAM(S));
    const real_T      V0           = *mxGetDoubles(V0_PARAM(S));

    real_T Vm = x[0];
    real_T Vf = x[1];
    real_T Vs = x[2];
    real_T Vu = x[3];
    real_T Iapp = *Iapp_in;
    
    int_T portNum = 1;
    if (*gfm_external) {
        gfm_ext = ssGetInputPortRealSignalPtrs(S,portNum);
        portNum += 1;
        gfm = *gfm_ext;
    }
    if (*gsp_external) {
        gsp_ext = ssGetInputPortRealSignalPtrs(S,portNum);
        portNum += 1;
        gsp = *gsp_ext;
    }
    if (*gsm_external) {
        gsm_ext = ssGetInputPortRealSignalPtrs(S,portNum);
        portNum += 1;
        gsm = *gsm_ext;
    }
    if (*gup_external) {
        gup_ext = ssGetInputPortRealSignalPtrs(S,portNum);
        portNum += 1;
        gup = *gup_ext;
    }
    if (*gum_external) {
        gum_ext = ssGetInputPortRealSignalPtrs(S,portNum);
        portNum += 1;
        gum = *gum_ext;
    }

    real_T Ifm = gfm*(fast_tanh(mfm*Vf - dfm) - fast_tanh(mfm*V0 - dfm));
    real_T Isp = gsp*(fast_tanh(msp*Vs - dsp) - fast_tanh(msp*V0 - dsp));
    real_T Ism = gsm*(fast_tanh(msm*Vs - dsm) - fast_tanh(msm*V0 - dsm));
    real_T Iup = gsp*(fast_tanh(mup*Vu - dup) - fast_tanh(mup*V0 - dup));
    real_T Ium = gsm*(fast_tanh(mum*Vu - dum) - fast_tanh(mum*V0 - dum));

    dx[0] = tau_inv_membrane * (V0 + Ifm - Isp + Ism - Iup + Ium + Iapp_base + Iapp - Vm);
    dx[1] = tau_inv_fast * (Vm - Vf);
    dx[2] = tau_inv_slow * (Vm - Vs);
    dx[3] = tau_inv_ultraslow * (Vm - Vu);
}
 
 
 
/* Function: mdlTerminate =====================================================
 * Abstract:
 *    Free the allocated run-time parameters.
 */
static void mdlTerminate(SimStruct *S)
{
    runtime_param_pack *runtime_params = ssGetUserData(S);
    free(runtime_params->tau_inv_membrane);
    free(runtime_params->tau_inv_fast);
    free(runtime_params->tau_inv_slow);
    free(runtime_params->tau_inv_ultraslow);
    free(runtime_params);
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
