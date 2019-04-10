#!/usr/bin/env python3
"""Module used to HumaniseNumber."""

import sys       # argv, exit()
import textwrap  # fill()
from collections import namedtuple
import math

HumanisedNumberTuple = namedtuple('HumanisedNumberTuple', 'locale_string magnitude_string')

# ==============================================================================
# Logging
# ==============================================================================
import logging
log = logging.getLogger(__name__)
handlerStream = logging.StreamHandler()
formatStream = logging.Formatter('%(message)s')
handlerStream.setFormatter(formatStream)
log.addHandler(handlerStream)
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
# HumaniseNumber code
# ==============================================================================


def _find_magnitude(number, base=10):
  '''How many times base goes into number.
      :param number: Number to find magnitude of.
      :param base: Divisor for number.
  '''
  count = 0
  number = int(number)
  base = int(base)
  while number > 0:
    number = int(number / base)
    count += 1
  if count > 0:
    count -= 1
  return count


def _build_magnitude_string_from_limit(number, limit_limit, converter=str):
  limit_size = limit_limit[0]
  divisor = 10 ** limit_size
  numerator = int(number / divisor)
  remainder = int(number % divisor)
  log.debug(f'divisor: {divisor}, numerator: {numerator}, remainder: {remainder}')
  if remainder > 0 and remainder != number:
    remainder_string = ' ' + _magnitude_string(remainder)
  else:
    remainder_string = ''
  return converter(numerator) + limit_limit[1] + remainder_string


def _locale_number(number):
  return '{:,}'.format(number)


def _magnitude_string(number):
  '''
    :param number: Number to convert to magnitude string.
    :return String describing number in magnitude (hundreds, thousands, etc.)
  '''
  magnitude = _find_magnitude(number, 10)
  magnitudes = (
          (0,  ''),
          (2,  ' hundred'),
          (3,  ' thousand'),
          (6,  ' million'),
          (9,  ' billion'),
          (12, ' trillion'),
          (13, '')
  )

  if magnitude >= magnitudes[-1][0]:
    return _build_magnitude_string_from_limit(number, magnitudes[-2], _locale_number)

  lower_limit = magnitudes[0]
  for upper_limit in magnitudes[1:]:
    log.debug(f'number: {number}, magnitude: {magnitude}, lower_limit: {lower_limit}: upper_limit: {upper_limit}')
    if magnitude >= lower_limit[0]:
      limit_limit = None
      upper_size = upper_limit[0]
      if magnitude < upper_size:
        limit_limit = lower_limit
      elif magnitude == upper_size:
        limit_limit = upper_limit
      if limit_limit is not None:
        return _build_magnitude_string_from_limit(number, limit_limit)
    lower_limit = upper_limit
  return str(number)


def humanise_number(number):
  '''Convert number to humanised string.
  '''
  result = HumanisedNumberTuple(_locale_number(number),
    magnitude_string=_magnitude_string(number)
  )
  return result

def do_run_humanise_number(number):
  """Do actual activity performed by this module.
    Parameters:
      number   - Number to convert to human readable strings.
    Returns:
      Tuple of: Human readable strings.
  """
  log.info('Running HumaniseNumber')
  return humanise_number(number)

# ==============================================================================
# Test code
# ==============================================================================


def test_humanise_number():
  """Test HumaniseNumber functionality."""
  return 1

# ==============================================================================
# Command line arguments code.
# ==============================================================================


def create_formatter_class_to_preserve_double_newlines(kls_formatter):
  """Create a formatting class which preserves double newlines.
      Parameters:
        kls_formatter - Base class for new HelpFormatter class.
      Returns:
        Formatter which preserves newlines.
  """

  # noinspection PyUnusedLocal
  def _fill_text(self, text, width, indent):
    """Fill the text but preserve newlines.
        Parameters:
          text  - Text to fill.
          width  - Maximum line length.
          indent  - Amount to indent text by.
        Returns:
          Filled text.
    """
    text = '\n\n'.join(map(textwrap.fill, text.split('\n\n')))
    return text

  str_kls_name = kls_formatter.__name__ + 'PreserveNewlines'
  dict_attributes = {
     '_fill_text': _fill_text,
    }
  if getattr(kls_formatter, '__doc__', None) is not None:
    dict_attributes['__doc__'] = kls_formatter.__doc__.replace(kls_formatter.__name__,
      str_kls_name)

  help_formatter_preserve_double_newlines = type(
    str_kls_name,
    (kls_formatter,),
    dict_attributes
  )
  return help_formatter_preserve_double_newlines

# ==============================================================================
# Script code
# ==============================================================================


def run_humanise_number(argv=None):
  """Execute the HumaniseNumber as a script.
    Parameters:
      argv    - Arguments to script.
    Returns:
      Exit code.
  """
  # Example command lines:
  import os        # linesep
  import time      # clock()
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
  # noinspection PyPep8Naming
  HelpFormatterPreserveDoubleNewlines = \
    create_formatter_class_to_preserve_double_newlines(argparse.HelpFormatter)
  # noinspection PyTypeChecker
  parser_run = argparse.ArgumentParser(description=r"""Convert number to something human readable.

For example: %(prog)s 12345 3333""",
    formatter_class=HelpFormatterPreserveDoubleNewlines
  )
  # noinspection PyUnusedLocal
  list_options = [
    parser_run.add_argument(
      '-n', '--number',
      dest='Numbers',
      type=int,
      action='append',
      help='Number to humanise'),
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

  if list_args:
    numbers = map(lambda s: s.replace(',', ''), list_args)
    numbers = list(map(int, numbers))
    if not vals_parse.Numbers:
      vals_parse.Numbers = numbers
    else:
      vals_parse.Numbers += numbers

  # Check arguments
  if not vals_parse.Numbers:  # If no numbers
    print('Error: No numbers specified')
    ok_to_continue = False

  if ok_to_continue:  # If OK to run
    time_start = None
    if vals_parse.Showtime:
      time_start = time.clock()
    for number in vals_parse.Numbers:
      human_number = do_run_humanise_number(number)
      #stream_out.write(str(human_number))
      stream_out.write(f'{human_number.locale_string} ({human_number.magnitude_string})')
      stream_out.write(os.linesep)
    time_stop = None
    if vals_parse.Showtime:
      time_stop = time.clock()
    # Finish up
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
  """Run the HumaniseNumber.
    Returns:
      Exit code.
  """
  import optparse
  result = 1
  try:
    result = run_humanise_number()
  except IOError as ioerrRun:
    if ioerrRun.args[0] == 22:  # If invalid argument
      pass
    else:
      raise
  except optparse.OptionError as errOpt:
    print(errOpt.option_id, errOpt.msg)
  return result


def test():
  """Test code for HumaniseNumber.
    Note that most tests belong in a separate test script using unit test.
  """
  result = None
  return result


def main():
  """Main entry point for module."""
  test() or sys.exit(run())


if __name__ == "__main__":
  main()
