SV_FILE = sample.sv
#UVM_SRC = /opt/1800.2-2017-1.0/src
UVM_SRC = /opt/intelFPGA/18.1/modelsim_ase/verilog_src/uvm-1.2/src
UVM_PKG = +incdir+$(UVM_SRC) -sv $(UVM_SRC)/uvm.sv $(UVM_SRC)/dpi/uvm_dpi.cc -ccflags -DQUESTA
TOP_NAME = tb_top
PROJECT_NAME = sample_project
DPI_OBJ = svdpi
MODELSIM_HOME = /opt/intelFPGA/18.1/modelsim_ase
OBJ = $(notdir $(SRC:%.cc=%.o))

run : vlib vlog dpi_lib vsim

vlib:
	vlib work

vmap:
	vmap $(PROJECT_NAME) work

vlog:
	vlog $(UVM_PKG) $(SV_FILE)

vsim: 
	vsim -L work $(TOP_NAME) -c -dpicpppath /usr/bin/gcc -sv_lib uvm_dpi -do "run -all; quit"

dpi_lib:
	gcc -m32 -fPIC -DQUESTA -g -W -shared -I/opt/intelFPGA/18.1/modelsim_ase/include $(UVM_SRC)/dpi/uvm_dpi.cc -o uvm_dpi.so

clean:
	$(RM) -rf work transcript uvm_dpi.so *.o

