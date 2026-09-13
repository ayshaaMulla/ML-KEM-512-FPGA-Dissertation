# ML-KEM-512 FPGA Dissertation

MSc dissertation project for **Implementation and Performance Evaluation of ML-KEM on FPGA**.

This repository is a clean archival copy of the final dissertation FPGA artefacts. The RTL originates from an existing **Round-3 Kyber-512** FPGA implementation. The dissertation evaluates and optimises the design in the ML-KEM-512 context, but the source identifiers remain the original project identifiers, such as `Kyber_Server`, `Kyber_Client`, and `Kyber512_check_tb`.

This repository does **not** claim full FIPS 203 compliance. It preserves the final evaluated Round-3 Kyber-512 RTL/IP configuration and the supporting reports/checkpoints used in the dissertation.

## Tool and Target

- Tool: Vivado 2025.2
- FPGA: Xilinx Artix-7 `xc7a12tcpg238-1`
- Final clock period: `5.952 ns`
- Final target frequency: `168.011 MHz`

## Architecture Roles

- `Kyber_Server`: server-side top level. Used for key generation and decapsulation in the final verification flow.
- `Kyber_Client`: client-side top level. Used for encapsulation in the final verification flow.
- `Kyber512_check_tb`: functional verification testbench for the complete Round-3 Kyber-512 flow.

## Main Optimisations Retained

- FIFO Generator memories remapped from Distributed RAM to Block RAM where beneficial.
- Hash FIFO startup/readiness protection added through `hash_fifo_ready` and FIFO startup gating.
- Short external start pulses protected with `start_pending` / `start_launch` sequencing.
- Server `hash_pk` storage forced away from SRL/LUT shift-register extraction using `(* shreg_extract = "no" *)`.
- Timing closure achieved using timing-focused placement, routing, and physical optimisation flows.
- Client active `fifo_generator_6` DFIFO remapped to Block RAM and closed using a WL block placement implementation variant.

## Final Results

### Kyber_Server

Expected final accepted result:

| Metric | Value |
|---|---:|
| LUT | 5992 |
| FF | 4636 |
| Slices | 1743 |
| BRAM | 7 |
| DSP | 2 |
| WNS | +0.009 ns |
| TNS | 0 |
| Clock period | 5.952 ns |
| Frequency | 168.011 MHz |

The exact accepted server checkpoint is in `final_checkpoints/Kyber_Server_final_5992LUT_168MHz.dcp`. The available copied server report set contains the closest final report artefacts found in the project, including the final timing-only accepted report and final direct implementation reports.

### Kyber_Client

| Metric | Value |
|---|---:|
| LUT | 5458 |
| FF | 3765 |
| Slices | 1556 |
| BRAM | 6.5 |
| DSP | 2 |
| WNS | +0.006 ns |
| TNS | 0 |
| Clock period | 5.952 ns |
| Frequency | 168.011 MHz |

The final client checkpoint is in `final_checkpoints/Kyber_Client_final_DFIFO6_BRAM_5458LUT_168MHz.dcp`.

## Cycle Counts

Measured final-design cycle counts:

| Operation | Cycles |
|---|---:|
| Key Generation | 3390 |
| Encapsulation | 5661 |
| Decapsulation | 7346 |

## Repository Layout

- `original_source/`: Git-history versions of RTL files with proven final modifications.
- `modified_source/`: final RTL files containing retained optimisation changes.
- `ip_configuration/`: final FIFO Generator `.xci` configuration files relevant to the retained memory-mapping optimisations.
- `constraints/`: final timing constraint file using `5.952 ns` clock period.
- `testbench/`: final verification testbench and related simulation Tcl files.
- `final_checkpoints/`: final Vivado implementation checkpoints.
- `reports/server/`: available final server timing/utilisation reports.
- `reports/client/`: final client timing/utilisation reports.
- `results/resource_utilisation/`: copied resource evidence.
- `results/timing/`: copied timing evidence.
- `results/functional_verification/`: copied KAT and optimisation evidence logs.

## Functional Verification

The expected Round-3 reference shared secret is:

```text
6725690a 2cb2246f 814c6f28 ec4c22a4 259b6c50 020e487d 449fb4e3 7f23a3ca
```

Final KAT evidence is provided under `results/functional_verification/`.

## Reproducing / Opening

This is a cleaned artefact repository, not a full Vivado generated project dump. To reproduce the final design in Vivado, start from the original project structure, apply the RTL files in `modified_source/`, the FIFO `.xci` files in `ip_configuration/`, and the `constraints/constr.xdc` clock constraint. Then regenerate IP output products in Vivado 2025.2 before synthesis/implementation.

The final DCP checkpoints can be opened directly in Vivado for inspection of the implemented server and client designs.

## Final RTL Source Set

The `src/rtl/` directory contains the active hand-written RTL/source dependencies from the Vivado `sources_1` fileset, preserving the original Vivado-relative structure. It includes the Kyber server/client top levels, NTT/butterfly/reduction logic, encode/decode logic, hash wrappers, Keccak VHDL files, and NTT coefficient `.coe` files. Generated Vivado output products, run directories, cache folders, and temporary files are intentionally excluded.

The final server checkpoint was re-opened directly in Vivado without rerunning implementation. The reports exported from that frozen checkpoint are:

- `reports/server/Kyber_Server_final_5992_util.rpt`
- `reports/server/Kyber_Server_final_5992_timing.rpt`
- `reports/server/Kyber_Server_final_5992_top10_timing.rpt`
- `reports/server/Kyber_Server_final_5992_clocks.rpt`

These checkpoint-derived reports confirm 5992 LUTs, 4636 FFs, 1743 slices, 7 BRAM, 2 DSP, WNS +0.009 ns, TNS 0, and a 5.952 ns clock.

## Licence and Provenance

No separate RTL licence file was found in the Vivado project directory. The Round-3 Kyber C reference material present in the workspace includes its own `LICENSE`, `README.md`, and metadata files, copied under `provenance/reference-kyber-round3/` for citation/provenance only.
