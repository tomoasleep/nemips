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

entity path is
  port(
        io_read_data : in std_logic_vector(31 downto 0);
        io_read_ready: in std_logic;
        io_write_ready: in std_logic;

        mem_read_data: in std_logic_vector(31 downto 0);
        mem_read_ready : in std_logic;
        reset : in std_logic;
        inst_ram_read_data : in std_logic_vector(31 downto 0);

        io_write_data: out std_logic_vector(31 downto 0);
        io_write_cmd: out io_length_type;
        io_read_cmd: out io_length_type;
        inst_ram_addr : out std_logic_vector(29 downto 0);

        inst_ram_write_enable : out std_logic;
        inst_ram_write_data : out std_logic_vector(31 downto 0);
        mem_write_data : out std_logic_vector(31 downto 0);
        mem_addr: out std_logic_vector(31 downto 0);
        sram_cmd: out sram_cmd_type;

        is_break: out std_logic;
        continue: in std_logic;
        clk : in std_logic
      );
end path;

architecture behave of path is
  component program_counter
    port(
          write_data:  in std_logic_vector(29 downto 0);
          pc:  out std_logic_vector(29 downto 0);

          pc_write: in std_logic;
          reset : in std_logic;
          clk : in std_logic
        );
  end component;

  component decoder
    port(
          instr: in std_logic_vector(31 downto 0);

          rs_reg : out std_logic_vector(4 downto 0);
          rt_reg : out std_logic_vector(4 downto 0);
          rd_reg : out std_logic_vector(4 downto 0);
          imm    : out std_logic_vector(15 downto 0);
          address : out std_logic_vector(25 downto 0);

          opcode : out std_logic_vector(5 downto 0);
          funct  : out std_logic_vector(5 downto 0);
          shamt  : out std_logic_vector(4 downto 0)
        );
  end component;

  component register_file
    port(
          a1 : in std_logic_vector(4 downto 0);
          a2 : in std_logic_vector(4 downto 0);
          a3 : in std_logic_vector(4 downto 0);

          rd1 : out std_logic_vector(31 downto 0);
          rd2 : out std_logic_vector(31 downto 0);
          wd3 : in std_logic_vector(31 downto 0);

          we3 : in std_logic;
          clk : in std_logic
        );
  end component;

  component register_file_float
    port(
          a1 : in std_logic_vector(4 downto 0);
          a2 : in std_logic_vector(4 downto 0);
          a3 : in std_logic_vector(4 downto 0);

          rd1 : out std_logic_vector(31 downto 0);
          rd2 : out std_logic_vector(31 downto 0);
          wd3 : in std_logic_vector(31 downto 0);

          we3 : in std_logic;
          clk : in std_logic
        );
  end component;

  component sign_extender
    port(
          imm    : in std_logic_vector(15 downto 0);

          ex_imm : out std_logic_vector(31 downto 0)
        );
  end component;

  component alu
    port(
          a : in std_logic_vector(31 downto 0);
          b : in std_logic_vector(31 downto 0);
          alu_ctl: in alu_ctl_type;

          result : out std_logic_vector(31 downto 0);
          clk : in std_logic
        );
  end component;

  component fpu_controller
    port(
          a: in std_logic_vector(31 downto 0);
          b: in std_logic_vector(31 downto 0);
          fpu_ctl: in fpu_ctl_type;

          result: out std_logic_vector(31 downto 0);
          done: out std_logic;
          clk : in std_logic
        );
  end component;

  component sub_fpu
    port(
          a: in std_logic_vector(31 downto 0);
          b: in std_logic_vector(31 downto 0);
          fpu_ctl: in fpu_ctl_type;

          result: out std_logic_vector(31 downto 0);
          done: out std_logic;
          clk : in std_logic
        );
  end component;

  component fpu_decoder is
    port(
          opcode: in std_logic_vector(5 downto 0);
          funct: in std_logic_vector(5 downto 0);

          fpu_ctl: out fpu_ctl_type
        );
  end component;

  component fsm
    port(
          opcode: in std_logic_vector(5 downto 0);
          funct: in std_logic_vector(5 downto 0);
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

  component alu_decoder
    port(
          opcode: in std_logic_vector(5 downto 0);
          funct : in std_logic_vector(5 downto 0);
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


  signal pc: std_logic_vector(29 downto 0);
  signal pc_write_data: std_logic_vector(29 downto 0);

  signal mem_write, ctl_pc_write, pc_write, ireg_write_enable, freg_write_enable: std_logic;
  signal alu_bool_result, inst_write, pc_branch: std_logic;
  signal fpu_done, sub_fpu_done: std_logic;
  signal a2_src_rd: std_logic;
  signal fsm_go : std_logic;
  signal pctl_inst_ram_write_enable : std_logic;

  signal decoder_opcode, decoder_funct: std_logic_vector(5 downto 0);
  signal decoder_imm: std_logic_vector(15 downto 0);
  signal decoder_addr: std_logic_vector(25 downto 0);

  signal decoder_s, reg_a2, reg_a3, decoder_t, decoder_d: std_logic_vector(4 downto 0);
  signal decoder_shamt: std_logic_vector(4 downto 0);

  signal winstr, decoder_inst_mem: std_logic_vector(31 downto 0) := (others => '0');
  signal alu_A, alu_B, alu_result, signex_imm: std_logic_vector(31 downto 0);
  signal fpu_A, fpu_B, fpu_result, sub_fpu_result: std_logic_vector(31 downto 0);
  signal past_alu_result : std_logic_vector(31 downto 0) := (others => '0');
  signal past_fpu_result : std_logic_vector(31 downto 0) := (others => '0');
  signal past_sub_fpu_result : std_logic_vector(31 downto 0) := (others => '0');
  signal ireg_wdata, ireg_rdata1, ireg_rdata2, ireg_rdata1_buf, ireg_rdata2_buf: std_logic_vector(31 downto 0) := (others => '0');
  signal freg_wdata, freg_rdata1, freg_rdata2, freg_rdata1_buf, freg_rdata2_buf: std_logic_vector(31 downto 0) := (others => '0');
  signal io_read_buf, mem_read_buf: std_logic_vector(31 downto 0) := (others => '0');
  signal saddr_fetcher, sdecode_addrr: std_logic_vector(31 downto 0);
  signal mem_write_addr: std_logic_vector(31 downto 0);

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

  constant reg_ra : std_logic_vector(4 downto 0) := "11111";

begin
  ppc: program_counter port map (
    clk=>clk,
    write_data=>pc_write_data,
    pc=>pc,
    reset=>reset,
    pc_write=>pc_write
  );

  pdecoder: decoder port map (
    instr=>decoder_inst_mem,

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

  palu: alu port map (
    a=>alu_A,
    b=>alu_B,
    alu_ctl=>alu_ctl,
    result=>alu_result,
    clk=>clk);

  palu_ctl: alu_decoder port map(
    opcode=>decoder_opcode,
    funct=>decoder_funct,
    alu_op=>alu_op,
    alu_ctl=>alu_ctl);

  pfpu: fpu_controller port map(
    a=>fpu_A,
    b=>fpu_B,
    fpu_ctl=>fpu_ctl,
    result=>fpu_result,
    done=>fpu_done,
    clk=>clk);

  psub_fpu: sub_fpu port map(
    a=>fpu_A,
    b=>fpu_B,
    fpu_ctl=>fpu_ctl,
    result=>sub_fpu_result,
    done=>sub_fpu_done,
    clk=>clk);

  pfpu_decoder: fpu_decoder port map(
    opcode => decoder_opcode,
    funct => decoder_funct,
    fpu_ctl => fpu_ctl
  );

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
      if inst_write = '1' then
        decoder_inst_mem <= inst_ram_read_data;
      end if;

      past_alu_result <= alu_result;
      past_fpu_result <= fpu_result;
      past_sub_fpu_result <= sub_fpu_result;

      ireg_rdata1_buf <= ireg_rdata1;
      ireg_rdata2_buf <= ireg_rdata2;
      freg_rdata1_buf <= freg_rdata1;
      freg_rdata2_buf <= freg_rdata2;

      io_read_buf <= io_read_data;
      mem_read_buf <= mem_read_data;
    end if;
  end process;

  mem_addr <= past_alu_result when inst_or_data = iord_data else
              pc & "00"; -- when iord_inst

  mem_write_data <= ireg_rdata2;
  inst_ram_write_data <= ireg_rdata2;
  io_write_data <=  ireg_rdata1;
  inst_ram_write_enable <= pctl_inst_ram_write_enable;

  alu_A <= ireg_rdata1_buf when alu_srcA = alu_srcA_rd1 else
           pc & "00" when alu_srcA = alu_srcA_pc;

  alu_B <= ireg_rdata2_buf when alu_srcB = alu_srcB_rd2 else
           x"00000004" when alu_srcB = alu_srcB_const4 else
           signex_imm when alu_srcB = alu_srcB_imm else
           signex_imm(29 downto 0) & "00" when alu_srcB = alu_srcB_imm_sft2 else
           x"0000" & decoder_imm(15 downto 0) when alu_srcB = alu_srcB_zimm else
           x"000000" & "000" & decoder_shamt; -- when alu_srcB_shamt

  fpu_A <= freg_rdata1_buf;
  fpu_B <= freg_rdata2_buf;

  pc_write <= '1' when ctl_pc_write = '1' else
              alu_result(0) when pc_branch = '1' else
              '0';

  reg_a2 <= decoder_d when a2_src_rd = '1' else
             decoder_t;

  reg_a3 <= decoder_t when regdist = regdist_rt else
            decoder_d when regdist = regdist_rd else
            reg_ra; --- when regdist = regdist_ra;

  ireg_wdata <= past_alu_result when wd_src = wd_src_alu_past else
                mem_read_buf when wd_src = wd_src_mem else
                io_read_buf when wd_src = wd_src_io else
                pc & "00" when wd_src = wd_src_pc else
                past_sub_fpu_result; -- when wd_src = wd_src_sub_fpu_past

  freg_wdata <= past_fpu_result when fwd_src = fwd_src_fpu_past else
                past_sub_fpu_result when fwd_src = fwd_src_sub_fpu_past else
                past_alu_result; -- when fwd_src = fwd_src_alu_past

  pc_write_data <= alu_result(31 downto 2) when pc_src = pc_src_alu else
                   pc(29 downto 26) & decoder_addr when pc_src = pc_src_jta else
                   past_alu_result(31 downto 2); -- when pc_src_bta

  alu_bool_result <= alu_result(0);

  io_write_cmd <= io_length_none when io_write_ready = '1' else
                  io_write_cmd_choice;

  io_read_cmd <= io_length_none when io_read_ready = '1' else
                 io_read_cmd_choice;

  inst_ram_addr <= pc when pctl_inst_ram_write_enable = '0' else
                   past_alu_result(31 downto 2);
end behave;

