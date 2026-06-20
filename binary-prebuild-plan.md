

# make command plugin for building the Macro generators as prebuild binary
* PySwiftKit/Sources/PySwiftGenerators
* PySwiftKit/Sources/PyWrapperInternal

make a command plugin that does we dont need to build full swift-syntax all the time
and instead these binaries is used.

soo command plugin is used to generate the binaries for the macroes, and can add them as assets in a github release..

but also do we can inject environment value for path to them, since atm there is no github release / assets to run binaries from.. 

because having to build swift-syntax always is becoming annoying

for now just make it work for macos, we can try linux after when macos is perfect ..
