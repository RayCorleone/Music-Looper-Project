proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {Common 17-41} -limit 10000000
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  set_param xicom.use_bs_reader 1
  set_param simulator.modelsimInstallPath D:/Modeltech_pe_10.4c/win32pe
  set_property design_mode GateLvl [current_fileset]
  set_param project.singleFileAddWarning.threshold 0
  set_property webtalk.parent_dir D:/Ray/Vivado/Music_Looper/Music_Looper.cache/wt [current_project]
  set_property parent.project_path D:/Ray/Vivado/Music_Looper/Music_Looper.xpr [current_project]
  set_property ip_repo_paths d:/Ray/Vivado/Music_Looper/Music_Looper.cache/ip [current_project]
  set_property ip_output_repo d:/Ray/Vivado/Music_Looper/Music_Looper.cache/ip [current_project]
  set_property XPM_LIBRARIES XPM_CDC [current_project]
  add_files -quiet D:/Ray/Vivado/Music_Looper/Music_Looper.runs/synth_1/Looper_Top.dcp
  add_files -quiet D:/Ray/Vivado/Music_Looper/Music_Looper.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.dcp
  set_property netlist_only true [get_files D:/Ray/Vivado/Music_Looper/Music_Looper.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.dcp]
  add_files -quiet d:/Ray/Vivado/Music_Looper/Music_Looper.srcs/sources_1/ip/mig_7series_0/mig_7series_0.dcp
  set_property netlist_only true [get_files d:/Ray/Vivado/Music_Looper/Music_Looper.srcs/sources_1/ip/mig_7series_0/mig_7series_0.dcp]
  read_xdc -mode out_of_context -ref clk_wiz_0 -cells inst d:/Ray/Vivado/Music_Looper/Music_Looper.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_ooc.xdc
  set_property processing_order EARLY [get_files d:/Ray/Vivado/Music_Looper/Music_Looper.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_ooc.xdc]
  read_xdc -prop_thru_buffers -ref clk_wiz_0 -cells inst d:/Ray/Vivado/Music_Looper/Music_Looper.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_board.xdc
  set_property processing_order EARLY [get_files d:/Ray/Vivado/Music_Looper/Music_Looper.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_board.xdc]
  read_xdc -ref clk_wiz_0 -cells inst d:/Ray/Vivado/Music_Looper/Music_Looper.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc
  set_property processing_order EARLY [get_files d:/Ray/Vivado/Music_Looper/Music_Looper.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc]
  read_xdc -mode out_of_context -ref mig_7series_0 d:/Ray/Vivado/Music_Looper/Music_Looper.srcs/sources_1/ip/mig_7series_0/mig_7series_0/user_design/constraints/mig_7series_0_ooc.xdc
  set_property processing_order EARLY [get_files d:/Ray/Vivado/Music_Looper/Music_Looper.srcs/sources_1/ip/mig_7series_0/mig_7series_0/user_design/constraints/mig_7series_0_ooc.xdc]
  read_xdc -ref mig_7series_0 d:/Ray/Vivado/Music_Looper/Music_Looper.srcs/sources_1/ip/mig_7series_0/mig_7series_0/user_design/constraints/mig_7series_0.xdc
  set_property processing_order EARLY [get_files d:/Ray/Vivado/Music_Looper/Music_Looper.srcs/sources_1/ip/mig_7series_0/mig_7series_0/user_design/constraints/mig_7series_0.xdc]
  read_xdc D:/Ray/Vivado/Music_Looper/Music_Looper.srcs/constrs_1/new/XDC.xdc
  link_design -top Looper_Top -part xc7a100tcsg324-1
  write_hwdef -file Looper_Top.hwdef
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  opt_design 
  write_checkpoint -force Looper_Top_opt.dcp
  report_drc -file Looper_Top_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  implement_debug_core 
  place_design 
  write_checkpoint -force Looper_Top_placed.dcp
  report_io -file Looper_Top_io_placed.rpt
  report_utilization -file Looper_Top_utilization_placed.rpt -pb Looper_Top_utilization_placed.pb
  report_control_sets -verbose -file Looper_Top_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force Looper_Top_routed.dcp
  report_drc -file Looper_Top_drc_routed.rpt -pb Looper_Top_drc_routed.pb
  report_timing_summary -warn_on_violation -max_paths 10 -file Looper_Top_timing_summary_routed.rpt -rpx Looper_Top_timing_summary_routed.rpx
  report_power -file Looper_Top_power_routed.rpt -pb Looper_Top_power_summary_routed.pb -rpx Looper_Top_power_routed.rpx
  report_route_status -file Looper_Top_route_status.rpt -pb Looper_Top_route_status.pb
  report_clock_utilization -file Looper_Top_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  catch { write_mem_info -force Looper_Top.mmi }
  write_bitstream -force Looper_Top.bit 
  catch { write_sysdef -hwdef Looper_Top.hwdef -bitfile Looper_Top.bit -meminfo Looper_Top.mmi -file Looper_Top.sysdef }
  catch {write_debug_probes -quiet -force debug_nets}
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

