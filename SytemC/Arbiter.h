#include <iostream>
#include <systemc.h>

SC_MODULE(Arbiter)
{	
	sc_in<sc_logic> clk, rst;
	sc_in<sc_logic> cpu_req, dma_req;
	sc_out<sc_logic> cpu_gnt, dma_gnt;


	SC_CTOR(Arbiter)
	{

		SC_THREAD(operation)
			sensitive << dma_req<<cpu_req;
	}
	void operation();
};

void Arbiter::operation()
{	
	int dma_en = 0;
	int cpu_en = 0;
	while (true)
	{	
		
		if(dma_req == '0'){
			dma_gnt = sc_logic_0;
			dma_en = 0;
		}

		if(cpu_req == '0'){
			cpu_gnt = sc_logic_0;
			cpu_en = 0;
		}

		if(dma_req == '1'){
			if(cpu_en == 0){
				dma_gnt = sc_logic_1;
				dma_en = 1;
			}
			else{ 
				dma_gnt = sc_logic_0;
				dma_en = 0;
			}
		}
		
		if(cpu_req == '1'){
			if(dma_en == 0){
				cpu_gnt = sc_logic_1;
				cpu_en = 1;
			}
			else{
				cpu_gnt = sc_logic_0;
				cpu_en = 0;
			}
		}
		
		wait();
	}
}
