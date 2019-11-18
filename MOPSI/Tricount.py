from flask import Flask
from flask import request
from flask import render_template
import csv 
import os


app = Flask(__name__)
file = open("Data.csv", 'w')
data =[]

@app.route('/')
def home():
    return render_template("home.html")

@app.route('/', methods=['POST'])
def text_box():
    text = request.form['text']
    data.append([text])
    print (data)
    csv_writer = csv.writer(file, delimiter=",")
    csv_writer.writerow([text])
    return render_template("home.html")
def lauch_opti()
    os.remove("C:/Users/pc/Desktop/Enpc/2A/MOPSI/Results.csv")
    os.system("glpsol -m C:/Users/pc/Desktop/Enpc/2A/MOPSI/Tricount.mod")
if __name__ == '__main__':
    app.run()