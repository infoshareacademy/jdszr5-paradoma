import ipywidgets as widgets 
from IPython.display import display
from IPython.display import Image
import pandas as pd 
import numpy as np 
import datetime
import os
import matplotlib.pyplot as plt

pd.options.mode.chained_assignment = None 
filename = "ks_projects_201801.csv"
df = pd.read_csv(filename)
df = df.dropna()
df["country"] = df["country"].replace(["LU", "BE"],"NL")
project_country = dict(df["country"].value_counts())
df = df[(df["country"] != "SG") 
        & (df["country"] != "JP") 
        & (df["country"] != "AT") 
        & (df["country"] != "HK")
        & (df["country"] != "NO")
        & (df["country"] != "CH")
        & (df["country"] != "IE")]


def value_choice(v):
    country_filter = df[df['country']==choice_widget.value]
    country_filter_date = country_filter[['launched']].sample(frac=1)
    country_filter_date['launched'] = pd.to_datetime(country_filter_date['launched'])
    country_filter_date['year'] = country_filter_date['launched'].dt.year
    date_filter = country_filter_date.groupby('year')
    print("\nDetails about Kickstarter crowdfunding in this country.")
    y_graph = date_filter['launched'].count()
    yyy = y_graph.to_numpy()
    xxx = country_filter_date['year'].unique()
    plt.xlabel('Year')
    plt.ylabel('Qty of projects')
    plt.title('Number of projects each year', fontdict={'fontname': 'monospace', 'fontsize': 18})
    plt.xlim(2008.5,2018.5)
    plt.bar(sorted(xxx), yyy, color='#5588cc', width=0.5, fill=True, linestyle=':', edgecolor='#000000')
    plt.show()
    
    country_filter.loc[:,'deadline'] = pd.to_datetime(country_filter['deadline'])
    country_filter.loc[:,'launched'] = pd.to_datetime(country_filter['launched'])
    country_filter.loc[:,'new_date'] = country_filter['deadline'] - country_filter['launched']
    time_pro = round(country_filter['new_date'] / np.timedelta64(1,'D'),0)
    print(f"\nAverage duration: {np.mean(time_pro):.2f} days.")
    success_filter = country_filter[country_filter['state']=='successful']
    a = len(success_filter)/len(country_filter)*100
    print(f"\nPercentage of successful projects in {choice_widget.value}: {a:.2f}%\n")
    pro_bes = country_filter[['ID', 'name', 'deadline', 'usd_pledged_real', 'backers', 'category']]
    project_best = country_filter['usd_pledged_real'].idxmax()
    project_best_dict = pro_bes.loc[project_best].to_dict()
    print(f"In this country, the most money was raised for the project {project_best_dict['name']}.\nThe fundraiser was successful on {project_best_dict['deadline']}. Pledged {project_best_dict['usd_pledged_real']} USD. Was {project_best_dict['backers']} founders.\nThe project was in the category: {project_best_dict['category']}.")
    photo_project = str(choice_widget.value+'.png')
    pil_img = Image(filename=os.path.join('png/', photo_project))
    display(pil_img)
    top_backers = pro_bes['backers'].idxmax()
    
    top_backers_dict = pro_bes.loc[top_backers].to_dict()
    print(f"\nProject with the largest number od backers - {top_backers_dict['name']}.\nWas {top_backers_dict['backers']} founders.")
    category_filter = country_filter.groupby('main_category')
    m_cat_list = category_filter['main_category'].count().sort_values(ascending=False).head(1).to_dict()
    for category, numbers in m_cat_list.items():
        print(f"\nThe most popular category with the most projects was {category} - {numbers} projects.")
#     The main category with the most projects was
    category_filter_succes = country_filter[country_filter['state']=='successful']
    category_filter_succes = category_filter_succes.groupby('main_category')
    m_cat_list2 = category_filter_succes['main_category'].count().sort_values(ascending=False).head(1).to_dict()
    for category, numbers in m_cat_list2.items():
        print(f"\nThe category with the most successful projects is {category}. It was successfully completed {numbers} projects.")

choice_widget = widgets.Dropdown(layout={'width': 'max-content'}, options=[("Australia",'AU'),("Benelux",'NL'),("Canada",'CA'),("Denmark",'DK'),("France",'FR'),("Germany",'DE'),("Great Britain",'GB'),("Itlay",'IT'),("Mexico",'MX'),("New Zealand",'NZ'),("Spain",'ES'),("Sweden",'SE'),("United States",'US')],value='US',description='Select country:',style={'description_width': 'initial'})
widgets.interact(value_choice, v=choice_widget)