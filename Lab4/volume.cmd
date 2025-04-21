/*
 *  Copyright 2012 by Texas Instruments Incorporated.
 *  All rights reserved. Property of Texas Instruments Incorporated.
 *  Restricted rights to use, duplicate or disclose this code are
 *  granted through contract.
 */
/*
 *  ======== volume.cmd ========
 *
 */

--heap 0x2ff
--stack 0x2ff

MEMORY 
{
   ISRAM       : origin = 0x0,         len = 0x100000
}

SECTIONS
{
        .vectors > ISRAM
        .text    > ISRAM

        .bss     > ISRAM
        .cinit   > ISRAM
        .const   > ISRAM
        .far     > ISRAM
        .stack   > ISRAM
        .cio     > ISRAM
        .sysmem  > ISRAM
}
