#include <iostream>
#include <systemc.h>


SC_MODULE(FIR)
{
public:
	sc_in<sc_logic> clk,rst;
	sc_in<sc_lv<16>> AddrBus;
	sc_in<sc_lv<16>> DataBus;

    sc_in<int> Ndata;

    sc_in<sc_logic> w2fir;
    sc_in<int> data2fir,add2fir;

    sc_out<sc_logic> w2dma;
    sc_out<int> data2dma,add2dma;


    sc_signal<sc_logic> start;

    int temp = 0;
    int result = 0;
    int numofdata;
	int coeff_reg[16];
    int inBuf[128];
    int outBuf[128];

	SC_CTOR(FIR)
	{

		SC_THREAD(coeff_reg_op)
			sensitive << clk.pos();

        SC_THREAD(start_op)
			sensitive << clk.pos();

        SC_THREAD(fir_op)
			sensitive << start.posedge_event();

        SC_THREAD(Dma_op);
			sensitive << add2fir << w2fir;

	}
	void coeff_reg_op();
    void Dma_op();
    void start_op();
    void fir_op();
};


void FIR::fir_op()
{
	while (true)
	{   
        if(start == '1'){
            temp = 0;
            result = 0;
            numofdata = Ndata;
            cout<< "fir calculation was started @"<<sc_time_stamp()<< endl;

            for(int i = 0; i < numofdata; i++){
                for(int j = 0 ; j < coeff_reg[0] ; j++){
                    cout<<"coeff_reg= "<<coeff_reg[j+1]<<"\tinBuf= "<<inBuf[i+j]<<endl;
                    temp = coeff_reg[j+1]*inBuf[i+j];
                    result = result + temp;
                    wait(clk->posedge_event());
                }
                cout<<"result= "<<result<<"\tcalculated @"<<sc_time_stamp()<< endl;
                outBuf[i] = result;
                temp = 0;
                result = 0;
            }
            
            w2dma = sc_logic_1;
            for(int i = 0; i < 128; i++){
                    add2dma = i;
                    data2dma = outBuf[i];
                    wait(0,SC_PS);
                }
            w2dma = sc_logic_0;
            cout<< "fir calculation was finished @"<<sc_time_stamp()<< endl;
            }
        wait();
    }
}


void FIR::start_op()
{
	while (true)
	{
        if(AddrBus->read() == "0x0C06"){
            start = sc_logic_1;
        }
        else{
            start = sc_logic_0;
        }
        wait();
    }
}



void FIR::Dma_op()
{
	while (true)
	{   
		if(w2fir == '1'){
            inBuf[add2fir] = data2fir;
        }
		wait();
	}
}





void FIR::coeff_reg_op()
{
	while (true)
	{   
        if(AddrBus->read() == "0x0B00"){
            coeff_reg[0] = DataBus.read().to_uint();
            wait(clk->posedge_event());
        }

        else if(AddrBus->read() == "0x0B01"){
            coeff_reg[1] = DataBus.read().to_uint();
            wait(clk->posedge_event());
        }

        else if(AddrBus->read() == "0x0B02"){
            coeff_reg[2] = DataBus.read().to_uint();
            wait(clk->posedge_event());
        }

        else if(AddrBus->read() == "0x0B03"){
            coeff_reg[3] = DataBus.read().to_uint();
            wait(clk->posedge_event());
        }

        else if(AddrBus->read() == "0x0B04"){
            coeff_reg[4] = DataBus.read().to_uint();
            wait(clk->posedge_event());
        }

        else if(AddrBus->read() == "0x0B05"){
            coeff_reg[5] = DataBus.read().to_uint();
            wait(clk->posedge_event());
        }

        else if(AddrBus->read() == "0x0B06"){
            coeff_reg[6] = DataBus.read().to_uint();
            wait(clk->posedge_event());
        }

        else if(AddrBus->read() == "0x0B07"){
            coeff_reg[7] = DataBus.read().to_uint();
            wait(clk->posedge_event());
        }
		
        else if(AddrBus->read() == "0x0B08"){
            coeff_reg[8] = DataBus.read().to_uint();
            wait(clk->posedge_event());
        }

        else if(AddrBus->read() == "0x0B09"){
            coeff_reg[9] = DataBus.read().to_uint();
            wait(clk->posedge_event());
        }

        else if(AddrBus->read() == "0x0B0A"){
            coeff_reg[10] = DataBus.read().to_uint();
            wait(clk->posedge_event());
        }

        else if(AddrBus->read() == "0x0B0B"){
            coeff_reg[11] = DataBus.read().to_uint();
            wait(clk->posedge_event());
        }

        else if(AddrBus->read() == "0x0B0C"){
            coeff_reg[12] = DataBus.read().to_uint();
            wait(clk->posedge_event());
        }

        else if(AddrBus->read() == "0x0B0D"){
            coeff_reg[13] = DataBus.read().to_uint();
            wait(clk->posedge_event());
        }

        else if(AddrBus->read() == "0x0B0E"){
            coeff_reg[14] = DataBus.read().to_uint();
            wait(clk->posedge_event());
        }

        else if(AddrBus->read() == "0x0B0F"){
            coeff_reg[15] = DataBus.read().to_uint();
            wait(clk->posedge_event());
        }

		wait();
	}
}