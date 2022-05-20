class MoveCleaner{
  
  ArrayList<Integer> enemyRange;
  int[] state;
  MoveMaker mm;
  int playing;
  
  MoveCleaner(){
    mm = new MoveMaker();
    enemyRange = new ArrayList<Integer>();
  }
  
  void setState(int[] state, int playing){
    this.state = state;
    updateEnemyRange();
    this.playing=playing;
  }
  
  int[] getLegalMoves(int x, int y){
    return addSpecialMoves(x,y,noCheck(x,y,cutPaths(x, y, firstPass(x,y,getPossibleMoves(x, y)))));
  }
  
  //-------------------------------------------------------------------------
  
  int[] getPossibleMoves(int x,int y){
    //récupérer le type à cette position, faire selon
    if(state[x*8+y]!=NOTHING && state[x*8+y]*playing>0){
      return mm.makeMoves(x,y,state[x*8+y]);
    }
    else{
      int[] ret =new int[1];
      ret[0]=0;
      return ret;
    }
  }
  
  //-------------basically clean pawn moves-------------------------------------------
  
  //x and y are the position of the piece to be moved
  int[] firstPass(int x, int y, int[] possible){
    ArrayList<Integer> listLegalMoves = new ArrayList<Integer>();
    int size = possible[0];
    for(int i=1;i<size/2+1;i++){
      int idx=2*i-1;
      int X=possible[idx];
      int Y=possible[idx+1];
      //don't move to self
      if(X!=x || Y!=y){
        //if anything but a pawn is selected, you can go ahead and add
        if(!(abs(state[x*8+y])==PION)){
          listLegalMoves.add(X);
          listLegalMoves.add(Y);
        }else{
          //otherwise, diagonal only if enemy piece's there
          if(X!=x && state[X*8+Y]*state[x*8+y]<0){
            listLegalMoves.add(X);
            listLegalMoves.add(Y);
          //or forward (the case of there being something in the way is taken care of in cutPaths
          }else if (X==x){
            listLegalMoves.add(X);
            listLegalMoves.add(Y);
          }
        }
      }
    }
    
    int[] legalMoves = new int[listLegalMoves.size()+1];
    //add size at the beginning of the array
    legalMoves[0]=listLegalMoves.size();
    for(int i=1;i<listLegalMoves.size()+1;i++){
      legalMoves[i]=listLegalMoves.get(i-1);
    }
    return legalMoves;
  }
  
  
  //-------------------------------------------cutPaths------------------------------------
  /*
  *cut paths
  *make sure not to eat forward with pawns
  *make sure not to move on friendly pieces.
  */
  int[] cutPaths(int x,int y, int[] legalMoves){
    ArrayList<Integer> listLegalMoves = new ArrayList<Integer>();
    ArrayList<Integer> toBeRemoved = new ArrayList<Integer>();
    //fill listLegalMoves while adding into toBeRemoved any moves detected as illegal
    int size = legalMoves[0];
    for(int i=1;i<size/2+1;i++){
      int idx=2*i-1;
      int X=legalMoves[idx];
      int Y=legalMoves[idx+1];
      //should not be able to move on friendly pieces
      if(state[X*8+Y]*state[x*8+y]>0){
        toBeRemoved.add(X);toBeRemoved.add(Y);
      }
      //PAWNS cannot move forward to eat anything
      if(X==x && abs(state[x*8+y])==PION && state[X*8+Y]!=NOTHING){
        toBeRemoved.add(X);toBeRemoved.add(Y);
      }
      if(state[X*8+Y]!=NOTHING){
        //get direction of intercepted line
        int a=X>x?1:X<x?-1:0;
        int b=Y>y?1:Y<y?-1:0;
        //initialize
        int removedX = X+a;
        int removedY = Y+b;
        while(removedY<8 && removedY>=0 && removedX<8 && removedX>=0){
          toBeRemoved.add(removedX);
          toBeRemoved.add(removedY);
          removedX+=a;
          removedY+=b;
        }
      }
      listLegalMoves.add(X);
      listLegalMoves.add(Y);
    }
    
    
    //any move in toBeRemoved is removed from 
    for(int i=listLegalMoves.size()-1;i>=0;i-=2){
      int X = listLegalMoves.get(i-1);
      int Y = listLegalMoves.get(i);
      
      //cutting paths
      int start = toBeRemoved.size();
      for(int j=start-1;j>=0;j-=2){
        if(toBeRemoved.get(j)==Y && toBeRemoved.get(j-1)==X){
          listLegalMoves.remove(i);
          listLegalMoves.remove(i-1);
          break;
        }
      }
    }
    
    int[] newLegalMoves = new int[listLegalMoves.size()+1];
    //add size at the beginning of the array
    newLegalMoves[0]=listLegalMoves.size();
    for(int i=1;i<listLegalMoves.size()+1;i++){
      newLegalMoves[i]=listLegalMoves.get(i-1);
    }
    
    return newLegalMoves;
  }
  
  //-------------------------------------------nocheck------------------------
  int[] noCheck(int x, int y, int[] legalMoves){    
    //make arrayList that can be modified
    ArrayList<Integer> newLegalMoves = new ArrayList<Integer>();
    for(int i=1;i<legalMoves[0]+1;i++){
      newLegalMoves.add(legalMoves[i]);
    }
    //loop over legalMoves
    for (int idx=0;idx<newLegalMoves.size();idx+=2){
      int X = newLegalMoves.get(idx);
      int Y = newLegalMoves.get(idx+1);
      
      //store overwritten value (most likely NOTHING unless you ate something)
      int stored_value = state[X*8+Y];
      //simulate state (apply move to state)
      state[X*8+Y] = state[x*8+y];
      state[x*8+y]=0;
      //simulating enemy moves
      playing*=-1;
      //special moves are irrelevant as they don't allow immediate eating
      int enPassant=mm.enPassant;
      mm.enPassant=0;
      //
      
      updateEnemyRange();
      
      //find king coords
      int kingX=-1;int kingY=-1;
      for(int i=0;i<8;i++){
        for(int j=0;j<8;j++){
          if(state[i*8+j]*playing<0 && abs(state[i*8+j])==ROI){
            kingX=i;kingY=j;
          }
        }
      }
      //loop over new enemy range, if you find king, remove present legalMove 
      for(int i=0;i<enemyRange.size();i+=2){
        int enemyX=enemyRange.get(i);
        int enemyY=enemyRange.get(i+1);
        if(enemyX==kingX && enemyY==kingY){
          if(newLegalMoves.size()>=0){
            newLegalMoves.remove(idx);
            newLegalMoves.remove(idx);
            //everything has moved 2 steps forward so go two steps back
            idx-=2;
            break;
          }
          else{print("there are no moves left to remove -- check ?");}
        }
      }
      //restore state to before simulation
      state[x*8+y]=state[X*8+Y];
      state[X*8+Y]=stored_value;
      //restore to current enemy range
      updateEnemyRange();
      //finally give hand back to player
      playing*=-1;
      //
      mm.enPassant=enPassant;
    }
    
    
    //printEnemyRange();
      
      
    //fill the return array
    int[] return_array = new int[newLegalMoves.size()+1];
    return_array[0]=newLegalMoves.size();
    for(int i=0;i<return_array[0];i++){
      return_array[i+1]=newLegalMoves.get(i);
    }
    return return_array;
  }
  
  //----------------------------------------------------------------------specialMoves--------------------------------------
  
  int[] addSpecialMoves(int x, int y, int[] return_array){
    return_array = return_with_enpassant(x, y, return_array);
    return_array = return_with_castling(x, y, return_array);
    return return_array;
  }
  
  
  //-------------------------------------------UpdateEnemyRange------------------------
  //calculate enemy range based on current attribute state
  void updateEnemyRange(){
    
    //calculate enemy range from previous state
    enemyRange.clear();
    //loop over enemy pieces
    for(int i=0;i<8;i++){
      for(int j=0;j<8;j++){
        if(state[i*8+j]*playing>0){
          //get all attacking moves of current enemy piece
          int[] pieceMoves = attacking_moves(i,j);
          //append each of these to enemyRange
          for(int idx=1;idx<pieceMoves[0]+1;idx+=2){
            enemyRange.add(pieceMoves[idx]);
            enemyRange.add(pieceMoves[idx+1]);
          }
        }
      }
    }
  }
  
  //------------------------------------------Get_attacking_moves-----------
  
  //we can do this straight from the attribute state because we change it for every simulated move
  int[] attacking_moves(int x, int y){
    int[] possible = getPossibleMoves(x,y);
    
    //remove moves to self and force pawns to only and always be able to attack diagonally.
    ArrayList<Integer> listLegalMoves = new ArrayList<Integer>();
    int size = possible[0];
    for(int i=1;i<size/2+1;i++){
      int idx=2*i-1;
      int X=possible[idx];
      int Y=possible[idx+1];
      //don't move to self
      if(X!=x || Y!=y){
        //if anything but a pawn is selected, you can go ahead and add
        if(!(abs(state[x*8+y])==PION)){
          listLegalMoves.add(X);
          listLegalMoves.add(Y);
        }else{
          //otherwise, diagonal only and always
          if(X!=x){
            listLegalMoves.add(X);
            listLegalMoves.add(Y);
          }
        }
      }
    }
    
    int[] legalMoves = new int[listLegalMoves.size()+1];
    //add size at the beginning of the array
    legalMoves[0]=listLegalMoves.size();
    for(int i=1;i<listLegalMoves.size()+1;i++){
      legalMoves[i]=listLegalMoves.get(i-1);
    }
    return cutPaths(x,y,legalMoves);
  }
  
  
  //-------------------------------------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------------------------------------
  
  
  
  //-------------------------------------------------------------------------enpassant_condition----------------------------------------
  //not really cleaning, but convenient to use it here
  //condition to check whether enPassnat move is possible at next step
  boolean enPassantCondition(int x, int y, int X, int Y){
    //check to the left
    if(X>0){
      if(state[(X-1)*8+Y]==playing*PION){
        if(y==1 && Y==3 || y==6 && Y==4){
          return true;
        }
      }
    }
    //check to the right
    if(X<7){
      if(state[(X+1)*8+Y]==playing*PION){
        if(y==1 && Y==3 || y==6 && Y==4){
          return true;
        }
      }
    }
    return false;
  }
  
  
  //-------------------------------------------------------------------------return_with_enpassant----------------------------------------
  //function to add the enpassant move if enpassant is not zero. otherwise it 
  int[] return_with_enpassant(int x, int y, int[] legalMoves){
    
    int enPassant = mm.enPassant;
    if(enPassant!=0 && abs(abs(enPassant)%8-x)==1){
      //add en passant move to possible moves
      legalMoves[0]+=2;
      int[] enP_move = new int[2];
      enP_move[0]= abs(enPassant)%8;
      enP_move[1]= enPassant>0?y-1:y+1;
      
      legalMoves = concat(legalMoves, enP_move);
      return legalMoves;
    }else
      return legalMoves;
  }
  
  
  //------------------------------------------------------------------------------------------------------------------------------------------------------
  
  //-------------------------------------------------------------------------castling_condition----------------------------------------
  //not really cleaning, but convenient to use it here
  //condition to know if castling is available on the (leftOrRight), for playing player.
  //leftOrRight : left ->0, right ->1.
  boolean castling_condition(int leftOrRight){
    //if left
    if(leftOrRight==0){
      //check bottom line if white is playing, black->top
      int line = playing==1?7:0;
      if(state[1*8+line]==NOTHING && state[2*8+line]==NOTHING && state[3*8+line]==NOTHING){
        //check for castling rights first as enemyRange is the most expensive
        //check black piece rights if black playing, white if white
        if(playing==-1? (!mm.rockMoved[3] && !mm.rockMoved[4])
                       :(!mm.rockMoved[0] && !mm.rockMoved[1])){
          //finally, check for enemyRange
          return castling_enemyRange(leftOrRight);
        }
      }
    }
    //if right
    if(leftOrRight==1){
      //check bottom line if white is playing, black->top
      int line = playing==1?7:0;
      if(state[5*8+line]==NOTHING && state[6*8+line]==NOTHING){
        //check for castling rights first as enemyRange is the most expensive
        //check black piece rights if black playing, white if white
        if(playing==-1? (!mm.rockMoved[3] && !mm.rockMoved[5])
                       :(!mm.rockMoved[0] && !mm.rockMoved[2])){
          //finally, check for enemyRange
          return castling_enemyRange(leftOrRight);
        }
      }
    }
    //if no opportunity for castle was found (there are pieces in the way), return false;
    return false;
  }
  
  //------------------checking for enemyrange---------------------
  
  boolean castling_enemyRange(int leftOrRight){
    //if left
    if(leftOrRight==0){
      //loop over enemyRange
      for(int i=0;i<enemyRange.size();i+=2){
        int X = enemyRange.get(i);
        int Y = enemyRange.get(i+1);
        //check for threats in castling path
        if(Y==(playing==-1?0:7) && (X==1||X==2||X==3||X==4)){
          return false;
        }
      }
    }
    //if right
    if(leftOrRight==1){
      //loop over enemyRange
      for(int i=0;i<enemyRange.size();i+=2){
        int X = enemyRange.get(i);
        int Y = enemyRange.get(i+1);
        //check for threats in castling path
        if(Y==(playing==-1?0:7) && (X==5||X==6)){
          return false;
        }
      }
    }
    //if no reason was found not to do this move, it can be done
    return true;
  }
  
  //-------------------------------------------------------------------------return_with_castling----------------------------------------
  //function to add the enpassant move if enpassant is not zero. otherwise it 
  int[] return_with_castling(int x, int y, int[] legalMoves){
    //if castling is possible at left, add left castling king move
    if(state[x*8+y]*playing==ROI && castling_condition(0)){
      legalMoves[0]+=2;
      int[] cst_move = new int[2];
      cst_move[0]= 2;
      cst_move[1]= playing==-1?0:7;
      
      legalMoves = concat(legalMoves, cst_move);
    }
    //if castling is possible at right, add right castling king move
    if(state[x*8+y]*playing==ROI && castling_condition(1)){
      legalMoves[0]+=2;
      int[] cst_move = new int[2];
      cst_move[0]= 6;
      cst_move[1]= playing==-1?0:7;
      
      legalMoves = concat(legalMoves, cst_move);
    }
    return legalMoves;
  }
  
  //--------------------------------------------------------------------check for checkmate---------------------------
  boolean checkMate(){
    playing=-1*playing;
    updateEnemyRange();
    playing=-1*playing;
    //find king coordinates
    int kingX=0;int kingY=0;
    for(int i=0;i<8;i++){
      for(int j=0;j<8;j++){
        if(playing*state[i*8+j]==ROI){
          kingX=i;kingY=j;
        }
      }
    }
    //loop over enemyRange, if danger, then lauch KingCantEscape().
    for(int i=0;i<enemyRange.size();i+=2){
      int X = enemyRange.get(i);
      int Y = enemyRange.get(i+1);
      if(X==kingX && Y==kingY){
        print("king is under menace\n");
        return KingCantEscape();
      }
    }
    return false;
  }
  
  boolean KingCantEscape(){
    //loop over allied pieces, if any have an available move, that means the king can escape.
    for(int i=0;i<8;i++){
      for(int j=0;j<8;j++){
        if(state[i*8+j]*playing>0){
          int[] temp = getLegalMoves(i,j);
          if(temp[0]>0){
            return false;
          }
        }
      }
    }
    return true;
  }
  
  
  
  //just for debugging
  void printEnemyRange(){
    for(int i=0;i<enemyRange.size();i+=2){
      fill(250,100,0,150);
      rect(48+100*enemyRange.get(i),49+100*enemyRange.get(i+1),100,100);
    }
  }
}
