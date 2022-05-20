class IA{ 
  int[] state;
  int playing;
  MoveCleaner mc;
  boolean checkmate;
  
  IA(){
    mc = new MoveCleaner();
  }
  
  void setState(int[] state, int playing){
    this.state = state;
    this.playing=playing;
    mc.setState(this.state, this.playing);
  }
  
  //here the moves are stored as 4 ints : startX,startY,endX,endY.
  int[] generateMoves(){
    //generate all possible moves for playing and state, and returns them.
    int[] allMoves = new int[1];
    allMoves[0]=0;
    for(int i=0;i<8;i++){
      for(int j=0;j<8;j++){
        if(state[i*8+j]*playing>0){
          int[] currentLegal = mc.getLegalMoves(i,j);
          //turn into start-end moves
          int[] startEndMoves = new int[2*currentLegal[0]];//no size indication as it will be concatenated
          for(int idx=0;idx<currentLegal[0];idx+=2){
            startEndMoves[idx*2]=i;
            startEndMoves[idx*2+1]=j;
            startEndMoves[idx*2+2]=currentLegal[idx+1];
            startEndMoves[idx*2+3]=currentLegal[idx+2];
          }
          //concatenate with allMoves
          allMoves[0]+=2*currentLegal[0];
          allMoves = concat(allMoves, startEndMoves);
        }
      }
    }
    return allMoves;
  }
  //calcule l'heuristique à partir de l'état courant.
  float computeHeuristic(){
    //first heuristic : one square of mobility counts for one twentieth of a pawn
    float heur1 = (float)mc.enemyRange.size()/20.;
    //second heuristic : how many pieces you have, weighted to prioritize more important ones.
    float heur2 = getMaterialValue();
    return (heur1+heur2)/2.;
  }
  
  int[] pickMove(){
    int[] allPossible = generateMoves();
    if(allPossible[0]==0){
      checkmate=true;
      return null;
    }
    float max=0;
    int argmax=0;
    for(int i=1;i<allPossible[0]+1;i+=4){
      float h = computeHeuristic();
      if(h>max){
        max=h;
        argmax=i;
      }
    }
    int[] return_array = new int[4];
    return_array[0]=allPossible[argmax];
    return_array[1]=allPossible[argmax+1];
    return_array[2]=allPossible[argmax+2];
    return_array[3]=allPossible[argmax+3];
    return return_array;
  }
  
  
  float getMaterialValue(){
    float value=0;
    for(int i=0;i<8;i++){
      for(int j=0;j<8;j++){
        if(state[i*8+j]*playing>0){
          switch(abs(state[i*8+j])){
            case PION:
              value+=1;
              break;
            case TOUR:
              value+=5;
              break;
            case FOU:
              value+=3;
              break;
            case CHEVAL:
              value+=3;
              break;
            case REINE:
              value+=9;
              break;
          }
        }
      }
    }
    return value;
  }
}
