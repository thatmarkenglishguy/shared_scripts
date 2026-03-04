#!/usr/bin/env python3

import unittest
import human_readable_numbers

class TestHumanReadableNumbers(unittest.TestCase):
  def verify_comma_count(self, number, expected_comma_count):
      result = human_readable_numbers.humanise_number(number)

      self.assertEqual(result.locale_string.count(','), expected_comma_count)

  def verify_locale_string_is_number(self, number):
      result = human_readable_numbers.humanise_number(number)

      self.assertEqual(int(result.locale_string.replace(',', '')), number)

  def verify_magnitude_string(self, number, expected_magnitude_string):
      result = human_readable_numbers.humanise_number(number)

      self.assertEqual(result.magnitude_string, expected_magnitude_string, 'Expected on right')

  def test_tens_get_no_comma(self):
      self.verify_comma_count(20, 0)

  def test_tens_get_correct_value(self):
      self.verify_locale_string_is_number(20)

  def test_tens_get_one_ten_magnitude(self):
      self.verify_magnitude_string(20, '20')

  def test_hundreds_get_no_comma(self):
      self.verify_comma_count(200, 0)

  def test_hundreds_get_correct_value(self):
      self.verify_locale_string_is_number(200)

  def test_hundreds_get_one_hundred_magnitude(self):
      self.verify_magnitude_string(200, '2 hundred')

  def test_ten_thousands_get_one_comma(self):
      self.verify_comma_count(12345, 1)

  def test_ten_thousands_get_correct_value(self):
      self.verify_locale_string_is_number(12345)

  def test_ten_thousands_get_thousand_and_hundred_magnitude(self):
      self.verify_magnitude_string(12345, '12 thousand 3 hundred 45')

  def test_thousands_get_one_comma(self):
      self.verify_comma_count(2000, 1)

  def test_thousands_get_correct_value(self):
      self.verify_locale_string_is_number(2000)
      
  def test_thousands_get_thousand_magnitude(self):
      self.verify_magnitude_string(2000, '2 thousand')

  def test_millions_get_two_comma(self):
      self.verify_comma_count(2000000, 2)

  def test_millions_get_correct_value(self):
      self.verify_locale_string_is_number(2000000)

  def test_millions_get_one_million_magnitude(self):
      self.verify_magnitude_string(2000000, '2 million')

  TWO_TRILLION = 2 * (10 ** 15)
  def test_trillions_get_five_comma(self):
      self.verify_comma_count(self.TWO_TRILLION, 5)

  def test_trillions_get_correct_value(self):
      self.verify_locale_string_is_number(self.TWO_TRILLION)
      
  def test_number_in_trillions_gets_unformatted_magnitude(self):
      self.verify_magnitude_string(self.TWO_TRILLION, '2,000 trillion')

if __name__ == '__main__':
  # import sys;sys.argv = ['', 'Test.testName']
  unittest.main()
