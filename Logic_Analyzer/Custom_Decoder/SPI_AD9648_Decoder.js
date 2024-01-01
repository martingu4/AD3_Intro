// rgData: input, raw digital sample array
// rgValue: output, decoded data array
// rgFlag: output, decoded flag array

var rec_val = 0;     // Receive value buffer
var Rcv_state = 0;   // Receive state-machine state
var Sclk_prec = 0;   // Previous clock state
var bits_cnt = 0;    // Bits counter
var payload_length;  // The data payload has variable length specified in the INSTR 16-bits word

// Variables for rgValue and rgFlag management
var start_Idx = 0;
var len = 0;

// Loop on all samples
for(var i = 0; i < rgData.length; i++)
{
    // By default, set all samples to IDLE.
        // Values will be changed for samples not in IDLE
    rgValue[i] = 0;
    rgFlag[i] = 0;

    // Increment the amount of samples for the current state
        // This value will be used to write the output values and
        // flags for the whole state at once.
    len = len + 1;

    ///////////////////////////////////////////////
    // Extract the signals from pins 0, 1 and 2
    ///////////////////////////////////////////////
    var CS_val = 1 & (rgData[i] >> 0);
    var Sclk_val = 1 & (rgData[i] >> 1);
    var data = 1 & (rgData[i] >> 2);

    ///////////////////////////////////////////////
    // Switch on the current receiver state.
    // The state machine handles the message reception
    // phases.
    ///////////////////////////////////////////////
    switch(Rcv_state)
    {
    // IDLE state: CS is inactive
    case 0:
        // CS active: go to INSTR state
        if(CS_val == 0)
        {
            // Go to INSTR state
            Rcv_state = 1;

            // Clear the receive buffer
            bits_cnt = 0;
            rec_val = 0;

            // Set start index and length variables for next state
            start_Idx = i;
            len = 0;
        }
        break;

    // INSTR state: 16-bits instruction is being received
    case 1:

        // Data bits are sampled on clock rising-edges
        if(Sclk_prec == 0 && Sclk_val != 0)
        {
            // Increment the bits counter
            bits_cnt++;

            // Insert the new bit
            rec_val <<= 1;
            rec_val |= data;
        }

        // Check for the end of INSTR phase (16-bits received)
            // This check is performed on falling-edge
        if(Sclk_prec != 0 && Sclk_val == 0)
        {
            if(bits_cnt == 16)
            {
                // Insert the INSTR flag with the data
                for(var j = 0; j < len; j++)
                {
                    rgFlag[start_Idx+j] = 1;
                    rgValue[start_Idx+j] = rec_val;
                }

                // Extract the payload length from the INSTR word
                payload_length = ((rec_val >> 13) & 0x03) + 1;

                if(payload_length == 0)
                {
                    // Go to IDLE state
                    Rcv_state = 0;
                    start_Idx = i;
                    len = 0;
                }
                else
                {
                    // Reset the receive buffer
                    bits_cnt = 0;
                    rec_val = 0;

                    // Go to DATA state
                    Rcv_state = 2;
                    start_Idx = i;
                    len = 0;
                }
            }
        }

        // CS is inactive before end of instruction: ERROR
            // (don't check for clock here because when CS is de-asserted,
            // the clock signal is disabled)
        if(CS_val == 1)
        {
            // Insert error flags starting from the beginning of INSTR phase
            for(var j = 0; j < len; j++)
                rgFlag[start_Idx+j] = 3;

            // Go to IDLE state
            Rcv_state = 0;

            // Set start index and length variables for next state
            start_Idx = i;
            len = 0;
        }
        break;

    // DATA state: x-bytes data is being received
    case 2:
        // Data bits are sampled on clock rising-edges
        if(Sclk_prec == 0 && Sclk_val != 0)
        {
            // Increment the bits counter
            bits_cnt++;

            // Insert the new bit
            rec_val <<= 1;
            rec_val |= data;
        }

        // When CS is de-asserted, check for the amount of bits received
        if(CS_val == 1)
        {
            // We received the correct amount of bits: no error
            if(bits_cnt == (8*payload_length))
            {
                // Insert the DATA flag with the data
                for(var j = 0; j < len; j++)
                {
                    rgFlag[start_Idx+j] = 2;
                    rgValue[start_Idx+j] = rec_val;
                }

                // Go to IDLE state
                Rcv_state = 0;
                start_Idx = i;
                len = 0;
            }
            else // Bad amount of bits received: ERROR
            {
                // Insert error flags starting from the beginning of DATA phase
                for(var j = 0; j < len; j++)
                    rgFlag[start_Idx+j] = 4;
    
                // Go to IDLE state
                Rcv_state = 0;
    
                // Set start index and length variables for next state
                start_Idx = i;
                len = 0;
            }
        }
        break;

    default:
        break;
    }

    // Store previous clock value
    Sclk_prec = Sclk_val;
}