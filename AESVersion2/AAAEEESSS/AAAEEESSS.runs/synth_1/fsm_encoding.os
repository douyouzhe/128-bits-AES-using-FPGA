
 add_fsm_encoding \
       {axi_datamover_pcc.sig_pcc_sm_state} \
       { }  \
       {{000 00000001} {001 00000010} {010 00000100} {011 00001000} {100 00010000} {101 00100000} {110 01000000} {111 10000000} }

 add_fsm_encoding \
       {axi_datamover_ibttcc.sig_csm_state} \
       { }  \
       {{000 00000010} {001 00000100} {010 00010000} {011 00100000} {100 01000000} {101 00001000} {110 10000000} }

 add_fsm_encoding \
       {axi_datamover_ibttcc.sig_psm_state} \
       { }  \
       {{000 0000010} {001 0000100} {010 0001000} {011 0010000} {100 1000000} {111 0100000} }

 add_fsm_encoding \
       {axi_datamover_s2mm_realign.sig_cmdcntl_sm_state} \
       { }  \
       {{000 0000010} {001 0000100} {010 0010000} {011 0100000} {100 1000000} {101 0001000} }

 add_fsm_encoding \
       {axi_data_fifo_v2_1_axic_reg_srl_fifo.state} \
       { }  \
       {{00 010} {01 011} {10 000} {11 001} }

 add_fsm_encoding \
       {axi_data_fifo_v2_1_axic_reg_srl_fifo__parameterized0.state} \
       { }  \
       {{00 010} {01 011} {10 000} {11 001} }

 add_fsm_encoding \
       {axi_data_fifo_v2_1_axic_reg_srl_fifo__parameterized1.state} \
       { }  \
       {{00 010} {01 011} {10 000} {11 001} }

 add_fsm_encoding \
       {axi_master_burst_pcc.sig_pcc_sm_state} \
       { }  \
       {{000 00000010} {001 00000100} {010 00001000} {011 00010000} {100 00100000} {101 01000000} {110 10000000} }
