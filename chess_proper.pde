PGraphics whiteQueen;
PGraphics blackQueen;
boolean isChoosing=false;
PImage img;

Game g;
void setup() {
  g = new Game();
  //setup background
  size(900,900,P2D);
  background(10,25,50);
  img = loadImage("texture/chess_board.png");
  
  textureMode(NORMAL); 
  beginShape();
  texture(img);
  vertex(50,50,1,0);
  vertex(850,50,1,1);
  vertex(850,850,0,1);
  vertex(50,850,0,0);
  endShape();
  fill(175,100,0,190);
  rect(50,50,800,800);
  noStroke();
  
  g.conformToState();
}


void draw() {
}

void mouseClicked(){
  if(g.checkmate!=true && mouseX>48&&mouseY>49 && mouseX<width-50&&mouseY<height-50){
    int y=(mouseY-49)/100;
    int x=(mouseX-48)/100;
    if(!isChoosing){
      if(g.hasPieceAt(x,y)){
        g.select(x,y);
        isChoosing=true;
      }
    } else {
      
      if(g.moveSelectedTo(x,y)!=0){
        g.makeIAMove();
      }
      
      background(20,25,50);
      textureMode(NORMAL); 
      beginShape();
      texture(img);
      vertex(50,50,1,0);
      vertex(850,50,1,1);
      vertex(850,850,0,1);
      vertex(50,850,0,0);
      endShape();
      fill(175,100,0,190);
      rect(50,50,800,800);
      g.display();
      noStroke();
      isChoosing=false;
    }
  }
  
  
  if(g.checkmate){
    ImageMaker imgmk = new ImageMaker();
    PGraphics txt = imgmk.makeImg(1000);
    image(txt,400,400);
  }
}
