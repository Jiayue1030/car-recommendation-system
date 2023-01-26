from shiny import App, render, ui
from recommender import get_recommendation

# https://docs.google.com/document/d/1HxcNTPyc8kSnJPwXxZL_vK80l60Mjam72omXK9yfxOk/edit

app_ui = ui.page_fluid(
    ui.h2("Vehicle Recommendation System"),
    ui.input_numeric("salary", 
                     "Which of the following best describes your personal income last year in Ringgit Malaysia?", 
                     value=100),
    ui.input_slider("data_installment", 
                    "What is your preferred monthly installment?", 
                    300, 6000, 100),
    ui.input_slider("seat_capacity", 
                    "How many seats do you prefer?", 
                    2, 9, 1),
    ui.input_select("car_model", "Preferred car model", 
                    {"0": "Sedans", 
                     "1": "Hatchbacks",
                     "2": "Sports-Utility Vehicle (SUV)",
                     "3": "Station Wagon",
                     "4": "Multi-Purpose Van (MPV)",
                     "5": "Coupe",
                     "6": "Convertible",
                    }),
    # ui.output_text_verbatim("txt"),
    ui.input_action_button("run", "Surprise Me!", class_="btn-primary w-100")
)

def server(input, output, session):
    @output
    @render.text
    def txt():
        return f"x*2 is {input.data_installment() * 2}"


app = App(app_ui, server)
