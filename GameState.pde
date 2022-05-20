//cette classe gère la représentation de la partie et sa modification.
//elle se sert des classes moveMaker et moveCleaner pour générer les possibilités de coups à faire
//elle se sert finalement de la classe stateManager pour transformer les coups en états, et pour obtenir des informations sur ces états.
//par exemple, savoir si le roi est modifié demande d'obtenir la portée d'attaque du côté adverse, et la position du roi, 
//ce qui n'est pas forcément contenu dans les coordonnées et le type de la pièce qui bouge. (d'où l'utilité de stateManager.)

class GameState{
  //one integer for each position 
  int[] state;
  MoveCleaner mc;
  int playing;
  
  //for management of special moves//white king, white tour, black king, black tour.
  
  GameState(){
    initState();
    mc = new MoveCleaner();
    mc.setState(state,1);
    playing=1;
    
  }
  
  void initState(){
    state = new int[8*8];
    for(int i=0;i<8;i++){
      state[i*8+1]=-PION;
    }
    for(int i=0;i<8;i++){
      state[i*8+6]=PION;
    }
    state[7*8+0]=state[0*8+0]=-TOUR;
    state[7*8+7]=state[0*8+7]=TOUR;
    state[6*8+0]=state[1*8+0]=-CHEVAL;
    state[6*8+7]=state[1*8+7]=CHEVAL;
    state[5*8+0]=state[2*8+0]=-FOU;
    state[5*8+7]=state[2*8+7]=FOU;
    
    state[3*8+0]=-REINE;
    state[3*8+7]=REINE;
    state[4*8+0]=-ROI;
    state[4*8+7]=ROI;
    
  }
  
  void conformToGame(){}
  
  
  int[] getLegalMoves(int x, int y){
    return mc.getLegalMoves(x,y);
  }
  
  //return value contains : [move was made],[enPassant was used],[enpassant X eaten],[enpassant y eaten],[side of castling (-1,0,1)(left,none,right)],[tower move X],[tower move Y],[CHECKMATE]
  int[] moveTo(int[] legalMoves, int selectedX,int selectedY,int x,int y){
    int[] res = new int[10];
    //assume no checkmate
    res[9]=0;
    
    int size=legalMoves[0];
    for(int i=1;i<size/2+1;i++){
      int idx=2*i-1;
      int X=legalMoves[idx];
      int Y=legalMoves[idx+1];
      if(X==x&&Y==y){
        res[0]=1;
        //make the move
        state[x*8+y]=state[selectedX*8+selectedY];
        state[selectedX*8+selectedY]=NOTHING;
        //update state
        playing*=-1;
        mc.setState(state,playing);
        
        //since a move was actually made, set enpassant to 0 (meaning, not possible)
        mc.mm.enPassant=0;
        
        //set values to return if a move was made 
        res = manage_special_moves(res, selectedX,selectedY,x,y);
        //if a move was made there is possiblility of a check.
        if(mc.checkMate()){
          res[9]=1;
        }
        return res;
      }
    }
    //set values to return if no move was made
    res[0]=res[1]=res[2]=res[3]=res[4]=res[5]=res[6]=res[7]=res[8]=0;
    return res;
  }
  
  int[] manage_special_moves(int[] res, int selectedX,int selectedY,int x,int y){
    //if the move we just made was enpassant, set to 0 and delete the eaten pawn
    if(x==abs(mc.mm.enPassant)%8 && (-playing*y==-5 || -playing*y==2) && abs(state[x*8+y])==PION){
      print("detected enPassant , playing= ",playing,"\n");
      //en passant move is made
      res[1]=1;
      //make the move
      int deleteDiff=-playing;
      state[x*8+y+deleteDiff]=NOTHING;
      mc.setState(state,playing);
      //return where you ate something
      res[2]=x;  res[3]=y+deleteDiff;
    }
    
    //if next turn could be enpassant, set enPassant to correct information.
    if(mc.enPassantCondition(selectedX, selectedY, x, y)){
      mc.mm.enPassant = playing*x;
      //if it's0, we set it to 8 so there is sign information and a modulo is enough to bring it back to 0 without perturbing the rest.
      if(mc.mm.enPassant==0){ 
        mc.mm.enPassant = playing*8;
      }
    }
    
    //if a king or a tower moved, give this information to the moveMaker (although it is the moveCleaner that uses it..)
    if(abs(state[x*8+y])==ROI){
      if(-playing==1){
        mc.mm.rockMoved[0]=true;
      }else mc.mm.rockMoved[3]=true;
    }
    if(abs(state[x*8+y])==TOUR){
      if(-playing==1){
        if(selectedX==0){
          mc.mm.rockMoved[1]=true;
        }if(x==7){
          mc.mm.rockMoved[2]=true;
        }
      }else{
        if(x==0){
          mc.mm.rockMoved[4]=true;
        }if(x==7){
          mc.mm.rockMoved[5]=true;
        }
      }
    }
    //if a king or a tower was eaten, give this information to the moveMaker (although it is the moveCleaner that uses it..)
    if((x==0&&y==0)){
      mc.mm.rockMoved[4]=true;
    }if((x==7&&y==0)){
      mc.mm.rockMoved[5]=true;
    }if((x==0&&y==7)){
      mc.mm.rockMoved[2]=true;
    }if((x==7&&y==7)){
      mc.mm.rockMoved[1]=true;
    }
    
    //if move made was castling, make the additional move of tower accordingly
    if( (x==2 || x==6) && (selectedX==4) && abs(state[x*8+y])==ROI){
      res[4]=x==2?-1:1;
      if(y==0){//if black king
        if(x==2){//if left castle
          state[3*8+0]=-TOUR;
          res[7]=3;res[8]=0;
          state[0*8+0]=NOTHING;
        }if(x==6){//if right castle
          state[5*8+0]=-TOUR;
          res[7]=5;res[8]=0;
          state[7*8+0]=NOTHING;
        }
      }else if(y==7){//if white king
        if(x==2){//if left castle
          state[3*8+7]=TOUR;
          res[7]=3;res[8]=7;
          state[0*8+7]=NOTHING;
        }if(x==6){//if right castle
          state[5*8+7]=TOUR;
          res[7]=5;res[8]=7;
          state[7*8+7]=TOUR;
        }
      }else print("castling was allowed with king not on first or last line...\n");
    }
    
    return res;
  }
  
  int[] getState(){
    return this.state;
  }
}
