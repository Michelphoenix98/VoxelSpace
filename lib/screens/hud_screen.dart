import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxel_space/cubit/map_load/map_load_cubit.dart';
import 'package:voxel_space/widgets/flight_controls.dart';
import 'package:voxel_space/widgets/frame.dart';

class HUDScreen extends StatefulWidget {
  const HUDScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HUDScreen> createState() => _HUDScreenState();
}

class _HUDScreenState extends State<HUDScreen> with TickerProviderStateMixin {
  late AnimationController animationControllerPd;
  late AnimationController animationControllerHorizon;
  late AnimationController animationControllerTranslationY;
  late AnimationController animationControllerTranslationX;
  late AnimationController animationControllerCameraHeight;

  double distanceValue = 600;
  @override
  void initState() {
    super.initState();
    super.initState();
    animationControllerPd = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 6.28,
      duration: const Duration(milliseconds: 5000),
    );
    animationControllerHorizon = AnimationController(
      vsync: this,
      lowerBound: -120,
      upperBound: 180,
      duration: const Duration(milliseconds: 5000),
    );
    animationControllerTranslationY = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 1024,
      duration: const Duration(milliseconds: 5000),
    );
    animationControllerTranslationX = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 1024,
      duration: const Duration(milliseconds: 5000),
    );
    animationControllerCameraHeight = AnimationController(
      vsync: this,
      lowerBound: 100,
      upperBound: 600,
      duration: const Duration(milliseconds: 5000),
    );
    animationControllerPd.value = 2.9;
    animationControllerHorizon.value = 120;
    animationControllerTranslationY.value = 500;
    animationControllerTranslationX.value = 800;
    animationControllerCameraHeight.value = 200;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    animationControllerPd.value += details.delta.dx / 400;
    if (animationControllerPd.value >= 6.28) {
      animationControllerPd.value %= 6.28;
    } else if (animationControllerPd.value <= 0) {
      animationControllerPd.value = 6.28;
    }

    animationControllerHorizon.value -= details.delta.dy;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onPanUpdate: _onPanUpdate,
          child: Frame(
            distance: distanceValue,
            animationControllerCameraHeight: animationControllerCameraHeight,
            animationControllerTranslationY: animationControllerTranslationY,
            animationControllerAngle: animationControllerPd,
            animationControllerHorizon: animationControllerHorizon,
            animationControllerTranslationX: animationControllerTranslationX,
          ),
        ),
        Positioned(
          top: 10,
          left: 20,
          child: Row(
            children: [
              const Text(
                'Distance',
                style: TextStyle(color: Colors.white),
              ),
              Slider(
                  activeColor: Colors.white,
                  inactiveColor: Colors.blue,
                  max: 800,
                  min: 100,
                  value: distanceValue,
                  onChanged: (value) {
                    setState(() {
                      distanceValue = value;
                    });
                  }),
            ],
          ),
        ),
        Positioned(
          bottom: 100,
          left: 20,
          child: ForwardControlWidget(
            animationControllerAngle: animationControllerPd,
            animationControllerTranslationX: animationControllerTranslationX,
            animationControllerTranslationY: animationControllerTranslationY,
          ),
        ),
        Positioned(
          bottom: 50,
          left: 20,
          child: BackwardControlWidget(
            animationControllerAngle: animationControllerPd,
            animationControllerTranslationX: animationControllerTranslationX,
            animationControllerTranslationY: animationControllerTranslationY,
          ),
        ),
        Positioned(
          bottom: 100,
          right: 20,
          child: AltitudeIncreaseWidget(
            animationControllerCameraHeight: animationControllerCameraHeight,
          ),
        ),
        Positioned(
          bottom: 50,
          right: 20,
          child: AltitudeDecreaseWidget(
            animationControllerCameraHeight: animationControllerCameraHeight,
          ),
        ),
      ],
    );
  }
}

class Frame extends StatelessWidget {
  const Frame(
      {Key? key,
      required this.animationControllerAngle,
      required this.animationControllerHorizon,
      required this.animationControllerTranslationY,
      required this.animationControllerTranslationX,
      required this.animationControllerCameraHeight,
      required this.distance})
      : super(key: key);

  final AnimationController animationControllerAngle;
  final AnimationController animationControllerHorizon;
  final AnimationController animationControllerTranslationY;
  final AnimationController animationControllerTranslationX;
  final AnimationController animationControllerCameraHeight;
  final double distance;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapLoadCubit, MapLoadState>(builder: (context, state) {
      if (state is MapLoadedState) {
        return AnimatedBuilder(
          animation: Listenable.merge([
            animationControllerAngle,
            animationControllerHorizon,
            animationControllerTranslationY,
            animationControllerTranslationX,
            animationControllerCameraHeight
          ]),
          builder: (context, child) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: FittedBox(
                fit: BoxFit.cover,
                child: CustomPaint(
                  key: GlobalKey(),
                  painter: RenderFrame(
                    mapLoadCubit: BlocProvider.of<MapLoadCubit>(context),
                    viewAngle: animationControllerAngle.value,
                    point: Offset(animationControllerTranslationX.value,
                        animationControllerTranslationY.value),
                    // viewAngle: pd,
                    cameraHeight: animationControllerCameraHeight.value,
                    horizon: animationControllerHorizon.value,
                    scaleFactor: 180,
                    widthFactor: 3,
                    distance: distance,
                  ),
                  size: const Size(300, 200),
                ),
              ),
            );
          },
        );
      }
      return const Center(child: CircularProgressIndicator());
    });
  }
}
