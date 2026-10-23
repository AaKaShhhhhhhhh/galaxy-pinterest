"""Check configured development services without printing keys or tokens."""
import base64,json,pathlib,urllib.request,urllib.error
config=json.loads((pathlib.Path(__file__).resolve().parents[1]/'config/local.json').read_text())
key=config.get('UNSPLASH_ACCESS_KEY','')
if key:
 request=urllib.request.Request('https://api.unsplash.com/photos?per_page=1',headers={'Authorization':'Client-ID '+key,'Accept-Version':'v1'})
 with urllib.request.urlopen(request,timeout=25) as response:
  photos=json.load(response)
  assert photos and photos[0].get('urls',{}).get('regular')
  print('Unsplash: authenticated successfully; photo and attribution fields available')
key=config.get('CLERK_PUBLISHABLE_KEY','')
if key:
 encoded=key.split('_',2)[2];host=base64.b64decode(encoded+'='*(-len(encoded)%4)).decode().rstrip('$')
 with urllib.request.urlopen('https://'+host+'/v1/environment',timeout=25) as response:
  data=json.load(response)
  assert data.get('response') or data.get('auth_config') or data.get('display_config')
  print('Clerk: development instance reachable; environment configuration available')
