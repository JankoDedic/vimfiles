import os
import lldb

def place_sign(file, line, type):
  try:
    vim.command('silent sign place {} line={} name={} file={}'.format(line, line, type, file))
  except vim.error:
    print('vim: Failed to place the sign.')

def unplace_sign(file, line):
  try:
    vim.command('silent sign unplace {} file={}'.format(line, file))
  except vim.error:
    print('vim: Failed to unplace the sign.')

def file_exists(file):
  return vim.eval("getftype(fnamemodify('{}', ':p'))".format(file)) != ''

def jump_to(file, line, column = 0):
  vim.command('silent edit {} | call cursor({}, {})'.format(file, line, column))

class Debugger:
  def __init__(self):
    self.debugger = lldb.SBDebugger.Create()
    self.debugger.SetAsync(False)
    self.target = None
    self.process = None

  def is_program_counter_at(self, file, line):
    if not self.process:
      return False

    line_entry = self.process.GetThreadAtIndex(0).GetFrameAtIndex(0).GetLineEntry()
    return line_entry.GetFileSpec() == lldb.SBFileSpec(file) and line_entry.GetLine() == line

  def place_breakpoint_sign_at(self, file, line):
    if self.is_program_counter_at(file, line):
      unplace_sign(file, line)
      place_sign(file, line, 'breakpoint_and_program_counter')
    else:
      place_sign(file, line, 'breakpoint')

  def unplace_breakpoint_sign_at(self, file, line):
    unplace_sign(file, line)
    if self.is_program_counter_at(file, line):
      place_sign(file, line, 'program_counter')

  def place_program_counter_sign(self):
    line_entry = self.process.GetThreadAtIndex(0).GetFrameAtIndex(0).GetLineEntry()
    file = str(line_entry.GetFileSpec())
    line = line_entry.GetLine()

    if self.dummy_target_breakpoint_at(file, line):
      unplace_sign(file, line)
      place_sign(file, line, 'breakpoint_and_program_counter')
    else:
      place_sign(file, line, 'program_counter')

  def unplace_program_counter_sign(self):
    line_entry = self.process.GetThreadAtIndex(0).GetFrameAtIndex(0).GetLineEntry()
    file = str(line_entry.GetFileSpec())
    line = line_entry.GetLine()

    unplace_sign(file, line)
    if self.dummy_target_breakpoint_at(file, line):
      place_sign(file, line, 'breakpoint')

  def place_selected_frame_sign(self):
    vim.command('sign unplace * file=debugger://call_stack')
    frame = self.process.GetSelectedThread().GetSelectedFrame().GetFrameID()
    vim.command('sign place 1 line={} name=selected_frame file=debugger://call_stack'.format(frame + 1))

  def jump_to_frame(self, frame_index):
    line_entry = self.process.GetThreadAtIndex(0).GetFrameAtIndex(frame_index).GetLineEntry()
    file = str(line_entry.GetFileSpec())
    line = line_entry.GetLine()
    column = line_entry.GetColumn()
    jump_to(file, line, column)

  def update_call_stack(self):
    frames = 'py3eval("map(str, debugger.process.GetSelectedThread().get_thread_frames())")'
    vim.command('silent call g:WriteLinesIntoBuffer("debugger://call_stack", {})'.format(frames))
    self.place_selected_frame_sign()

  def update_variables(self):
    frame = self.process.GetSelectedThread().GetSelectedFrame()
    lines = []
    for variable in frame.get_all_variables():
      for line in str(variable).split('\n'):
        lines.append(line)
    vim.Function('g:WriteLinesIntoBuffer')('debugger://variables', lines)
    # vim.command('silent call g:WriteLinesIntoBuffer("debugger://variables", py3eval(\'{}\'))'.format(lines))

  def start(self):
    if self.target:
      print('Process is already running.')
      return

    # exe_name = 'build/vim-debugger-main.exe'
    exe_name = 'build/' + os.path.basename(os.path.normpath(os.getcwd())) + '-main.exe'
    self.target = self.debugger.CreateTarget(exe_name)
    self.process = self.target.LaunchSimple(None, None, vim.eval('getcwd(-1)'))
    self.place_program_counter_sign()
    self.jump_to_frame(0)
    self.update_call_stack()
    self.update_variables()

  # Unplace the previous sign, execute and then place the sign on a new place.
  def continue_(self):
    self.unplace_program_counter_sign()
    self.process.Continue()
    if self.process.GetState() == lldb.eStateExited:
      self.process.Kill()
      self.debugger.DeleteTarget(self.target)
    else:
      self.place_program_counter_sign()
      self.jump_to_frame(0)
      self.update_call_stack()
      self.update_variables()

  def stop(self):
    self.unplace_program_counter_sign()
    self.process.Kill()
    self.debugger.DeleteTarget(self.target)

  def step_over(self):
    self.unplace_program_counter_sign()
    self.process.GetThreadAtIndex(0).StepOver()
    self.place_program_counter_sign()
    self.jump_to_frame(0)
    self.update_call_stack()
    self.update_variables()

  def step_into(self):
    self.unplace_program_counter_sign()
    self.process.GetThreadAtIndex(0).StepInto()
    self.place_program_counter_sign()
    self.jump_to_frame(0)
    self.update_call_stack()
    self.update_variables()

  def step_out(self):
    self.unplace_program_counter_sign()
    self.process.GetThreadAtIndex(0).StepOut()
    self.place_program_counter_sign()
    self.jump_to_frame(0)
    self.update_call_stack()
    self.update_variables()

  def set_selected_frame(self, new_frame_index):
    thread = self.process.GetThreadAtIndex(0)
    if not (0 <= new_frame_index and new_frame_index < thread.GetNumFrames()):
      return

    line_entry = thread.GetFrameAtIndex(new_frame_index).GetLineEntry()
    file = str(line_entry.GetFileSpec())
    if not file_exists(file):
      return

    line = line_entry.GetLine()
    column = line_entry.GetColumn()
    self.process.GetSelectedThread().SetSelectedFrame(new_frame_index)
    jump_to(file, line, column)
    self.place_selected_frame_sign()

  def higher_frame(self):
    self.set_selected_frame(self.process.GetSelectedThread().GetSelectedFrame().GetFrameID() + 1)
    self.update_variables()

  def lower_frame(self):
    self.set_selected_frame(self.process.GetSelectedThread().GetSelectedFrame().GetFrameID() - 1)
    self.update_variables()

  # SBBreakpoint doesn't seem to have methods for returning file/line information.
  # However, file and line are printed when you print the breakpoint.
  # Thus, I will just convert the breakpoint to a string and extract the info from it.
  def get_file_and_line_from_breakpoint(self, bp):
    s = str(bp)
    file = s.split("'")[1]
    line = int(s.split(' ')[9][:-1])
    return { 'file': file, 'line': line }

  def dummy_target_breakpoint_at(self, file, line):
    for b in self.debugger.GetDummyTarget().breakpoint_iter():
      loc = self.get_file_and_line_from_breakpoint(b)
      if lldb.SBFileSpec(file) == lldb.SBFileSpec(loc['file']) and line == loc['line']:
        return b

  def target_breakpoint_at(self, file, line):
    for b in self.target.breakpoint_iter():
      loc = self.get_file_and_line_from_breakpoint(b)
      if lldb.SBFileSpec(file) == lldb.SBFileSpec(loc['file']) and line == loc['line']:
        return b

  # We can set breakpoints on the dummy target. When the real target is created,
  # it will inherit the breakpoints set on the dummy target. After the real target
  # is created, breakpoints set on the dummy target will not transfer to the real
  # target. Thus, we need to keep the breakpoints on the dummy target and on the
  # real target in sync.
  def create_breakpoint(self, file, line):
    dbp = self.debugger.GetDummyTarget().BreakpointCreateByLocation(file, line)
    if not dbp:
      print('lldb: Failed to create the dummy target breakpoint.')
      return False

    if not self.target:
      return True

    bp = self.target.BreakpointCreateByLocation(file, line)
    if not bp:
      print('lldb: Failed to create the target breakpoint.')
      return False

    return True

  def delete_breakpoint(self, file, line):
    if not self.debugger.GetDummyTarget().BreakpointDelete(self.dummy_target_breakpoint_at(file, line).GetID()):
      print('lldb: Failed to delete the dummy target breakpoint.')
      return False

    if not self.target:
      return True

    if not self.target.BreakpointDelete(self.target_breakpoint_at(file, line).GetID()):
      print('lldb: Failed to delete the target breakpoint.')
      return False

    return True

  def toggle_breakpoint_at_current_line(self):
    file = vim.eval('expand("%:p")')
    line = int(vim.eval('line(".")'))

    if not self.dummy_target_breakpoint_at(file, line):
      if self.create_breakpoint(file, line):
        self.place_breakpoint_sign_at(file, line)
      else:
        print('lldb: Failed to create the breakpoint.')
    else:
      if self.delete_breakpoint(file, line):
        self.unplace_breakpoint_sign_at(file, line)
      else:
        print('lldb: Failed to delete the breakpoint.')

global debugger

# TODO: I don't like this.
try:
  debugger.process.Kill()
  debugger.DeleteTarget(debugger.target)
except (NameError, AttributeError):
  debugger = Debugger()

