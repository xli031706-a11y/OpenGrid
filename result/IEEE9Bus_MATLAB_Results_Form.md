
## 3. Base-case power-flow results


### 3.1 Busbar / node results

| Bus | Type / connected blocks | Voltage (pu) | Phase angle (°) | Active injection (MW) | Reactive injection (MVAr) | Voltage check / note |
|---:|---|---:|---:|---:|---:|---|
| 1 | Swing generator |  |  | **76.4*** | **27.5*** |  |
| 2 | PV generator |  |  |  |  |  |
| 3 | PV generator |  |  |  |  |  |
| 4 | Generator tie / network |  |  |  |  |  |
| 5 | PQ load |  |  |  |  |  |
| 6 | PQ load |  |  |  |  |  |
| 7 | Generator tie / network |  |  |  |  |  |
| 8 | PQ load |  |  |  |  |  |
| 9 | Generator tie / network |  |  |  |  |  |

\*The starred Bus 1 values are the published MathWorks example values, not a substitute for the student's result. Record the student's own output in the blank cells and note any difference.

### 3.2 Generator results

| Generator | Bus | Active output (MW) | Reactive output (MVAr) | Terminal voltage (pu) | Voltage angle (°) | Limit / note |
|---|---:|---:|---:|---:|---:|---|
| G1 / swing | 1 | 76.4* | 27.5* |  |  |  |
| G2 | 2 |  |  |  |  |  |
| G3 | 3 |  |  |  |  |  |
| Wind plant, if modeled | 5 |  |  |  |  |  |

### 3.3 Line and transformer results

\
| Connection / block | From bus | To bus | P at from end (MW) | Q at from end (MVAr) | P at to end (MW) | Q at to end (MVAr) | RMS current (A) | Rating (MVA) | Loading (%) | Real loss (kW) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
|  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |

For balanced three-phase RMS current calculated from measured P/Q and line-to-line RMS voltage:

\[
I_{RMS}=\frac{\sqrt{P^2+Q^2}}{\sqrt{3}V_{LL}}
\]

```latex
I_{RMS}=\frac{\sqrt{P^2+Q^2}}{\sqrt{3}V_{LL}}
```

Calculate thermal loading from the measured apparent power and the documented MVA rating:

\[
\text{Loading (\%)}=100\frac{\sqrt{P^2+Q^2}}{S_{rated}}
\]

```latex
\text{Loading (\%)}=100\frac{\sqrt{P^2+Q^2}}{S_{rated}}
```

Calculate each element's real-power loss from simultaneous measurements at both terminals, using one consistent direction into the element:

\[
P_{loss}=P_{in}-P_{out}
\]

```latex
P_{loss}=P_{in}-P_{out}
```

### 3.4 Power-balance summary

| Quantity | MATLAB result |
|---|---:|
| Total generator active power (MW) |  |
| Wind-plant active power (MW), if present |  |
| Total load active power (MW) |  |
| Total measured line loss (MW) |  |
| Total measured transformer loss (MW) |  |
| Other modeled loss (MW) |  |
| Active-power balance residual (MW) |  |
| Total generator reactive power (MVAr) |  |
| Total load reactive power (MVAr) |  |
| Minimum bus voltage (pu) and bus number |  |
| Maximum bus voltage (pu) and bus number |  |
| Maximum line loading (%) and connection |  |
| Voltage / thermal violations |  |

## 4. Base case versus 54 MW wind case


| Metric | MATLAB base case | MATLAB wind case | Change |
|---|---:|---:|---:|
| Wind output (MW) | 0 |  |  |
| G1 active output (MW) |  |  |  |
| G2 active output (MW) |  |  |  |
| G3 active output (MW) |  |  |  |
| Total system losses (MW) |  |  |  |
| Bus 5 voltage (pu) |  |  |  |
| Minimum bus voltage (pu) |  |  |  |
| Maximum branch loading (%) |  |  |  |
| Voltage violations |  |  |  |

## 5. Dynamic load-step results


| Dynamic-case metadata | Value |
|---|---|
| Load-step bus | 6 |
| Load-step size (MW / MVAr) |  |
| Step start time (s) |  |
| Simulation stop time (s) |  |
| RMS window / filter |  |
| Rotor-angle reference machine |  |
| Settling band |  |

| Time-domain metric | G1 | G2 | G3 | System / bus |
|---|---:|---:|---:|---:|
| Prefault frequency (Hz) |  |  |  |  |
| Frequency nadir (Hz) |  |  |  |  |
| Time of frequency nadir (s) |  |  |  |  |
| Frequency settling time (s) |  |  |  |  |
| Maximum rotor-angle deviation (°) |  |  |  |  |
| Maximum rotor-angle separation (°) |  |  |  |  |
| Terminal voltage minimum (pu) |  |  |  |  |
| Terminal voltage settling time (s) |  |  |  |  |
| Active-power change after step (MW) |  |  |  |  |
| Reactive-power change after step (MVAr) |  |  |  |  |


## 6. Fault, voltage-sag, and protection results


| Fault-case input | Value |
|---|---|
| Base case / wind case |  |
| Fault type (3-phase / SLG / LL / LLG) |  |
| Fault bus or line and location |  |
| Phase selection / ground connection |  |
| Fault resistance (Ω) |  |
| Ground resistance (Ω) |  |
| Fault application time (s) |  |
| Clearing time (s) |  |
| Breaker / relay model |  |
| Converter current-limit setting, if applicable |  |

| Fault result | MATLAB result |
|---|---:|
| Prefault RMS voltage at monitored bus (pu) |  |
| Minimum retained RMS voltage during fault (pu) |  |
| Voltage sag depth (%) |  |
| One-cycle RMS fault current at POI (kA) |  |
| First-cycle peak current (kA) |  |
| Voltage recovery time to stated threshold (s) |  |
| Relay pickup time (s) |  |
| Relay trip-command time (s) |  |
| Breaker clearing time (s) |  |
| Wind converter maximum current (pu) |  |
| Converter current-limit flag / duration |  |
| Maximum DC-link voltage (pu) |  |
| Post-fault frequency nadir (Hz) |  |
| Maximum post-fault rotor-angle separation (°) |  |

