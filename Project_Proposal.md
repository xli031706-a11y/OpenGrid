
# Project Proposal 

# OpenGrid Planner — Open-Source Transmission Planning and Renewable Integration Toolkit

## Overall Vision

OpenGrid Planner is a long-term open-source project intended to make practical transmission-planning studies more accessible to students using free or university-accessible software. Professional transmission planners commonly use commercial tools such as PSS®E, PowerWorld, TARA, ASPEN, and PSCAD for contingency, transfer, interconnection, and stability studies, but these tools can be difficult for students to access independently because of licensing restrictions.

The goal of OpenGrid Planner is to create a transparent and reproducible workflow using tools such as **MATPOWER, GNU Octave, Python, and MATLAB/Simulink when available through the university**. Instead of functioning only as a collection of mathematical demonstrations, the project will organize studies around the practical transmission-planning process:

**Model → Analyze → Identify Constraint → Investigate Cause → Test Solution → Re-evaluate**

The first research case will use the **IEEE 9-bus system to study wind-farm integration**. A wind farm will be connected to the system while existing generation is adjusted to maintain supply-demand balance. The original and wind-integrated systems will then be compared using power-flow and contingency studies to determine how renewable integration changes bus voltages, transmission-line loading, reactive-power behavior, and system response to outages.

The longer-term goal is for OpenGrid Planner to become an educational transmission-planning environment supporting N-1 contingency analysis, PTDF/LODF calculations, transfer capability, generator interconnection studies, voltage stability, and transmission-upgrade evaluation. Fall 2026 will establish the foundation and first major planning capability.

## Fall 2026 Semester Goals

The primary goal for Fall 2026 is to establish the software, modeling, and research foundation of OpenGrid Planner and develop a reliable **N-1 transmission contingency-analysis workflow**.

September will focus on project setup, learning the IEEE 9-bus model, validating the base-case AC power flow, and creating the wind-integrated case. October and November will focus on automating branch N-1 contingencies and comparing the original and wind-integrated systems under identical outage conditions.

The semester will end with a reproducible study that identifies thermal and voltage violations, ranks important contingencies, and documents how renewable integration changes transmission-system performance. More advanced functions such as PTDF/LODF, transfer capability, and generator interconnection will be developed in future semesters.

## Milestones

### Milestone 1 — Project and Model Foundation

**Nominal Completion: End of September**

* Create the GitHub repository and open-source project structure.
* Set up MATPOWER/GNU Octave and supporting Python tools.
* Validate the IEEE 9-bus base-case AC power flow.
* Become familiar with bus, generator, load, andyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy transmission-line data.
* Create and validate the wind-integrated IEEE 9-bus case.
* Extract baseline voltage, generation, reactive-power, and line-flow results.

**Deliverable:** A documented and reproducible IEEE 9-bus base case and wind-integrated model ready for planning studies.

### Milestone 2 — Automated N-1 Contingency Analysis

**Nominal Completion: End of October**

* Automatically generate branch N-1 contingencies.
* Remove one transmission element at a time and rerun AC power flow.
* Detect thermal and voltage violations.
* Record convergence and outage results.
* Compare the original and wind-integrated systems under the same contingencies.
* Export results to CSV or another structured format.

**Deliverable:** An automated N-1 analysis tool that identifies post-contingency transmission and voltage problems.

### Milestone 3 — Analysis, Ranking, and Semester Release

**Nominal Completion: End of November / Semester End**

* Add contingency ranking and severity screening.
* Identify islanding or non-converged cases.
* Distinguish the outaged element from the resulting violated facility.
* Summarize how wind integration changes contingency performance.
* Expand testing and documentation.
* Produce one complete reproducible example study.

**Deliverable:** A documented Fall 2026 release of OpenGrid Planner demonstrating renewable-integration and N-1 transmission-planning analysis on the IEEE 9-bus system.
