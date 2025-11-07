import 'package:flutter/material.dart';
import 'package:project_showcase/animations/opacity_scale_animation.dart';
import 'package:project_showcase/animations/width_animation.dart';
import 'package:project_showcase/components/back_container.dart';
import 'package:project_showcase/components/movies/mvie_header.dart';
import 'package:project_showcase/pages/componets/header.dart';
import 'package:project_showcase/pages/detail/componets/cast.dart';
import 'package:project_showcase/pages/detail/componets/header_card.dart';
import 'package:project_showcase/pages/detail/componets/summary.dart';
import 'package:provider/provider.dart';
import '../../config/size_config.dart';
import '../../models/movie.dart';
import '../../notifiers/animation_notifier.dart';
import '../project_submit/project_submit_page.dart';

class DetailPage extends StatefulWidget {
  final Movie movie;

  const DetailPage({super.key, required this.movie});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _willPop(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              HeaderCard(indexMovie: movies.indexOf(widget.movie)),
              Header(),
              Container(
                height: SizeConfig.screenHeight * 0.7,
                child: WidthAnimation(
                  begin: SizeConfig.screenWidth * 0.7,
                  end: SizeConfig.screenWidth,
                  child: BackContainer(
                    child: Container(),
                  ),
                ),
              ),
              Container(
                height: SizeConfig.screenHeight * 0.7,
                width: SizeConfig.screenWidth - SizeConfig.defaultHeight * 2,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.defaultWidth,
                      vertical: SizeConfig.defaultHeight * 2),
                  physics: BouncingScrollPhysics(),
                  child: OpacityScaleAnimation(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MovieHeader(movie: widget.movie),
                        SizedBox(height: SizeConfig.defaultHeight),
                        Center(
                          child: Text(
                            "Mentor / ${widget.movie.director}",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.black87),
                          ),
                        ),
                        SizedBox(height: SizeConfig.defaultHeight * 4),
                        Cast(
                          cast: widget.movie.cast!,
                        ),
                        SizedBox(height: SizeConfig.defaultHeight * 4),
                        Summary(
                          summary: widget.movie.summary,
                          videoPath: widget.movie.videoPath,
                          pptPath: widget.movie.pptPath,
                          pdfPath: widget.movie.pdfPath,
                          imagePaths: widget.movie.imagePaths,
                          link: widget.movie.link,
                          mmbrs: widget.movie.members,
                          year: widget.movie.year,
                        ),
                        SizedBox(height: SizeConfig.defaultHeight * 8),
                      ],
                    ),
                  ),
                ),
              ),

              // Submit Project Button
              Positioned(
                bottom: SizeConfig.defaultHeight,
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectSubmitPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Submit Project",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              // Back Button (Top Left)
              Positioned(
                top: SizeConfig.defaultHeight * 1.5,
                left: SizeConfig.defaultWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () {
                      _willPop(); // Trigger animation and pop
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _willPop(){
    Provider.of<AnimationNotifier>(context, listen: false).playDetailToHomeAnimations();
    return Future.delayed(Duration(milliseconds: 200),() => true);
  }
}
