import sys
from pathlib import Path

__version__ = "313.8.0"

_HERE = Path(__file__).parent

# Apple platforms get a Mach-O dylib; Linux and Android get an ELF .so.
LIB_NAME = "libPySwiftKit.dylib" if sys.platform == "darwin" else "libPySwiftKit.so"


def get_lib_dir() -> str:
    """Return the directory containing the PySwiftKit shared library.

    Use this when building user extension modules to set the correct rpath.

    From a user module's setup.py / build backend:
        rpath = pyswiftkit.get_lib_dir()
        # pass as linker flag: -rpath <rpath>

    The static rpath for user .so files (relative, embedded at link time):
        @loader_path/../../pyswiftkit
        (resolves site-packages/mymodule/mymodule.so → site-packages/pyswiftkit/)
    """
    return str(_HERE)


def get_lib_path() -> str:
    """Return the absolute path to the PySwiftKit shared library."""
    return str(_HERE / LIB_NAME)
