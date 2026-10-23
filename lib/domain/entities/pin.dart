class Pin {
  const Pin({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.description = '',
    this.creator = 'Pexels creator',
    this.category = 'For you',
    this.sourceUrl = '',
    this.assetPath,
    this.imageBase64,
    this.videoUrl,
    this.source = 'Pexels',
    this.creatorUrl = '',
    this.downloadLocation,
    this.color = 0xffe9e4de,
  });

  final String id, title, description, creator, category, imageUrl, sourceUrl;
  final String? assetPath, imageBase64, videoUrl, downloadLocation;
  final String source, creatorUrl;
  final int width, height, color;
  bool get isVideo => videoUrl != null;
  bool get isCreated => id.startsWith('local_');
  double get aspectRatio => (width / (height == 0 ? 1 : height)).clamp(.5, 1.5);

  factory Pin.fromJson(Map<String, dynamic> j) => Pin(
    id: j['id'].toString(),
    title: j['title'] as String? ?? 'An idea to keep',
    imageUrl: j['imageUrl'] as String? ?? '',
    width: j['width'] as int? ?? 800,
    height: j['height'] as int? ?? 1200,
    description: j['description'] as String? ?? '',
    creator: j['creator'] as String? ?? 'Pexels creator',
    category: j['category'] as String? ?? 'For you',
    sourceUrl: j['sourceUrl'] as String? ?? '',
    assetPath: j['assetPath'] as String?,
    imageBase64: j['imageBase64'] as String?,
    videoUrl: j['videoUrl'] as String?,
    source: j['source'] as String? ?? 'Pexels',
    creatorUrl: j['creatorUrl'] as String? ?? '',
    downloadLocation: j['downloadLocation'] as String?,
    color: j['color'] as int? ?? 0xffe9e4de,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'creator': creator,
    'category': category,
    'imageUrl': imageUrl,
    'sourceUrl': sourceUrl,
    'width': width,
    'height': height,
    'assetPath': assetPath,
    'imageBase64': imageBase64,
    'videoUrl': videoUrl,
    'source': source,
    'creatorUrl': creatorUrl,
    'downloadLocation': downloadLocation,
    'color': color,
  };
}

class PinPage {
  const PinPage(this.pins, {required this.hasMore});
  final List<Pin> pins;
  final bool hasMore;
}
