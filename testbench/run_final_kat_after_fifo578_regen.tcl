open_project {C:/Users/aysha/Desktop/project/CRYSTALS-Kyber/Crystals-kyber/Crystals-kyber.xpr}
set_property top Kyber512_check_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
launch_simulation -simset sim_1 -mode behavioral
puts "KAT_AFTER_FIFO578_REGEN_DONE"
exit
