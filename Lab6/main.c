#include <stdio.h>
#include "MassoudBabaieZadeh_IO.h"
int FRAME_LEN = 100;
#define N 100
#define L 100
#include "volume.h"
#define CHIP_6416
#include <math.h>


double Fs = 8000;
double pi = 3.1415926;
int index;
int counter;
double freqs_hor[] = {1209, 1336, 1477};
double freqs_ver[] = {697, 770 , 852, 941};
double THR = 1;
int i,j;
extern DSK6416_AIC23_CodecHandle hCodec;
int volumeGain=1;
int alpha=0;
short int avg_left, avg_right;



void LED(int i , int j){
	index = i + 3*j + 1;
	if (index%2==1){
		DSK6416_LED_on(0);
	} if (index >=8){
		DSK6416_LED_on(3);
		index -= 8;
	} if (index>=4) {
		DSK6416_LED_on(2);
		index -= 4;
	} if (index>=2) {
		DSK6416_LED_on(1);
		index -= 2;
	}
	return;
}

double max(double x, double y) {
	if (x<y ) {
		return y;
	} else {
		return x;
	}
}

double max_inner_prod(short int*x, int l, double fc) {
	double sum1=0, sum2=0;
	int i=0;
	for (i=0; i < l ; i ++) {
		sum1 += sin(2*pi*fc*i/Fs)*((double)x[i])/1000;
		sum2 += cos(2*pi*fc*i/Fs)*((double)x[i])/1000;
	}
	return max(abs(sum1), abs(sum2));
}


static int processing(short int *input)
{
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

	// thresholding
	if ((max1>THR) && (max2 > THR)) {
		LED(index1, index2);
	} else {
		DSK6416_LED_off(1);
		DSK6416_LED_off(0);
		DSK6416_LED_off(3);
		DSK6416_LED_off(2);
	}


    return(TRUE);
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
	Uint32 temp_right, temp;
	DSK6416_AIC23_read(hCodec, &temp);
	temp_right = (temp * volumeGain) & 0xFFFF;
	// update frame 
	for (i=N-1; i>0;i= i-1){
		buffer_right[i] = buffer_right[i-1];
	}
	// update buffer
	buffer_right[0] = (short int)temp_right; 
	counter += 1;
	if(counter == L){
		counter = 0;
		processing(buffer_right);
	}
	

	
}

int main(){
	MBZIO_init(DSK6416_AIC23_FREQ_8KHZ);
	MBZIO_set_inputsource_microphone();
	counter = 0;
	//volumeGain=3;
	
	hook_int();
	while(1){
	
	}
}


