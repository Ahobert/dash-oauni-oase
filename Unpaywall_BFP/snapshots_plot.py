import pandas as pd
import numpy as np
from bokeh.plotting import figure, show, column, row, curdoc
from bokeh.models import ColumnDataSource, HoverTool, CheckboxGroup, Legend, NumeralTickFormatter, Div


df = pd.read_csv('data.csv')

oa_names = {'bronze': 'Bronze OA',
            'gold': 'Gold OA',
            'hybrid': 'Hybrid OA',
            'green': 'Green OA',
            'closed': 'Closed OA'}

df['oa_status'] = df['oa_status'].map(oa_names)

snapshot_names = {
    'apr19': 'April 2019',
    'aug19': 'August 2019',
    'nov19': 'November 2019',
    'feb20': 'February 2020',
    'apr20': 'April 2020',
    'oct20': 'October 2020',
    'feb21': 'February 2021',
    'jul21': 'July 2021'
}

df['snapshot'] = df['snapshot'].map(snapshot_names)

df = df.replace({np.nan: None})

snapshots = ['April 2019',
             'August 2019',
             'November 2019',
             'February 2020',
             'April 2020',
             'October 2020',
             'February 2021',
             'July 2021']

palette = {'Bronze OA': '#a48300',
           'Gold OA': '#e8d651',
           'Hybrid OA': '#73b4ff',
           'Green OA': '#258200',
           'Closed OA': '#410c4c'}

p = figure(title='',
           plot_width=800,
           x_axis_label='Year',
           y_axis_label='OA Share',
           x_range=(2008, 2018),
           y_range=(0, 0.6),
           tools=['hover'],
           tooltips=[('Snapshot', '@snapshot'),
                     ('OA Status', '@oa_status'),
                     ('Year', '@year'),
                     ('Proportion', '@prop')],
           toolbar_location=None)

checkbox = CheckboxGroup(labels=snapshots, active=[0], width=120, margin=(30, 0, 0, 30))

def checkbox_handler(new):
    updated_snapshot_list = []
    for snapshot_idx in new:
        updated_snapshot_list.append(snapshots[snapshot_idx])
    p = plot_snapshots(updated_snapshot_list)

p.xgrid.grid_line_color = None
p.toolbar.logo = None

xticks = [2008, 2010, 2012, 2014, 2016, 2018]
p.xaxis[0].ticker = xticks

p.yaxis.formatter = NumeralTickFormatter(format='0 %')

yticks = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6]
p.yaxis[0].ticker = yticks


dash_style=['solid', 'dashed', 'dotted', 'dotdash', 'dashdot']

def plot_snapshots(snapshot_list):

    p.renderers = []
    p.legend.items = []

    for i, snapshot in enumerate(snapshot_list):

        snapshot_df = df[df.snapshot==snapshot].copy()

        for oa_status in snapshot_df.oa_status.unique():
            if oa_status is None:
                continue
            df_plot = snapshot_df[snapshot_df.oa_status == oa_status].copy()
            cds = ColumnDataSource(df_plot[['snapshot', 'year', 'prop', 'oa_status']])
            p.line(x='year',
                   y='prop',
                   source=cds,
                   color=palette[oa_status],
                   legend_label=f'{oa_status} - {snapshot}',
                   line_dash=dash_style[i],
                   line_width=2)

plot_snapshots(['April 2019'])

div = Div(text="""<b>Snapshot</b>""", margin=(15, 0, -20, 30))

p.legend.title = 'OA Status - Snapshot'
p.legend.click_policy = 'hide'
p.legend.location = 'top_right'
p.add_layout(p.legend[0], 'right')

layout = row(column(div, checkbox), p)

checkbox.on_click(checkbox_handler)
curdoc().add_root(layout)
