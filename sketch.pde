/*

 watchSunTraject v.18 230415-0938

 Часы с визуализацией положения Солнца 
 относительно горизонта (для северного 
 полушария).
 
 Для смены локации измените переменную 
 am (широта в градусах с десятыми долями)
 ниже, а также, задайте метку для локации.
 
 Север (солнце "максимально за горизонтом") 
 располагается снизу, это связано
 с тем, что 12 часов (полдень) на 
 циферблате часов располагается сверху.
 
 */


Sun s = new Sun(); // объект Солнце
float deg = PI/180;
String loclabel = "";
float am;

float nr = 1; // число оборотов солнца за сутки по циферблату
float kdist = 0.0; // -0.4..2 искажение траекторий (на случай, если она уж очень похожа на жопу, а Вам это по какой-то причине не нравится)


float ymax;
void setup() {
  frameRate(1);
  ymax = width*.5; // масштаб отрисовки

  // широта локации в градусах с десятыми долями (есть в википедии, нажать "H" над координатами в не-мобильной версии страницы)
  am = 55.75*deg; loclabel = "Moscow";
  // am = 59.95*deg; loclabel = "Piter";
  // am = 61.37*deg; loclabel = "Valaam";
  // am = 52.28*deg; loclabel = "Irkutsk";
  // am = 33.89*deg; loclabel = "Beirut";
  // am = 68.97*deg; loclabel = "Murmansk";
  // am = 1.35*deg; loclabel = "Singapore"; // Сингапур
  // am = 42.00*deg; loclabel = "My location";
}


void draw() {

  background(0);
  translate(width*.5, height*.5);


  // траектории солнца за год (точнее за полгода)

  noFill();


  strokeWeight(3);
  for (float ky=0; ky<0.5; ky+=6/365.) { // часть года от лет. солнцестояния 6/365 это 1 линия в 2 недели
    beginShape();
    for (float ks=-0.5; ks<0.5; ks+=0.004) { // часть суток от астр. полдня
      float x = map(ks, -0.5, 0.5, -180*nr*deg, 180*nr*deg); // угол по азимуту
      s.calc(ky, ks, am); // расчет угла солнца над горизонтом
      stroke(255, 60); // цвета вспомогательных траекторий
      float y = -map(s.ksi, -90*deg, 90*deg, -ymax*kdist, ymax*(kdist+1)); // для отрисовки
      vertex(y*cos((x+HALF_PI)), y*sin(x+HALF_PI));
    }
    endShape(CLOSE);
  }


  // текущая траектория и солнце
  float ky_now = (month()*30+day())/365.-0.5; // грубо, TODO уточнить
  // TODO ввести поправку на сетку часовых поясов (и заодно летнее-зимнее время)

  strokeWeight(6);
  beginShape();
  for (float ks=-0.5; ks<0.5; ks+=0.004) { // часть суток от астр. полудня
    float x = map(ks, -0.5, 0.5, -180*nr*deg, 180*nr*deg); // угол по азимуту
    s.calc(ky_now, ks, am); // расчет угла солнца нaд горизонтом
    stroke(255, 180); // цвет тек. траектории
    float y = -map(s.ksi, -90*deg, 90*deg, -ymax*kdist, ymax*(kdist+1)); // для отрисовки
    vertex(y*cos((x+HALF_PI)), y*sin(x+HALF_PI));
  }
  endShape(CLOSE);

  float ks_now = 0.5-(hour()*60*60+minute()*60+second()) / (24*60*60.);
  s.calc(ky_now, ks_now, am);
  float x_now = map(ks_now, -0.5, 0.5, -180*nr*deg, 180*nr*deg);
  float y_now = -map(s.ksi, -90*deg, 90*deg, -ymax*kdist, ymax*(kdist+1));
  stroke(255, 255, 0, 22); // цвет солнца
  for (int sw=41; sw<66; sw++) { // диаметр солнца с размытием края
    strokeWeight(sw);
    point(-y_now*cos(x_now+HALF_PI), y_now*sin(x_now+HALF_PI));
  }


  // горизонт (круг)
  strokeWeight(6);
  fill(0, 144); // заливка круга
  stroke(255, 0, 0);
  ellipse(0, 0, ymax, ymax);


  //// далее немного вспомогательной графики, в перспективе она будет появляться на 1 минуту в час вместе с отрисовкой компаса
  /*
  // часовая стрелка по солнцу
   // stroke(255, 0, 0);
   // line(0, 0, -y_now*cos(x_now+HALF_PI), y_now*sin(x_now+HALF_PI));
   //// здесь можно вставить по часам, не по солнцу
   // часовая стрелка по часам 
   line(0, 0, ymax*.5*-cos(map(hour(), 0, 12, 0, 360*deg)+HALF_PI), 
   ymax*.5*-sin(map(hour(), 0, 12, 0, 360*deg)+HALF_PI));
   
   // минутная стрелка
   line(0, 0, 1000*-cos(map(minute(), 0, 60, 0, 360*deg)+HALF_PI), 
   1000*-sin(map(minute(), 0, 60, 0, 360*deg)+HALF_PI));
   
   // черный кружок по центру
   noStroke();
   fill(0);
   //ellipse(0, 0, ymax*.2, ymax*.2);
   */


  // время
  pushMatrix();

  int h = hour();
  int m = minute();
  String hs = nf(h, 2);
  String ms = nf(m, 2);
  translate(0, ymax*.5);
  fill(255, 128);
  textAlign(CENTER);

  float tsh = height*.066;
  float twh = tsh*0.228;
  textSize(tsh);
  text(hs.substring(0, 1), -twh, tsh);
  text(hs.substring(1), twh, tsh);

  float tsm = tsh*.75;
  float twm = tsm*0.228;
  textSize(tsm);
  text(ms.substring(0, 1), -twm, tsm*.7*3);
  text(ms.substring(1), twm, tsm*2.5);

  popMatrix();


  // название локации
  float ts_label = tsh*.75;
  // float tw_label = tsm*0.228;
  textSize(ts_label);
  translate(0, -ymax*1.1); //
  text(loclabel, 0, 0);
}




// TODO нарисовать калибровочные
// отметки и тексты времени восхода/захода 


class Sun {

  // солнце северного полушария

  float ksi; // угол возвышения солнца над горизонтом
  //// ky доля года от летнего рав��оденствия
  //// ks доля суток от астрономического полудня
  //// am широта места (локации)
  float deg = PI/180;
  float ast = 23.4378*deg; // северный тропик 

  void calc(float ky, float ks, float am) {

    float as = atan(tan(ast) * cos(ky * 360*deg)); // широта солнца в полдень
    float a = ks*360*deg;
    PVector v1 = sphToCart(1, 0, 90*deg-as); // вектор земля-солнце
    PVector v2 = sphToCart(1, a, 90*deg-am); // вектор локация-солнце

    // искомый угол
    ksi = 90*deg-PVector.angleBetween(v1, v2); // уго�� от горизонта на солнце ☀️
  }
}


PVector sphToCart(float r, float theta, float phi) {
  // сферические  координаты в прямоугольные (они же "картезианские")
  // тета откладывантся от оси x, фи от оси z
  float x = cos(theta)*sin(phi)*r;
  float y = sin(theta)*sin(phi)*r;
  float z = cos(phi)*r;
  return new PVector(x, y, z);
}
