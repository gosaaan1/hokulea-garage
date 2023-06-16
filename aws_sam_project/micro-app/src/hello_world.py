from flask_restful import Resource

class HelloWorld(Resource):

    def get(self):
        return {'msg': 'get method canary'}

    def post(self):
        return {'msg': 'post method'}
