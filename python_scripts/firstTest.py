import sys
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import math
from scipy.spatial import distance
import numpy as np

sys.path.insert(0, '/Library/Application Support/MWorks/Scripting/Python')
from mworks.data import MWKFile

f = MWKFile('Mouse_WalkRDP+Target.mwk2')
f.open()

TRIAL_start = f.get_events(codes=['ML_trialStart'])
TRIAL_end = f.get_events(codes=['ML_trialEnd'])

VAR_names = ['IO_mouse_x', 'IO_mouse_y', 'ML_trialStart', 'ML_trialEnd', 'target_x', 'target_y', 'IO_target_ON',
             'TRIAL_outcome', 'RDP_direction', 'RDP_coherence']

DATA = pd.DataFrame({c: np.repeat([''], [len(TRIAL_start)]) for c in VAR_names})
TIME = pd.DataFrame({c: np.repeat([''], [len(TRIAL_start)]) for c in VAR_names})
for i in range(0,len(TRIAL_start)):

    t1 = TRIAL_start[i].time
    t2 = TRIAL_end[i].time

    if t2 - t1 > 0:
        VAR_data = {k: [] for k in VAR_names}
        VAR_time = {k: [] for k in VAR_names}

        for var in VAR_names:
            evt = f.get_events(codes=[var], time_range=[t1, t2])

            for y in range(0,len(evt)):
                VAR_data[var].append(evt[y].data)
                VAR_time[var].append(evt[y].time)

            if len(evt) == 1:
                DATA.at[i, var] = VAR_data[var][0]
                TIME.at[i, var] = VAR_time[var][0]
            else:
                DATA.at[i, var] = VAR_data[var]
                TIME.at[i, var] = VAR_time[var]


RDPchON = []
TarON = []
for i in range(0,len(TRIAL_start)):

    t1 = TRIAL_start[i].time
    t2 = TRIAL_end[i].time

    if t2 - t1 > 0:
        #trial start
        start = 0

        #RDP coherence on
        evt = f.get_events(codes=['RDP_coherence'], time_range=[t1, t2])
        RDPchON.append((evt[0].time - TRIAL_start[i].time) / 1000)

        #Target ON
        evt = f.get_events(codes=['IO_target_ON'], time_range=[t1, t2])
        TarON.append((evt[0].time - TRIAL_start[i].time) / 1000)


# ================================= PLOT =====================================================
# Calculate euclidean distance between mouse and target for each trial
sns.set_palette("Set2")
sns.set(style="whitegrid")

EuclDist = pd.DataFrame(columns=['trial', 'distance', 'angle', 'time', 'outcome', 'SNR_time', 'confidence',
                                 'SNR', 'target', 'difference', 'target_x', 'target_y'])

for i in range(0,len(DATA)):
    print(i)

    try:
        target = TIME.IO_target_ON[i][0]
    except:
        target = TIME.IO_target_ON[i]

    for j in range(0, len(DATA.IO_mouse_x[i])):

        x = (DATA.IO_mouse_x[i][j], DATA.IO_mouse_y[i][j])
        y = (DATA.target_x[i], DATA.target_y[i])
        a = (math.atan2(DATA.IO_mouse_x[i][j],DATA.IO_mouse_y[i][j]) * 180) / 3.14
        t = (math.atan2(DATA.target_x[i],DATA.target_y[i]) * 180) / 3.14
        c = 0,0

        EuclDist = EuclDist.append({
            'trial': DATA['ML_trialStart'][i],
            'distance': distance.euclidean(x, y),
            'angle': a,
            'time': ((TIME.IO_mouse_x[i][j] - target) / 1000),
            'outcome': DATA['TRIAL_outcome'][i],
            'target': t,
            'SNR_time': TIME['RDP_coherence'][i][0] - TIME['ML_trialStart'][i],
            'SNR': DATA['RDP_coherence'][i][0],
            'target_x': DATA.target_x[i],
            'target_y': DATA.target_y[i],
            'confidence': distance.euclidean(x, c),
            'difference': 180 - abs(abs(a - t) - 180)},
            ignore_index=True)


custom_palette = sns.color_palette("RdBu", len(EuclDist.SNR.unique()))

f, (ax0, ax1) = plt.subplots(2, 1, sharex=True)

g = sns.lineplot(x="time", y="distance", hue="SNR", style='outcome', palette=custom_palette, units="trial", estimator=None,
                  data= EuclDist, ax=ax0, legend='brief')
plt.axvline(0, color='k', linestyle='--')
g.set(ylabel='Distance to Target')
g.legend_.remove()

g = sns.lineplot(x="time", y="confidence", hue="SNR", style='outcome', palette=custom_palette, units="trial", estimator=None,
                  data= EuclDist, ax=ax1, legend='brief')
plt.axvline(0, color='k', linestyle='--')
g.set(ylabel='Distance from Center')

g.legend(loc='lower right', bbox_to_anchor=(1.145, -0.1), ncol=1, frameon=False, title=None, fontsize='small')

# ax = sns.lineplot(x="time", y="difference", hue="SNR", units="trial", estimator=None,
#                   data= EuclDist[EuclDist['outcome'] == 'hit'])
# plt.axvline(0, color='k', linestyle='--')
#



