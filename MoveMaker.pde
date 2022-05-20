//cette classe fait toutes les générations de coups pour chaque pièce, sans s'occupper de leur légalité.
//elle sert juste à ne pas avoir tout ce code dans une classe qui fait aussi autre chose.

class MoveMaker{
  
  int enPassant;
  boolean[] rockMoved;
  
  MoveMaker(){
    //special moves management
    enPassant=0;
    rockMoved=new boolean[6];
    rockMoved[0]=rockMoved[1]=rockMoved[2]=rockMoved[3]=rockMoved[4]=rockMoved[5]=false;
  }
  
  int[] makeMoves(int x, int y, int type){
    switch(abs(type)){
      case REINE:
        return makeQueenMoves(x,y,type);
      case TOUR:
        return makeTowerMoves(x,y,type);
      case FOU:
        return makeFouMoves(x,y,type);
      case ROI:
        return makeRoiMoves(x,y,type);
      case CHEVAL:
        return makeChevalMoves(x,y,type);
      case PION:
          return makePionMoves(x,y,type);
      default:
        print("makeMoves was called with no piece here");
        return null;
    }
  }
  //--------------------------------------------------------------TOWER-----------------------------------------------------------
  int[] makeTowerMoves(int x,int y,int type){
    ArrayList<Integer> listPossibleMoves = new ArrayList<Integer>();
    if(type!=NOTHING){
      int i=0;
      while(i<8){
          listPossibleMoves.add(x);
          listPossibleMoves.add(i);
          i++;
      }i=0;
      while(i<8){
          listPossibleMoves.add(i);
          listPossibleMoves.add(y);
          i++;
      }
    }
      int[] possibleMoves = new int[listPossibleMoves.size()+1];
      //add size at the beginning of the array
      possibleMoves[0]=listPossibleMoves.size();
      for(int i=1;i<listPossibleMoves.size()+1;i++){
        possibleMoves[i]=listPossibleMoves.get(i-1);
      }
    return possibleMoves;
    }
    
    
//--------------------------------------------------------------PION-----------------------------------------------------------
    
  int[] makePionMoves(int x,int y,int type){
    ArrayList<Integer> listPossibleMoves = new ArrayList<Integer>();
    //à remplir petit à petit
    if(type!=NOTHING){
      if(type<0){
        listPossibleMoves.add(x);
        listPossibleMoves.add(y+1);
        
        if(y==1){
          listPossibleMoves.add(x);
          listPossibleMoves.add(y+2);
        }
        
        if(x>0){
          listPossibleMoves.add(x-1);
          listPossibleMoves.add(y+1);
        }if(x<7){
          listPossibleMoves.add(x+1);
          listPossibleMoves.add(y+1);
        }
      }if(type>0){
        listPossibleMoves.add(x);
        listPossibleMoves.add(y-1);
        
        if(y==6){
          listPossibleMoves.add(x);
          listPossibleMoves.add(y-2);
        }
        
        if(x>0 && y>0){
          listPossibleMoves.add(x-1);
          listPossibleMoves.add(y-1);
        }if(x<7){
          listPossibleMoves.add(x+1);
          listPossibleMoves.add(y-1);
        }
      }
    }
    int[] possibleMoves = new int[listPossibleMoves.size()+1];
    //add size at the beginning of the array
    possibleMoves[0]=listPossibleMoves.size();
    for(int i=1;i<listPossibleMoves.size()+1;i++){
      possibleMoves[i]=listPossibleMoves.get(i-1);
    }
    return possibleMoves;
  }
    
  //--------------------------------------------------------------FOU-----------------------------------------------------------
    int[] makeFouMoves(int x,int y,int type){
    ArrayList<Integer> listPossibleMoves = new ArrayList<Integer>();
    //à remplir petit à petit
    if(type!=NOTHING){
      int min = x<y?x:y;
      int i=0;
      int j=y+x;
      while(i<8 && j>=0){
        if(j<8&&j>=0 && i<8&&i>=0){
          listPossibleMoves.add(i);
          listPossibleMoves.add(j);
        }
        i++;j--;
      }
      i=-min+x;
      j=-min+y;
      while(i<8 && j<8){
        listPossibleMoves.add(i);
        listPossibleMoves.add(j);
        i++;j++;
      }
      
    }
    int[] possibleMoves = new int[listPossibleMoves.size()+1];
    //add size at the beginning of the array
    possibleMoves[0]=listPossibleMoves.size();
    for(int i=1;i<listPossibleMoves.size()+1;i++){
      possibleMoves[i]=listPossibleMoves.get(i-1);
    }
    return possibleMoves;
  }
  
  //--------------------------------------------------------------CHEVAL-----------------------------------------------------------
  int[] makeChevalMoves(int x,int y,int type){
    ArrayList<Integer> listPossibleMoves = new ArrayList<Integer>();
    //à remplir petit à petit
    if(type!=NOTHING){
      int i=2;  int j=1;
      if(x+i>=0 && x+i<8 && y+j>=0 && y+j<8){
        listPossibleMoves.add(x+i); listPossibleMoves.add(y+j);
      }
      i=2;  j=-1;
      if(x+i>=0 && x+i<8 && y+j>=0 && y+j<8){
        listPossibleMoves.add(x+i); listPossibleMoves.add(y+j);
      }
      i=1;  j=2;
      if(x+i>=0 && x+i<8 && y+j>=0 && y+j<8){
        listPossibleMoves.add(x+i); listPossibleMoves.add(y+j);
      }
      i=-1;  j=2;
      if(x+i>=0 && x+i<8 && y+j>=0 && y+j<8){
        listPossibleMoves.add(x+i); listPossibleMoves.add(y+j);
      }
      i=-2;  j=1;
      if(x+i>=0 && x+i<8 && y+j>=0 && y+j<8){
        listPossibleMoves.add(x+i); listPossibleMoves.add(y+j);
      }
      i=-2;  j=-1;
      if(x+i>=0 && x+i<8 && y+j>=0 && y+j<8){
        listPossibleMoves.add(x+i); listPossibleMoves.add(y+j);
      }
      i=1;  j=-2;
      if(x+i>=0 && x+i<8 && y+j>=0 && y+j<8){
        listPossibleMoves.add(x+i); listPossibleMoves.add(y+j);
      }
      i=-1;  j=-2;
      if(x+i>=0 && x+i<8 && y+j>=0 && y+j<8){
        listPossibleMoves.add(x+i); listPossibleMoves.add(y+j);
      }
    }
    int[] possibleMoves = new int[listPossibleMoves.size()+1];
    //add size at the beginning of the array
    possibleMoves[0]=listPossibleMoves.size();
    for(int i=1;i<listPossibleMoves.size()+1;i++){
      possibleMoves[i]=listPossibleMoves.get(i-1);
    }
    return possibleMoves;
  }
  
  //--------------------------------------------------------------ROI-----------------------------------------------------------
  
  int[] makeRoiMoves(int x,int y,int type){
    ArrayList<Integer> listPossibleMoves = new ArrayList<Integer>();
    //à remplir petit à petit
    if(type!=NOTHING){
      int i=0;  int j=1;
      if(x+i>=0 && x+i<8 && y+j>=0 && y+j<8){
        listPossibleMoves.add(x+i); listPossibleMoves.add(y+j);
      }
      i=1;  j=0;
      if(x+i>=0 && x+i<8 && y+j>=0 && y+j<8){
        listPossibleMoves.add(x+i); listPossibleMoves.add(y+j);
      }
      i=1;  j=1;
      if(x+i>=0 && x+i<8 && y+j>=0 && y+j<8){
        listPossibleMoves.add(x+i); listPossibleMoves.add(y+j);
      }
      i=0;  j=-1;
      if(x+i>=0 && x+i<8 && y+j>=0 && y+j<8){
        listPossibleMoves.add(x+i); listPossibleMoves.add(y+j);
      }
      i=-1;  j=0;
      if(x+i>=0 && x+i<8 && y+j>=0 && y+j<8){
        listPossibleMoves.add(x+i); listPossibleMoves.add(y+j);
      }
      i=-1;  j=-1;
      if(x+i>=0 && x+i<8 && y+j>=0 && y+j<8){
        listPossibleMoves.add(x+i); listPossibleMoves.add(y+j);
      }
      i=-1;  j=1;
      if(x+i>=0 && x+i<8 && y+j>=0 && y+j<8){
        listPossibleMoves.add(x+i); listPossibleMoves.add(y+j);
      }
      i=1;  j=-1;
      if(x+i>=0 && x+i<8 && y+j>=0 && y+j<8){
        listPossibleMoves.add(x+i); listPossibleMoves.add(y+j);
      }
      
    }
    int[] possibleMoves = new int[listPossibleMoves.size()+1];
    //add size at the beginning of the array
    possibleMoves[0]=listPossibleMoves.size();
    for(int i=1;i<listPossibleMoves.size()+1;i++){
      possibleMoves[i]=listPossibleMoves.get(i-1);
    }
    return possibleMoves;
  }
  
  //--------------------------------------------------------------QUEEN-----------------------------------------------------------
  int[] makeQueenMoves(int x,int y,int type){
    ArrayList<Integer> listPossibleMoves = new ArrayList<Integer>();
    //à remplir petit à petit
    if(type!=NOTHING){
      int min = x<y?x:y;
      int i=0;
      int j=y+x;
      while(i<8 && j>=0){
        if(j<8&&j>=0 && i<8&&i>=0){
          listPossibleMoves.add(i);
          listPossibleMoves.add(j);
        }
        i++;j--;
      }
      i=-min+x;
      j=-min+y;
      while(i<8 && j<8){
        listPossibleMoves.add(i);
        listPossibleMoves.add(j);
        i++;j++;
      }
      
      i=0;
      while(i<8){
          listPossibleMoves.add(x);
          listPossibleMoves.add(i);
          i++;
      }i=0;
      while(i<8){
          listPossibleMoves.add(i);
          listPossibleMoves.add(y);
          i++;
      }
      
    }
    int[] possibleMoves = new int[listPossibleMoves.size()+1];
    //add size at the beginning of the array
    possibleMoves[0]=listPossibleMoves.size();
    for(int i=1;i<listPossibleMoves.size()+1;i++){
      possibleMoves[i]=listPossibleMoves.get(i-1);
    }
    return possibleMoves;
  }
}
