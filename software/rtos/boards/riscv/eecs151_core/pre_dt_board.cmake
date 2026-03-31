list(APPEND TOOLCHAIN_C_FLAGS -march=rv32im -mabi=ilp32)
list(APPEND TOOLCHAIN_LD_FLAGS -march=rv32im -mabi=ilp32)
list(APPEND TOOLCHAIN_LD_FLAGS -Wl,-melf32lriscv)
