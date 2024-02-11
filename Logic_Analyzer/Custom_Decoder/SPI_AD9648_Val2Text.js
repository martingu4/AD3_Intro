// value: value sample
// flag: flag sample

function Value2Text(flag, value)
{
    switch(flag)
    {
    // IDLE flag
    case 0:
        return "X";

    // INSTR flag, print R/W, W1|W0 and address
    case 1:

        // Decode the R/W bit
        var RW_str;
        if((value & 0x8000) == 0)
            RW_str = "W";
        else
            RW_str = "R";

        // Decode the word length field
        var WL_str = (((value >> 13) & 0x03) + 1).toString(10);
        
        // Extract the address
        var Addr_str = "0x" + (value & 0x1FFF).toString(16).toUpperCase();

        return RW_str + " " + WL_str + " byte(s) at " + Addr_str;
    
    // DATA flag, print the data payload
    case 2:
        return "D=0x" + value.toString(16).toUpperCase();

    // ERROR: CS de-asserted in the middle of INSTR phase
    case 3:
        return "ERROR: INSTR not fully received.";
    
    // ERROR: CS de-asserted when invalid amount of data bits were received
    case 4:
        return "ERROR: Invalid amount of data bits.";

    // The default case should never happen
    default:
        return "Unhandled case (val = " + value.toString(10).toUpperCase() + ")";
    }
}