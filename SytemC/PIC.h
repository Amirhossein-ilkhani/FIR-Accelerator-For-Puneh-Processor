#include <iostream>
#include <systemc.h>

#define ADDLOGIC "0x0c05"
#define IR1ISR "0x0900"
#define IR2ISR "0x0910"
#define IR3ISR "0x0920"

SC_MODULE(PIC)
{
	sc_in<sc_logic> clk,rst,infully, outfully, out_complete;
	sc_in<sc_lv<16>> AddrBus;

	sc_out<sc_lv<16>> DataBus;
	sc_out<sc_logic> interrupt;


	SC_CTOR(PIC)
	{

		SC_THREAD(operation)
			//sensitive<<clk.pos();
			sensitive << AddrBus << infully << outfully << out_complete;
	}
	void operation();
};

void PIC::operation()
{
	while (true)
	{
			if(infully == '1'){
				interrupt = SC_LOGIC_1;	
				if (AddrBus->read() == "0x0c05")
					DataBus = IR1ISR;
			}
			else if(outfully == '1'){
				interrupt = SC_LOGIC_1;
				if (AddrBus->read() == "0x0c05")
					DataBus = IR2ISR;
			}
			else if(out_complete == '1'){
				interrupt = SC_LOGIC_1;
				if (AddrBus->read() == "0x0c05")
					DataBus = IR3ISR;
			}
			else{
				interrupt = SC_LOGIC_0;
				//DataBus = "0x0000";
			}
		wait();
	}
}