#import("lib/konami_code.dart");
#import('dart:html');

void main() {
  var konami = new KonamiCode();
  konami.onPerformed = onSuccess;
}

onSuccess() {
  success.classes.add("b");
}

Element get success => query("#success");


