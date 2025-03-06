/*******************************************************************
*  MBZIO = Massoud Babaie-Zadeh Input/Output                       *
*  IO routines, written by Massoud Babaie-Zadeh, to ease I/O with  *
*  DSK6416 board. In writing it, the Chassaing book has also been  *
*  used.                                                           *
*                                                                  *
*                                                                  *
*  Version 1.0                                                     *
*  Date: August 2019                                               *
*                                                                  *
*******************************************************************/

#ifndef MBZ_IO_
#define MBZ_IO_

/***************************************************************************/
#define CHIP_6416 1

#include <stdio.h>
#include <c6x.h>
#include <csl.h>
#include <csl_mcbsp.h>
#include <csl_irq.h>

#include "dsk6416.h"
#include "dsk6416_aic23.h"

/***************************************************************************/
// Define AIC23 data structure unioning a 32 bit "unsigned" variable with two 16 bit "signed" variables
#define LEFT  1
#define RIGHT 0   // Right is the least significant 16bit of the whole 32 bit. Unless 
                  // bit LRSWAP (Left/Right swap) of control register 7 if AIC23 is set, which is not
				  // the case in the default config (DSK6416_AIC23_DEFAULTCONFIG).

typedef union {
	Uint32 whole;
	Int16 channel[2];
	} AIC_IO_DataType; 

/***************************************************************************/
// Function declarations
void MBZIO_init(Uint32 sampling_frequency_value);  // the value of sampling frequnecy should be
                                                    // one of the following constants:
                                                    //    DSK6416_AIC23_FREQ_8KHZ
													//    DSK6416_AIC23_FREQ_16KHZ
													//    DSK6416_AIC23_FREQ_24KHZ
													//    DSK6416_AIC23_FREQ_32KHZ
													//    DSK6416_AIC23_FREQ_44KHZ
													//    DSK6416_AIC23_FREQ_48KHZ
													//    DSK6416_AIC23_FREQ_96KHZ

void MBZIO_close(void);

// faster read/write functions
Uint32 MBZIO_read_input_sample_raw32bit(void);
void MBZIO_write_output_sample_raw32bit(Uint32 output_value);

// easier (for user) read/write functions (but probably slower)
void MBZIO_read_input_sample_stereo(Int16* left_channel, Int16* right_channel);
Int16 MBZIO_read_input_sample_left_channel(void);
Int16 MBZIO_read_input_sample_right_channel(void);
void MBZIO_write_output_sample_stereo(Int16 left_channel_value, Int16 right_channel_value);


// Control functions
void MBZIO_set_inputsource_microphone(void);
void MBZIO_activate_microphone_boost(void);  // By default (DSK6416_AIC23_DEFAULTCONFIG), it is active. If active, microphone input before ADC is amplified by 20dB
void MBZIO_disactivate_microphone_boost(void);
void MBZIO_set_inputsource_linein(void);     // This is the default by DSK6416_AIC23_DEFAULTCONFIG

// To Do:
//unsigned char is_input_from_microphone(void);
//set_microphone_mute;
//adjust_LineIn_gain_amplifier_gain
//adjust_headphone_amplifier_gain

#endif
