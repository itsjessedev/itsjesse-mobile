class PortfolioData {
  final Profile profile;
  final Skills skills;
  final List<Service> services;
  final List<Project> projects;
  final String version;
  final String lastUpdated;

  PortfolioData({
    required this.profile,
    required this.skills,
    required this.services,
    required this.projects,
    required this.version,
    required this.lastUpdated,
  });

  factory PortfolioData.fromJson(Map<String, dynamic> json) {
    return PortfolioData(
      profile: Profile.fromJson(json['profile']),
      skills: Skills.fromJson(json['skills']),
      services: (json['services'] as List).map((s) => Service.fromJson(s)).toList(),
      projects: (json['projects'] as List).map((p) => Project.fromJson(p)).toList(),
      version: json['version'] ?? '1.0.0',
      lastUpdated: json['lastUpdated'] ?? '',
    );
  }
}

class Profile {
  final String name;
  final String title;
  final String? photoUrl;
  final String location;
  final bool remote;
  final String email;
  final String jobsEmail;
  final String github;
  final String linkedin;
  final String website;
  final String summary;

  Profile({
    required this.name,
    required this.title,
    this.photoUrl,
    required this.location,
    required this.remote,
    required this.email,
    required this.jobsEmail,
    required this.github,
    required this.linkedin,
    required this.website,
    required this.summary,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      photoUrl: json['photoUrl'],
      location: json['location'] ?? '',
      remote: json['remote'] ?? false,
      email: json['email'] ?? '',
      jobsEmail: json['jobsEmail'] ?? '',
      github: json['github'] ?? '',
      linkedin: json['linkedin'] ?? '',
      website: json['website'] ?? '',
      summary: json['summary'] ?? '',
    );
  }
}

class Skills {
  final List<String> languages;
  final List<String> frameworks;
  final List<String> databases;
  final List<String> integrations;
  final List<String> concepts;

  Skills({
    required this.languages,
    required this.frameworks,
    required this.databases,
    required this.integrations,
    required this.concepts,
  });

  factory Skills.fromJson(Map<String, dynamic> json) {
    return Skills(
      languages: List<String>.from(json['languages'] ?? []),
      frameworks: List<String>.from(json['frameworks'] ?? []),
      databases: List<String>.from(json['databases'] ?? []),
      integrations: List<String>.from(json['integrations'] ?? []),
      concepts: List<String>.from(json['concepts'] ?? []),
    );
  }
}

class Service {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool highlight;
  final List<String> features;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.highlight = false,
    this.features = const [],
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      highlight: json['highlight'] ?? false,
      features: List<String>.from(json['features'] ?? []),
    );
  }
}

class Project {
  final String id;
  final String title;
  final String tagline;
  final String description;
  final String problem;
  final String solution;
  final List<String> results;
  final List<String> tech;
  final String category;
  final String serviceId;
  final String image;
  final String? githubUrl;
  final String? demoUrl;
  final bool featured;

  Project({
    required this.id,
    required this.title,
    required this.tagline,
    required this.description,
    required this.problem,
    required this.solution,
    required this.results,
    required this.tech,
    required this.category,
    required this.serviceId,
    required this.image,
    this.githubUrl,
    this.demoUrl,
    this.featured = false,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      tagline: json['tagline'] ?? '',
      description: json['description'] ?? '',
      problem: json['problem'] ?? '',
      solution: json['solution'] ?? '',
      results: List<String>.from(json['results'] ?? []),
      tech: List<String>.from(json['tech'] ?? []),
      category: json['category'] ?? '',
      serviceId: json['serviceId'] ?? '',
      image: json['image'] ?? '',
      githubUrl: json['githubUrl'],
      demoUrl: json['demoUrl'],
      featured: json['featured'] ?? false,
    );
  }
}
