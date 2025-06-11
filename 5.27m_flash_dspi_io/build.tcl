set_device GW2AR-LV18QN88C8/I7
foreach file [glob -nocomplain *.v] {
    add_file $file
}
add_file top.cst
set_option -top_module top
set_option -use_mspi_as_gpio 1
run all
