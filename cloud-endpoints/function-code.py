from flask import escape

def uploads(request):
    """HTTP Cloud Function.
    Args:
        request (flask.Request): The request object.
        <http://flask.pocoo.org/docs/1.0/api/#flask.Request>
    Returns:
        The response text, or any set of values that can be turned into a
        Response object using `make_response`
        <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>.
    """
    request_json = request.get_json(silent=True)
    request_args = request.args

    if request_json and '_id' in request_json:
        name = request_json['_id']
    elif request_args and '_id' in request_args:
        name = request_args['_id']
    else:
        name = 'World'
    return 'Hello {}!'.format(escape(name))