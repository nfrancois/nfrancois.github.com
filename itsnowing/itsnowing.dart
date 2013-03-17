import 'dart:html';
import 'dart:math';


void main() {
  CanvasElement canvas = query("#canvasSnow");
  InputElement flakesRange =  query("#flakesRange");
  ButtonElement takePhoto = query("#takePhoto");
  VideoElement video = query('#webcam');
  CanvasElement photoBuffer = query("#photoBuffer");
  
  var photoContent = query("#photoContent");
  var content = query("#content");
  var acceptVideo = query("#acceptVideo");
  
  takePhoto.onClick.listen((e) {
    var previousImage = photoContent.query("img");
    if(previousImage != null){
      previousImage.remove();
    }
    
    CanvasRenderingContext2D photoContext = photoBuffer.getContext("2d");
    photoContext.drawImage(video, 0, 0, video.width, video.height);
    photoContext.drawImage(canvas, 0, 0, canvas.width, canvas.height);
    var data = photoBuffer.toDataUrl("image/png");
    ImageElement photo = new Element.tag("img");
    photoContent.append(photo);
    photo..height = canvas.height~/2
         ..width = canvas.width~/2
         ..src = data;
  });
  var snow = new Snow(canvas.getContext("2d"), canvas.width, canvas.height, int.parse(flakesRange.value));
  flakesRange.onChange.listen((e) => snow.numberOfFlake = int.parse(flakesRange.value));
  
  window.navigator.getUserMedia(video: true).then((stream) {
    video
    ..autoplay = true
    ..src = Url.createObjectUrl(stream)
    ..onError.listen((e) => window.alert("e"))
    ..onLoadStart
    ..onLoadedMetadata.listen((e) {
      acceptVideo.classes.add("invisible");
      content.classes.remove("invisible");
      snow.start();
    });
  });

}

class Snow {
 
  int numberOfFlake;
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
      flake..draw(ctx)
           ..updatePosition();
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

