#!/usr/bin/env python3

import unittest
import human_readable_numbers

class TestHumanReadableNumbers(unittest.TestCase):
  def test_ten_gets_no_comma(self):
      number = 20

      result = human_readable_numbers.humanise_number(number)

      self.assertEqual(result.locale_string.count(','), 0)
      self.assertEqual(int(result.locale_string.replace(',', '')), number)

  def test_ten_gets_one_ten_magnitude(self):
      number = 20

      result = human_readable_numbers.humanise_number(number)

      self.assertEqual(result.magnitude_string, '20')

  def test_hundred_gets_no_comma(self):
      number = 200

      result = human_readable_numbers.humanise_number(number)

      self.assertEqual(result.locale_string.count(','), 0)
      self.assertEqual(int(result.locale_string.replace(',', '')), number)

  def test_hundred_gets_one_hundred_magnitude(self):
      number = 200

      result = human_readable_numbers.humanise_number(number)

      self.assertEqual(result.magnitude_string, '2 hundred')

  def test_ten_thousand_gets_one_comma(self):
      number = 12345

      result = human_readable_numbers.humanise_number(number)

      self.assertEqual(result.locale_string.count(','), 1)
      self.assertEqual(int(result.locale_string.replace(',', '')), number)

  def test_ten_thousand_gets_thousand_magnitude(self):
      number = 12345

      result = human_readable_numbers.humanise_number(number)

      self.assertEqual(result.magnitude_string, '12 thousand 3 hundred 45')

  def test_thousand_gets_one_comma(self):
      number = 2000

      result = human_readable_numbers.humanise_number(number)

      self.assertEqual(result.locale_string.count(','), 1)
      self.assertEqual(int(result.locale_string.replace(',', '')), number)

  def test_thousand_gets_thousand_magnitude(self):
      number = 2000

      result = human_readable_numbers.humanise_number(number)

      self.assertEqual(result.magnitude_string, '2 thousand')

  def test_million_gets_two_comma(self):
      number = 2000000

      result = human_readable_numbers.humanise_number(number)

      self.assertEqual(result.locale_string.count(','), 2)
      self.assertEqual(int(result.locale_string.replace(',', '')), number)

  def test_million_gets_one_million_magnitude(self):
      number = 2000000

      result = human_readable_numbers.humanise_number(number)

      self.assertEqual(result.magnitude_string, '2 million')

  def test_next_over_trillion_gets_five_comma(self):
      number = 2 * (10 ** 15)

      result = human_readable_numbers.humanise_number(number)

      self.assertEqual(result.locale_string.count(','), 5)
      self.assertEqual(int(result.locale_string.replace(',', '')), number)

  def test_next_over_trillion_gets_unformatted_magnitude(self):
      number = 2 * (10 ** 15)

      result = human_readable_numbers.humanise_number(number)

      self.assertEqual(result.magnitude_string, '2,000 trillion')

if __name__ == '__main__':
  # import sys;sys.argv = ['', 'Test.testName']
  unittest.main()
