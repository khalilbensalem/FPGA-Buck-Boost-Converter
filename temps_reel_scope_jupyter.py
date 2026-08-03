from pynq import MMIO
from IPython.display import display
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import time
import io
from IPython.display import Image, clear_output

# ─── Configuration ───────────────────────────────────────────
BASE_ADDR  = 0x40430000
SCALE_27   = 2**27
SCALE_29   = 2**29
WINDOW_SEC = 5.0
REFRESH    = 5        # Rafraîchir toutes les 5 lectures
SLEEP      = 0.02     # 20ms entre lectures = 50Hz

mmio = MMIO(BASE_ADDR, 0x200)

# ─── Vérification FPGA ───────────────────────────────────────
lectures = []
for _ in range(10):
    lectures.append(mmio.read(0x11C))
    time.sleep(0.02)

if (max(lectures) - min(lectures)) < 1000:
    print("⚠️  FPGA NON ACTIF — Lance NOA → Run d'abord !")
    raise SystemExit()
else:
    print(f"✅ FPGA actif ! Vout ≈ {lectures[-1]/SCALE_27:.3f} V")

# ─── Buffers ─────────────────────────────────────────────────
t_data, vin_data, vout_data, pwm_data, error_data = [], [], [], [], []
t_start = time.time()

# ─── Figure créée UNE SEULE FOIS ─────────────────────────────
fig, axes = plt.subplots(3, 1, figsize=(11, 7))
line_vin,  = axes[0].plot([], [], 'y-', lw=1.5, label='Vin')
line_vout, = axes[0].plot([], [], 'b-', lw=1.5, label='Vout')
axes[0].set_ylabel('Tension (V)'); axes[0].legend(); axes[0].grid(True); axes[0].set_ylim(0, 14)

line_pwm, = axes[1].plot([], [], 'g-', lw=1.5, label='PWM')
axes[1].set_ylabel('PWM'); axes[1].legend(); axes[1].grid(True); axes[1].set_ylim(-1, 6)

line_err, = axes[2].plot([], [], 'm-', lw=1.5, label='Error')
axes[2].set_ylabel('Erreur (V)'); axes[2].set_xlabel('Temps (s)')
axes[2].legend(); axes[2].grid(True)

plt.tight_layout()

# ─── Boucle rapide ───────────────────────────────────────────
try:
    MAX_ITER = 100000
    for i in range(MAX_ITER):
        now = time.time() - t_start

        # Lectures AXI
        t_data.append(now)
        vin_data.append(mmio.read(0x118) / SCALE_27)
        vout_data.append(mmio.read(0x11C) / SCALE_27)
        pwm_data.append(mmio.read(0x120) / SCALE_29)
        error_data.append(mmio.read(0x124) / SCALE_27)

        # Fenêtre glissante
        while t_data and (now - t_data[0]) > WINDOW_SEC:
            for lst in [t_data, vin_data, vout_data, pwm_data, error_data]:
                lst.pop(0)

        # Mise à jour RAPIDE — juste les données, pas la figure
        if i % REFRESH == 0:
            line_vin.set_data(t_data, vin_data)
            line_vout.set_data(t_data, vout_data)
            line_pwm.set_data(t_data, pwm_data)
            line_err.set_data(t_data, error_data)

            for ax in axes:
                ax.set_xlim(max(0, now - WINDOW_SEC), now + 0.1)
            axes[2].relim(); axes[2].autoscale_view(scalex=False)

            fig.suptitle(f'Buck Converter | t = {now:.1f}s', fontsize=13, fontweight='bold')

            # Convertir en image PNG et afficher
            buf = io.BytesIO()
            fig.savefig(buf, format='png', dpi=80)
            buf.seek(0)
            clear_output(wait=True)
            display(Image(data=buf.read()))
            buf.close()

        time.sleep(SLEEP)

except KeyboardInterrupt:
    print("\n⏹️  Arrêt propre.")
    plt.close('all')