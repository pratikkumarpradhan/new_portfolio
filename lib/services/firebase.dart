class PortfolioProject {
  final String title;
  final String overview;
  final String tagline;
  final String youtubeUrl;
  final String description1Heading;
  final String description1;
  final String description2Heading;
  final String description2;
  final String description3Heading;
  final String description3;
  final String description4Heading;
  final String description4;
  final String description5Heading;
  final String description5;
  final List<String> images;
  final int order;

  PortfolioProject({
    required this.title,
    required this.overview,
    required this.tagline,
    required this.youtubeUrl,
    required this.description1Heading,
    required this.description1,
    required this.description2Heading,
    required this.description2,
    required this.description3Heading,
    required this.description3,
    required this.description4Heading,
    required this.description4,
    required this.description5Heading,
    required this.description5,
    required this.images,
    required this.order,
  });

  factory PortfolioProject.fromMap(Map<String, dynamic> map) {
    return PortfolioProject(
      title: map['title'] ?? '',
      overview: map['overview'] ?? '',
      tagline: map['tagline'] ?? '',
      youtubeUrl: map['youtube_url'] ?? '',
      description1Heading: map['description1_heading'] ?? 'Overview',
      description1: map['description1'] ?? '',
      description2Heading: map['description2_heading'] ?? 'Technical Details',
      description2: map['description2'] ?? '',
      description3Heading: map['description3_heading'] ?? 'Implementation',
      description3: map['description3'] ?? '',
      description4Heading: map['description4_heading'] ?? 'Challenges',
      description4: map['description4'] ?? '',
      description5Heading: map['description5_heading'] ?? 'Future Improvements',
      description5: map['description5'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'overview': overview,
      'tagline': tagline,
      'youtube_url': youtubeUrl,
      'description1_heading': description1Heading,
      'description1': description1,
      'description2_heading': description2Heading,
      'description2': description2,
      'description3_heading': description3Heading,
      'description3': description3,
      'description4_heading': description4Heading,
      'description4': description4,
      'description5_heading': description5Heading,
      'description5': description5,
      'images': images,
      'order': order,
    };
  }
}