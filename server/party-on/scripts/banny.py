#!/usr/bin/env python
"""
Take our FBTestUser Banny McBannerson and either 'ban' him or 'unban' him.
Hitting the /bannedstatus endpoint after running this script should return
the expected result based on the subcommand used. 
"""
import datetime, sys
import requests, pymongo

mongo_client = pymongo.MongoClient()
db = mongo_client['party-on-test']

api_root = 'http://localhost/api'
banny_id = '138176626529976'
banny_token = 'CAABzpqkH5PgBAG0jeaDbJOk1UilxRyj37kjta27GO1zZAVlW0lQJxE7STHhRG8QQouEvgi3KxAasc1cfwf12EcZBqJZAQU9elHqYwcpVM7nKda7ZAg4gJiFSjbLVFBI1POEiN64Q5dmcjj8oYN1JIhpvgRx1ZCi5dqqk5g7g3bw0VpW29sXRma5xZAoR0RzPZBcmhfxPu6DDotyLtNLz2WTxsJxRafDNyccOQkIbE62qwZDZD'

def make_party():
    party = {
        "formattedAddress": "123 N Jefferson",
        "latitude": 21.63,
        "longitude": -83.2783,
        "maleCost": 5,
        "femaleCost": 0,
        "startTime": 1441782205000,
        "byob": False,
        "university": "Indiana University"
        }
    
    res = requests.post(api_root + '/parties',
                        headers={
            'Authorization': 'Bearer ' + banny_token,
            'Passport-Auth-Strategy': 'facebook'
            }, data=party)
    assert res.status_code == 200    
    return res.json()

def flag_party(party):
    endpoint = api_root + '/parties/%s/flag' % party['_id']
    res = requests.post(endpoint,
                        data = {
            'comment': 'Fuck banny'
            })
    return res.json()

def delete_banny_parties():
    banny_fb = db.fblogins.find_one({'userId': banny_id})
    banny = db.users.find_one({'facebook': banny_fb['_id']})
    # remove banny's parties for kicks
    db.parties.remove({'user': banny['_id']})
    # but care about removing his flags
    flagrecord_update = db.flaghistories.find_one_and_update(
        {'user': banny['_id']},
        {'$set': {'flags': []}})
    return flagrecord_update


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print 'must pass a command'
        exit(2)

    cmd = sys.argv[1]
    if cmd == 'ban':
        flags_until_ban = 3
        for _ in range(flags_until_ban):
            party_json = make_party()
            flag_party(party_json)
    elif cmd == 'unban':
        print 'removed: %s' % delete_banny_parties()
    else:
        print 'not a valid command'



