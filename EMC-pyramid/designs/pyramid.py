#!/usr/bin/env python3

# fine tune resistivity and frame thickness
# to get good wave damping over large freq range 50-1200 MHz

from scipy.spatial.transform import Rotation
from numpy.linalg import norm
import numpy as np

from math import sqrt, sin, cos, tan, atan, pi

# pyramid wireframe gemoetry and material conductivity
pyr_a            = 0.5    # [m] side length
pyr_d            = 1.0E-3 # [m] wire diameter
pyr_conductivity = 10.5   # [S/m] material
# copper:    conductivity = 5.80E7 S/m
# aluminium: conductivity = 3.77E7 S/m
# sea water: conductivity = 4.80   S/m
pyr_seg          = 4      # number of triangular segments

# calculate number of segments per side
Ns = 0
for i in range(0, pyr_seg):
  Ns += 3*(i+1)
# 1->  3 = 3
# 2->  9 = 3+6
# 3-> 18 = 3+6+9
# 4-> 30 = 3+6+9+12
# 5-> 45 = 3+6+9+12+15

# resistance of one segment wire (length pyr_a/pyr_seg)
pyr_Rs = pyr_a/pyr_seg / ((pyr_d/2)**2 * pi) / pyr_conductivity

# probe dipole
dipole_len = 10.0E-2 # [m] 10..18 cm defines resonant freq
#dipole_len = 0.5
dipole_d   = 1.0E-3  # [m] wire diameter

itag_start = 100
itag = itag_start

def nec2geo(c, i1, i2, f1, f2, f3, f4, f5, f6, f7):
  print("%2s %5d %5d %12.5E %12.5E %12.5E %12.5E %12.5E %12.5E %12.5E" % (c, i1, i2, f1, f2, f3, f4, f5, f6, f7))

def nec2cmd(c, i1, i2, i3, i4, f1, f2, f3, f4, f5, f6):
  print("%2s %5d %5d %5d %6d %12.5E %12.5E %12.5E %12.5E %12.5E %12.5E" % (c, i1, i2, i3, i4, f1, f2, f3, f4, f5, f6))

def reflectors(a):
  side_angle = atan(sqrt(2))*2
  a0 = a/sqrt(2)
  h = a*sqrt(2/3)
  x0 = a0
  y0 = 0
  for i in range(0,3):
    x1 = a0*cos( (i * 120 + 90) * pi/180 )
    y1 = a0*sin( (i * 120 + 90) * pi/180 )
    # side triangle center
    xbc = x1 * 0.3
    ybc = y1 * 0.3
    zbc = h  * 0.22
    # surface patch (ideal reflector) outside 20%, 5% above
    nec2geo("SP", 0, 0, xbc, ybc, zbc, 21, i*120+90, a*a, 0)
    x0 = x1
    y0 = y1
  # bottom surface patch (ideal reflector), 15mm below
  nec2geo("SP", 0, 0, 0, 0, -h*0.32, 90, 0, a*a, 0)

# n starting ings
# fs segments eeach line (min. 1)
# a side length [m]
# m each side is divided to m smaller parts, forming small triangle too
# d wire diameter
# xrot rotation angle around x-axis [deg] (0 or 120)
# zrot rotation angle around z-axis [deg] (0, 60, 120)
# spc additional spacing > 0 triangles will not touch
# e end option [0,0,0]: include all sides, [-1, -1, -1]: without largest sides
def triangle(n, fs, a, m, d, xrot, zrot, spc, e):
  global itag
  axis_x  = [1, 0, 0]
  axis_z  = [0, 0, 1]

  rot_axis_x = axis_x / norm(axis_x)
  rotation_xrot = Rotation.from_rotvec( (xrot * pi/180) * rot_axis_x)
  #angle_120_deg = 120*pi/180
  #angle_240_deg = 240*pi/180
  rot_axis_z = axis_z / norm(axis_z)
  rotation_zrot = Rotation.from_rotvec( (zrot * pi/180) * rot_axis_z)
  #rot_120_deg = Rotation.from_rotvec(angle_120_deg * rot_axis_z)
  #rot_240_deg = Rotation.from_rotvec(angle_240_deg * rot_axis_z)
  # top vertice
  v0 = [   0,  a/sqrt(3), 0]
  # bottom vertices, z-rotate
  #v1 = rot_120_deg.apply(v0)
  #v2 = rot_240_deg.apply(v0)
  # triangle between 3 vertices
  #nec2geo("GW", n  , 1, v0[0], v0[1], v0[2], v1[0], v1[1], v1[2], d)
  #nec2geo("GW", n+1, 1, v0[0], v0[1], v0[2], v2[0], v2[1], v2[2], d)
  #nec2geo("GW", n+2, 1, v1[0], v1[1], v1[2], v2[0], v2[1], v2[2], d)
  # lines from top (1) to bottom (m-1)
  translate_below = np.array([0, 0, -a/sqrt(3*8) - spc])
  translate_step = np.array([0,-a/sqrt(3)*(3/2),0]) / m
  side_step = np.array([a/2/m,0,0])
  for j in range(0,3):
    angle_triangle = 120*pi/180 * j
    for i in range(0,m+e[j]):
      v1t = translate_below + v0 + side_step * (i+1) + translate_step * (i+1)
      v2t = translate_below + v0 - side_step * (i+1) + translate_step * (i+1)
      rotation = Rotation.from_rotvec(angle_triangle * rot_axis_z)
      v1tr = rotation_zrot.apply(rotation_xrot.apply(rotation.apply(v1t)))
      v2tr = rotation_zrot.apply(rotation_xrot.apply(rotation.apply(v2t)))
      nec2geo("GW", itag, (i+1), v1tr[0], v1tr[1], v1tr[2], v2tr[0], v2tr[1], v2tr[2], d)
      itag += 1

# conductivity is 1/(ohm*m) = mho/m = S/m
# copper:    conductivity = 5.80E7
# aluminium: conductivity = 3.77E7 
# sea water: conductivity = 4.80
def resistance_pyramid(n, m, conductivity):
  for i in range(0, m-n):
    nec2cmd("LD", 5,  i+n,  0,  0, conductivity, 0, 0, 0, 0, 0)

print("CM pyramid")
print("CM edge length        a  = %.0fcm" % (pyr_a*100))
print("CM segment resistance Rs = %.0fk" % (pyr_Rs/1000))
print("CM segments per side  Ns = %d" % (Ns))
print("CE End comments")
pyr_angle = atan(sqrt(2))*2 * 180/pi
if 0:
  # triangles touch, no spacing
  triangle(100, 1, a=pyr_a, m=pyr_seg, d=pyr_d, xrot=        0, zrot= 60, spc=0, e=[ 0, 0, 0])
  triangle(200, 1, a=pyr_a, m=pyr_seg, d=pyr_d, xrot=pyr_angle, zrot=  0, spc=0, e=[-1,-1, 0])
  triangle(300, 1, a=pyr_a, m=pyr_seg, d=pyr_d, xrot=pyr_angle, zrot=120, spc=0, e=[-1,-1, 0])
  triangle(400, 1, a=pyr_a, m=pyr_seg, d=pyr_d, xrot=pyr_angle, zrot=240, spc=0, e=[-1,-1, 0])
else:
  # triangles don't touch, have spacing
  triangle(100, 1, a=pyr_a, m=pyr_seg, d=pyr_d, xrot=        0, zrot= 60, spc=pyr_a*0.03, e=[ 0, 0, 0])
  triangle(200, 1, a=pyr_a, m=pyr_seg, d=pyr_d, xrot=pyr_angle, zrot=  0, spc=pyr_a*0.03, e=[ 0, 0, 0])
  triangle(300, 1, a=pyr_a, m=pyr_seg, d=pyr_d, xrot=pyr_angle, zrot=120, spc=pyr_a*0.03, e=[ 0, 0, 0])
  triangle(400, 1, a=pyr_a, m=pyr_seg, d=pyr_d, xrot=pyr_angle, zrot=240, spc=pyr_a*0.03, e=[ 0, 0, 0])

reflectors(pyr_a)
nec2geo("GW", 1, 25,  -dipole_len/2, 0.0, pyr_a/sqrt(3)/8, dipole_len/2, 0.0, pyr_a/sqrt(3)/8, 1E-3)
nec2geo("GW", 30, 25,  0.0, -dipole_len/2, -pyr_a/sqrt(3)/8, 0.0, dipole_len/2, -pyr_a/sqrt(3)/8, 1E-3)
nec2geo("GE", 0,  0,  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
nec2cmd("FR", 0, 25,  0,  0, 50.0, 50.0, 0, 0, 0, 0)
nec2cmd("EX", 0,  1, 13,  0, 1.0, 0, 0, 0, 0, 0)
nec2cmd("LD", 5,  0,  0,  0, 5.8E7, 0, 0, 0, 0, 0) # dipole wire copper
resistance_pyramid(itag_start, itag, pyr_conductivity) # make pyramid frame lossy (resistive)
nec2cmd("NH", 0,  0,  0,  0, 0.0, 0, 0, 0, 0, 0)
nec2cmd("NE", 0, 20, 15,  1, -1.4, -1.4, 5E-2, 2E-1, 2E-1, 0)
nec2cmd("RP", 0, 72, 72, 1000, 0.0, 0.0, 5.0, 5.0, 0, 0)
nec2cmd("EN", 0,  0,  0,  0, 0.0, 0.0, 0.0, 0.0, 0, 0)
