import numpy as np

# ---------------------------------------------------------
# Dofbot link lengths from HW2
# Values are entered in mm and converted to meters.
# ---------------------------------------------------------
l0 = 61.00 / 1000
l1 = 43.50 / 1000
l2 = 82.85 / 1000
l3 = 82.85 / 1000
l4 = 73.85 / 1000
l5 = 54.57 / 1000

# Hardware angles when the arm is in the HW2 zero configuration.
# Update these if your measured home angles are different.
HOME_SERVO_DEG = np.array([90, 91, 91, 91, 90], dtype=float)

# Start with all positive signs. Change an entry to -1 if that
# joint's physical positive direction is opposite the HW2 model.
JOINT_SIGNS = np.array([1, 1, 1, 1, 1], dtype=float)


def rotx(theta_deg):
    theta = np.deg2rad(theta_deg)
    c = np.cos(theta)
    s = np.sin(theta)

    return np.array([
        [1, 0, 0],
        [0, c, -s],
        [0, s, c]
    ])


def roty(theta_deg):
    theta = np.deg2rad(theta_deg)
    c = np.cos(theta)
    s = np.sin(theta)

    return np.array([
        [c, 0, s],
        [0, 1, 0],
        [-s, 0, c]
    ])


def rotz(theta_deg):
    theta = np.deg2rad(theta_deg)
    c = np.cos(theta)
    s = np.sin(theta)

    return np.array([
        [c, -s, 0],
        [s, c, 0],
        [0, 0, 1]
    ])


def servo_to_fk_angles(servo_angles_deg):
    """
    Converts measured Dofbot servo readings to the HW2
    zero-referenced FK joint angles.
    """
    servo_angles_deg = np.array(servo_angles_deg, dtype=float)

    q_fk_deg = JOINT_SIGNS * (servo_angles_deg - HOME_SERVO_DEG)

    return q_fk_deg


def fk_dofbot(q_deg):
    """
    Calculates the Dofbot end-effector position.

    Input:
        q_deg: [q1, q2, q3, q4, q5] in degrees

    Output:
        P0T: [x, y, z] end-effector position in meters
    """
    q1, q2, q3, q4, q5 = q_deg

    ex = np.array([1.0, 0.0, 0.0])
    ez = np.array([0.0, 0.0, 1.0])

    R01 = rotz(q1)
    R12 = roty(-q2)
    R23 = roty(-q3)
    R34 = roty(-q4)
    R45 = rotx(-q5)

    P01 = (l0 + l1) * ez
    P12 = np.zeros(3)
    P23 = l2 * ex
    P34 = -l3 * ez
    P45 = np.zeros(3)
    P5T = -(l4 + l5) * ex

    P0T = P01 + R01 @ (
        P12 + R12 @ (
            P23 + R23 @ (
                P34 + R34 @ (
                    P45 + R45 @ P5T
                )
            )
        )
    )

    return P0T


def print_end_effector_position():
    # Reads the measured Dofbot angles for joints 1 through 5.
    measured_servo_deg = readAllActualJointAngles()[:5]

    # Converts hardware servo readings to FK joint angles.
    q_fk_deg = servo_to_fk_angles(measured_servo_deg)

    # Calculates x, y, z.
    position_m = fk_dofbot(q_fk_deg)
    position_mm = position_m * 1000

    print("Measured servo angles [q1-q5] (deg):", measured_servo_deg)
    print("FK joint angles [q1-q5] (deg):", q_fk_deg)
    print("End-effector position (m):", position_m)
    print("End-effector position (mm):", position_mm)

    return measured_servo_deg, q_fk_deg, position_m, position_mm