import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer

@cocotb.test()
async def test_project(dut):

    await Timer(5000, unit="ns") 
    errors = int(dut.error_count.value)
    #await Timer(1, unit="ms") 
    
    assert errors == 0