#include "memory.h"
#include "Cpu.h"
#include "DMA1.h"
#include "Arbiter.h"
#include "PIC.h"
#include "FIR.h"

SC_MODULE(memoryTB)
{
	sc_signal<sc_logic, SC_MANY_WRITERS> cpu_req, cpu_gnt;
	sc_signal<sc_logic> dma_req, dma_gnt;
	sc_signal<sc_logic> clk,rst,out_fully, in_fully, out_complete;
	sc_signal<sc_lv<16>, SC_MANY_WRITERS> Addrbus;
	sc_signal<sc_lv<16>, SC_MANY_WRITERS> DataBus;
	sc_signal<sc_logic> w2dma,w2fir,interrupt;
	sc_signal<int> data2dma,add2dma,data2fir,add2fir,Ndata;


	Cpu* WR1;
	memoryUnit* MU1;
	DMA1* DM1;
	Arbiter *AR1;
	PIC *PI1;
	FIR *FIR1;

	SC_CTOR(memoryTB)
	{	
		
		FIR1 = new FIR("FIR");
		(*FIR1) (clk,rst,Addrbus, DataBus,Ndata,w2fir,data2fir,add2fir,w2dma,data2dma,add2dma);

		PI1 = new PIC("PI");
		(*PI1) (clk, rst, in_fully, out_fully, out_complete, Addrbus, DataBus, interrupt);

		AR1 = new Arbiter("AR");
		(*AR1) (clk,rst,cpu_req, dma_req, cpu_gnt, dma_gnt);

		WR1 = new Cpu("WR");
		(*WR1) (clk,rst,Addrbus,DataBus,interrupt,cpu_gnt,cpu_req);

		DM1 = new DMA1("DM");
		(*DM1) (clk,rst,Addrbus, DataBus,out_fully, in_fully, out_complete,dma_gnt,dma_req,w2dma,data2dma,add2dma,w2fir,data2fir,add2fir,Ndata);

		MU1 = new memoryUnit("memory");
		WR1->memWRSocket.bind(MU1->memSocket);
		DM1->dmaSocket.bind(MU1->dmaSocket);

		//SC_THREAD(inGenerating);
		SC_THREAD(clocking);
	}

	//void inGenerating();
	void clocking();
};

void memoryTB::clocking(){
	int i; 
	clk = sc_logic('1'); 
	for (i=0; i <=300; i++)   
	{
		clk = sc_logic('0');
		wait (1, SC_NS); 
		clk = sc_logic('1');
		wait (1, SC_NS); 
	}
}

// void memoryTB::inGenerating()
// {
// 	while (true)
// 	{	
// 		Addrbus = "0x0C01";	//add reg DMA
// 		DataBus = "0x0064"; //100
// 		wait(10, SC_NS);

// 		Addrbus = "0x0C02"; //num reg DMA
// 		DataBus = "0x0008"; 
// 		wait(100, SC_NS);

// 		Addrbus = "0x0C00"; //control reg DMA
// 		DataBus = "0x0005";
// 		wait(80, SC_NS);

		
		
// 		wait();
// 	}
// }
