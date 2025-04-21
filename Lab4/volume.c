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
#define CHIP_6416
#include <stdio.h>
#include "dsk6416.h"
#include "volume.h"

/* Global declarations */
int inp_buffer[BUFSIZE];       /* processing data buffers */
int out_buffer[BUFSIZE];
int index;
char v[20];
int j;
float c;
int flag;
float chunk_energy[20];
float frame_energy;
long long int tot_energy;
int gain = MINGAIN;                      /* volume control variable */
unsigned int processingLoad = BASELOAD;  /* processing routine load value */



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

static int processing(int *input, int *output);
static void dataIO(void);

float calc_avg_energy(int* x, int len){
long long int energy = 0;
int i=0;
	for(; i<len;i++){
		energy += x[i]*x[i];
	}
	return ((float)(energy)/((float)len));
}
/*
 * ======== main ========
 */
void main()
{
	DSK6416_LED_off(1);
	DSK6416_LED_off(0);
	DSK6416_LED_off(3);
	DSK6416_LED_off(2);
	flag = 0;
	index = 0;
	c = 1.8;
	for(j=0;j<20;j++){
		chunk_energy[j]=0;
	}
	//chunk_energy = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
	DSK6416_init();
	DSK6416_LED_init();
 //   int *input = &inp_buffer[0];
  //  int *output = &out_buffer[0];
	
    puts("volume example started\n");


    /* loop forever */
    while(TRUE)
    {       
        /* 
         *  Read input data using a probe-point connected to a host file. 
         *  Write output data to a graph connected through a probe-point.
         */
		
		//DSK6416_LED_on(0);
        dataIO();

        #ifdef FILEIO
        puts("begin processing");        /* deliberate syntax error */
        #endif
        
        /* apply gain */
        processing(inp_buffer, out_buffer);
		if(flag==1){
			long long int count = 0;
			for(;count<10000;count++){
				DSK6416_LED_on(1);
			}
		}
		DSK6416_LED_off(1);
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
    int size = BUFSIZE;

    //while(size--){
    //    *output++ = *input++ * gain;
    //}
    float mean_energy = calc_avg_energy(input, size);
	chunk_energy[index] = mean_energy;
	index++;
	index %= 20;
	tot_energy = 0;
	
	for(j=0; j<20;j++){
		tot_energy += chunk_energy[j];
	}
	frame_energy = ((float)(tot_energy))/20;
    /* additional processing load */
    //load(processingLoad);

    if(mean_energy - frame_energy*c >= 0){
		flag = 1;
	}
	else flag=0;
	sprintf(v, "%f", mean_energy);
	puts(v);
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

