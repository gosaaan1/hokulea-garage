import awsgi
from flask import Flask, request
from flask_restful import Resource, Api
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()
app = Flask(__name__)
api = Api(app)
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///project.db"
db.init_app(app)

class HelloWorld(Resource):
    def get(self):
        return {'msg': 'get method'}

    def post(self):
        return {'msg': 'post method'}

api.add_resource(HelloWorld, '/hello')

def lambda_handler(event, context):
    return awsgi.response(app, event, context)