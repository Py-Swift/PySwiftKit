

@wrapper
class TestClassA: ...

@wrapper
class TestClassB: ...


@wrapper
class StaticClassTest:
    
    @staticmethod
    def testA(): ...
    
    @staticmethod
    def testB(count: int, n: int): ...
    
    @staticmethod
    def add_callback(cb: object): ...
    
    class Callbacks(list):
        
        a: int
        
        
