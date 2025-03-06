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

#include "MassoudBabaieZadeh_IO.h"

/***************************************************************************/
// Global variables:
DSK6416_AIC23_CodecHandle hCodec;
AIC_IO_DataType AIC_Data_tempMBZ;  // MBZ = Massoud Babaie-Zadeh. This is a global variable

/***************************************************************************/
void MBZIO_init(Uint32 sampling_frequency_value){
	DSK6416_AIC23_Config config = DSK6416_AIC23_DEFAULTCONFIG; // Codec configuration with default settings

    hCodec = DSK6416_AIC23_openCodec(0, &config);

	MCBSP_FSETS(SPCR2, RINTM, FRM); // FSETS="Field Set Symbolic", SPCR="Serial Port Control Register", RINTM="Receive INTerrupt Mode", FRM="FRaMe"
	MCBSP_FSETS(SPCR2, XINTM, FRM);
	MCBSP_FSETS(RCR2, RWDLEN1, 32BIT);
	MCBSP_FSETS(XCR2, XWDLEN1, 32BIT);
         
	DSK6416_AIC23_setFreq(hCodec, sampling_frequency_value);
	
}

/***************************************************************************/
Uint32 MBZIO_read_input_sample_raw32bit(void){
	return MCBSP_read(DSK6416_AIC23_DATAHANDLE);
}

/***************************************************************************/
void MBZIO_write_output_sample_raw32bit(Uint32 output_value){
	MCBSP_write(DSK6416_AIC23_DATAHANDLE, output_value);
}

/***************************************************************************/
void MBZIO_close(void){
	DSK6416_AIC23_closeCodec(hCodec);	    // Close the codec
}

/***************************************************************************/
void MBZIO_read_input_sample_stereo(Int16* left_channel, Int16* right_channel){

	AIC_Data_tempMBZ.whole = MCBSP_read(DSK6416_AIC23_DATAHANDLE);
	*left_channel = AIC_Data_tempMBZ.channel[LEFT];
	*right_channel = AIC_Data_tempMBZ.channel[RIGHT];
}

/***************************************************************************/
Int16 MBZIO_read_input_sample_left_channel(void){

	AIC_Data_tempMBZ.whole = MCBSP_read(DSK6416_AIC23_DATAHANDLE);
	return AIC_Data_tempMBZ.channel[LEFT];
}

/***************************************************************************/
Int16 MBZIO_read_input_sample_right_channel(void){

	AIC_Data_tempMBZ.whole = MCBSP_read(DSK6416_AIC23_DATAHANDLE);
	return AIC_Data_tempMBZ.channel[RIGHT];
}

/***************************************************************************/
void MBZIO_write_output_sample_stereo(Int16 left_channel_value, Int16 right_channel_value){

	AIC_Data_tempMBZ.channel[LEFT] = left_channel_value;
	AIC_Data_tempMBZ.channel[RIGHT] = right_channel_value;
	MCBSP_write(DSK6416_AIC23_DATAHANDLE, AIC_Data_tempMBZ.whole);
}

/***************************************************************************/
void MBZIO_set_inputsource_microphone(void){
	// Bit 2 of register number 4 of AIC23 should be set equal to 1 (see 
	// page 3-3 of AIC23 datasheet, that is, page 22 of the pdf file "tlv320aic32b.pdf")

	DSK6416_AIC23_rset(hCodec, 4, 0x0004 | DSK6416_AIC23_rget(hCodec, 4));
}

/***************************************************************************/
void MBZIO_activate_microphone_boost(void){
	// By default (DSK6416_AIC23_DEFAULTCONFIG), it is active. If active, microphone input 
	// before ADC is amplified by 20dB. To activate, 
	// Bit 0 of register number 4 of AIC23 should be set equal to 1 (see 
	// page 3-3 of AIC23 datasheet, that is, page 22 of the pdf file "tlv320aic32b.pdf")

	DSK6416_AIC23_rset(hCodec, 4, 0x0001 | DSK6416_AIC23_rget(hCodec, 4));

}

/***************************************************************************/
void MBZIO_disactivate_microphone_boost(void){
	// By default (DSK6416_AIC23_DEFAULTCONFIG), it is active. If active, microphone input 
	// before ADC is amplified by 20dB. To disactivate, 
	// Bit 0 of register number 4 of AIC23 should be set equal to 0 (see 
	// page 3-3 of AIC23 datasheet, that is, page 22 of the pdf file "tlv320aic32b.pdf")

	DSK6416_AIC23_rset(hCodec, 4, 0xfffe & DSK6416_AIC23_rget(hCodec, 4));

	// Microphone can also be muted by bit 1 of the same register, but I did not write the function.

}

/***************************************************************************/
void MBZIO_set_inputsource_linein(void){
	// Bit 2 of register number 4 of AIC23 should be set equal to 0 (see 
	// page 3-3 of AIC23 datasheet, that is, page 22 of the pdf file "tlv320aic32b.pdf")

	DSK6416_AIC23_rset(hCodec, 4, 0xfffb & DSK6416_AIC23_rget(hCodec, 4));
}


/***************************************************************************/
/***************************************************************************/

/***************************************************************************/

/***************************************************************************/

/***************************************************************************/

