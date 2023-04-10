import requests

for repo in ('minio', 'mc', 'console'):
    r = requests.get('https://api.github.com/repos/minio/{}/releases/latest'.format(repo))
    if r.status_code == 200:
        print('{}: {}'.format(repo, r.json()['tag_name']))
