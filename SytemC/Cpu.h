#include <systemc.h>

#include "tlm.h"
#include "tlm_utils/simple_initiator_socket.h"
#include "tlm_utils/simple_target_socket.h"

class Cpu : public sc_module {
public:

	sc_in<sc_logic> clk,rst;
	sc_out<sc_lv<16>> Addrbus;
	sc_inout<sc_lv<16>> DataBus;
	sc_in<sc_logic> interrupt,cpu_gnt;
	sc_out<sc_logic> cpu_req;


	sc_signal<sc_lv<16>> coeffAddres;


	tlm_utils::simple_initiator_socket<Cpu, 32> memWRSocket;
	
	SC_CTOR(Cpu) : memWRSocket("mem_WR_socket"), nBlockWriteRead(0)
	{	
		coeffAddres = "0x0B00";
		nBlockWriteRead = new tlm::tlm_generic_payload();

		SC_THREAD(program);

		SC_THREAD(isr);
		 	sensitive << interrupt.pos(); 
		

	}

	tlm::tlm_generic_payload* nBlockWriteRead;
	void program();
	void isr();
	int memread(int);
	void memwrite(int,int *);
	void doSomethingGood(tlm::tlm_generic_payload&, sc_time);

	int data[1];
};




int Cpu::memread(int Add)
{	
	
	tlm::tlm_phase forwardPhase;
	sc_time processTime; // Processing time of initiator prior to call

	// cpu_req = sc_logic_1;
	// wait(cpu_gnt->posedge_event());
	// wait(clk->posedge_event());//read gnt
	
	processTime = sc_time(0, SC_PS);

		tlm::tlm_command cmd = tlm::TLM_READ_COMMAND;

		nBlockWriteRead->set_command(cmd);
		nBlockWriteRead->set_address(Add);
		nBlockWriteRead->set_data_ptr((unsigned char*)data);
		nBlockWriteRead->set_data_length(1);
		nBlockWriteRead->set_streaming_width(1);
		nBlockWriteRead->set_byte_enable_ptr(0);
		nBlockWriteRead->set_dmi_allowed(false);
		nBlockWriteRead->set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);

		forwardPhase = tlm::BEGIN_REQ;

		cout << "CPU side  " << (cmd ? 'W' : 'R') << ", @" << Add << " data:";
		sc_lv<8> vv;
		// for (int j = 0; j < 5; j++) { vv = data[j]; cout << vv << " "; }
		cout << data[0] << " ";
		cout << " @time " << sc_time_stamp() << " delay=" << processTime << '\n';

		tlm::tlm_sync_enum returnStatus;
		returnStatus = memWRSocket->
			nb_transport_fw(*nBlockWriteRead, forwardPhase, processTime);

		int* ptr = reinterpret_cast<int*>(nBlockWriteRead->get_data_ptr());
        cout<< "readData ="<<(*ptr)<<endl;
		// if (returnStatus == tlm::TLM_COMPLETED)
		// 	doSomethingGood(*nBlockWriteRead, processTime);

		// cpu_req = sc_logic_0;
		// wait(clk->posedge_event());
		return (*ptr);
	}





void Cpu::memwrite(int Add,int *putdata)
{	
	
	tlm::tlm_phase forwardPhase;
	sc_time processTime; // Processing time of initiator prior to call

	cpu_req = sc_logic_1;
	wait(cpu_gnt->posedge_event());
	wait(clk->posedge_event());//fetch
	
	processTime = sc_time(0, SC_PS);

		tlm::tlm_command cmd = tlm::TLM_WRITE_COMMAND;

		nBlockWriteRead->set_command(cmd);
		nBlockWriteRead->set_address(Add);
		nBlockWriteRead->set_data_ptr((unsigned char*)putdata);
		nBlockWriteRead->set_data_length(1);
		nBlockWriteRead->set_streaming_width(1);
		nBlockWriteRead->set_byte_enable_ptr(0);
		nBlockWriteRead->set_dmi_allowed(false);
		nBlockWriteRead->set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);

		forwardPhase = tlm::BEGIN_REQ;

		cout << "CPU side  " << (cmd ? 'W' : 'R') << ", @" << Add << " data:";
		sc_lv<8> vv;
		// for (int j = 0; j < 5; j++) { vv = data[j]; cout << vv << " "; }
		cout << putdata << " ";
		cout << " @time " << sc_time_stamp() << " delay=" << processTime << '\n';

		tlm::tlm_sync_enum returnStatus;
		returnStatus = memWRSocket->
			nb_transport_fw(*nBlockWriteRead, forwardPhase, processTime);

		// int* ptr = reinterpret_cast<int*>(nBlockWriteRead->get_data_ptr());
        // cout<< "readData ="<<(*ptr)<<endl;
		// if (returnStatus == tlm::TLM_COMPLETED)
		// 	doSomethingGood(*nBlockWriteRead, processTime);

		cpu_req = sc_logic_0;
		wait(clk->posedge_event());
	}




void Cpu::doSomethingGood(tlm::tlm_generic_payload& completeTrans,
	sc_time totalTime)
{	
	int rdata[1];
	if (completeTrans.is_response_error())
		SC_REPORT_ERROR("TLM-2", "error...\n");

	tlm::tlm_command cmd = completeTrans.get_command();
	uint64           adr = completeTrans.get_address();
	int* ptr = reinterpret_cast<int*>(completeTrans.get_data_ptr());
	cout << "Above was completed @time " << totalTime << '\n';
	cout<< "readdata=" << (*ptr)<<endl<<endl;
}



void Cpu::program()
{	
	int temp[1]; 
		wait(clk->posedge_event());
		//read coefficients from memory[450:465] and write in coefficients register in fir
		for(int i = 450; i < 466; i++){
			
			cpu_req = sc_logic_1;
			wait(cpu_gnt->posedge_event());
			wait(clk->posedge_event());//read gnt
			wait(clk->posedge_event());//fetch
			cpu_req = sc_logic_1;
			wait(clk->posedge_event());//instruction
			temp[0] = memread(i);
			cpu_req = sc_logic_0;
			wait(clk->posedge_event());


			cpu_req = sc_logic_1;
			wait(cpu_gnt->posedge_event());
			wait(clk->posedge_event());//read gnt
			wait(clk->posedge_event());//fetch
			Addrbus = sc_lv<16>(coeffAddres.read().to_uint() + (i-450));
			DataBus = sc_lv<16>(temp[0]);
			cpu_req = sc_logic_1;
			wait(clk->posedge_event());//instruction
			cpu_req = sc_logic_0;
			Addrbus = "xxxxxxxxxxxxxxxx";
			DataBus = "xxxxxxxxxxxxxxxx";
			wait(clk->posedge_event());
		}
		

		cpu_req = sc_logic_1;
		wait(cpu_gnt->posedge_event());
		wait(clk->posedge_event());//read gnt
		wait(clk->posedge_event());//fetch
		Addrbus = "0x0C01";	//add reg DMA
 		DataBus = "0x0064"; //100
		cpu_req = sc_logic_1;
		wait(clk->posedge_event());//instruction
		cpu_req = sc_logic_0;
		Addrbus = "xxxxxxxxxxxxxxxx";
		DataBus = "xxxxxxxxxxxxxxxx";
		wait(clk->posedge_event());

		cpu_req = sc_logic_1;
		wait(cpu_gnt->posedge_event());
		wait(clk->posedge_event());//read gnt
		wait(clk->posedge_event());//fetch
		Addrbus = "0x0C02";	//num reg DMA
 		DataBus = "0x0008"; //100
		cpu_req = sc_logic_1;
		wait(clk->posedge_event());//instruction
		cpu_req = sc_logic_0;
		Addrbus = "xxxxxxxxxxxxxxxx";
		DataBus = "xxxxxxxxxxxxxxxx";
		wait(clk->posedge_event());



		cpu_req = sc_logic_1;
		wait(cpu_gnt->posedge_event());
		wait(clk->posedge_event());//read gnt
		wait(clk->posedge_event());//fetch
		Addrbus = "0x0C00";	//control reg DMA
 		DataBus = "0x0003"; //100
		cpu_req = sc_logic_1;
		wait(clk->posedge_event());//instruction
		cpu_req = sc_logic_0;
		Addrbus = "xxxxxxxxxxxxxxxx";
		DataBus = "xxxxxxxxxxxxxxxx";
		wait(clk->posedge_event());




}




void Cpu::isr()
{	
	while (true)
	{   

		if(interrupt == '1'){
			
			cout<< "interrupt was recieved@"<<sc_time_stamp()<< endl;
			
			cpu_req = sc_logic_1;
			wait(cpu_gnt->posedge_event());
			wait(clk->posedge_event());//read gnt
			wait(clk->posedge_event());//fetch
			Addrbus = "0x0C05";	//PIC REG
			DataBus = "0x0000"; //
			cpu_req = sc_logic_1;
			wait(clk->posedge_event());//instruction
			cpu_req = sc_logic_0;
			wait(clk->posedge_event());

			if(DataBus->read() == "0x0900"){
				cout<< "in_fully was recieved@"<<sc_time_stamp()<< endl;
				cpu_req = sc_logic_1;
				wait(cpu_gnt->posedge_event());
				wait(clk->posedge_event());//read gnt
				Addrbus = "0x0C06";
				cpu_req = sc_logic_1;
				wait(clk->posedge_event());//instruction
				cpu_req = sc_logic_0;
				Addrbus = "xxxxxxxxxxxxxxxx";
				DataBus = "xxxxxxxxxxxxxxxx";
				wait(clk->posedge_event());
				

				cpu_req = sc_logic_1;
				wait(cpu_gnt->posedge_event());
				wait(clk->posedge_event());//read gnt
				Addrbus = "0x0C00";
				DataBus = "0x0000";
				cpu_req = sc_logic_1;
				wait(clk->posedge_event());//instruction
				cpu_req = sc_logic_0;
				Addrbus = "xxxxxxxxxxxxxxxx";
				DataBus = "xxxxxxxxxxxxxxxx";
				wait(clk->posedge_event());
			}


			else if(DataBus->read() == "0x0910"){
				cout<< "out_fully was recieved@"<<sc_time_stamp()<< endl;

				cpu_req = sc_logic_1;
				wait(cpu_gnt->posedge_event());
				wait(clk->posedge_event());//read gnt
				Addrbus = "0x0C01";	// add reg DMA
 				DataBus = "0x012C"; //300
				cpu_req = sc_logic_1;
				wait(clk->posedge_event());//instruction
				cpu_req = sc_logic_0;
				Addrbus = "xxxxxxxxxxxxxxxx";
				DataBus = "xxxxxxxxxxxxxxxx";
				wait(clk->posedge_event());

				cpu_req = sc_logic_1;
				wait(cpu_gnt->posedge_event());
				wait(clk->posedge_event());//read gnt
				Addrbus = "0x0C00";	// contrp reg DMA
 				DataBus = "0x0005"; //5
				cpu_req = sc_logic_1;
				wait(clk->posedge_event());//instruction
				cpu_req = sc_logic_0;
				Addrbus = "xxxxxxxxxxxxxxxx";
				DataBus = "xxxxxxxxxxxxxxxx";
				wait(clk->posedge_event());

			}




			else if(DataBus->read() == "0x0920"){
				cout<< "out_complete was recieved@"<<sc_time_stamp()<< endl;

				cpu_req = sc_logic_1;
				wait(cpu_gnt->posedge_event());
				wait(clk->posedge_event());//read gnt
				Addrbus = "0x0C00";	// contrp reg DMA
 				DataBus = "0x0000"; //0
				cpu_req = sc_logic_1;
				wait(clk->posedge_event());//instruction
				cpu_req = sc_logic_0;
				Addrbus = "xxxxxxxxxxxxxxxx";
				DataBus = "xxxxxxxxxxxxxxxx";
				wait(clk->posedge_event());

			}
		}

		wait();
	}
}