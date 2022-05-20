class ImageMaker{
  
  ImageMaker(){}
  
  PGraphics makeImg(int type){
    String path = getPathForType(type);
    PImage queenImg = loadImage(path);
    PGraphics img = createGraphics(100,100);
    img.beginDraw();
    img.image(queenImg,0,0,100,100);
    img.loadPixels();
    for(int i=0;i<100;i++){
      for(int j=0;j<100;j++){
        if(red(img.pixels[i*100+j])>50){
          img.pixels[i*100+j]=color(0,0,0,0);
        }else{
          img.pixels[i*100+j]=type>0?color(255,255,255,255):color(0,0,0,255);
        }
      }
    }
    img.updatePixels();
    img.endDraw();
    return img;
  }
  
  String getPathForType(int type){
    if(abs(type)==REINE)return "texture/pieces/queen.png";
    else if(abs(type)==TOUR)return "texture/pieces/tower.png";
    else if(abs(type)==FOU)return "texture/pieces/fou.png";
    else if(abs(type)==ROI)return "texture/pieces/roi.png";
    else if(abs(type)==CHEVAL)return "texture/pieces/cheval.png";
    else if(abs(type)==PION)return "texture/pieces/pion.png";
    else if(abs(type)==1000)return "texture/checkmate.jpg";
    
    else return null;
  }
}
