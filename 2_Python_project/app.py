######################
# Import libraries
######################

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import streamlit as st
from PIL import Image
import base64

st.set_option('deprecation.showPyplotGlobalUse', False)

icon = Image.open("icon.ico")
st.set_page_config(
     page_title="Kickstarter Web App",
     layout="wide",
     page_icon=icon,
     initial_sidebar_state="expanded",
 )

######################
# Page Title
######################

# Image

image = Image.open("logo_app.jpg")

st.image(image, use_column_width=True)

# Title

st.title("Kickstarter Web App")

st.write("This app helps to improve your crowdfunding project!")

# About section

expander_bar = st.expander("About")
expander_bar.markdown("""
* **Python libraries:** numpy, pandas, streamlit, matplotlib, base64, PIL
* **Data source:** [Kaggle.com](https://www.kaggle.com/kemical/kickstarter-projects)
* **App Developers:** M.Majdak, D.Migoń, P.Rakowska [github.com](https://github.com/infoshareacademy/paradoma)
""")

st.write("""
***
""")


# Divide page to 3 columns (col1 = sidebar, col2 and col3 = page contents)
col1 = st.sidebar
col2, col3 = st.columns((3,1))

######################
# Import data
######################

@st.cache
def load_data():
    df = pd.read_csv("ks_projects_201801.csv")
    # Drop NaN
    df = df.dropna()
    # Convert data to datetime format
    df['deadline_new'] = pd.to_datetime(df['deadline']).dt.date
    df['launched_new'] = pd.to_datetime(df['launched']).dt.date
    # Calculating the duration of projects, cleaning data - conversion to the int type 
    df['duration'] = df['deadline_new'] - df['launched_new']
    df['duration'] = df['duration'].map(lambda x: int(str(x).split(" ")[0]))
    # Extract two project states: successful = 1, others = 0
    df["state_new"] = df["state"].map(lambda x: 1 if x == "successful" else 0 )
    # Removal of unnecessary columns
    to_drop = ["currency",
            "deadline",
            "goal",
             "launched",
            "pledged",
            "usd pledged"]
    df.drop(to_drop, inplace=True, axis=1)
    # Joining Luxembourg, Belgium and the Netherlands data as the Benelux
    df["country"] = df["country"].replace(["LU", "BE"],"NL")
    # Removal of countries with less than 1000 projects
    df = df[(df["country"] != "SG") 
            & (df["country"] != "JP") 
            & (df["country"] != "AT") 
            & (df["country"] != "HK")
            & (df["country"] != "NO")
            & (df["country"] != "CH")
            & (df["country"] != "IE")]
    # Extracting the year and month from the data 
    df['year_launched'] = pd.DatetimeIndex(df['launched_new']).year
    df['month_launched'] = pd.DatetimeIndex(df['launched_new']).month
    # Removal of records from 1970
    df = df[df["year_launched"] != 1970]

    return df

df = load_data()

######################
# Input - country selection
######################

col2.header("Choose Your Country")
col2.text("")

country_list = ["Australia", "Benelux", "Canada", "Denmark", "France", "Germany", "Great Britain", "Italy", "Mexico", "New Zealand", "Spain", "Sweden", "United States"]
country_dict = {
    "Australia": "AU",
    "Benelux": "NL",
    "Canada": "CA",
    "Denmark": "DK",
    "France": "FR",
    "Germany": "DE",
    "Great Britain": "GB",
    "Italy": "IT",
    "Mexico": "MX",
    "New Zealand": "NZ",
    "Spain": "ES",
    "Sweden": "SE",
    "United States": "US"
}

selected_country = col2.selectbox('Country', country_list)
selected_country_conv = country_dict[selected_country]

######################
# Output - after country selection
######################

col2.text("")
col2.warning("Click the button below to see the stats for country of your choise")
col2.text("")

if col2.button("Country Stats"):

    col2.subheader("Details about Kickstarter crowdfunding in " + selected_country)
    col2.text("")

    # Number of projects each year
    # col1, col2 = st.columns(2)
    country_filter = df[df["country"] == selected_country_conv]
    data_all = country_filter.groupby(by="year_launched").size().reset_index(name="sum")
    success_filter = country_filter[country_filter["state_new"] == 1]
    data_success = success_filter.groupby(by="year_launched").size().reset_index(name="sum_success")
    data = pd.merge(data_all, data_success, on="year_launched", how="left")
    plt.xlabel("Year", fontdict={"fontsize": 15})
    plt.ylabel("Qty of projects", fontdict={"fontsize": 15})
    plt.xticks(fontsize=13)
    plt.yticks(fontsize=13)
    plt.title("Number of projects each year", fontdict={"fontname": "monospace", "fontsize": 18})
    plt.xlim(2008.5,2018.5)
    plt.bar(data["year_launched"], data["sum"], color="#5588cc", width=0.5, fill=True, linestyle=":", edgecolor="#000000", label="Total")
    plt.bar(data["year_launched"], data["sum_success"], color="#29528a", width=0.5, fill=True, linestyle=":", edgecolor="#000000", label="Succeed")
    plt.legend()
    col2.pyplot()

    # Average duration of the project
    avg_dur = round(country_filter["duration"].mean(), 1)
    col2.text("")
    col2.warning("Average duration of the project in " + selected_country + ": " + str(avg_dur) + " days")
    
    # Percent of successful projects
    success_filter = country_filter[country_filter["state"]=="successful"]
    perc_success = round(len(success_filter)/len(country_filter)*100, 1)
    
    col2.warning("Percentage of successful projects in this country: " + str(perc_success) + " %.")
    
    # The best project (the highest amount of money)
    pro_bes = country_filter[["ID", "name", "deadline_new", "usd_pledged_real", "backers", "main_category"]]
    project_best = country_filter["usd_pledged_real"].idxmax()
    project_best_dict = pro_bes.loc[project_best].to_dict()
    
    col2.info("The most money was raised for the \"" + project_best_dict["name"] + "\" project.")

    image_2 = Image.open("png/" + selected_country_conv +".png")
    col2.image(image_2, use_column_width=True)

    col2.info("The collection finished successfully on " + str(project_best_dict["deadline_new"]) + ".") 
    col2.info("Project creators raised $ " + str(project_best_dict["usd_pledged_real"]) + ".")
    col2.info("The project had " + str(project_best_dict["backers"]) + " founders and was submitted in the " + project_best_dict["main_category"] + " category.")

    # The best project (the largest number of backers)
    top_backers = pro_bes["backers"].idxmax()
    top_backers_dict = pro_bes.loc[top_backers].to_dict()

    col2.error("The project with the largest number of backers was \"" + top_backers_dict["name"] + "\". It had " + str(top_backers_dict['backers']) + " founders.")
    
    image_3 = Image.open("png/" + selected_country_conv +"b.png")
    col2.image(image_3, use_column_width=True)

    # Sum backers in selected country
    sum_backers = country_filter["backers"].sum()
    
    col2.warning("The total number of people supporting crowdfunding projects in this country is " + str(sum_backers) + ".")


    # The most popular category
    category_filter = country_filter.groupby("main_category")
    m_cat_list = category_filter["main_category"].count().sort_values(ascending=False).head(1).to_dict()
    
    for cat, num in m_cat_list.items():
        col2.warning("The most popular category in " + selected_country + " is " + cat + " (" + str(num) + " projects).")
    
    # The most successful main category
    category_filter_succes = country_filter[country_filter["state"]=="successful"]
    category_filter_succes = category_filter_succes.groupby("main_category")
    m_cat_list2 = category_filter_succes["main_category"].count().sort_values(ascending=False).head(1).to_dict()
    
    for cat2, num2 in m_cat_list2.items():
        col2.warning("The category with the most successful projects is " + cat2 + ". There were " + str(num2) + " completed  projects.")

    col2.text("")

######################
# Input - params selection
######################

col2.subheader("🠈 To find out what are the chances for your project to succeed, choose params in the sidebar")
col2.text("")

# Sidebar
col1.header("Input Options")

# Main category selection
sorted_unique_m_category = sorted(df["main_category"].unique())
selected_m_category = col1.multiselect("Main category", sorted_unique_m_category, sorted_unique_m_category[:1])

# Category selection (dependent on main category)
main_cat_select = df[df["main_category"].isin(selected_m_category)]

sorted_unique_category = sorted(main_cat_select["category"].unique())
selected_category = col1.multiselect("Category", sorted_unique_category, sorted_unique_category)

# Project duration selection
selected_duration = col1.slider("How many days is the fundraising going to last?", min_value=1, max_value=100)
    
# Project amount selection
selected_amount = col1.number_input("How much money do you want to collect? [$]", step=10)

######################
# Output - after params selection
######################

# Filtering data
cf = df[df["country"] == selected_country_conv]

df_selected_projects = df[(df["country"] == selected_country_conv) & 
                        (df["main_category"].isin(selected_m_category)) & 
                        (df["category"].isin(selected_category))]

interval_list = [(0, 10), (10, 20), (20, 30), (30, 40), (40, 50), (50, 60), (60, 70), (70, 80), (80, 90), (90, 100)]
amount_list = list(cf["usd_goal_real"].quantile([0.2, 0.4, 0.6, 0.8]))

for start, stop in interval_list:
    if selected_duration > start and selected_duration <= stop:
        if selected_amount < amount_list[0]:
            df_selected_projects = df[(df["country"] == selected_country_conv) & 
                                    (df["main_category"].isin(selected_m_category)) & 
                                    (df["category"].isin(selected_category)) &
                                    (cf["duration"] > start) & (cf["duration"] <= stop) &
                                    (cf["usd_goal_real"] < amount_list[0])]
        elif selected_amount >= amount_list[0] and selected_amount < amount_list[1]:
            df_selected_projects = df[(df["country"] == selected_country_conv) & 
                                    (df["main_category"].isin(selected_m_category)) & 
                                    (df["category"].isin(selected_category)) &
                                    (cf["duration"] > start) & (cf["duration"] <= stop) &
                                    (cf["usd_goal_real"] >= amount_list[0]) & (cf["usd_goal_real"] < amount_list[1])]
        elif selected_amount >= amount_list[1] and selected_amount < amount_list[2]:
            df_selected_projects = df[(df["country"] == selected_country_conv) & 
                                    (df["main_category"].isin(selected_m_category)) & 
                                    (df["category"].isin(selected_category)) &
                                    (cf["duration"] > start) & (cf["duration"] <= stop) &
                                    (cf["usd_goal_real"] >= amount_list[1]) & (cf["usd_goal_real"] < amount_list[2])]
        elif selected_amount >= amount_list[2] and selected_amount < amount_list[3]:
            df_selected_projects = df[(df["country"] == selected_country_conv) & 
                                    (df["main_category"].isin(selected_m_category)) & 
                                    (df["category"].isin(selected_category)) &
                                    (cf["duration"] > start) & (cf["duration"] <= stop) &
                                    (cf["usd_goal_real"] >= amount_list[2]) & (cf["usd_goal_real"] < amount_list[3])] 
        elif selected_amount >= amount_list[3]:
            df_selected_projects = df[(df["country"] == selected_country_conv) & 
                                    (df["main_category"].isin(selected_m_category)) & 
                                    (df["category"].isin(selected_category)) &
                                    (cf["duration"] > start) & (cf["duration"] <= stop) &
                                    (cf["usd_goal_real"] >= amount_list[3])]

col2.header("Display Projects Info with Selected Params")
col2.success("Data Quantity: " + str(df_selected_projects.shape[0]) + " projects (" + str(df_selected_projects[df_selected_projects["state_new"] == 1].shape[0]) + " successful).")
col2.dataframe(df_selected_projects[["name", "category", 
                                    "main_category", "state", 
                                    "backers", "country", 
                                    "usd_pledged_real", 
                                    "usd_goal_real", 
                                    "launched_new", "duration"]].rename(
                                        columns= {
                                            "main_category": "main category",
                                            "usd_pledged_real" : "collected [$]",
                                            "usd_goal_real": "goal [$]",
                                            "launched_new": "launched",
                                            "duration": "duration [days]"
                                        }))

# Download selected projects data
# https://discuss.streamlit.io/t/how-to-download-file-in-streamlit/1806

def filedownload(df):
    csv = df.to_csv(index=False)
    b64 = base64.b64encode(csv.encode()).decode()  # strings <-> bytes conversions
    href = f'<a href="data:file/csv;base64,{b64}" download="projectinfo.csv">Download CSV File</a>'
    return href

col2.markdown(filedownload(df_selected_projects), unsafe_allow_html=True)

######################
# Output - probability calc
######################

col2.text("")
col2.header("Probability of getting funds")

def mcat_prob():
    # Founded projects in selected main category
    mcat_s = cf[(cf["main_category"].isin(selected_m_category)) & (cf["state_new"] == 1)]
    # No fundation in selected main category
    mcat_no_s = cf[(cf["main_category"].isin(selected_m_category)) & (cf["state_new"] == 0)]
    # The probability that the project will be funded if it is submitted to a certain main category
    prob_main_category = round(100 * mcat_s["state_new"].count() / (mcat_s["state_new"].count() + mcat_no_s["state_new"].count()), 1)
    return prob_main_category

def cat_prob():      
    # Founded projects in selected category
    cat_s = cf[(cf["category"].isin(selected_category)) & (cf["state_new"] == 1)]
    # No fundation in selected category
    cat_no_s = cf[(cf["category"].isin(selected_category)) & (cf["state_new"] == 0)]
    # The probability that the project will be funded if it is submitted to a certain category
    prob_category = round(100 * cat_s["state_new"].count() / (cat_s["state_new"].count() + cat_no_s["state_new"].count()), 1)
    return prob_category    

# The probability that the project will be funded if it lasts a certain amount of time
prob_duration = 100 * (cf[cf["state_new"] == 1].count()/cf["state_new"].count())
# Checks in which range is the value specified by the user
interval_list = [(0, 10), (10, 20), (20, 30), (30, 40), (40, 50), (50, 60), (60, 70), (70, 80), (80, 90), (90, 100)]
for start, stop in interval_list:
    if selected_duration > start and selected_duration <= stop:
         # Founded projects in selected duration
        dur_s = cf[ (cf["duration"] > start) & (cf["duration"] <= stop) & (cf["state_new"] == 1) ]
        # No fundation in selected duration
        dur_no_s = cf[ (cf["duration"] > start) & (cf["duration"] <= stop) & (cf["state_new"] == 0) ]
        # The probability that the project will be funded if it lasts for a certain amount of time
        prob_duration = round(100 * dur_s["state_new"].count() / (dur_s["state_new"].count() + dur_no_s["state_new"].count()), 1)

# The probability that the project will be funded depending on the amount of money needed
prob_amount = 100 * (cf[cf["state_new"] == 1].count()/cf["state_new"].count())
# Checks in which range is the value specified by the user
amount_list = list(cf["usd_goal_real"].quantile([0.2, 0.4, 0.6, 0.8]))
if selected_amount < amount_list[0]:   
    amount_s = cf[ (cf["usd_goal_real"] < amount_list[0]) & (cf["state_new"] == 1) ]
    amount_no_s = cf[ (cf["usd_goal_real"] < amount_list[0]) & (cf["state_new"] == 0) ]
    prob_amount = round(100 * amount_s["state_new"].count() / (amount_s["state_new"].count() + amount_no_s["state_new"].count()), 1)     
elif selected_amount >= amount_list[0] and selected_amount < amount_list[1]: 
    amount_s = cf[ (cf["usd_goal_real"] >= amount_list[0]) & (cf["usd_goal_real"] < amount_list[1]) & (cf["state_new"] == 1)]
    amount_no_s = cf[ (cf["usd_goal_real"] >= amount_list[0]) & (cf["usd_goal_real"] < amount_list[1]) & (cf["state_new"] == 0) ]
    prob_amount = round(100 * amount_s["state_new"].count() / (amount_s["state_new"].count() + amount_no_s["state_new"].count()), 1)
elif selected_amount >= amount_list[1] and selected_amount < amount_list[2]:
    amount_s = cf[ (cf["usd_goal_real"] >= amount_list[1]) & (cf["usd_goal_real"] < amount_list[2]) & (cf["state_new"] == 1)]
    amount_no_s = cf[ (cf["usd_goal_real"] >= amount_list[1]) & (cf["usd_goal_real"] < amount_list[2]) & (cf["state_new"] == 0) ]
    prob_amount = round(100 * amount_s["state_new"].count() / (amount_s["state_new"].count() + amount_no_s["state_new"].count()), 1)  
elif selected_amount >= amount_list[2] and selected_amount < amount_list[3]:
    amount_s = cf[ (cf["usd_goal_real"] >= amount_list[2]) & (cf["usd_goal_real"] < amount_list[3]) & (cf["state_new"] == 1)]
    amount_no_s = cf[ (cf["usd_goal_real"] >= amount_list[2]) & (cf["usd_goal_real"] < amount_list[3]) & (cf["state_new"] == 0) ]
    prob_amount = round(100 * amount_s["state_new"].count() / (amount_s["state_new"].count() + amount_no_s["state_new"].count()), 1)
elif selected_amount >= amount_list[3]:       
    amount_s = cf[(cf["usd_goal_real"] >= amount_list[3]) & (cf["state_new"] == 1)]
    amount_no_s = cf[(cf["usd_goal_real"] >= amount_list[3]) & (cf["state_new"] == 0) ]
    prob_amount = round(100 * amount_s["state_new"].count() / (amount_s["state_new"].count() + amount_no_s["state_new"].count()), 1)


p_abcd = np.sum((df["country"] == selected_country_conv) & 
                (df["main_category"].isin(selected_m_category)) & 
                (df["category"].isin(selected_category))) / cf["ID"].count()

p_abcde = np.sum((df["country"] == selected_country_conv) & 
                (df["main_category"].isin(selected_m_category)) & 
                (df["category"].isin(selected_category)) &
                (df["state_new"] == 1)) / cf["ID"].count()

interval_list = [(0, 10), (10, 20), (20, 30), (30, 40), (40, 50), (50, 60), (60, 70), (70, 80), (80, 90), (90, 100)]
amount_list = list(cf["usd_goal_real"].quantile([0.2, 0.4, 0.6, 0.8]))

for start, stop in interval_list:
    if selected_duration > start and selected_duration <= stop:
        if selected_amount < amount_list[0]:
            p_abcd = np.sum((df["country"] == selected_country_conv) & 
                            (df["main_category"].isin(selected_m_category)) & 
                            (df["category"].isin(selected_category)) &
                            (cf["duration"] > start) & (cf["duration"] <= stop) &
                            (cf["usd_goal_real"] < amount_list[0])) / cf["ID"].count()
            p_abcde = np.sum((df["country"] == selected_country_conv) & 
                             (df["main_category"].isin(selected_m_category)) & 
                             (df["category"].isin(selected_category)) &
                             (df["state_new"] == 1) &
                             (cf["duration"] > start) & (cf["duration"] <= stop) &
                             (cf["usd_goal_real"] < amount_list[0])) / cf["ID"].count()
        elif selected_amount >= amount_list[0] and selected_amount < amount_list[1]:
            p_abcd = np.sum((df["country"] == selected_country_conv) & 
                            (df["main_category"].isin(selected_m_category)) & 
                            (df["category"].isin(selected_category)) &
                            (cf["duration"] > start) & (cf["duration"] <= stop) &
                            (cf["usd_goal_real"] >= amount_list[0]) & (cf["usd_goal_real"] < amount_list[1])) / cf["ID"].count()
            p_abcde = np.sum((df["country"] == selected_country_conv) & 
                             (df["main_category"].isin(selected_m_category)) & 
                             (df["category"].isin(selected_category)) &
                             (df["state_new"] == 1) &
                             (cf["duration"] > start) & (cf["duration"] <= stop) &
                             (cf["usd_goal_real"] >= amount_list[0]) & (cf["usd_goal_real"] < amount_list[1])) / cf["ID"].count()
        elif selected_amount >= amount_list[1] and selected_amount < amount_list[2]:
            p_abcd = np.sum((df["country"] == selected_country_conv) & 
                            (df["main_category"].isin(selected_m_category)) & 
                            (df["category"].isin(selected_category)) &
                            (cf["duration"] > start) & (cf["duration"] <= stop) &
                            (cf["usd_goal_real"] >= amount_list[1]) & (cf["usd_goal_real"] < amount_list[2])) / cf["ID"].count()
            p_abcde = np.sum((df["country"] == selected_country_conv) & 
                             (df["main_category"].isin(selected_m_category)) & 
                             (df["category"].isin(selected_category)) &
                             (df["state_new"] == 1) &
                             (cf["duration"] > start) & (cf["duration"] <= stop) &
                             (cf["usd_goal_real"] >= amount_list[1]) & (cf["usd_goal_real"] < amount_list[2])) / cf["ID"].count()
        elif selected_amount >= amount_list[2] and selected_amount < amount_list[3]:
            p_abcd = np.sum((df["country"] == selected_country_conv) & 
                            (df["main_category"].isin(selected_m_category)) & 
                            (df["category"].isin(selected_category)) &
                            (cf["duration"] > start) & (cf["duration"] <= stop) &
                            (cf["usd_goal_real"] >= amount_list[2]) & (cf["usd_goal_real"] < amount_list[3])) / cf["ID"].count()
            p_abcde = np.sum((df["country"] == selected_country_conv) & 
                             (df["main_category"].isin(selected_m_category)) & 
                             (df["category"].isin(selected_category)) &
                             (df["state_new"] == 1) &
                             (cf["duration"] > start) & (cf["duration"] <= stop) &
                             (cf["usd_goal_real"] >= amount_list[2]) & (cf["usd_goal_real"] < amount_list[3])) / cf["ID"].count()
        elif selected_amount >= amount_list[3]:
            p_abcd = np.sum((df["country"] == selected_country_conv) & 
                            (df["main_category"].isin(selected_m_category)) & 
                            (df["category"].isin(selected_category)) &
                            (cf["duration"] > start) & (cf["duration"] <= stop) &
                            (cf["usd_goal_real"] >= amount_list[3])) / cf["ID"].count()
            p_abcde = np.sum((df["country"] == selected_country_conv) & 
                             (df["main_category"].isin(selected_m_category)) & 
                             (df["category"].isin(selected_category)) &
                             (df["state_new"] == 1) &
                             (cf["duration"] > start) & (cf["duration"] <= stop) &
                             (cf["usd_goal_real"] >= amount_list[3])) / cf["ID"].count()

if p_abcde == 0 or p_abcd == 0:
    answear = "##### The overal probability cannot be determined"
else:
    p = round((p_abcde / p_abcd) * 100, 1)
    answear = f"##### The overall probability of getting funds is {p}%"


col2.text("")
if col2.button("Calculate"):
    col2.text("")
    col2.markdown(f"""
    ##### Probability of funding a project in selected main categories: 
    <span style='color:limegreen; font-family:Papyrus; font-size:2.5em; display: block; text-align:center;'><b> {mcat_prob()}% </b></span>.
    """, unsafe_allow_html=True)
    col2.text("")
    col2.markdown(f"##### Probability of funding a project in selected categories: {cat_prob()}%.")
    col2.text("")
    col2.markdown(f"##### Probability of funding for project duration {selected_duration} days: {prob_duration}%.")
    col2.text("")
    col2.markdown(f"##### Probability of financing a project with an estimated cost of $ {selected_amount}: {prob_amount}%.")
    col2.text("")
    col2.markdown(answear)
