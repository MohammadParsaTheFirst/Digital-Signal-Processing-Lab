//#include <studio.h>
#include "MassoudBabaieZadeh_IO.h"
extern DSK6416_AIC23_CodecHandle hCodec;
int volumeGain;
void hook_int(){
	IRQ_globalDisable();
	IRQ_nmiEnable();
	IRQ_map(IRQ_EVT_RINT2, 15);
	IRQ_enable(IRQ_EVT_RINT2);
	IRQ_globalEnable();
}

interrupt void serialPortRcvISR(){
	Uint32 temp;
	DSK6416_AIC23_read(hCodec, &temp);
	temp = (temp * volumeGain); //& 0xFFFE;
	DSK6416_AIC23_write(hCodec, temp);
}

int main(){
	MBZIO_init(DSK6416_AIC23_FREQ_8KHZ);
	MBZIO_set_inputsource_microphone();
	//volumeGain=3;
	
	hook_int();
	while(1){
	
	}
}


