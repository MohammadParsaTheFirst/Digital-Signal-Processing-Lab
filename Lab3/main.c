#include <stdio.h>
#include "MassoudBabaieZadeh_IO.h"
int FRAME_LEN = 16;
#define N 2000
#define L 10
//#define alpha 0
int i,j;
extern DSK6416_AIC23_CodecHandle hCodec;
int volumeGain=1;
int alpha=0;
short int avg_left, avg_right;
short int moving_avg(short int *arr, int l) {
	//short int temp[l];
	long long int sum =0;
	for (j=0;j< l;j++){
		sum += arr[j];
	}
	
	return (short int)(sum/l);
}


void hook_int(){
	IRQ_globalDisable();
	IRQ_nmiEnable();
	IRQ_map(IRQ_EVT_RINT2, 15);
	IRQ_enable(IRQ_EVT_RINT2);
	IRQ_globalEnable();
}

interrupt void serialPortRcvISR(){
	// reading the inputs
	short int buffer_right[N];
	short int buffer_left[N];
	short int win_buffer_right[L];
	short int win_buffer_left[L];
	Uint32 temp_right, temp_left, temp;
	DSK6416_AIC23_read(hCodec, &temp);
	temp_right = (temp * volumeGain) & 0xFFFF;
	temp_left = (temp * volumeGain) & 0xFFFF0000;
	temp_left = (temp_left >> FRAME_LEN);
	// moving avg logic
	for (i=L-1; i>0;i= i-1){
		win_buffer_left[i] = win_buffer_left[i-1];
		win_buffer_right[i] = win_buffer_right[i-1];
	}
	win_buffer_left[0] = (short int)temp_left;
	win_buffer_right[0] = (short int)temp_right;
	avg_left = moving_avg(win_buffer_left, L);
	avg_right = moving_avg(win_buffer_right, L);
	// echo logic
	for (i=N-1; i>0;i= i-1){
		buffer_left[i] = buffer_left[i-1];
		buffer_right[i] = buffer_right[i-1];
	}
	//buffer_left[0] = (short int)temp_left+(short int)(alpha*buffer_left[N-1]/10);
	//buffer_right[0] = (short int)temp_right+(short int)(alpha*buffer_right[N-1]/10);
	buffer_left[0] = (short int)avg_left+(short int)(alpha*buffer_left[N-1]/10);
	buffer_right[0] = (short int)avg_right+(short int)(alpha*buffer_right[N-1]/10);
	temp = ((Uint32) buffer_left[0] << FRAME_LEN) |  ((Uint32) buffer_right[0] & 0xFFFF); 
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


