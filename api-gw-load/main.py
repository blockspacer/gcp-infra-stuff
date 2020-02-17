from flask import escape

def upload(request):
    json = request.get_json(silent=True)
    args = request.args
    
    if request.method == 'POST':
        firstname = json["firstname"]
        lastname = json["lastname"]
        ip = request.remote_addr
        return firstname+lastname+ip
    return 'What Method?'
