#!/usr/bin/env python3
'''
Tests for date_difference.
'''
import unittest
import date_difference

class TestDateDiff(unittest.TestCase):
  def verify_dates(self, start_date, end_date, expected_days):
    result = date_difference.do_run_date_diff(start_date, end_date)

    self.assertEqual(result, expected_days, 'result on left, expected on right')

  def test_same_date_is_zero(self):
    self.verify_dates('15 04 2024', '15 04 2024', 0)

  def test_one_day(self):
    self.verify_dates('15 04 2024', '16 04 2024', 1)

  def test_one_day_reversed(self):
    self.verify_dates('16 04 2024', '15 04 2024', 1)

  def test_five_days_different_months(self):
    self.verify_dates('29 04 2024', '04 05 2024', 5)

  def test_leap_year(self):
    self.verify_dates('28 02 2024', '01 03 2024', 2)

  def test_non_leap_year(self):
    self.verify_dates('28 02 2023', '01 03 2023', 1)


if __name__ == '__main__':
  unittest.main()
