import awsgi
from flask import Flask, request
from flask_restful import Resource, Api

app = Flask(__name__)
api = Api('app')

def lambda_handler(event, context):
    return awsgi.response(app, event, context)