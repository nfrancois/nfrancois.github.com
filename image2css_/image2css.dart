import "dart:html";

main(){
  var imageInput = query("#imageInput");
  var imageCss = query("#cssImage");
  var pixelSizeInput = query("#pixelSizeInput");
  new Converter(imageInput, pixelSizeInput, imageCss);
  
}

class Converter {
  
  final FileReader reader = new FileReader();
  final FileUploadInputElement imageInput;
  final InputElement pixelSizeInput;
  final Element imageCss;
  int _pixelSize;
  
  Converter(this.imageInput, this.pixelSizeInput, this.imageCss){
    _pixelSize = int.parse(pixelSizeInput.value);
    _bind();
  }
  
  _bind(){
    imageInput.onChange.listen((e) => _loadFile());
    pixelSizeInput.onChange.listen((e) {
      _pixelSize = int.parse(pixelSizeInput.value);
      _loadFile();
    });
  }
  
  _loadFile(){
    var imageFile = imageInput.files[0];
    reader.onLoad.listen((e) => _readFile(reader.result));
    reader.readAsArrayBuffer(imageFile);    
  }
  
  _readFile(ArrayBuffer buffer){
    var array = new Uint8Array.fromBuffer(buffer);
    var signature = _readSignature(array);
    try {
      var imageReader = ImageReader.fromSignature(signature);
      var content = imageReader.read(array, _pixelSize);
      _write(content);
    } on UnsupportedImageFormatException catch(uife){
      _unsupportedImageType();
    }
  }
  
  _readSignature(Uint8Array array){
    var imageHeader = array.getRange(0, 2);
    var signature = 0;
    for(int i=0; i<imageHeader.length; i++){
      signature = (signature << 8) + (imageHeader[i] & 255);
    }
    return signature;
  }

  _write(String boxShadowContent){
    imageCss.style.boxShadow = boxShadowContent;
  }
  
  _unsupportedImageType(){
    // TODO pretty error message with bootstrap
    window.alert("Unsupported image type");
  }
  
}

/// A Image reader decode image 
abstract class ImageReader{
  
  static int BMP_HEADER = 0x424D;
  
  String read(Uint8Array array, int pixelSize);
  
  static ImageReader fromSignature(int signature){
    if(signature == BMP_HEADER){
      return new BMPReader();
    }
    throw new UnsupportedImageFormatException();
  }
}

/// Cannot read this image
class UnsupportedImageFormatException implements Exception {
  const UnsupportedImageFormatException();
}


/// Image reader for BMP files
class BMPReader extends ImageReader {
  
  int _pixelSize;
  
  String read(Uint8Array array, int pixelSize){
    _pixelSize = pixelSize;
    var width = _readInt(array.getRange(18, 4));
    var height = _readInt(array.getRange(22, 4));
    var current = 54;
    var pixelCount = 0;
    var pixelNbr = height * width;
    var outBuffer = new StringBuffer();
    for(int y = height - 1; y >= 0; y--){
      for(int x = 0; x < width; x++){
        var color = _readColor(array.getRange(current, 3));
        current+=3;
        pixelCount++;
        outBuffer.write("${x*_pixelSize}px ${y*_pixelSize}px ${_pixelSize}px ${_pixelSize}px $color");
        if(pixelCount != pixelNbr) {
          outBuffer.write(",");
        }
      }
    }
    return outBuffer.toString();    
  }
 
  int _readInt(List<int> bytes){
    var result = 0;
    for(int i=0; i<bytes.length; i++){
      result += ((bytes[i] & 255) << 8*i);
    }
    return result;
  }   
  
  String _readColor(List<int> b){
    var red = _toHex(b[2]);
    var green = _toHex(b[1]);
    var blue = _toHex(b[0]);
    return "#$red$green$blue";
  }

  String _toHex(int val){
    var result = val.toRadixString(16);
    if(result.length == 1){
      result = "0$result";
    }
    return result;
  }  
  
}

