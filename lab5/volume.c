/*
 *  Copyright 2003 by Texas Instruments Incorporated.
 *  All rights reserved. Property of Texas Instruments Incorporated.
 *  Restricted rights to use, duplicate or disclose this code are
 *  granted through contract.
 *  
 */
/* "@(#) DSP/BIOS 4.90.270 01-13-05 (barracuda-o07)" */
/***************************************************************************/
/*                                                                         */
/*     V O L U M E . C                                                     */
/*                                                                         */
/*     Audio gain processing in a main loop                                */
/*                                                                         */
/***************************************************************************/

#include <stdio.h>

#include "volume.h"

#include <math.h>
#define CHIP_6416
#include "dsk6416.h"
/* Global declarations */
int inp_buffer[BUFSIZE];       /* processing data buffers */
int out_buffer[BUFSIZE];
double pi = 3.1415926;
char v[20];
double THR = 40000;
double Fs = 8000;
int index;
int gain = MINGAIN;                      /* volume control variable */
unsigned int processingLoad = BASELOAD;  /* processing routine load value */
double freqs_hor[] = {1209, 1336, 1477};
double freqs_ver[] = {697, 770 , 852, 941};



struct PARMS str =
{
    2934,
    9432,
    213,
    9432,
    &str
};

/* Functions */
extern void load(unsigned int loadValue);
void LED(int i , int j){

	
	index = i + 3*j + 1;
	/*
	DSK6416_LED_off(1);
	DSK6416_LED_off(0);
	DSK6416_LED_off(3);
	DSK6416_LED_off(2);
	*/
	//sprintf(v, "%f", index);
	//puts(v);
	if (index%2==1){
		DSK6416_LED_on(0);
	}
	if (index >=8){
		DSK6416_LED_on(3);
		index -= 8;
	}
	if (index>=4) {
		DSK6416_LED_on(2);
		index -= 4;
	}
	if (index>=2) {
		DSK6416_LED_on(1);
		index -= 2;
	}
	return;

}
static int processing(int *input, int *output);
static void dataIO(void);


double max(double x, double y) {
if (x<y ) {
	return y;
} else {
	return x;}

}

double max_inner_prod(int*x, int l, double fc) {
double sum1=0, sum2=0;
int i=0;
	for (i=0; i < l ; i ++) {
		sum1 += sin(2*pi*fc*i/Fs)*((double)x[i])/10000;
		sum2 += cos(2*pi*fc*i/Fs)*((double)x[i])/10000;
	}
	
	return max(abs(sum1), abs(sum2));
}
/*
 * ======== main ========
 */
void main()
{
    int *input = &inp_buffer[0];
    int *output = &out_buffer[0];
	DSK6416_init();
	DSK6416_LED_init();

    puts("volume example started\n");


    /* loop forever */
    while(TRUE)
    {       
        /* 
         *  Read input data using a probe-point connected to a host file. 
         *  Write output data to a graph connected through a probe-point.
         */
        dataIO();

        #ifdef FILEIO
        puts("begin processing");        /* deliberate syntax error */
        #endif
        
        /* apply gain */
        processing(input, output);
    }
}

/*
 *  ======== processing ========
 *
 * FUNCTION: apply signal processing transform to input signal.
 *
 * PARAMETERS: address of input and output buffers.
 *
 * RETURN VALUE: TRUE.
 */
static int processing(int *input, int *output)
{
   // int size = BUFSIZE;
/*
    while(size--){
        *output++ = *input++ * gain;
    }
    
   
    load(processingLoad);*/
	int index1=0, index2=0;
	int i=0, j=0;
	double corr = 0, max1= 0, max2 =0 ;
    for (i=0;i<3;i++){
    	corr = max_inner_prod(input, BUFSIZE, freqs_hor[i]);
		if(corr> max1) {
			index1 = i;
			max1 = corr;
		}
    } 
	corr = 0;
	for (; j<4; j++){
		corr = max_inner_prod(input, BUFSIZE, freqs_ver[j]);
		if(corr> max2) {
			index2 = j;
			max2 = corr;
		}
	}

	// thr
	
	if ((max1>THR) && (max2 > THR)) {
		LED(index1, index2);

	}
	else {
		DSK6416_LED_off(1);
		DSK6416_LED_off(0);
		DSK6416_LED_off(3);
		DSK6416_LED_off(2);
		//puts("nashod");
	}


    return(TRUE);
}

/*
 *  ======== dataIO ========
 *
 * FUNCTION: read input signal and write processed output signal.
 *
 * PARAMETERS: none.
 *
 * RETURN VALUE: none.
 */

static void dataIO()
{
    /* do data I/O */

    return;
}

