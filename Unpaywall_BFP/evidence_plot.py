from google.cloud import bigquery
import pandas as pd
import datetime
import plotly.express as px

client = bigquery.Client(project='api-project-764811344545')

unpaywall_snapshots = {
    # 2018-03-29
    'mar18': ['`oadoi_full.upw_Mar18_08_20`'],

    # 2018-04-28
    'apr18': ['`oadoi_full.upw_Apr18_08_20`'],

    # 2018-06-21
    'jun18': ['`oadoi_full.upw_Jun18_08_20`'],

    # 2018-09-27
    'sep18': ['`oadoi_full.upw_Sep18_08_20`'],

    # 2019-02-21
    'feb19': ['`oadoi_full.feb_19_mongo_export_2008_2012_full_all_genres`',
              '`oadoi_full.feb_19_mongo_export_2013_Feb2019_full_all_genres`'],

    # 2019-04-20
    'apr19': ['`oadoi_full.mongo_export_apr19_2008_2012_full_macos`',
              '`oadoi_full.mongo_export_apr19_2013_Apr2019_full_macos`'],

    # 2019-08-16
    'aug19': ['`oadoi_full.upw_Aug19_08_20`'],

    # 2019-11-22
    'nov19': ['`oadoi_full.mongo_export_upwNov19_08_12`',
              '`oadoi_full.mongo_export_upwNov19_13_19`'],

    # 2020-02-25
    'feb20': ['`oadoi_full.mongo_upwFeb20_08_12`',
              '`oadoi_full.mongo_upwFeb20_13_20`'],

    # 2020-04-27
    'apr20': ['`oadoi_full.upw_Apr20_08_20`'],

    # 2020-10-09
    'oct20': ['`oadoi_full.upw_Oct20_08_20`'],

    # 2021-02-18
    'feb21': ['`oadoi_full.upw_Feb21_08_21`'],

    # 2021-07-02
    'jul21': ['`oadoi_full.upw_Jul21_08_21`']
}

snapshot_dates = {
    'mar18': [2018, 3],
    'apr18': [2018, 4],
    'jun18': [2018, 6],
    'sep18': [2018, 9],
    'feb19': [2019, 2],
    'apr19': [2019, 4],
    'aug19': [2019, 8],
    'nov19': [2019, 11],
    'feb20': [2020, 2],
    'apr20': [2020, 4],
    'oct20': [2020, 10],
    'feb21': [2021, 2],
    'jul21': [2021, 7]
}

order = ['mar18', 'apr18', 'jun18', 'sep18', 'feb19', 'apr19', 'aug19',
         'nov19', 'feb20', 'apr20', 'oct20', 'feb21', 'jul21']

df_evidence = pd.DataFrame()

for snapshot in unpaywall_snapshots:
    if snapshot in ['feb20', 'apr20', 'oct20', 'feb21', 'jul21']:
        is_paratext = 'AND is_paratext=false'
    else:
        is_paratext = ''
    for snapshot_name in unpaywall_snapshots[snapshot]:
        df2 = client.query(f"""
                           SELECT evidence, year, COUNT(DISTINCT(doi)) AS n
                           FROM {snapshot_name}, UNNEST (oa_locations)
                           WHERE year<2019 AND genre="journal-article" {is_paratext}
                           GROUP BY evidence, year
                           ORDER BY year
                           """).to_dataframe()

        df2['snapshot'] = snapshot

        df2['snapshot_timestamp'] = datetime.datetime(snapshot_dates[snapshot][0],
                                                      snapshot_dates[snapshot][1],
                                                      1)

        i = order.index(snapshot)

        if order[i] == order [-1]:
            df2['next_snapshot'] = datetime.datetime(2021, 2, 1)
        else:
            df2['next_snapshot'] = datetime.datetime(snapshot_dates[order[i+1]][0],
                                                     snapshot_dates[order[i+1]][1],
                                                     1)

        df_evidence = pd.concat([df_evidence, df2], ignore_index=True)


df_evidence.rename(columns={'snapshot_timestamp':'Snapshot timestamp',
                            'next_snapshot':'Next snapshot',
                            'evidence': 'Evidence'}, inplace=True)


fig = px.timeline(df_evidence,
                  x_start='Snapshot timestamp',
                  x_end='Next snapshot',
                  y='Evidence',
                  color_discrete_sequence=['#56B4E9'],
                  width=800,
                  height=800)

config = dict({'scrollZoom': False,
               'displaylogo': True,
               'modeBarButtonsToRemove': ['zoom',
                                          'pan',
                                          'select',
                                          'lasso',]})

fig.update_layout(
    plot_bgcolor='white',
    font_color='black',
    title_font_color='black',
    legend_title_font_color='black'
)
fig.update_yaxes(showgrid=True, gridwidth=1, gridcolor='lightgrey')
#fig.show(config=config)
fig.write_html('plotly_fig.html', config=config)
