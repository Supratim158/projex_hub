import 'dart:core';
import 'actor.dart';

class Movie {
  int? id;
  String name;
  String imageUrl;
  String coverUrl;
  String summary;
  String director;
  List<String>? genres;
  double rate;
  List<Actor>? cast;

  // 🆕 Fields for Summary screen
  List<String> imagePaths; // 1–4 images
  String videoPath;        // demo video
  String pptPath;          // presentation PDF
  String pdfPath;          // project report PDF

  // 🆕 Newly added fields
  String link;             // project or GitHub link
  String members;          // team members or count
  String year;             // project year

  Movie({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.coverUrl,
    required this.summary,
    required this.director,
    this.genres,
    required this.rate,
    this.cast,
    required this.imagePaths,
    required this.videoPath,
    required this.pptPath,
    required this.pdfPath,
    required this.link,
    required this.members,
    required this.year,
  });
}

List<Movie> movies = [
  Movie(
    id: 1,
    name: "Smart Classroom Monitoring",
    imageUrl: "assets/movies/smart1.jpg",
    coverUrl: "assets/movies/smart1.jpg",
    summary: "This project is an Computer Vision-Based Smart Classroom Monitoring System that uses computer vision to automatically detect student activities in real time. It identifies students using face recognition, detects sleeping behavior through eye aspect ratio (EAR) using MediaPipe, and monitors phone usage with YOLOv8. When a student is found sleeping or using a phone, the system plays a sound alert, displays a personalized warning (e.g., “Ank is sleeping” or “Ank is using phone”), and logs the event in a CSV file with timestamp and name. This system helps teachers maintain focus, discipline, and attentiveness in classrooms effectively.",
    director: "Debajyoti Chatterjee",
    genres: ["Web", "ML"],
    rate: 7.1,
    cast: [
      Actor(name: "Supratim Modak", imageUrl: "assets/movies/smart4.jpg"),
      Actor(name: "Ankshika Ghosh", imageUrl: "assets/movies/smart5.jpg"),
      Actor(name: "Stuti Modak", imageUrl: "assets/movies/smart6.jpg"),
    ],
    imagePaths: [
      "assets/movies/smart1.jpg",
      "assets/movies/smart2.jpg",
      "assets/movies/smart3.jpg",
    ],
    videoPath: "assets/movies/smart.mp4",
    pptPath: "assets/movies/pdf1.pdf",
    pdfPath: "assets/movies/pdf1.pdf",
    link: "https://github.com/Ankshika1508/Smart-Classroom-Monitoring",
    members: "3",
    year: "2",
  ),
  Movie(
    id: 2,
    name: "Automatic Railway Gate Control System",
    imageUrl: "assets/cast/t2.jpg",
    coverUrl: "assets/cast/t2.jpg",
    summary: "This project demonstrates an Automatic Railway Gate Control System built using React for the frontend and Firebase for real-time data handling. The system automates railway gate operations to enhance safety and reduce human error. It uses IoT sensors to detect train movement and automatically triggers the gate’s open/close mechanism based on live input. Firebase stores and synchronizes sensor data instantly with the web interface, ensuring quick status updates. The responsive dashboard displays train status, gate position, and alert notifications, providing an efficient, modern, and scalable railway safety management solution.",
    director: "Debajyoti Chatterjee",
    genres: ["IoT", "Web"],
    rate: 7.1,
    cast: [
      Actor(name: "Sayan Mukherjee", imageUrl: "assets/cast/tom_hanks.jpg"),
      Actor(name: "Arka Mahajan", imageUrl: "assets/cast/stephen_graham.jpg"),
    ],
    imagePaths: [
      "assets/cast/t2.jpg",
      "assets/cast/t3.jpg",
      "assets/cast/t4.jpg",
      "assets/cast/t5.jpg",
    ],
    videoPath: "assets/cast/t1.mp4",
    pptPath: "assets/cast/t6.pdf",
    pdfPath: "assets/cast/t6.pdf",
    link: "https://github.com/Supratim158/TYSON_Personal_Ai.git",
    members: "2",
    year: "3",
  ),

  Movie(
    id: 3,
    name: "TeleMedecine App",
    imageUrl: "assets/movies/1.jpg",
    coverUrl: "assets/movies/1.jpg",
    summary:
    "An AI-powered chatbot system that interacts with users using NLP and machine learning techniques.",
    director: "Sagarika Ghosh",
    genres: ["App", "ML"],
    rate: 8.5,
    cast: [
      Actor(name: "Soumik Chaudury", imageUrl: "assets/movies/4.jpg"),
    ],
    imagePaths: [
      "assets/movies/1.jpg",
      "assets/movies/2.jpg",
      "assets/movies/3.jpg",
    ],
    videoPath: "assets/movies/5.mp4",
    pptPath: "assets/movies/chatbot_presentation.pdf",
    pdfPath: "assets/movies/chatbot_report.pdf",
    link: "https://github.com/example/chatbot-ai",
    members: "1",
    year: "3",
  ),


  Movie(
    id: 4,
    name: "Self-Sovereign Identity System",
    imageUrl: "assets/movies/b1.jpg",
    coverUrl: "assets/movies/b1.jpg",
    summary:
    "The Self-Sovereign Identity System is a decentralized application (DApp) built on the Ethereum blockchain, enabling users to fully control their digital identities. Utilizing smart contracts and encryption, this platform ensures secure, private, and tamper-proof identity management without centralized authorities. Users can create, manage, and share identity data confidently through a modern React-based frontend with seamless MetaMask integration.",
    director: "Thomas Kail",
    genres: ["Blockchain", "web"],
    rate: 8.9,
    cast: [
      Actor(name: "Supratim Modak", imageUrl: "assets/movies/smart4.jpg"),
    ],
    imagePaths: [
      "assets/movies/b1.jpg",
      "assets/movies/b2.jpg",
      "assets/movies/b3.jpg",
      "assets/movies/b4.jpg",
    ],
    videoPath: "assets/movies/hamilton_demo.mp4",
    pptPath: "assets/movies/hamilton_presentation.pdf",
    pdfPath: "assets/movies/hamilton_report.pdf",
    link: "https://github.com/Supratim158/Self-Sovereign_Identity-System.git",
    members: "1",
    year: "2",
  ),
];
