#!/usr/bin/env python

"""Module used to CalendarText."""
from __future__ import print_function
import sys       # argv, exit()
import textwrap  # fill()
import datetime  # now(), timedelta()

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
# CalendarText code
# ==============================================================================

class InvalidWeekdayRangeException(Exception):
  pass


# def _day_range_token_to_tuple(day_range_token):
#   '''Convert a hypenatied day_range_token to a range.
#       :param day_range_token: Either hypenated numeric string, or simple number.
#   '''
#   range_strings = day_range_token.split('-')
#   range_lower = int(range_strings[0])
#
#   if len(range_strings) > 1:
#     range_upper = int(range_strings[-1])
#   else:
#     range_upper = range_lower
#
#   if range_lower < 1 or range_lower > 7:
#     raise InvalidWeekdayRangeException()
#
#   return range_lower, range_upper+1
#

def _day_range_token_to_tuple(day_range_token):
  '''Convert a hypenatied day_range_token to a range.
      :param day_range_token: Tuple of numbers in specified range.
  '''
  range_strings = day_range_token.split('-')
  range_lower = int(range_strings[0])

  if range_lower < 1 or range_lower > 7:
    raise InvalidWeekdayRangeException(f'Lower weekday range should be between 1 and 7: {range_lower}')

  if len(range_strings) > 1:
    range_upper = int(range_strings[-1])

    if range_upper < 1 or range_upper > 7:
      raise InvalidWeekdayRangeException(f'Upper weekday range should be between 1 and 7: {range_upper}')

    if range_upper < range_lower:
      raise InvalidWeekdayRangeException(f'Upper weekday range {range_upper} '
                                         f'should be greater than lower weekday range {range_upper}')
  else:
    range_upper = range_lower

  return tuple(range(range_lower, range_upper+1))


def day_range(day_range_string):
  '''Convert the specified string into a tuple.
      :param day_range_string: String from 1-7 inclusive delimited by commas or hyphen.
      :result Tuple of specified days
  '''
  tokens = map(str.strip, day_range_string.split(','))

  sequences = map(_day_range_token_to_tuple, tokens)

  sequences = sum(sequences, ())
  sequences = tuple(sorted(set(sequences)))

  return sequences


def move_date_to_monday(start_date):
  '''

  :param start_date: Date to start from seeking a Monday.
  :return: Nearest Monday datetime moving forward.
  '''
  one_day_delta = datetime.timedelta(days=1)
  while start_date.weekday() != 0:
    start_date += one_day_delta
  return start_date


def gen_do_run_calendar_text(weekdays, weeks, start_date):
  """Do actual activity performed by this module.
    Parameters:
      :param weekdays: Sequence of weekdays between 1(Monday) and 7(Sunday).
      :param weeks: Number of weeks to produce output for.
      :param start_date: Date to start from (defaults to now).
      :return Sequence of date strings containing specified weekdays.
  """
  log.info('Running CalendarText')
  if not weekdays:
    return

  if start_date is None: start_date = datetime.datetime.now()

  start_date = move_date_to_monday(start_date)

  week_counter = 0
  date_iterator = start_date
  week_delta = datetime.timedelta(weeks=1)
  weekday_deltas = tuple(map(lambda n: datetime.timedelta(days=n-1), weekdays))

  while week_counter < weeks:
    weekday_datetime = date_iterator + weekday_deltas[0]
    output = weekday_datetime.strftime('%b ')  # Month abbreviated
    weekday_output = []
    for weekday_delta in weekday_deltas:
      previous_weekday_datetime = weekday_datetime
      weekday_datetime = date_iterator + weekday_delta
      output_string = ''

      if weekday_datetime.year != previous_weekday_datetime.year:
        output_string += weekday_datetime.strftime('%Y ')  # New Year

      if weekday_datetime.month != previous_weekday_datetime.month:
        output_string += weekday_datetime.strftime('%b ')  # New Month abbreviation

      output_string += weekday_datetime.strftime('%d')  # Day of month
      weekday_output.append(output_string)
    output += str.join(', ', weekday_output)
    yield output
    date_iterator += week_delta
    week_counter += 1


def do_run_calendar_text(weekdays, weeks, start_date):
  """Do actual activity performed by this module.
    Parameters:
      :param weekdays: Sequence of weekdays between 1(Monday) and 7(Sunday).
      :param weeks: Number of weeks to produce output for.
      :param start_date: Date to start from (defaults to now).
      :return Sequence of date strings containing specified weekdays.
  """
  log.info('Running CalendarText')
  return tuple(gen_do_run_calendar_text(weekdays, weeks, start_date))


# ==============================================================================
# Command line arguments code.
# ==============================================================================


def test_calendar_text():
  """Test CalendarText functionality."""
  return 1

# ==============================================================================
# Script code
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
# Module entry code
# ==============================================================================


def run_calendar_text(argv=None):
  """Execute the CalendarText as a script.
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
  parser_run = argparse.ArgumentParser(description=r"""Description of what CalendarText
actually does.

For example: %(prog)s SomeFile.xml -e SomeElement -a SomeAttribute=foo""",
    formatter_class=HelpFormatterPreserveDoubleNewlines
  )
  # noinspection PyUnusedLocal
  list_options = [
    parser_run.add_argument(
      '-d', '--days',
      dest='Days',
      help='Weekdays to include in output. Hyphen for range, comma for separate entry. 1-7,'
           'Defaults to 6,7 (Saturday, Sunday)'),
    parser_run.add_argument(
      '-w', '--weeks',
      dest='Weeks',
      type=int,
      help='Number of weeks to produce output for. Defaults to 5.'),
    parser_run.add_argument(
      '-s', '--start',
      dest='Start',
      help='Start date in format "<Month Titlecase 3 letter abbreviation> <day as number> <year as 4 digit number>". '
           'Defaults to today.'),
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

  if vals_parse.Days is None and list_args:
    vals_parse.Days = list_args.pop(0)

  if vals_parse.Weeks is None and list_args:
    vals_parse.Weeks = int(list_args.pop(0))

  if vals_parse.Start is None and list_args:
    vals_parse.Start = list_args.pop(0)

  # Check arguments
  if vals_parse.Days is None:
    weekdays = (6, 7)
  else:
    weekdays = day_range(vals_parse.Days)

  if vals_parse.Weeks is None:
    weeks = 5
  else:
    weeks = vals_parse.Weeks

  if vals_parse.Start is None:
    start_date = datetime.datetime.now()
  else:
    start_date = datetime.datetime.strptime(vals_parse.Start, '%b %d %Y')

  if ok_to_continue:  # If OK to run
    time_start = None
    if vals_parse.Showtime:
      time_start = time.clock()

    calendar_strings = do_run_calendar_text(weekdays, weeks, start_date)

    time_stop = None
    if vals_parse.Showtime:
      time_stop = time.clock()
    # Finish up
    for calendar_string in calendar_strings:
        stream_out.write(calendar_string)
        stream_out.write('\n')
    # Show time
    if vals_parse.Showtime:  # If showing time
      sys.stderr.write('That took: %.04f\n' % (time_stop - time_start))
  else:  # Else not OK to run
    result = 1
  return result


def run():
  """Run the CalendarText.
    Returns:
      Exit code.
  """
  import optparse
  result = 1
  try:
    result = run_calendar_text()
  except IOError as ioerrRun:
    if ioerrRun.args[0] == 22:  # If invalid argument
      pass
    else:
      raise
  except optparse.OptionError as errOpt:
    print(errOpt.option_id, errOpt.msg)
  return result


def main():
  """Main entry point for module."""
  sys.exit(run())


if __name__ == "__main__":
  main()