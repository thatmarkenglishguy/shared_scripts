#!/usr/bin/env python3

"""Module used to CalendarText."""
from __future__ import print_function
import sys       # argv, exit()
import textwrap  # fill()
import datetime  # now(), timedelta()
from io import StringIO


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


class DateVisitor(object):
  """Does things with dates.
  """
  def __init__(self):
    super().__init__()


class SummaryDateVisitor(DateVisitor):
  """Summaries dates. Outputs month each time cross month line.
  """
  def __init__(self):
    super().__init__()
    self.output = StringIO()
    self.line_output = StringIO()
    self.lines = []

  def _append(self, item):
    self.output.write(item + ' ')

  def _line_item(self, item):
    self.line_output.write(item + ' ')

  def _line_finish(self, item):
    self.line_output.write(item)

  def _finish(self, item):
    self.output.write(item)

  def start_with_month(self, date):
    self._append(date.strftime('%b'))

  def start_year(self, date):
    self._line_item(date.strftime('%Y'))

  def start_month(self, date):
    self._line_item(date.strftime('%b'))

  def add_day(self, date):
    self._line_finish(date.strftime('%d'))
    self.lines.append(self.line_output.getvalue())
    self.line_output = StringIO()

  def finish_days(self):
    days = ', '.join(self.lines)
    self.lines = []
    self._finish(days)

  def consume(self):
    result = self.output.getvalue()
    self.output = StringIO()
    return result

class PollDateVisitor(DateVisitor):
  """Poll consisting of dates. 
  """
  def __init__(self, poll):
    super().__init__()
    self.current_month = None
    self.output = StringIO()
    self.output.write(f'"{poll}" ')
    self.line_output = StringIO()
    self.lines = []

  def _append(self, item):
    self.output.write(item + ' ')

  def _line_item(self, item):
    self.line_output.write(item + ' ')

  def _line_finish(self, item):
    self.line_output.write(item)

  def _finish(self, item):
    self.output.write(item)

  def start_with_month(self, date):
    self.current_month = date.strftime('%b')

  def start_year(self, date):
    self._line_item(date.strftime('%Y'))

  def start_month(self, date):
    self.current_month = date.strftime('%b')

  def add_day(self, date):
    self._line_finish(f'"{date.strftime("%a")} {self.current_month} {date.strftime("%d")}"')
    self.lines.append(self.line_output.getvalue())
    self.line_output = StringIO()

  def finish_days(self):
    days = ' '.join(self.lines)
    self.lines = []
    self._finish(days)

  def consume(self):
    result = self.output.getvalue()
    self.output = StringIO()
    return result

def gen_do_run_calendar_text(weekdays, weeks, start_date, date_visitor):
  """Do actual activity performed by this module.
    Parameters:
      :param weekdays: Sequence of weekdays between 1(Monday) and 7(Sunday).
      :param weeks: Number of weeks to produce output for.
      :param start_date: Date to start from (defaults to now).
      :param date_visitor: Handles dates.
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
    date_visitor.start_with_month(weekday_datetime)
    for weekday_delta in weekday_deltas:
      previous_weekday_datetime = weekday_datetime
      weekday_datetime = date_iterator + weekday_delta

      if weekday_datetime.year != previous_weekday_datetime.year:
        date_visitor.start_year(weekday_datetime)

      if weekday_datetime.month != previous_weekday_datetime.month:
        date_visitor.start_month(weekday_datetime)

      date_visitor.add_day(weekday_datetime)
    date_visitor.finish_days()
    yield date_visitor.consume()
    date_iterator += week_delta
    week_counter += 1


def do_run_calendar_text(weekdays, weeks, start_date, date_visitor):
  """Do actual activity performed by this module.
    Parameters:
      :param weekdays: Sequence of weekdays between 1(Monday) and 7(Sunday).
      :param weeks: Number of weeks to produce output for.
      :param start_date: Date to start from (defaults to now).
      :param date_visitor: Handles dates.
      :return Sequence of date strings containing specified weekdays.
  """
  log.info('Running CalendarText')
  return tuple(gen_do_run_calendar_text(weekdays, weeks, start_date, date_visitor))


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
  parser_run = argparse.ArgumentParser(description=r"""Output calendar dates.

For example:

%(prog)s --days 1-7 --start 'Mar 09 2024' --weeks 5

%(prog)s --days 1-7 --start 'Mar 09 2024' --weeks 2 --poll \ 'When do you need a cat sitter?'
""",
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
      '--summary',
      dest='Format',
      action='store_const',
      const=SummaryDateVisitor,
      help='Output in summary format.'),
    parser_run.add_argument(
      '-p', '--poll',
      dest='Poll',
      help='Use poll format output, where the poll question is the argument to this parameter.'),
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

  end_of_line_delim = '\n'
  if vals_parse.Format is None:
    if vals_parse.Poll:
      date_visitor = PollDateVisitor(vals_parse.Poll)
      end_of_line_delim = ' '
    else:
      date_visitor = SummaryDateVisitor()
  else:
    date_visitor = vals_parse.Format()

  if ok_to_continue:  # If OK to run
    time_start = None
    if vals_parse.Showtime:
      time_start = time.clock()

    calendar_strings = do_run_calendar_text(weekdays, weeks, start_date, date_visitor)

    time_stop = None
    if vals_parse.Showtime:
      time_stop = time.clock()
    # Finish up
    for calendar_string in calendar_strings:
      stream_out.write(calendar_string)
      stream_out.write(f'{end_of_line_delim}')
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
