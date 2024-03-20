#!/usr/bin/env python3

'''
Test for XXX.
'''
import datetime
import unittest
import calendar_text


class TestDayRange(unittest.TestCase):
  def test_given_range_6_and_7_when_get_day_range_then_result_is_tuple_of_6_7(self):
    result = calendar_text.day_range('6,7')

    self.assertEqual(result, (6, 7))

  def test_given_range_6_to_7_when_get_day_range_then_result_is_tuple_of_6_7(self):
    result = calendar_text.day_range('6-7')

    self.assertEqual(result, (6, 7))

  def test_given_range_6_and_6_when_get_day_range_then_result_is_tuple_of_6(self):
    result = calendar_text.day_range('6,6')

    self.assertEqual(result, (6,))

  def test_given_range_6_to_6_when_get_day_range_then_result_is_tuple_of_6(self):
    result = calendar_text.day_range('6-6')

    self.assertEqual(result, (6,))

  def test_given_range_7_to_6_when_get_day_range_then_raises(self):
    with self.assertRaises(calendar_text.InvalidWeekdayRangeException) as reversed_context:
      calendar_text.day_range('7-6')

    self.assertIn('should be greater than lower', str(reversed_context.exception))

  def test_given_range_0_to_6_when_get_day_range_then_raises(self):
    with self.assertRaises(calendar_text.InvalidWeekdayRangeException) as invalid_context:
      calendar_text.day_range('0-6')

    self.assertIn('0', str(invalid_context.exception))

  def test_given_range_1_to_8_when_get_day_range_then_raises(self):
    with self.assertRaises(calendar_text.InvalidWeekdayRangeException) as invalid_context:
      calendar_text.day_range('1-8')

    self.assertIn('8', str(invalid_context.exception))


class TestMoveDateToMonday(unittest.TestCase):
  def test_given_june_10th_2018_then_result_is_june_11th_2018(self):
    start_date = datetime.date(year=2018, month=6, day=10)

    monday_date = calendar_text.move_date_to_monday(start_date)

    self.assertEqual(monday_date, datetime.date(year=2018, month=6, day=11))


class TestSummaryCalendarText(unittest.TestCase):
  def test_given_mon_wed_fri_5_weeks_from_june_10th_2018_then_result_is_5_tuples_of_3_in_june_2_in_july(self):
    start_date = datetime.date(year=2018, month=6, day=10)
    weekdays = (1, 3, 5)
    weeks = 5
    date_visitor = calendar_text.SummaryDateVisitor()

    result = calendar_text.do_run_calendar_text(weekdays, weeks, start_date, date_visitor)

    self.assertEqual(
      (
        'Jun 11, 13, 15'
        , 'Jun 18, 20, 22'
        , 'Jun 25, 27, 29'
        , 'Jul 02, 04, 06'
        , 'Jul 09, 11, 13'
      ),
      result
    )

  def test_given_mon_wed_fri_1_weeks_from_july_30th_2018_then_result_is_1_tuple_of_dates_straddling_august(self):
    start_date = datetime.date(year=2018, month=7, day=30)
    weekdays = (1, 3, 5)
    weeks = 1
    date_visitor = calendar_text.SummaryDateVisitor()

    result = calendar_text.do_run_calendar_text(weekdays, weeks, start_date, date_visitor)

    self.assertEqual(('Jul 30, Aug 01, 03',), result)

  def test_given_mon_wed_fri_1_weeks_from_december_31st_2018_then_result_is_1_tuple_of_dates_straddling_2019(self):
    start_date = datetime.date(year=2018, month=12, day=31)
    weekdays = (1, 3, 5)
    weeks = 1
    date_visitor = calendar_text.SummaryDateVisitor()

    result = calendar_text.do_run_calendar_text(weekdays, weeks, start_date, date_visitor)

    self.assertEqual(('Dec 31, 2019 Jan 02, 04',), result)

  def test_given_0_weeks_then_result_is_empty(self):
    start_date = datetime.date(year=2018, month=7, day=30)
    weekdays = (1, 3, 5)
    weeks = 0
    date_visitor = calendar_text.SummaryDateVisitor()

    result = calendar_text.do_run_calendar_text(weekdays, weeks, start_date, date_visitor)

    self.assertEqual((), result)

  def test_given_sat_sun_2_weeks_from_january_20th_2019_then_result_is_2_tuples_straddling_february(self):
    start_date = datetime.date(year=2019, month=1, day=20)
    weekdays = (6, 7)
    weeks = 2
    date_visitor = calendar_text.SummaryDateVisitor()

    result = calendar_text.do_run_calendar_text(weekdays, weeks, start_date, date_visitor)

    self.assertEqual(
        ('Jan 26, 27'
         , 'Feb 02, 03'),
        result
    )


if __name__ == '__main__':
  # import sys;sys.argv = ['', 'Test.testName']
  unittest.main()
