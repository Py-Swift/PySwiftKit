package_path = "PySwiftKit/Package.swift"

def get_package_swift() -> str:
    text = ""
    with open(package_path, "r") as rf:
        text = rf.read()
    return text

def write_package_swift(path, content):
    with open(path, "w") as f:
        old = "PythonSwiftLink/PythonCore"
        new = "KivySwiftLink/PythonCore"
        package_text = content.replace(old, new)
        f.write(package_text)
    
write_package_swift(
    package_path, 
    get_package_swift()
)
