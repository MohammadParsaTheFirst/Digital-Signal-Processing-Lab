; vectors.asm
	.ref  _c_int00
	.ref  _serialPortRcvISR ; refer the addr of ISR defined in C code
	.sect  "vectors"

RESET_RST:  MVKL  .S2 _c_int00, B0
			    MVKH  .S2 _c_int00, B0
				B     .S2 B0
				NOP
				NOP
				NOP
				NOP
				NOP
NMI_RST:   .loop 8
				NOP
			   .endloop
RESV1:     .loop 8
				NOP
			    .endloop
RESV2:     .loop 8
				NOP
			    .endloop
INT4:      .loop 8
				NOP
				.endloop
INT5:      .loop 8
				NOP
				.endloop
INT6:      .loop 8
				NOP
				.endloop
INT7:      .loop 8
				NOP
				.endloop
INT8: .loop 8
				NOP
				.endloop
INT9: .loop 8
				NOP
				.endloop
INT10: .loop 8
				NOP
				.endloop
INT11: .loop 8
				NOP
				.endloop
INT12: .loop 8
				NOP
				.endloop
INT13: .loop 8
				NOP
				.endloop
INT14: .loop 8
				NOP
				.endloop
INT15: MVKL .S2 _serialPortRcvISR, B0
				MVKH .S2 _serialPortRcvISR, B0
				B .S2 B0 ;branch to ISR
				NOP
				NOP
				NOP
				NOP
				NOP