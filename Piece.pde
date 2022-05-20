//cette classe est utilisée par la classe game, pour gérer l'affichage. Elle n'est pas utilisée dans le back end.

//valeurs positives : blanc;valeurs négatives : noir.
final int NOTHING=0;
final int CHEVAL=1;
final int TOUR=2;
final int FOU=3;
final int REINE=4;
final int ROI=5;
final int PION=6;


class Piece{
  
  int type;
  int x;
  int y;
  PGraphics img;
  
  Piece(){
    type=0;
  }
  
  Piece(int type,int x, int y){
    this.type=type;
    this.x=x;
    this.y=y;
    
    makeImage();
  }
  
  void display(){
    image(img,48+100*x,48+100*y); 
  }
  
  boolean isAt(int X,int Y){
    boolean res = (X>48+x*100&&X<48+(x+1)*100  &&  Y>48+y*100&&Y<48+(y+1)*100);
    return res;
  }
  
  boolean isAt_boardCoords(int x,int y){
    boolean res = (this.x==x && this.y==y);
    return res;
  }
  
  void moveTo(int x, int y){
    this.x = x;this.y = y;
  }
  
  boolean isDummy(){
    return type==0;
  }
  
  void makeImage(){
    ImageMaker maker = new ImageMaker();
    img = maker.makeImg(type);
  }
}
