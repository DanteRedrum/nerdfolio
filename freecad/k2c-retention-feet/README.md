# K2C Retention Feet

Anti-vibration retention feet for the Creality K2C printer.
Prevents the printer from vibrating off the top of a safe during operation.

## Problem

K2C sits on top of a small safe. Printer vibration during operation
risks walking the printer to the edge and off the safe.

## Solution

Four retention feet — one per printer foot. Each foot has:
- A center post that inserts into the hollow of the rubber foot
- A ring pocket that captures the outer rim of the foot
- L-shaped walls that drop down and grip the corners of the safe top
- Front feet have shortened walls for safe door clearance

## Variants

| File | Use | Wall Drop |
|---|---|---|
| `k2c-foot-rear.FCStd` | Rear two feet | 35mm — full grip |
| `k2c-foot-front.FCStd` | Front two feet | 22.6mm — door clearance |

## Dimensions

### Foot Capture (same on all four)

| Dimension | Value | Notes |
|---|---|---|
| Base platform | 60mm × 60mm | Square with rounded corners |
| Center post diameter | 32mm | Inserts into hollow of rubber foot |
| Center post height | 10mm | Conservative — actual hollow is 15mm |
| Ring pocket depth | 10mm | Captures outer rim of foot |
| Foot outer diameter | 47mm | +1.5mm clearance each side = 50mm pocket |
| Wall thickness | 5mm | Around pocket perimeter |

### L-Shape Walls

| Dimension | Rear Feet | Front Feet |
|---|---|---|
| Wall thickness | 4mm | 4mm |
| Long leg drop | 35mm | 22.6mm |
| Short leg drop | 35mm | 22.6mm |
| Short leg length | Full corner | Shortened for door clearance |

### Profile (Front View)

Rear foot:          Front foot:
████████████        ████████████
█          █        █
█          █        █
█          █        █ ← shortened for door clearance

### Top View

┌─────────────────┐
│  ┌───────────┐  │  ← outer wall
│  │  ┌─────┐  │  │  ← ring pocket
│  │  │post │  │  │  ← center post (32mm)
│  │  └─────┘  │  │
│  └───────────┘  │
└─────────────────┘
L-walls drop down from here

## Print Settings

| Setting | Value |
|---|---|
| Material | PETG recommended — flexible enough for rubber foot grip |
| Infill | 40% — needs to handle vibration |
| Layer height | 0.2mm |
| Supports | None — print upside down, base prints first |
| Orientation | Upside down — L-walls point up during print |

## Print Orientation

Print upside down — the flat base (60mm × 60mm platform with pocket
and post) prints first. The L-shape walls print last pointing upward.
When flipped for use, the walls drop down to grip the safe corners.

## Assembly

1. Print two rear feet and two front feet
2. Place each foot pad on the safe top at the K2C corner positions
3. Lower K2C onto the feet — rubber feet press onto center posts
4. Front feet oriented with shortened wall facing the safe door side
5. Verify door opens without contacting the shortened wall

## Notes

- Measure safe top edge thickness before printing to verify 35mm wall
  is sufficient to grip — adjust if needed
- Front feet short wall measured at 22.6mm available clearance
- PETG preferred over PLA for slight flex and temperature resistance
  near a running printer
- If center post is too tight, sand lightly or increase clearance
  tolerance by 0.5mm in FreeCAD sketch
