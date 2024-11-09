from shiny import App, ui, render
import pandas as pd
import numpy as np
import plotly.express as px
from datetime import datetime, timedelta

# Define UI
app_ui = ui.page_fluid(
    ui.panel_title("Data Analysis Dashboard"),
    
    ui.layout_sidebar(
        ui.panel_sidebar(
            ui.input_numeric("n_points", "Number of data points:", 100, min=10, max=1000),
            
            ui.input_select("plot_type", "Select Plot Type:",
                          choices={
                              "scatter": "Scatter Plot",
                              "box": "Box Plot",
                              "time": "Time Series"
                          }),
            
            ui.panel_conditional("input.plot_type === 'scatter'",
                               ui.input_slider("point_size", "Point Size:",
                                             min=1, max=10, value=3)),
            
            ui.input_action_button("generate", "Generate Data",
                                 class_="btn-primary")
        ),
        
        ui.panel_main(
            ui.navset_tab_card(
                ui.nav_panel("Visualization",
                            ui.output_plot("main_plot", height="500px"),
                            ui.output_text_verbatim("summary_stats")),
                ui.nav_panel("Data Table",
                            ui.output_data_frame("data_table"))
            )
        )
    )
)

# Define server logic
def server(input, output, session):
    # Reactive data generation
    def dataset():
        if input.generate() == 0:
            return None
        
        n = input.n_points()
        
        # Generate sample data
        dates = pd.date_range(
            start=datetime.now() - timedelta(days=n),
            end=datetime.now(),
            periods=n
        )
        
        df = pd.DataFrame({
            'timestamp': dates,
            'value': np.cumsum(np.random.normal(size=n)),
            'category': np.random.choice(list('ABCD'), size=n),
            'metric': np.random.uniform(0, 100, size=n)
        })
        
        return df
    
    @output
    @render.plot
    def main_plot():
        df = dataset()
        if df is None:
            return None
        
        if input.plot_type() == "scatter":
            fig = px.scatter(df, x='metric', y='value', color='category',
                           title='Scatter Plot Analysis',
                           labels={'metric': 'Metric', 'value': 'Value'},
                           size=[input.point_size()] * len(df))
            
        elif input.plot_type() == "box":
            fig = px.box(df, x='category', y='value', color='category',
                        title='Distribution by Category',
                        labels={'category': 'Category', 'value': 'Value'})
            
        else:  # time series
            fig = px.line(df, x='timestamp', y='value', color='category',
                         title='Time Series Analysis',
                         labels={'timestamp': 'Time', 'value': 'Value'})
        
        fig.update_layout(
            showlegend=True,
            legend=dict(orientation="h", yanchor="bottom", y=-0.3),
            template="plotly_white"
        )
        
        return fig
    
    @output
    @render.text
    def summary_stats():
        df = dataset()
        if df is None:
            return ""
        
        return f"Summary Statistics:\n\n{df['value'].describe()}"
    
    @output
    @render.data_frame
    def data_table():
        df = dataset()
        if df is None:
            return None
        
        return render.DataGrid(df, row_selection_mode="multiple")

# Create and run the app
app = App(app_ui, server)
