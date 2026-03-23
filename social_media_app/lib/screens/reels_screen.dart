import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 15 Random Web-Friendly Video URLs
    final List<Map<String, String>> reelData = [
      {'video': 'https://www.w3schools.com/html/mov_bbb.mp4', 'user': '@nature_01', 'caption': 'Big Buck Bunny Adventure! 🐰'},
      {'video': 'https://www.w3schools.com/html/movie.mp4', 'user': '@wildlife', 'caption': 'Bear sighting in the woods 🐻'},
      {'video': 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 'user': '@dreamer', 'caption': 'Surreal mechanical dreams ⚙️'},
      {'video': 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4', 'user': '@fire_tech', 'caption': 'The power of digital fire 🔥'},
      {'video': 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.dart.mp4', 'user': '@escape', 'caption': 'Running into the sunset 🌅'},
      {'video': 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4', 'user': '@fun_times', 'caption': 'Just having some fun! 🎈'},
      {'video': 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4', 'user': '@joyride', 'caption': 'The ultimate road trip 🚗'},
      {'video': 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4', 'user': '@chef_pro', 'caption': 'Kitchen meltdowns are real 🍳'},
      {'video': 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4', 'user': '@sintel_fan', 'caption': 'Finding the baby dragon 🐉'},
      {'video': 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackAds.mp4', 'user': '@car_vibe', 'caption': 'Off-roading excellence 🏔️'},
      {'video': 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4', 'user': '@sci_fi', 'caption': 'Robots in the city 🤖'},
      {'video': 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4', 'user': '@auto_review', 'caption': 'Speed and style 🏎️'},
      {'video': 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4', 'user': '@crypto_king', 'caption': 'Heading to the moon! 🚀'},
      {'video': 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4', 'user': '@budget_car', 'caption': 'Shopping for cheap cars 💸'},
      {'video': 'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNHJueW90Z3BqZTVyeWp3eXQ5eHptbmR6Z3R6Z3R6Z3R6Z3R6Z3R6Z3ImZXA9djFfdmlkZW9zX3NlYXJjaCZjdD12/3o7TKMGpx4S8A5P8Lm/giphy.mp4', 'user': '@city_lights', 'caption': 'Neon nights 🌃'},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        // Remove itemCount to allow infinite scrolling logic
        itemBuilder: (context, index) {
          // Use modulo to cycle through the 15 videos infinitely
          final actualIndex = index % reelData.length;
          final data = reelData[actualIndex];

          return WebVideoItem(
            // We append the index to the key to force a fresh video element for every scroll
            key: ValueKey('video-$index'),
            videoUrl: data['video']!,
            username: data['user']!,
            caption: data['caption']!,
          );
        },
      ),
    );
  }
}

class WebVideoItem extends StatefulWidget {
  final String videoUrl;
  final String username;
  final String caption;

  const WebVideoItem({
    super.key,
    required this.videoUrl,
    required this.username,
    required this.caption,
  });

  @override
  State<WebVideoItem> createState() => _WebVideoItemState();
}

class _WebVideoItemState extends State<WebVideoItem> {
  late String viewId;

  @override
  void initState() {
    super.initState();
    // Unique ID for the platform view
    viewId = 'video-view-${widget.hashCode}';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final videoElement = web.document.createElement('video') as web.HTMLVideoElement;

      videoElement
        ..src = widget.videoUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..autoplay = true
        ..controls = false
        ..loop = true
        ..muted = true;

      return videoElement;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HtmlElementView(viewType: viewId),

        // Darkened bottom for text readability
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.username,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                widget.caption,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}