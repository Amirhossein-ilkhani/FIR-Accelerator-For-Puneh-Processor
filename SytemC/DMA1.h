#include <systemc.h>

#include "tlm.h"
#include "tlm_utils/simple_initiator_socket.h"
#include "tlm_utils/simple_target_socket.h"

class DMA1 : public sc_module {
public:

    sc_in<sc_logic> clk,rst;
    sc_in<sc_lv<16>> Addrbus, DataBus;
	sc_out<sc_logic> out_fully, in_fully, out_complete;

	sc_in<sc_logic> dma_gnt;
	sc_out<sc_logic> dma_req;

    sc_in<sc_logic> w2dma;
    sc_in<int> data2dma,add2dma;

    sc_out<sc_logic> w2fir;
    sc_out<int> data2fir,add2fir;


    sc_signal<sc_lv<16>> control_reg, addr_reg, number_reg, reserved_reg;
    sc_signal<sc_logic> read_flag, write_flag;

    sc_out<int> Ndata;

    int inBuf[128];
    int outBuf[128];
    

    sc_signal<sc_logic, SC_MANY_WRITERS> in_fully_flag,out_fully_flag,dma_req_flag,out_complete_flag;
	tlm_utils::simple_initiator_socket<DMA1, 32> dmaSocket;
	
	SC_CTOR(DMA1) : dmaSocket("dma_socket"), nBlockWriteRead(0)
	{
        
        // intialize buffers
        for(int i=0; i<128; i++){
        outBuf[i]=0;
        }

        for(int i=0; i<128; i++){
        inBuf[i]=0;
        }

		nBlockWriteRead = new tlm::tlm_generic_payload();

		SC_THREAD(memRead);
            sensitive << read_flag;
        
        SC_THREAD(memWrite);
            sensitive << write_flag;

        SC_THREAD(register_op);
			sensitive << Addrbus;

        SC_THREAD(Fir_op);
			sensitive << add2dma << w2dma;

        SC_THREAD(assign);
			sensitive << in_fully_flag << out_fully_flag << dma_req_flag << out_complete_flag;
        
	}

	tlm::tlm_generic_payload* nBlockWriteRead;
	void memRead();
    void assign();
    void memWrite();
    void Fir_op();
	void doSomethingGood(tlm::tlm_generic_payload&, sc_time);
    void register_op();

	int data[1];
};

void DMA1::assign()
{
	while (true)
	{   
		in_fully = in_fully_flag;
        out_fully =out_fully_flag;
        out_complete = out_complete_flag;
        dma_req = dma_req_flag;
		wait();
	}
}

void DMA1::memRead()
{	
    while (true)
	{
        if(read_flag == sc_logic_1){
            //cout << "here" << endl;
            tlm::tlm_phase forwardPhase;
            sc_time processTime; 

            for(int z=0; z<(((number_reg.read().to_uint()-1)/8)+1); z++){

                dma_req_flag = sc_logic_1;
                wait(dma_gnt->posedge_event());
                wait(clk->posedge_event());//read gnt

                for(int k=0; k<8; k++){
                    processTime = sc_time(0, SC_PS);
                    tlm::tlm_command cmd = tlm::TLM_READ_COMMAND;
                    int i = addr_reg.read().to_uint() + (z*8) + k;
                    data[0] = outBuf[(z*8) + k];

                    nBlockWriteRead->set_command(cmd);
                    nBlockWriteRead->set_address(i);
                    nBlockWriteRead->set_data_ptr((unsigned char*)data);
                    nBlockWriteRead->set_data_length(1);
                    nBlockWriteRead->set_streaming_width(1);
                    nBlockWriteRead->set_byte_enable_ptr(0);
                    nBlockWriteRead->set_dmi_allowed(false);
                    nBlockWriteRead->set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);

                    forwardPhase = tlm::BEGIN_REQ;

                    cout << "DMA side  " << (cmd ? 'W' : 'R') << ", @" << i << " data:";
                    sc_lv<8> vv;
                    // for (int j = 0; j < 5; j++) { vv = data[j]; cout << vv << " "; }
                    cout << data[0] << " ";
                    cout << " @time " << sc_time_stamp() << " delay=" << processTime << '\n';

                    tlm::tlm_sync_enum returnStatus;
                    returnStatus = dmaSocket->
                        nb_transport_fw(*nBlockWriteRead, forwardPhase, processTime);

                    int* ptr = reinterpret_cast<int*>(nBlockWriteRead->get_data_ptr());
                    inBuf[(z*8)+k] = (*ptr); 
                    cout<< "inBuf[" << (z*8)+k << "]= "<<(*ptr)<<endl;

                    // if (returnStatus == tlm::TLM_COMPLETED)
                    //     doSomethingGood(*nBlockWriteRead, processTime);
                    wait(clk->posedge_event());
                }

                dma_req_flag = sc_logic_0;
                wait(clk->posedge_event());
            }

            Ndata = number_reg.read().to_uint();
            w2fir = sc_logic_1;
            for(int i = 0; i < 128; i++){
                data2fir = inBuf[i];
                add2fir = i;
                wait(0,SC_PS);
            }
            w2fir = sc_logic_0;
            in_fully_flag = sc_logic_1;
        }
        wait();
    }
}


void DMA1::memWrite()
{	
    while (true)
	{
        if(write_flag == sc_logic_1){
            //cout << "here" << endl;
            tlm::tlm_phase forwardPhase;
            sc_time processTime; 

            for(int z=0; z<(((number_reg.read().to_uint()-1)/8)+1); z++){

                dma_req_flag = sc_logic_1;
                wait(dma_gnt->posedge_event());
                wait(clk->posedge_event());//read gnt
                
                for(int k=0; k<8; k++){
                    processTime = sc_time(0, SC_PS);
                    tlm::tlm_command cmd = tlm::TLM_WRITE_COMMAND;
                    int i = addr_reg.read().to_uint() + (z*8) + k;
                    
                    data[0] = outBuf[(z*8) + k];
        
                    nBlockWriteRead->set_command(cmd);
                    nBlockWriteRead->set_address(i);
                    nBlockWriteRead->set_data_ptr((unsigned char*)data);
                    nBlockWriteRead->set_data_length(1);
                    nBlockWriteRead->set_streaming_width(1);
                    nBlockWriteRead->set_byte_enable_ptr(0);
                    nBlockWriteRead->set_dmi_allowed(false);
                    nBlockWriteRead->set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);

                    forwardPhase = tlm::BEGIN_REQ;

                    cout << "DMA side  " << (cmd ? 'W' : 'R') << ", @" << i << " data:";
                    sc_lv<8> vv;
                    // for (int j = 0; j < 5; j++) { vv = data[j]; cout << vv << " "; }
                    cout << data[0] << " ";
                    cout << " @time " << sc_time_stamp() << " delay=" << processTime << '\n';

                    tlm::tlm_sync_enum returnStatus;
                    returnStatus = dmaSocket->
                        nb_transport_fw(*nBlockWriteRead, forwardPhase, processTime);

                    // int* ptr = reinterpret_cast<int*>(nBlockWriteRead->get_data_ptr());
                    // inBuf[(z*8)+k] = (*ptr); 
                    // cout<< "inBuf[" << (z*8)+k << "]= "<<(*ptr)<<endl;

                    // if (returnStatus == tlm::TLM_COMPLETED)
                    //     doSomethingGood(*nBlockWriteRead, processTime);
                    wait(clk->posedge_event());
                }
                
                dma_req_flag = sc_logic_0;
                wait(clk->posedge_event());
            }
            out_complete_flag = sc_logic_1;
        }
        wait();
    }
}

void DMA1::doSomethingGood(tlm::tlm_generic_payload& completeTrans,
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


void DMA1::register_op()
{
	while (true)
	{
		if (Addrbus->read() == "0x0C00") {
            control_reg = DataBus;
            wait(clk->posedge_event());
            if(control_reg.read() == "0x0003"){
                read_flag = SC_LOGIC_1;
            }
            else if(control_reg.read() == "0x0005"){
                write_flag = sc_logic_1;
                out_fully_flag = sc_logic_0;
            }
            else if(control_reg.read() == "0x0000"){
                read_flag = sc_logic_0;
                write_flag = sc_logic_0;
                in_fully_flag = sc_logic_0;
                out_fully_flag = sc_logic_0;
                out_complete_flag = sc_logic_0; 
            }
		}
		else if (Addrbus->read() == "0x0C01") {
			addr_reg = DataBus;
            wait(clk->posedge_event());
		}
		else if (Addrbus->read() == "0x0C02") {
			number_reg = DataBus;
            wait(clk->posedge_event());
		}
		else if (Addrbus->read() == "0x0C03") {
			reserved_reg = DataBus;
            wait(clk->posedge_event());
		}

		wait();
	}
}



void DMA1::Fir_op()
{
	while (true)
	{   
		if(w2dma == '1'){
            //cout<<"here2"<<endl;
            outBuf[add2dma] = data2dma;
            out_fully_flag = sc_logic_1;
        }
		wait();
	}
}