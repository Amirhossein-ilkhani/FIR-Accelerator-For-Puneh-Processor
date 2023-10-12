/*
#include "PICTB.h"

int sc_main(int argc, char* argv[])
{
	PICTB* TOP = new PICTB("PICTB_Instance");

	sc_trace_file* VCDFile;
	VCDFile = sc_create_vcd_trace_file("PIC_VCD1");

	sc_trace(VCDFile, TOP->infully, "infully");
	sc_trace(VCDFile, TOP->outfully, "outfully");
	sc_trace(VCDFile, TOP->out_complete, "out_complete");
	sc_trace(VCDFile, TOP->AddrBus, "AddrBus");
	sc_trace(VCDFile, TOP->DataBus, "DataBus");
	sc_trace(VCDFile, TOP->interrupt, "interrupt");
	

	sc_start(2000, SC_NS);
	return 0;
}
*/



// #include "ArbiterTB.h"

// int sc_main(int argc, char* argv[])
// {
// 	ArbiterTB* TOP = new ArbiterTB("ArbiterTB_Instance");

// 	sc_trace_file* VCDFile;
// 	VCDFile = sc_create_vcd_trace_file("Arbiter_VCD");

// 	sc_trace(VCDFile, TOP->clk, "clk");
// 	sc_trace(VCDFile, TOP->cpu_req, "cpu_req");
// 	sc_trace(VCDFile, TOP->dma_req, "dma_req");
// 	sc_trace(VCDFile, TOP->cpu_gnt, "cpu_gnt");
// 	sc_trace(VCDFile, TOP->dma_gnt, "dma_gnt");

// 	sc_start(500, SC_NS);
// 	return 0;
// }






/*
#include "DMATB.h"

int sc_main(int argc, char* argv[])
{
	DMATB* TOP = new DMATB("DMATB_Instance");

	sc_trace_file* VCDFile;
	VCDFile = sc_create_vcd_trace_file("DMA_VCD");

	sc_trace(VCDFile, TOP->Addrbus, "Addrbus");
	sc_trace(VCDFile, TOP->DataBus, "DataBus");
	sc_trace(VCDFile, TOP->out_fully, "out_fully");
	sc_trace(VCDFile, TOP->in_fully, "out_complete");
	sc_trace(VCDFile, TOP->in_fully, "out_complete");

	sc_start(2000, SC_NS);
	return 0;
}
*/


#include "memoryTB.h"

int sc_main(int argc, char* argv[])
{
	memoryTB* TB1 = new memoryTB("memoryTB_inst");

	sc_trace_file* VCDFile;
	VCDFile = sc_create_vcd_trace_file("memory_VCD");

	sc_trace(VCDFile, TB1->clk, "clk");
	sc_trace(VCDFile, TB1->cpu_req, "cpu_req");
	sc_trace(VCDFile, TB1->cpu_gnt, "cpu_gnt");
	sc_trace(VCDFile, TB1->dma_req, "dma_req");
	sc_trace(VCDFile, TB1->dma_gnt, "dma_gnt");
	sc_trace(VCDFile, TB1->Addrbus, "Addrbus");
	sc_trace(VCDFile, TB1->DataBus, "DataBus");
	sc_trace(VCDFile, TB1->out_fully, "out_fully");
	sc_trace(VCDFile, TB1->in_fully, "in_fully");
	sc_trace(VCDFile, TB1->out_complete, "out_complete");
	sc_trace(VCDFile, TB1->interrupt, "interrupt");
	
	//DMA internal
	sc_trace(VCDFile, TB1->DM1->addr_reg, "addr_reg");
	sc_trace(VCDFile, TB1->DM1->number_reg, "number_reg");
	sc_trace(VCDFile, TB1->DM1->control_reg, "control_reg");
	sc_trace(VCDFile, TB1->DM1->read_flag, "read_flag");
	
	//signal between DMA and FIR
	sc_trace(VCDFile, TB1->w2fir, "w2fir");
	sc_trace(VCDFile, TB1->data2fir, "data2fir");
	sc_trace(VCDFile, TB1->add2fir, "add2fir");
	sc_trace(VCDFile, TB1->w2dma, "w2dma");
	sc_trace(VCDFile, TB1->data2dma, "data2dma");
	sc_trace(VCDFile, TB1->add2dma, "add2dma");

	//FIR internal
	sc_trace(VCDFile, TB1->FIR1->start, "start");



	sc_start(2000, SC_NS);
	return 0;
}
