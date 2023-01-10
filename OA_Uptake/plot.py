import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import numpy as np

df = pd.read_csv('oa_shares_inst_sec_boxplot.csv')

def update_all(dataframe, oa_category):
    df_temp = dataframe.copy()
    df_temp = df_temp.groupby(['INST_NAME', 'sec_abbr', 'sector_cat'],
                    as_index=False).sum().eval('prop = n_cat / articles')
    df_temp = df_temp[['INST_NAME', 'sec_abbr', 'sector_cat', 'prop']]
    df_temp['oa_category'] = oa_category
    df_temp.drop_duplicates(inplace=True)
    df_temp.sort_values(by='sec_abbr', inplace=True)
    df_temp.rename(columns={'INST_NAME':'Research institution',
                            'sec_abbr': 'sector',
                            'prop': 'OA percentage'
                           }, inplace=True)
    return df_temp
    
df2 = update_all(df[df.oa_category=='not_oa'], 'not_oa')
df2['color'] = '#684747'

fig1 = px.box(df2,
              x='sector',
              y='OA percentage',
              color='color',
              color_discrete_map={
                  '#684747': '#051461'
              },
              title='',
              points=False,
              hover_name='Research institution',
              hover_data=['oa_category'])

fig1.update_traces(showlegend=False)

fig2 = px.strip(df2,
                x='sector',
                y='OA percentage',
                color='color',
                color_discrete_map={
                      '#684747': '#051461'
                },
                hover_name='Research institution',
                hover_data=None,
                stripmode='overlay')

fig2.update_traces(showlegend=False)

fig = go.Figure(data=fig1.data + fig2.data)

fig.update_layout(
    xaxis=dict(showgrid=False, zeroline=False, showticklabels=True),
    yaxis=dict(zeroline=False, gridcolor='grey', tickformat=',.0%'),
    width=900,
    height=600,
    paper_bgcolor='white',
    plot_bgcolor='white',
    boxgap=0,
    yaxis_range=[-0.1,1.05],
    title='OA percentage across sectors',
    yaxis_title='OA percentage',
    updatemenus=[
        dict(
            buttons=list([
                dict(
                    args=[{'y': [update_all(df[df.oa_category=='full_oa_journal'],
                                            'full_oa_journal')['OA percentage'].to_list()],
                           'x': [update_all(df[df.oa_category=='full_oa_journal'],
                                            'full_oa_journal')['sector'].to_list()]
                          }],
                    label='Full OA Journals',
                    method='update'),
                dict(
                    args=[{'y': [update_all(df[df.oa_category=='other_oa_journal'],
                                            'other_oa_journal')['OA percentage'].to_list()],
                           'x': [update_all(df[df.oa_category=='other_oa_journal'],
                                            'other_oa_journal')['sector'].to_list()]
                          }],
                    label='Other OA Journals',
                    method='update'),
                dict(
                    args=[{'y': [update_all(df[df.oa_category=='not_oa'],
                                            'not_oa')['OA percentage'].to_list()],
                           'x': [update_all(df[df.oa_category=='not_oa'],
                                            'not_oa')['sector'].to_list()]
                          }],
                    label='Closed articles',
                    method='update'),
                dict(
                    args=[{'y': [update_all(df[df.oa_category=='other_repo'],
                                            'other_repo')['OA percentage'].to_list()],
                           'x': [update_all(df[df.oa_category=='other_repo'],
                                            'other_repo')['sector'].to_list()]
                          }],
                    label='Other Repositories',
                    method='update'),
                dict(
                    args=[{'y': [update_all(df[df.oa_category=='opendoar_inst'],
                                            'opendoar_inst')['OA percentage'].to_list()],
                           'x': [update_all(df[df.oa_category=='opendoar_inst'],
                                            'opendoar_inst')['sector'].to_list()]
                          }],
                    label='Repositories in OpenDOAR: institutional',
                    method='update'),
                dict(
                    args=[{'y': [update_all(df[df.oa_category=='opendoar_subject'],
                                            'opendoar_subject')['OA percentage'].to_list()],
                           'x': [update_all(df[df.oa_category=='opendoar_subject'],
                                            'opendoar_subject')['sector'].to_list()]
                          }],
                    label='Repositories in OpenDOAR: disciplinary',
                    method='update'),
                dict(
                    args=[{'y': [update_all(df[df.oa_category=='opendoar_other'],
                                            'opendoar_other')['OA percentage'].to_list()],
                           'x': [update_all(df[df.oa_category=='opendoar_other'],
                                            'opendoar_other')['sector'].to_list()]
                          }],
                    label='Repositories in OpenDOAR: other',
                    method='update'),
            ]),
            direction='down',
            showactive=True,
            x=1.04,
            xanchor='left',
            y=0.85,
            yanchor='top'
        )],
    annotations=[
        dict(text='Which articles should be included?', x=1.53, xref='paper', y=0.95, yref='paper',
                             align='center', showarrow=False)
    ]
)

fig.write_html('boxplot_plotly.html')
