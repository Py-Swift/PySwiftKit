from unittest import TestCase, main
from numbers import Number
from numbers import Integral
from typing import SupportsInt

from pyswiftwrapper import NumericTestClass # pyright: ignore[reportMissingImports] # typing: ignore

class TestNumericTestClass():
    def __init__(self):
        self.obj = NumericTestClass("abc")
        
        self.test_addition()
        self.test_subtraction()
        self.test_multiplication()
        self.test_division()
    
    def setUp(self):
        #self.obj = NumericTestClass()
        #self.r = NumericTestClass()
        ...

    def test_addition(self):
        
        result = self.obj + 5
        assert result == 10
        if result == 10:
            print("Addition test passed.")
        else:
            print("Addition test failed.")
            raise AssertionError("Addition test failed.")

    def test_subtraction(self):
        result = self.obj - 4
        if result == 10:
            print("Subtraction test passed.")
        else:
            print("Subtraction test failed.")
            raise AssertionError("Subtraction test failed.")

    def test_multiplication(self):
        result = self.obj * 6
        if result == 18:
            print("multiplication test passed.")
        else:
            print("multiplication test failed.")
            raise AssertionError("multiplication test failed.")

    def test_division(self):
        result = self.obj / 5
        if result == 3:
            print("division test passed.")
        else:
            print("division test failed.")
            raise AssertionError("division test failed.")

    # def test_division_by_zero(self):
    #     with self.assertRaises(ZeroDivisionError):
    #         self.obj / 0


if __name__ == "__main__":
    TestNumericTestClass()
