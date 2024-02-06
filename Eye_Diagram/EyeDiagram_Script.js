// This script will build a custom signal.
// The signal is trapezoidal. Parameters allow the user to
// change the rise/fall times and the noise level.

////////////////////////////////////////////////////////////////
// Script parameters
////////////////////////////////////////////////////////////////
transitionTime = 60 // The transitionTime must be between 0 and 100
noiseLevel = 100 // The noiseLevel must be between 0 and 100


////////////////////////////////////////////////////////////////
// Misc. initializations
////////////////////////////////////////////////////////////////
clear()
// Test if scope and wavegen are opened
if(!('Wavegen' in this) || !('Scope' in this))
    throw "Please open a Scope and a Wavegen instrument";

////////////////////////////////////////////////////////////////
// Scope configuration
////////////////////////////////////////////////////////////////
Scope1.Channel2.setDisable()            // Disable channel 2
Scope1.Channel1.Offset.value = 0        // Channel 1 offset to 0V
Scope1.Channel1.Range.value = 5         // Channel 1 range to 500mV/div
Scope1.Time.Base.value = 0.002          // Timescale to 200us/div
if(Scope1.window.eye == undefined)      // If the eye window is in undefined state, enable it
    Scope1.window.toggleEye()
Scope1.Eye.Lock.value = 1
Scope1.Eye.Rate.value = 5000            // Eye diagram rate to 5kHz
print("Scope 1 configured.")

////////////////////////////////////////////////////////////////
// Custom signal creation
////////////////////////////////////////////////////////////////
// Create the signal array
level = -1

wave = Array()
for(var i = 0; i < 80; i++)
{
    precLevel = level

    // Set the level for the current symbol (-1 or 1)
    if(i < 79)
    {
        // Randomly pick a level
        level = random() > 0.5 ? 1 : -1
    }
    else
    {
        // Always low for last symbol because the first one always starts with a rising edge
        level = -1
    }

    // Transition between two symbols
    randTransitionTime = transitionTime + (random() - 0.5)*40
    incr = (level - precLevel) / randTransitionTime
    val = precLevel
    for(var j = 0; j < randTransitionTime; j++)
    {
        val = val + incr
        wave.push(addNoise(val, noiseLevel))
    }

    for(var j = 0; j < 200-randTransitionTime; j++)
    {
        wave.push(addNoise(level, noiseLevel))
    }
}

////////////////////////////////////////////////////////////////
// Custom signal output on Wavegen
////////////////////////////////////////////////////////////////
Wavegen1.Channel1.Mode.text = "Eye_Diagram_Test"
Wavegen1.Custom.set("Eye_Diagram_Test", wave)

print("Wavegen 1 signal built and set.")

////////////////////////////////////////////////////////////////
// Run the Wavegen and the Scope
////////////////////////////////////////////////////////////////
Wavegen1.Channel1.run()
Scope1.run()

print("Wavegen and Scope running. Script is finished.")


////////////////////////////////////////////////////////////////
// Add some noise to a sample
////////////////////////////////////////////////////////////////
function addNoise(sample, noiseLevel)
{
    // Random number from -0.1 to 0.1
    noise = (random() - 0.5) / 5

    // Scale the noise from noiseLevel
    noise = noise * noiseLevel / 100

    // Scale the input sample value so we do not have an overflow
    scaledSample = sample * 0.9

    return scaledSample + noise
}





// EOF