set dcp {C:/Users/aysha/Desktop/ML-KEM-512-FPGA-Dissertation/final_checkpoints/Kyber_Server_final_5992LUT_168MHz.dcp}
set outdir {C:/Users/aysha/Desktop/ML-KEM-512-FPGA-Dissertation/reports/server}
open_checkpoint $dcp
report_utilization -file [file join $outdir Kyber_Server_final_5992_util.rpt]
report_timing_summary -file [file join $outdir Kyber_Server_final_5992_timing.rpt]
report_timing -max_paths 10 -sort_by group -file [file join $outdir Kyber_Server_final_5992_top10_timing.rpt]
report_clocks -file [file join $outdir Kyber_Server_final_5992_clocks.rpt]
set paths [get_timing_paths -setup -max_paths 1]
if {[llength $paths] > 0} {
  puts "DCP_WNS [get_property SLACK [lindex $paths 0]]"
}
puts "DCP_REPORTS_WRITTEN"
exit
