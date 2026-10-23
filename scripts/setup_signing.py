"""Create an assignment-only release signing identity; never commit its files."""
import os,pathlib,secrets,shutil,subprocess
root=pathlib.Path(__file__).resolve().parents[1]
properties=root/'android/key.properties'
if properties.exists():
 print('Existing local release signing configuration retained.')
else:
 password=secrets.token_urlsafe(32)
 bundled='/opt/homebrew/opt/openjdk@17/bin/keytool'
 keytool=bundled if pathlib.Path(bundled).exists() else shutil.which('keytool')
 keystore=root/'android/app/assignment-release.jks'
 environment={**os.environ,'GALAXY_SIGNING_PASSWORD':password}
 subprocess.run([keytool,'-genkeypair','-keystore',str(keystore),'-alias','galaxy_pinterest',
  '-storetype','JKS','-keyalg','RSA','-keysize','2048','-validity','3650',
  '-dname','CN=Galaxy Internship Assignment, OU=Development, O=Personal, C=IN',
  '-storepass:env','GALAXY_SIGNING_PASSWORD','-keypass:env','GALAXY_SIGNING_PASSWORD'],env=environment,check=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
 properties.write_text(f'storePassword={password}\nkeyPassword={password}\nkeyAlias=galaxy_pinterest\nstoreFile=assignment-release.jks\n')
 properties.chmod(0o600);keystore.chmod(0o600)
 print('Created local assignment signing identity. Keystore and passwords are ignored by Git.')
