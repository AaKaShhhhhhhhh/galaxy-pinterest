"""Regenerate the simple typographic app mark. Requires Pillow (development only)."""
import json,pathlib
from PIL import Image,ImageDraw,ImageFont
root=pathlib.Path(__file__).resolve().parents[1]
font_path='/System/Library/Fonts/Supplemental/Georgia Bold Italic.ttf'
if not pathlib.Path(font_path).exists():
 raise SystemExit('Set font_path to a local bold italic serif font before regenerating.')
icon=Image.new('RGB',(1024,1024),'#e60023')
draw=ImageDraw.Draw(icon);font=ImageFont.truetype(font_path,800)
box=draw.textbbox((0,0),'P',font=font)
x=(1024-(box[2]-box[0]))/2-box[0]-28
y=(1024-(box[3]-box[1]))/2-box[1]
draw.text((x,y),'P',font=font,fill='white')
def save(path,size):
 path.parent.mkdir(parents=True,exist_ok=True)
 icon.resize((size,size),Image.Resampling.LANCZOS).save(path)
for density,size in [('mdpi',48),('hdpi',72),('xhdpi',96),('xxhdpi',144),('xxxhdpi',192)]:
 save(root/f'android/app/src/main/res/mipmap-{density}/ic_launcher.png',size)
folder=root/'ios/Runner/Assets.xcassets/AppIcon.appiconset'
for item in json.loads((folder/'Contents.json').read_text())['images']:
 if 'filename' in item:
  size=round(float(item['size'].split('x')[0])*float(item['scale'].rstrip('x')))
  save(folder/item['filename'],size)
for size in (192,512):
 save(root/f'web/icons/Icon-{size}.png',size)
 save(root/f'web/icons/Icon-maskable-{size}.png',size)
save(root/'web/favicon.png',48)
print('Generated Android, iOS and web app icons.')
