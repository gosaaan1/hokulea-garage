import awsgi
from flask import Flask, request
from flask_restful import Resource, Api
from hello_world import HelloWorld

app = Flask(__name__)
api = Api(app)

api.add_resource(HelloWorld, '/api/micro/hello')

def lambda_handler(event, context):
    return awsgi.response(app, event, context)