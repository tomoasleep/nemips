library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_state.all;
use work.const_mux.all;
use work.const_alu_ctl.all;
use work.const_fpu_ctl.all;
use work.const_io.all;
use work.const_sram_cmd.all;
use work.const_pipeline_state.all;

use work.typedef_opcode.all;
use work.typedef_data.all;

entity path is
  port(
        io_read_data : in word_data_type;
        io_read_ready: in std_logic;
        io_write_ready: in std_logic;

        mem_read_data: in word_data_type;
        mem_read_ready : in std_logic;
        reset : in std_logic;
        inst_ram_read_data : in order_type;

        io_write_data: out word_data_type;
        io_write_cmd: out io_length_type;
        io_read_cmd: out io_length_type;
        inst_ram_addr : out pc_data_type;

        inst_ram_write_enable : out std_logic;
        inst_ram_write_data : out order_type;
        mem_write_data : out word_data_type;
        mem_addr: out word_data_type;
        sram_cmd: out sram_cmd_type;

        is_break: out std_logic;
        continue: in std_logic;
        clk : in std_logic
      );
end path;

architecture behave of path is
  component program_counter
    port(
          write_data:  in pc_data_type;
          pc:  out pc_data_type;

          pc_write: in std_logic;
          reset : in std_logic;
          clk : in std_logic
        );
  end component;

  component decoder
    port(
          instr: in order_type;

          rs_reg : out register_addr_type;
          rt_reg : out register_addr_type;
          rd_reg : out register_addr_type;
          imm    : out immediate_type;
          address : out addr_type;

          opcode : out opcode_type;
          funct  : out funct_type;
          shamt  : out shift_amount_type
        );
  end component;

  component register_file
    port(
          a1 : in register_addr_type;
          a2 : in register_addr_type;
          a3 : in register_addr_type;

          rd1 : out word_data_type;
          rd2 : out word_data_type;
          wd3 : in word_data_type;

          we3 : in std_logic;
          clk : in std_logic
        );
  end component;

  component register_file_float
    port(
          a1 : in register_addr_type;
          a2 : in register_addr_type;
          a3 : in register_addr_type;

          rd1 : out word_data_type;
          rd2 : out word_data_type;
          wd3 : in word_data_type;

          we3 : in std_logic;
          clk : in std_logic
        );
  end component;

  component sign_extender
    port(
          imm    : in immediate_type;

          ex_imm : out word_data_type
        );
  end component;

  component alu
    port(
          a : in word_data_type;
          b : in word_data_type;
          alu_ctl: in alu_ctl_type;

          result : out word_data_type;
          clk : in std_logic
        );
  end component;

  component fpu_controller
    port(
          a: in word_data_type;
          b: in word_data_type;
          fpu_ctl: in fpu_ctl_type;

          result: out word_data_type;
          done: out std_logic;
          clk : in std_logic
        );
  end component;

  component sub_fpu
    port(
          a: in word_data_type;
          b: in word_data_type;
          fpu_ctl: in fpu_ctl_type;

          result: out word_data_type;
          done: out std_logic;
          clk : in std_logic
        );
  end component;

  component fpu_decoder is
    port(
          opcode: in opcode_type;
          funct: in funct_type;

          fpu_ctl: out fpu_ctl_type
        );
  end component;

  component fsm
    port(
          opcode: in opcode_type;
          funct: in funct_type;
          reset: in std_logic;
          go: in std_logic;

          state: out state_type;
          clk : in std_logic
        );
  end component;

  component path_controller
    port(
          state : in state_type;

          alu_op:  out alu_op_type;
          wd_src:  out wd_src_type;
          fwd_src:  out fwd_src_type;
          regdist: out regdist_type;
          inst_or_data: out iord_type;
          pc_src:   out pc_src_type;
          go_src:   out go_src_type;
          alu_srcA: out alu_srcA_type;
          alu_srcB: out alu_srcB_type;
          sram_cmd: out sram_cmd_type;
          io_write_cmd: out io_length_type;
          io_read_cmd: out io_length_type;
          mem_write: out std_logic;
          pc_write: out std_logic;
          pc_branch: out std_logic;
          ireg_write: out std_logic;
          freg_write: out std_logic;
          program_write: out  std_logic;
          inst_write: out std_logic;
          a2_src_rd: out std_logic;
          is_break: out std_logic
        );
  end component;

  component exec_state_decoder
    port(
          opcode: in opcode_type;
          funct : in funct_type;
          state : out exec_state_type
        );
  end component;

  component mem_state_decoder
    port(
          opcode: in opcode_type;
          funct : in funct_type;
          state : out mem_state_type
        );
  end component;

  component write_back_state_decoder
    port(
          opcode: in opcode_type;
          funct : in funct_type;
          state : out write_back_state_type
        );
  end component;

  component exec_ctl
    port(
          state : in exec_state_type;
          calc_srcB: out  calc_srcB_type;
          go_src: out  ex_go_src_type;
          result_src: out  ex_result_src_type
        );
  end component;

  component mem_ctl
    port(
          state : in mem_state_type;
          sram_cmd: out  sram_cmd_type;
          go_src: out  mem_go_src_type;
          io_read_cmd: out  io_length_type;
          io_write_cmd: out  io_length_type;
          mem_src: out  mem_result_src_type;
          program_write: out  std_logic;
          mem_write: out  std_logic
        );
  end component;

  component write_back_ctl
    port(
          state : in write_back_state_type;
          int_write: out  std_logic;
          float_write: out  std_logic;
          wdata_src: out  wd_src_type;
          regdist: out  regdist_type
        );
  end component;

  component alu_decoder
    port(
          opcode: in opcode_type;
          funct : in funct_type;
          alu_op : in alu_op_type;
          alu_ctl : out alu_ctl_type
        );
  end component;

  component state_go_selector
    port(
          mem_read_ready: in std_logic;
          io_write_ready: in std_logic;
          io_read_ready: in std_logic;
          continue: in std_logic;
          fpu_done: in std_logic;
          sub_fpu_done: in std_logic;
          go_src: in go_src_type;

          go: out std_logic
        );
  end component;


  signal pc: pc_data_type;
  signal pc_write_data: pc_data_type;

  signal mem_write, ctl_pc_write, pc_write, ireg_write_enable, freg_write_enable: std_logic;
  signal alu_bool_result, inst_write, pc_branch: std_logic;
  signal fpu_done, sub_fpu_done: std_logic;
  signal a2_src_rd: std_logic;
  signal fsm_go : std_logic;
  signal pctl_inst_ram_write_enable : std_logic;

  signal decoder_opcode: opcode_type;
  signal decoder_funct: funct_type;
  signal decoder_imm: immediate_type;
  signal decoder_addr: addr_type;

  signal decoder_s, reg_a2, reg_a3, decoder_t, decoder_d: register_addr_type;
  signal decoder_shamt: shift_amount_type;

  signal alu_A, alu_B, alu_result, signex_imm: word_data_type;
  signal fpu_A, fpu_B, fpu_result, sub_fpu_result: word_data_type;
  signal past_alu_result : word_data_type := (others => '0');
  signal past_fpu_result : word_data_type := (others => '0');
  signal past_sub_fpu_result : word_data_type := (others => '0');
  signal ireg_wdata, ireg_rdata1, ireg_rdata2, ireg_rdata1_buf, ireg_rdata2_buf: word_data_type := (others => '0');
  signal freg_wdata, freg_rdata1, freg_rdata2, freg_rdata1_buf, freg_rdata2_buf: word_data_type := (others => '0');
  signal io_read_buf, mem_read_buf: word_data_type := (others => '0');
  signal saddr_fetcher, sdecode_addrr: word_data_type;
  signal mem_write_addr: word_data_type;

  signal go_src: go_src_type;
  signal fsm_state: state_type;
  signal alu_op: alu_op_type;
  signal wd_src: wd_src_type;
  signal fwd_src: fwd_src_type;
  signal regdist: regdist_type;
  signal inst_or_data: iord_type;
  signal pc_src: pc_src_type;
  signal alu_srcA: alu_srcA_type;
  signal alu_srcB: alu_srcB_type;
  signal alu_ctl: alu_ctl_type;
  signal fpu_ctl: fpu_ctl_type;
  signal io_write_cmd_choice, io_read_cmd_choice : io_length_type;

  constant reg_ra : register_addr_type := "11111";
  constant zero : word_data_type := (others => '0');

  signal pc_bta, pc_jta, pc_increment: pc_data_type;
  signal decode_pc_increment, ex_pc_increment: pc_data_type;

  signal exec_state: exec_state_type;
  signal mem_state: mem_state_type;
  signal write_back_state: write_back_state_type;

  signal calc_input1, calc_input2: word_data_type;

  signal to_decode_reset, to_ex_reset, to_mem_reset, to_write_back_reset: std_logic;
  signal to_decode_write_enable, to_ex_write_enable: std_logic;
  signal to_mem_write_enable, to_write_back_write_enable: std_logic;

  signal to_decode_rs, to_decode_rt, to_decode_rd: register_addr_type;
  signal to_decode_imm  : immediate_type; signal to_decode_addr : addr_type;
  signal to_decode_funct: funct_type; signal to_decode_opcode: opcode_type;
  signal to_decode_pc: pc_data_type; signal to_decode_shamt: shift_amount_type;

  signal to_ex_rs, to_ex_rt, to_ex_rd: register_addr_type;
  signal to_ex_imm  : immediate_type; signal to_ex_addr : addr_type;
  signal to_ex_funct: funct_type; signal to_ex_opcode: opcode_type;
  signal to_ex_pc: pc_data_type; signal to_ex_shamt: shift_amount_type;
  signal to_ex_int_rd1, to_ex_int_rd2: word_data_type;
  signal to_ex_float_rd1, to_ex_float_rd2: word_data_type;

  signal to_mem_rs, to_mem_rt, to_mem_rd: register_addr_type;
  signal to_mem_imm  : immediate_type; signal to_mem_addr : addr_type;
  signal to_mem_funct: funct_type; signal to_mem_opcode: opcode_type;
  signal to_mem_pc: pc_data_type; signal to_mem_shamt: shift_amount_type;
  signal to_mem_result: word_data_type;
  signal phase_ex_result: word_data_type;

  signal to_write_back_rs, to_write_back_rt, to_write_back_rd: register_addr_type;
  signal to_write_back_imm  : immediate_type; signal to_write_back_addr : addr_type;
  signal to_write_back_funct: funct_type; signal to_write_back_opcode: opcode_type;
  signal to_write_back_pc: pc_data_type; signal to_write_back_shamt: shift_amount_type;
  signal to_write_back_result: word_data_type;
  signal phase_mem_result: word_data_type;

  signal ex_state: exec_state_type;
  signal ex_result_src: ex_result_src_type;
  signal ex_go_src: ex_go_src_type;
  signal ex_calc_srcB: calc_srcB_type;

begin
  ppc: program_counter port map (
    clk=>clk,
    write_data=>pc_write_data,
    pc=>pc,
    reset=>reset,
    pc_write=>pc_write
  );

  pdecoder: decoder port map (
    instr=>inst_ram_read_data,

    rs_reg=>decoder_s,
    rt_reg=>decoder_t,
    rd_reg=>decoder_d,
    imm=>decoder_imm,
    address=>decoder_addr,

    opcode=>decoder_opcode,
    funct=>decoder_funct,
    shamt=>decoder_shamt
  );

  pex_imm: sign_extender port map (
    imm=>decoder_imm,
    ex_imm=>signex_imm);

  i_register: register_file port map (
    a1=>decoder_s,
    a2=>reg_a2,
    a3=>reg_a3,

    rd1=>ireg_rdata1,
    rd2=>ireg_rdata2,
    wd3=>ireg_wdata,

    we3=>ireg_write_enable,
    clk=>clk
  );

  f_register: register_file_float port map (
    a1=>decoder_s,
    a2=>reg_a2,
    a3=>reg_a3,

    rd1=>freg_rdata1,
    rd2=>freg_rdata2,
    wd3=>freg_wdata,

    we3=>freg_write_enable,
    clk=>clk
  );

  pfsm: fsm port map(
    opcode=>decoder_opcode,
    funct=>decoder_funct,
    reset=>reset,
    go => fsm_go,

    state=>fsm_state,
    clk=>clk);

  p_ctl:  path_controller port map(
    state=>fsm_state,
    alu_op=>alu_op,
    wd_src=>wd_src,
    fwd_src=>fwd_src,
    regdist=>regdist,
    inst_or_data=>inst_or_data,
    pc_src=>pc_src,
    go_src=>go_src,
    sram_cmd=>sram_cmd,
    alu_srcA=>alu_srcA,
    alu_srcB=>alu_srcB,
    mem_write=>mem_write,
    pc_write=>ctl_pc_write,
    pc_branch=>pc_branch,
    ireg_write=>ireg_write_enable,
    freg_write=>freg_write_enable,
    inst_write=>inst_write,
    program_write=>pctl_inst_ram_write_enable,
    a2_src_rd=>a2_src_rd,
    is_break=>is_break,
    io_write_cmd=>io_write_cmd_choice,
    io_read_cmd=>io_read_cmd_choice);

  go_selector: state_go_selector port map(
    mem_read_ready => mem_read_ready,
    io_write_ready => io_write_ready,
    io_read_ready => io_read_ready,
    continue=>continue,
    fpu_done=>fpu_done,
    sub_fpu_done=>sub_fpu_done,
    go_src => go_src,
    go => fsm_go);

  update: process(clk) begin
    if rising_edge(clk) then
      past_alu_result <= alu_result;
      past_fpu_result <= fpu_result;
      past_sub_fpu_result <= sub_fpu_result;

      io_read_buf <= io_read_data;
      mem_read_buf <= mem_read_data;
    end if;
  end process;

  with pc_src select
    pc_write_data <= pc_bta when pc_src_bta,
                     pc_jta when pc_src_jta,
                     pc_increment when others; -- pc_src_increment

  pc_increment <= std_logic_vector(unsigned(pc) + 1);

  phase_fetch_to_decode: process(clk) begin
    if rising_edge(clk) then
      if to_decode_reset = '1' then
        to_decode_rs <= (others => '0');
        to_decode_rt <= (others => '0');
        to_decode_rd <= (others => '0');

        to_decode_imm <= (others => '0');
        to_decode_addr <= (others => '0');

        to_decode_opcode <= (others => '0');
        to_decode_shamt <= (others => '0');
        to_decode_shamt <= (others => '0');

        to_decode_pc <= (others => '0');
      elsif to_decode_write_enable = '1' then
        to_decode_rs <= decoder_s;
        to_decode_rt <= decoder_t;
        to_decode_rd <= decoder_d;

        to_decode_imm <= decoder_imm;
        to_decode_addr <= decoder_addr;

        to_decode_opcode <= decoder_opcode;
        to_decode_funct <= decoder_funct;
        to_decode_shamt <= decoder_shamt;

        to_decode_pc <= to_decode_pc;
      end if;
    end if;
  end process;

  decode_pc_increment <= std_logic_vector(unsigned(to_decode_pc) + 1);
  pc_jta <= decode_pc_increment(29 downto 26) & to_decode_addr(25 downto 0);

  phase_decode_to_ex: process(clk) begin
    if rising_edge(clk) then
      if to_ex_reset = '1' then
        to_ex_rs <= (others => '0');
        to_ex_rt <= (others => '0');
        to_ex_rd <= (others => '0');

        to_ex_imm <= (others => '0');
        to_ex_addr <= (others => '0');

        to_ex_opcode <= (others => '0');
        to_ex_shamt <= (others => '0');
        to_ex_shamt <= (others => '0');

        to_ex_pc <= (others => '0');
      elsif to_decode_write_enable = '1' then
        to_ex_rs <= decoder_s;
        to_ex_rt <= decoder_t;
        to_ex_rd <= decoder_d;

        to_ex_imm <= decoder_imm;
        to_ex_addr <= decoder_addr;

        to_ex_opcode <= decoder_opcode;
        to_ex_funct <= decoder_funct;
        to_ex_shamt <= decoder_shamt;

        to_ex_pc <= to_ex_pc;

        to_ex_int_rd1 <= ireg_rdata1;
        to_ex_int_rd2 <= ireg_rdata2;

        to_ex_float_rd1 <= freg_rdata1;
        to_ex_float_rd2 <= freg_rdata2;
      end if;
    end if;
  end process;

  ex_pc_increment <= std_logic_vector(unsigned(to_ex_pc) + 1);
  pc_bta <= std_logic_vector(unsigned(ex_pc_increment) + unsigned(signex_imm));

  fpu_A <= to_ex_float_rd1;
  fpu_B <= to_ex_float_rd2;

  calc_input1 <= to_ex_int_rd1;

  with ex_calc_srcB select
    calc_input2 <= to_ex_int_rd1 when calc_srcB_rd2,
                   signex_imm when calc_srcB_imm,
                   x"0000" & to_ex_imm when calc_srcB_zimm,
                   x"000000" & "000" & decoder_shamt when others;

  with ex_result_src select
    phase_ex_result <= alu_result when ex_result_src_alu,
                       fpu_result when ex_result_src_fpu,
                       sub_fpu_result when ex_result_src_sub_fpu,
                       zero when others;

  ex_path_ctl: exec_ctl port map(
    state => ex_state,
    calc_srcB => ex_calc_srcB,
    go_src => ex_go_src,
    result_src => ex_result_src);

  ex_decoder: exec_state_decoder port map(
    opcode => to_ex_opcode,
    funct => to_ex_funct,
    state => ex_state);

  palu_decoder: alu_decoder port map(
    opcode=>to_ex_opcode,
    funct=>to_ex_funct,
    alu_ctl=>alu_ctl);

  pfpu_decoder: fpu_decoder port map(
    opcode => to_ex_opcode,
    funct => to_ex_funct,
    fpu_ctl => fpu_ctl
  );

  palu: alu port map (
    a=>calc_input1,
    b=>calc_input2,
    alu_ctl=>alu_ctl,
    result=>alu_result,
    clk=>clk);

  pfpu: fpu_controller port map(
    a=>calc_input1,
    b=>calc_input2,
    fpu_ctl=>fpu_ctl,
    result=>fpu_result,
    done=>fpu_done,
    clk=>clk);

  psub_fpu: sub_fpu port map(
    a=>calc_input1,
    b=>calc_input2,
    fpu_ctl=>fpu_ctl,
    result=>sub_fpu_result,
    done=>sub_fpu_done,
    clk=>clk);

  phase_ex_to_mem: process(clk) begin
    if rising_edge(clk) then
      if to_mem_reset = '1' then
        to_mem_rs <= (others => '0');
        to_mem_rt <= (others => '0');
        to_mem_rd <= (others => '0');

        to_mem_imm <= (others => '0');
        to_mem_addr <= (others => '0');

        to_mem_opcode <= (others => '0');
        to_mem_funct <= (others => '0');
        to_mem_shamt <= (others => '0');

        to_mem_pc <= (others => '0');
      elsif to_mem_write_enable = '1' then
        to_mem_rs <= decoder_s;
        to_mem_rt <= decoder_t;
        to_mem_rd <= decoder_d;

        to_mem_imm <= decoder_imm;
        to_mem_addr <= decoder_addr;

        to_mem_opcode <= decoder_opcode;
        to_mem_funct <= decoder_funct;
        to_mem_shamt <= decoder_shamt;

        to_mem_pc <= to_mem_pc;

        to_mem_result <= phase_ex_result;
      end if;
    end if;
  end process;

  io_write_cmd <= io_length_none when io_write_ready = '1' else
                  io_write_cmd_choice;

  io_read_cmd <= io_length_none when io_read_ready = '1' else
                 io_read_cmd_choice;

  inst_ram_addr <= pc when pctl_inst_ram_write_enable = '0' else
                   past_alu_result(31 downto 2);

  with mem_state select
    phase_mem_result <= io_read_data when mem_state_io_read,
                        mem_read_data when mem_state_sram_read,
                        zero when others;

  mem_addr <= past_alu_result when inst_or_data = iord_data else
              pc & "00"; -- when iord_inst

  mem_write_data <= ireg_rdata2;
  inst_ram_write_data <= ireg_rdata2;
  io_write_data <=  ireg_rdata1;
  inst_ram_write_enable <= pctl_inst_ram_write_enable;

  phase_mem_to_write_back: process(clk) begin
    if rising_edge(clk) then
      if to_write_back_reset = '1' then
        to_write_back_rs <= (others => '0');
        to_write_back_rt <= (others => '0');
        to_write_back_rd <= (others => '0');

        to_write_back_imm <= (others => '0');
        to_write_back_addr <= (others => '0');

        to_write_back_opcode <= (others => '0');
        to_write_back_shamt <= (others => '0');
        to_write_back_shamt <= (others => '0');

        to_write_back_pc <= (others => '0');
      elsif to_write_back_write_enable = '1' then
        to_write_back_rs <= decoder_s;
        to_write_back_rt <= decoder_t;
        to_write_back_rd <= decoder_d;

        to_write_back_imm <= decoder_imm;
        to_write_back_addr <= decoder_addr;

        to_write_back_opcode <= decoder_opcode;
        to_write_back_funct <= decoder_funct;
        to_write_back_shamt <= decoder_shamt;

        to_write_back_pc <= to_write_back_pc;

        to_write_back_result <= phase_mem_result;
      end if;
    end if;
  end process;


  pc_write <= '1' when ctl_pc_write = '1' else '0';

  reg_a2 <= decoder_d when a2_src_rd = '1' else
             decoder_t;

  with regdist select
    reg_a3 <= to_write_back_rt when regdist_rt,
              to_write_back_rd when regdist_rd,
              reg_ra when others; --- when regdist = regdist_ra;

  ireg_wdata <= to_write_back_result; 
  freg_wdata <=  to_write_back_result;

  ireg_write_enable <= write_back_int_we;
  freg_write_enable <= write_back_float_we;

  alu_bool_result <= alu_result(0);

end behave;

