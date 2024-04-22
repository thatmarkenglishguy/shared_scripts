#!/usr/bin/env python3

"""Module used to DateDiff."""
from __future__ import print_function
import sys       # argv, exit()
import datetime  # strptime()

# ==============================================================================
# Logging
# ==============================================================================
import logging
log = logging.getLogger(__name__)
handler_stream = logging.StreamHandler()
format_stream = logging.Formatter('%(message)s')
handler_stream.setFormatter(format_stream)
log.addHandler(handler_stream)
log.setLevel(logging.WARN)

# ==============================================================================
# Globals
# ==============================================================================
# EXAMPLE ONLY - WAXME


def global_func(arg):
  del arg

# ==============================================================================
# Debugging
# ==============================================================================


# noinspection PyGlobalUndefined
def switch_to_debug():
  """Debug this script.
  """
  log.setLevel(logging.DEBUG)
  # EXAMPLE ONLY - WAXME
  global global_func

  def debug_global_func(arg):
    print('Doing an', arg)
  global_func = debug_global_func


# ==============================================================================
# DateDiff code
# ==============================================================================


def do_run_date_diff(start_date, end_date):
  """Calculate difference between two dates.
    Parameters:
      :param start_date - String containing start date.
      :param end_date - String containing end date.
      :result Difference between dates
  """
  log.info('Running DateDiff. start=%s, end=%s', start_date, end_date)
  start_date = datetime.datetime.strptime(start_date, '%d %m %Y')
  end_date = datetime.datetime.strptime(end_date, '%d %m %Y')
  if end_date < start_date:
    swap_date = start_date
    start_date = end_date
    end_date = swap_date
    log.debug('Swapped DateDiff. start=%s, end=%s', start_date, end_date)
    del swap_date
  log.info('Parsed dates. start=%s, end=%s', start_date, end_date)
  
  date_delta = end_date - start_date
  date_delta = date_delta / datetime.timedelta(days=1)
  return int(date_delta)


# ==============================================================================
# Test code
# ==============================================================================


def test_date_diff():
  """Test DateDiff functionality."""
  return 1


# ==============================================================================
# Script code
# ==============================================================================


def run_date_diff(argv=None):
  """Execute the DateDiff as a script.
    Parameters:
      argv    - Arguments to script.
    Returns:
      Exit code.
  """
  # Example command lines:
  import os        # linesep
  import time      # process_time()
  import argparse  # ArgumentParser
  if argv is None:  # If no arguments specified
    argv = sys.argv
  try:  # To test for debugging
    argv.remove('--debug')
    switch_to_debug()
  except ValueError:  # Not debugging
    pass
  result = 0
  ok_to_continue = True
  stream_out = sys.stdout
  # noinspection PyTypeChecker
  parser_run = argparse.ArgumentParser(description=r"""
Subtract first date from the second. Date format is Day Month Year.
Result is in days.

For example: %(prog)s '20 04 2023' '14 05 2023'""",
    formatter_class=argparse.RawDescriptionHelpFormatter
  )
  # noinspection PyUnusedLocal
  list_options = [
    parser_run.add_argument(
      '--showtime',
      dest='Showtime',
      default=False,
      action='store_true',
      help='If specified, show processing time.')
  ]
  parser_run.add_argument('ARGS', nargs='*')
  vals_parse = parser_run.parse_args(argv[1:])
  list_args = []
  if hasattr(vals_parse, 'ARGS'):
    list_args = vals_parse.ARGS
    del vals_parse.ARGS

  # Check arguments
  if len(list_args) != 2:
    print(f'Error: Exactly two arguments expected. Got f{list_args}')
    ok_to_continue = False

  if ok_to_continue:  # If OK to run
    time_start = None
    if vals_parse.Showtime:
      time_start = time.process_time()
    date_start = list_args[0]
    date_end = list_args[1]

    date_delta = do_run_date_diff(date_start, date_end)
    time_stop = None
    if vals_parse.Showtime:
      time_stop = time.process_time()
    # Finish up
    stream_out.write(f'{date_delta}\n')
    # Show time
    if vals_parse.Showtime:  # If showing time
      sys.stderr.write('That took: %.04f\n' % (time_stop - time_start))
  else:  # Else not OK to run
    result = 1
  return result

# ==============================================================================
# Module entry code
# ==============================================================================


def run():
  """Run the DateDiff.
    Returns:
      Exit code.
  """
  import optparse
  result = 1
  try:
    result = run_date_diff()
  except IOError as ioerrRun:
    if ioerrRun.args[0] == 22:  # If invalid argument
      pass
    else:
      raise
  except optparse.OptionError as errOpt:
    print(errOpt.option_id, errOpt.msg)
  return result


def test():
  """Test code for DateDiff.
    Note that most tests belong in a separate test script using unit test.
  """
  result = None
  return result


def main():
  """Main entry point for module."""
  test() or sys.exit(run())


if __name__ == "__main__":
  main()
