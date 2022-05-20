//cette classe sert d'interface avec le display.

class Game{
  
  ArrayList<Piece> Pieces;
  GameState state;
  int selectedX;
  int selectedY;
  int[] selectedLegalMoves;
  boolean checkmate;
  Minimax mm;
  
  Game(){
    Pieces = new ArrayList<Piece>();
    Pieces.add(new Piece(REINE,3,4));
    Pieces.add(new Piece(-REINE,3,0));
    state = new GameState();
    mm = new Minimax();
    mm.ia.setState(state.getState(), state.mc.playing);
    
    checkmate=false;
  }
  
  boolean hasPieceAt(int x, int y){
    return state.getState()[x*8+y]!=NOTHING && state.getState()[x*8+y]*state.playing>0;
  }
  
  void makeIAMove(){
    mm.ia.setState(state.getState(),state.mc.playing);
    int[] move = mm.pickMove(3);
    if(mm.ia.checkmate){
      checkmate=true;
      return;
    }
    select(move[0],move[1]);
    moveSelectedTo(move[2],move[3]);
    mm.alpha=mm.beta=0;
  }
  
  void conformToState(){
    Pieces.clear();
    int[] stateArray = state.getState();
    for(int i=0;i<8;i++){
      for(int j=0;j<8;j++){
        if(stateArray[i*8+j]!=NOTHING){
          Pieces.add(new Piece(stateArray[i*8+j],i,j));
        }
      } 
    }
    display();
  }
  
  void updateSelectedPiece(int x, int y){
    for(int i=0;i<Pieces.size();i++){
      if(Pieces.get(i).isAt_boardCoords(x, y)){
        Pieces.remove(Pieces.get(i));
      }
    }
    for(int i=0;i<Pieces.size();i++){
      if(Pieces.get(i).isAt_boardCoords(selectedX, selectedY)){
        Pieces.get(i).moveTo(x,y);
      }
    }
    g.display();
  }
  
  void displayMoves(){
    int size = selectedLegalMoves[0];
    for(int i=1;i<size/2+1;i++){
      int idx=2*i-1;
      int X=selectedLegalMoves[idx];
      int Y=selectedLegalMoves[idx+1];
      fill(100,50,200,150);
      rect(48+100*X,49+100*Y,100,100);
    }
  }
  
  void select(int x, int y){
    selectedX = x;selectedY=y;
    selectedLegalMoves = state.getLegalMoves(x, y);
    displayMoves();
  }
  
  //res contains : [move was made],[enPassant was used],[enpassant X eaten],[enpassant y eaten]
  int moveSelectedTo(int x, int y){
    int[] res = state.moveTo(selectedLegalMoves,selectedX,selectedY,x,y);
    if(state.mc.checkMate()){
      checkmate=true;
    }
    /*if(res[9]==1){
      checkmate=true;
    }*/
    //move normally
    if(res[0]!=0){
      updateSelectedPiece(x,y);
    }
    //if enpassant move was made, needs an additional deletion.
    if(res[1]!=0){
      for(int i=0;i<Pieces.size();i++){
        if(Pieces.get(i).x==res[2] && Pieces.get(i).y==res[3]){
          Pieces.remove(i);
          break;
        }
      }
    }
    //if castling move was made, needs an additional move (the tower).
    if(res[4]!=0){
      //find the tower
      for(int i=0;i<Pieces.size();i++){
        //check first column if left, right->7;
        int column=res[4]==-1?0:7;
        if(Pieces.get(i).x==column && state.playing*Pieces.get(i).type==-TOUR){
          //change its position
          Pieces.get(i).x=res[7];
          Pieces.get(i).y=res[8];
          break;
        }
      }
    }
    return res[0];
  }
  
  void emptyGame(){
    for(int i=Pieces.size()-1;i>=0;i--){
      Pieces.remove(i);
    }
  }
  
  void display(){
    for(Piece p : Pieces){
      p.display();
    }
  }
}
