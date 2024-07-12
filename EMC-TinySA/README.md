# EMC-experiments - EEZ Studio EMC

### THIS IS STILL PROOF OF CONCEPT, ONCE I CONFIRM EVERYTING IS WORKING I WILL REMOVE THIS LINE !!!

### Check what levels you equipement can handle, tinySA is very sensitive so be carefull!

### Do not brodcast any frequency out of it's legal limits!

### If you use amplifier connect it to receiving port!

## Initial Software idea

![Initial software idea](pictures/Initial_software_flow.png)

## How to use

Download and install ![EEZ Studio](https://github.com/eez-open/studio)

Download ![EEZ meassuring project](https://github.com/intergalaktik/EMC-experiments/tree/main/EMC-TinySA/EEZ)

You can first do meassurements then connect your SA and get measurements into computer.

## Measurements

### Amplifier

Be carefull not to burn your equipement, use attenuators to lower signal strength. 

Once you are sure signal is not to strong you can decrease attenuation.

With this measurements we will get amplification for each frequency we will meassure later.

Setup one TinySA in signal generator mode.

Set FREQ, in our case we will have this set to 500MHz.

Set level - in our case that is -30dBm

Set SWEEP to some range in our case SPAN will be 1GHz

Set SWEEP time - in our case 600s

Press BACK 

On attenuator set attenuation to for high level - in our case -30dBm

Connect atenuator to receiving tinySA

In Spectrum analyser mode set FREQUENCY

START 30 MHz, STOP 1GHz

Enable Trace1 

Set CALC to MAX HOLD

on TX tiny Start SWEEP and LOW output ON

Wait untli you get nice filled line (at least 10 minutes as that is one pass).

Once you have done meassurements you can FREEZE that trace.

You can turn off your sending tiny and disconnect receiving one.

Open EEZ meassuring project, connect receiving tiny and start the project.

Click on Settings

Change amplification settings - "TX Signal(dBm)" and "Attenuator(dBm)"

Click on Save and Back

Click on "Get trace 1"

Click on "TR1 - dBm > GAIN"

Now you can save graph with "Add to Instrument History"

Or you can use "Export JSON" and "Import JSON"

On the graph you can enable or disable some lines by clicking on there name in top right corner.

Also on top right corner of plotty you will find autoscale button.

### Antennas

We need to have two identical antennas

You will need to find low noise location, for example basement.

We will use same range for the antennas from 30MHz to 1GHz so you will have same setup.

Distance antennas (best 1m or more) I did 0.5m as then lower power is needed.

Use some holder to hold antennas at some level (like 1m).

Connect one antena to TX and one to RX tinySA.

Do not connect amplifier, you can do everything wihout one.

Use same settings on both tinySA devices.

Now set "TRACE 2" on RX device to MAX HOLD.

Star SWEEP with TX device and you should get nice line after some time (10-30min).

Now you have TRACE 1 and TRACE 2

Connect RX device to EEZ meassuring project and get TRACE 1 and TRACE 2

Click on Settings

Change amplification settings - "TX Signal(dBm)" and "Attenuator(dBm)"

Change Antenna Measurements settings - Distance(m)" and "TX Signal(dBm)" <- this can be different then TX Signa used for amplifier.

Click on Save and Back

Click on "Get trace 1"

Click on "TR1 - dBm > GAIN"

Click on "Get trace 2"

Click on "TR2 + dBm > ANT"

Now you should also have antenna caracteristics.

I got those formulas from chatGPT so I am still not confident that all calculations are correct

![GPT1](pictures/gpt1.png)

![GPT2](pictures/gpt2.png)

## Chamber noise

Use amplifier and MAX hold and save to TRACE 3

Click on "COPY TR3 > CHA" to get chamber noise inside studio.

## DUT - calculations are still not in place!!!

Put device into chamber

Use amplifier and MAX hold and save to TRACE 5

Click on "COPY TR4 > DUT" to get device meassurements into graph.

Export your JSON and add it to instrument history, as then you can reuse it any time!

V1 version of software

![SW v1.0](pictures/software_v1.png)

Settings screen

![Settings](pictures/settings.png)

## Funding

This project is funded through the [NGI Zero Entrust Fund](https://nlnet.nl/entrust), a fund
established by [NLnet](https://nlnet.nl) with financial support from the European Commission's
[Next Generation Internet](https://ngi.eu) program. Learn more on the [NLnet project page](https://nlnet.nl/project/Balthazar-Casing/).

[<img src="https://nlnet.nl/logo/banner.png" alt="NLNet foundation logo" width="300" />](https://nlnet.nl)
[<img src="https://nlnet.nl/image/logos/NGI0Entrust_tag.svg" alt="NGI0 Entrust Logo" width="300" />](https://nlnet.nl/entrust)

https://nlnet.nl/project/BB3-CM4

## Check up our blogposts

https://intergalaktik.eu/news

## Contact us

Discord: https://discord.gg/qwMUk6W
