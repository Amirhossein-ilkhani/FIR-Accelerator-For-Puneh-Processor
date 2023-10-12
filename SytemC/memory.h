#include <systemc.h>

#include "tlm.h"
#include "tlm_utils/simple_initiator_socket.h"
#include "tlm_utils/simple_target_socket.h"

class memoryUnit : public sc_module {
public:
	tlm_utils::simple_target_socket<memoryUnit, 32> memSocket;
	tlm_utils::simple_target_socket<memoryUnit, 32> dmaSocket;

	static const int SIZE = 512;

	SC_CTOR(memoryUnit) : memSocket("cpu_side_socket"),dmaSocket("dma_side_socket") {
		memSocket.register_nb_transport_fw(this, &memoryUnit::nb_transport_fw);
		dmaSocket.register_nb_transport_fw(this, &memoryUnit::nb_transport_fw);
		
		// Initialize memory
		for (int i = 100; i < 228; i++){
			memArray[i] = i-100;
		}

		memArray[450] = 3;
		for (int i = 451; i < 466; i++){
			memArray[i] = i-450;
		}
		// memArray[4] = "00000001";
		// memArray[5] = "00000010";
		memArray[5] = 12;

	}

	virtual tlm::tlm_sync_enum nb_transport_fw(tlm::tlm_generic_payload&,
		tlm::tlm_phase&, sc_time&);
	int memArray[SIZE];
};



tlm::tlm_sync_enum memoryUnit::nb_transport_fw
(tlm::tlm_generic_payload& receivedTrans,
	tlm::tlm_phase& phase, sc_time& delay) {

	tlm::tlm_command cmd = receivedTrans.get_command();
	uint64           adr = receivedTrans.get_address();
	unsigned char* ptr = receivedTrans.get_data_ptr();
	unsigned int     len = receivedTrans.get_data_length();
	unsigned char* byt = receivedTrans.get_byte_enable_ptr();
	unsigned int     wid = receivedTrans.get_streaming_width();

	if (byt != 0) {
		receivedTrans.set_response_status(tlm::TLM_BYTE_ENABLE_ERROR_RESPONSE);
		return tlm::TLM_COMPLETED;
	}
	if (len > 5 || wid < len) {
		receivedTrans.set_response_status(tlm::TLM_BURST_ERROR_RESPONSE);
		return tlm::TLM_COMPLETED;
	}
	unsigned int i;
	if (cmd == tlm::TLM_READ_COMMAND)
		for (i = 0; i < len; i = i + 1) {
			*(ptr + i) = *((unsigned char*)(memArray + adr + i));
		}
	else if (cmd == tlm::TLM_WRITE_COMMAND)
		for (i = 0; i < len; i = i + 1) {
			*((unsigned char*)(memArray + adr + i)) = *(ptr + i);
			cout<<"memArray["<< adr + i<<"]= "<<memArray[adr + i]<<endl;
		}

	receivedTrans.set_response_status(tlm::TLM_OK_RESPONSE);
	delay = delay + sc_time(0, SC_NS);
	return tlm::TLM_COMPLETED;
	
}