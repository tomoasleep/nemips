library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_state.all;
use work.const_mux.all;
use work.const_alu_ctl.all;
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

        io_write_data: out std_logic_vector(31 downto 0);
        io_write_cmd: out io_length_type;
        io_read_cmd: out io_length_type;

        mem_write_data : out std_logic_vector(31 downto 0);
        mem_addr: out std_logic_vector(31 downto 0);
        sram_cmd: out sram_cmd_type;
        clk : in std_logic
      );
end path;

architecture behave of path is
  component program_counter
    port(
          write_data:  in std_logic_vector(29 downto 0);
          pc:  out std_logic_vector(29 downto 0);

          pc_write: in std_logic;
          clk : in std_logic
        );
  end component;

  -- component memory_interface
  --   port(
  --       address_in : in std_logic_vector(31 downto 0);
  --       memory_in : in std_logic_vector(31 downto 0);
  --       write_data : in std_logic_vector(31 downto 0);
  --       write_enable: in std_logic;

  --       read_data: out std_logic_vector(31 downto 0);
  --       write_out: out std_logic;
  --       write_out_data: out std_logic_vector(31 downto 0);
  --       address_out : out std_logic_vector(31 downto 0);
  --       clk : in std_logic
  --     );
  -- end component;

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

  component fsm
    port(
          opcode: in std_logic_vector(5 downto 0);
          funct: in std_logic_vector(5 downto 0);
          reset: in std_logic;
          alu_bool_result: in std_logic;
          go: in std_logic;

          state: out state_type;
          clk : in std_logic
        );
  end component;

  component path_controller
    port(
          opcode: in std_logic_vector(5 downto 0);
          funct : in std_logic_vector(5 downto 0);
          state : in state_type;

          alu_op:  out alu_op_type;
          wd_src:  out wd_src_type;
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
          inst_write: out std_logic;
          a2_src_rd: out std_logic
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
          go_src: in go_src_type;

          go: out std_logic
        );
  end component;


  signal pc, pc_write_data: std_logic_vector(29 downto 0);

  signal mem_write, ctl_pc_write, pc_write, ireg_write, freg_write: std_logic;
  signal alu_bool_result, inst_write, pc_branch: std_logic;
  signal a2_src_rd: std_logic;
  signal state_go : std_logic;

  signal opcode, funct: std_logic_vector(5 downto 0);
  signal imm: std_logic_vector(15 downto 0);
  signal addr_decode: std_logic_vector(25 downto 0);

  signal s_reg_address, t_reg_address, d_reg_address, t_decoder, d_decoder: std_logic_vector(4 downto 0);
  signal shamt: std_logic_vector(4 downto 0);

  signal winstr, instr_mem: std_logic_vector(31 downto 0);
  signal alu_A, alu_B, alu_result, ex_imm: std_logic_vector(31 downto 0);
  signal past_alu_result : std_logic_vector(31 downto 0);
  signal wdata_reg, i_rd1, i_rd2, i_rd1_buf, i_rd2_buf, f_rd1, f_rd2: std_logic_vector(31 downto 0);
  signal io_read_buf, mem_read_buf: std_logic_vector(31 downto 0);
  signal saddr_fetcher, saddr_decoder: std_logic_vector(31 downto 0);
  signal mem_write_addr: std_logic_vector(31 downto 0);

  signal go_src: go_src_type;
  signal fsm_state: state_type;
  signal alu_op: alu_op_type;
  signal wd_src: wd_src_type;
  signal regdist: regdist_type;
  signal inst_or_data: iord_type;
  signal pc_src: pc_src_type;
  signal alu_srcA: alu_srcA_type;
  signal alu_srcB: alu_srcB_type;
  signal alu_ctl: alu_ctl_type;
  signal io_write_cmd_choice, io_read_cmd_choice : io_length_type;

  constant reg_ra : std_logic_vector(4 downto 0) := "11111";

begin
  ppc: program_counter port map (
    clk=>clk,
    write_data=>pc_write_data,
    pc=>pc,
    pc_write=>pc_write
  );

  -- memif: memory_interface port map (
  --   clk=>clk,
  --   address_in=>mem_write_addr,
  --   memory_in=>mem_read_data,
  --   write_data=>mem_write_data,
  --   write_enable=>mem_write,
  --   read_data=>mem_read_data,
  --   write_out=>mem_we,
  --   write_out_data=>mem_write_data,
  --   address_out=>mem_addr
  -- );

  pdecoder: decoder port map (
    instr=>instr_mem,

    rs_reg=>s_reg_address,
    rt_reg=>t_decoder,
    rd_reg=>d_decoder,
    imm=>imm,
    address=>addr_decode,

    opcode=>opcode,
    funct=>funct,
    shamt=>shamt
  );

  pex_imm: sign_extender port map (
    imm=>imm,
    ex_imm=>ex_imm);

  palu: alu port map (
    a=>alu_A,
    b=>alu_B,
    alu_ctl=>alu_ctl,
    result=>alu_result,
    clk=>clk);

  palu_ctl: alu_decoder port map(
    opcode=>opcode,
    funct=>funct,
    alu_op=>alu_op,
    alu_ctl=>alu_ctl);

  i_register: register_file port map (
    a1=>s_reg_address,
    a2=>t_reg_address,
    a3=>d_reg_address,

    rd1=>i_rd1,
    rd2=>i_rd2,
    wd3=>wdata_reg,

    we3=>ireg_write,
    clk=>clk
  );

  --f_register: register_file port map (
  --  a1=>s_reg_address,
  --  a2=>t_reg_address,
  --  a3=>d_reg_address,

  --  rd1=>f_rd1,
  --  rd2=>f_rd2,
  --  wd3=>wdata_reg,

  --  we3=>freg_write,
  --  clk=>clk
  --);

  pfsm: fsm port map(
    opcode=>opcode,
    funct=>funct,
    reset=>reset,
    alu_bool_result=>alu_bool_result,
    go => state_go,

    state=>fsm_state,
    clk=>clk);

  p_ctl:  path_controller port map(
    opcode=>opcode,
    funct=>funct,
    state=>fsm_state,
    alu_op=>alu_op,
    wd_src=>wd_src,
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
    ireg_write=>ireg_write,
    freg_write=>freg_write,
    inst_write=>inst_write,
    a2_src_rd=>a2_src_rd,
    io_write_cmd=>io_write_cmd_choice,
    io_read_cmd=>io_read_cmd_choice);

  go_selector: state_go_selector port map(
    mem_read_ready => mem_read_ready,
    io_write_ready => io_write_ready,
    io_read_ready => io_read_ready,
    go_src => go_src,
    go => state_go);

  update: process(clk) begin
    if rising_edge(clk) then
      if inst_write = '1' then
        instr_mem <= mem_read_data;
      end if;

      past_alu_result <= alu_result;
      i_rd1_buf <= i_rd1;
      i_rd2_buf <= i_rd2;
      io_read_buf <= io_read_data;
      mem_read_buf <= mem_read_data;
    end if;
  end process;

  mem_addr <= past_alu_result when inst_or_data = iord_data else
              pc & "00"; -- when iord_inst

  mem_write_data <= i_rd2;
  io_write_data <=  i_rd1;

  alu_A <= i_rd1_buf when alu_srcA = alu_srcA_rd1 else
           pc & "00" when alu_srcA = alu_srcA_pc;

  alu_B <= i_rd2_buf when alu_srcB = alu_srcB_rd2 else
           x"00000004" when alu_srcB = alu_srcB_const4 else
           ex_imm when alu_srcB = alu_srcB_imm else
           ex_imm(29 downto 0) & "00" when alu_srcB = alu_srcB_imm_sft2 else
           x"0000" & imm(15 downto 0) when alu_srcB = alu_srcB_zimm;

  pc_write <= '1' when ctl_pc_write = '1' else
              alu_result(0) when pc_branch = '1' else
              '0';

  t_reg_address <= d_decoder when a2_src_rd = '1' else
                   t_decoder;

  d_reg_address <= t_decoder when regdist = regdist_rt else
                   d_decoder when regdist = regdist_rd else
                   reg_ra; --- when regdist = regdist_ra;

  wdata_reg <= past_alu_result when wd_src = wd_src_alu_past else
               mem_read_buf when wd_src = wd_src_mem else
               io_read_buf when wd_src = wd_src_io else
               pc & "00"; -- when wd_src = wd_src_pc;

  pc_write_data <= alu_result(31 downto 2) when pc_src = pc_src_alu else
                   pc(29 downto 26) & addr_decode when pc_src = pc_src_jta else
                   past_alu_result(31 downto 2); -- when pc_src_bta

  alu_bool_result <= alu_result(0);

  io_write_cmd <= io_length_none when io_write_ready = '1' else
                  io_write_cmd_choice;

  io_read_cmd <= io_length_none when io_read_ready = '1' else
                 io_read_cmd_choice;
end behave;

