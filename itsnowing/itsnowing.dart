import 'dart:html';
import 'dart:math';


void main() {
  CanvasElement canvas = query("#canvas-snow");
  CanvasRenderingContext2D ctx = canvas.getContext("2d");
  InputElement flakesRange =  query("#flakesRange");
  var content = query("#content");
  var acceptVideo = query("#acceptVideo");
  var snow = new Snow(ctx, canvas.width, canvas.height, int.parse(flakesRange.value));
  flakesRange.onChange.listen((e) => snow.numberOfFlake = int.parse(flakesRange.value));
  var video = query('#webcam') as VideoElement;
  
  window.navigator.getUserMedia(video: true).then((stream) {
    video
    ..autoplay = true
    ..src = Url.createObjectUrl(stream)
    ..onLoadedMetadata.listen((e) {
      acceptVideo.classes.add("invisible");
      content.classes.remove("invisible");
      snow.start();
    });
  });

}

class Snow {
 
  int numberOfFlake = 50;
  final CanvasRenderingContext2D ctx;
  final int width;
  final int heigth;
  
  final List<Flake> flakes;
  Random _random;
  
  Snow(this.ctx, this.width, this.heigth, this.numberOfFlake) : flakes = [] {
    _random = new Random();
    for(int i=0; i<numberOfFlake; i++){
      _createFlake();
    }
  }
  
  _createFlake(){
    var size = _random.nextInt(5) + 2;
    var speedX = _random.nextInt(3);
    var speedY = _random.nextInt(5) + 2;
    var x = _random.nextInt(width);
    var y = _random.nextInt(heigth);      
    flakes.add(new Flake(x, y, size, speedX, speedY));
  }
  
  start() => window.requestAnimationFrame(_animate);
  
  _animate(num time){
    draw();
    window.requestAnimationFrame(_animate);    
  }
  
  draw(){
    ctx.clearRect(0, 0, width, heigth);
    for(Flake flake in flakes){
      flake.draw(ctx);
      flake.updatePosition();
    }
    // Remove unvisible flakes and recreate new
    flakes.removeMatching((Flake flake)  => flake.y > heigth || flake.y > heigth);
    for(int i=0; i<numberOfFlake-flakes.length; i++){
      _createFlake();
    }
  }
}

class Flake {
  
  final num size;
  final num speedX;
  final num speedY;
  num x;
  num y;
  
  Flake(this.x, this.y, this.size, this.speedX, this.speedY);
  
  updatePosition(){
    this.x += speedX;
    this.y += speedY;   
  }
  
  draw(CanvasRenderingContext2D ctx){
    ctx..beginPath()
      ..arc(x, y, this.size, 0, PI*2, false)
      ..fillStyle = "#FFF"
      ..fill();    
  }
  
}

