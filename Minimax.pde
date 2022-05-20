class Minimax{
  IA ia;
  int playing=-1;
  boolean isMax;
  float alpha,beta;
  Minimax(){
    isMax=true;
    ia=new IA();
    alpha=beta=0;
  }
  
  //lastMove taille 5 pour départ, arrivée, ce qu'on a mangé si on a mangé.
  //avant un return, on doit toujours remettre l'état à ce qu'il était avant l'appel.
  float minimax(int[] lastMove, int lvlrec){
    //print("lvlrec : ",lvlrec,"\n");
    //calculer l'heuristique en ce point
    float Heuristic = ia.computeHeuristic();
    //check le niveau de récursion
    if(lvlrec>0){
      //générer tous les moves possibles
      int[] moves = ia.generateMoves();
      //condition d'arrêt si pas de moves possibles (auquel cas renvoyer une valeur négative si roi menacé ; sinon 0.)
      if(moves[0]==0){
        if(ia.mc.checkMate()){
          //print("pruning branch : checkmate\n");
          //if checkmate, return -100, this can be tuned to let the AI take more or less risk in getting close to a checkmate
          undoSimulatedMove(lastMove);
          return isMax?-100.:100.;
        }else{
          //print("pruning branch : draw\n");
          //if draw, score is 0
          undoSimulatedMove(lastMove);
          return 0.;
        }
      }
      //condition d'arrêt (alpha beta ne garantit pas maximum absolu) si l'heuristique sur état courant est moins bien qu'alpha ou beta
      if((Heuristic<alpha&&isMax) || (-Heuristic>beta&&!isMax)){
        //on renvoie la valeur de l'heuristique en ce point, de toute façon elle sera ignorée car on a mieux.
        //print("pruning branch : worse than alpha beta : \nalpha : ",alpha,",  beta : ",beta," Heuristic : ",isMax?Heuristic:-Heuristic,"\n");
        updateAlphaBeta(isMax,Heuristic);
        undoSimulatedMove(lastMove);
        return isMax?Heuristic:-Heuristic;
      }
      
      //ici on est sûr d'avoir dépassé toutes les conditions d'arrêt.
      
      //pour chaque move disponible, appliquer le move et lancer minimax dessus, ajoutant le return à une arrayList.
      //trouver min et max disponibles à la volée
      float min=5000;float max=-5000;
      //pour simuler les états on switch isMax
      isMax=isMax?false:true;
      lvlrec--;
      for(int i=1;i<moves[0]+1;i+=4){
        //give info to the call
        int[] move_made = new int[5];
        move_made[0]=moves[i+0];move_made[1]=moves[i+1];move_made[2]=moves[i+2];move_made[3]=moves[i+3];
        move_made[4]=ia.state[moves[i+2]*8+moves[i+3]];
        //make the move
        simulateMove(move_made);
        float res = minimax(move_made,lvlrec);
        
        //trouver min et max à la volée
        min=res<min?res:min;
        max=res>max?res:max;
      }
      //revenir au isMax non-simulé :
      isMax=isMax?false:true;
      lvlrec++;
      //selon la valeur de isMax, choisir la valeur à renvoyer
      float to_return =isMax?max:min;
      /*print("min : ",min," max : ",max,"\n");
      print("isMax : ",isMax,"\n");
      print("alpha : ",alpha,",  beta : ",beta,", return at ",lvlrec," : ",isMax?max:-min,"\n");*/
      //défaire le lastMove dans le state de IA.
      undoSimulatedMove(lastMove);
      //renvoyer la valeur déterminée -- update alpha et beta car on ne renvoie jamais que des valeurs garanties
      updateAlphaBeta(isMax,to_return);
      return to_return;
    }
    //si on est au bout de la récursion, on renvoie le score de l'état actuel.
    else{
      //print("pruning branch : end of recursion, returning : ",isMax?Heuristic:-Heuristic, "\n");
      //renvoyer la valeur déterminée -- update alpha et beta car on ne renvoie jamais que des valeurs garanties
      updateAlphaBeta(isMax,Heuristic);
      undoSimulatedMove(lastMove);
      return isMax?Heuristic:-Heuristic;
    }  
  }
  
  int[] pickMove(int lvlrec){
    //generate moves
    int[] moves = ia.generateMoves();
    //launch minimax on each
    float max=0;int argmax=1;
    //flip isMax during simulation
    isMax=isMax?false:true;
    for(int i=1;i<moves[0]+1;i+=4){
      //give info to the call
      int[] move_made = new int[5];
      move_made[0]=moves[i+0];move_made[1]=moves[i+1];move_made[2]=moves[i+2];move_made[3]=moves[i+3];
      move_made[4]=ia.state[moves[i+2]*8+moves[i+3]];
      //make the move
      simulateMove(move_made);
      float res = minimax(move_made,lvlrec);
      //print("Heuristic : ",res,"\n");
      
      //trouver min et max à la volée -- l'appelant est toujours le maximiseur.
      if(max<res){
        max=res;argmax=i;
      }
    }
    //flip isMax back since simulation is done
    isMax=isMax?false:true;
    //print("max : ",max," argmax : ",argmax,"\n");
    
    //return best move if there's such a move
    int[] best = new int[4];
    if(moves[0]>0){
      for(int k=0;k<4;k++){
        best[k]=moves[argmax+k];
      }
    }else print("should have checkmate : ",ia.checkmate,"\n");
    return best;
  }
  
  
  //avant un return, on doit toujours remettre l'état à ce qu'il était avant l'appel.
  void undoSimulatedMove(int[] move){
    ia.state[move[0]*8+move[1]]=ia.state[move[2]*8+move[3]];
    ia.state[move[2]*8+move[3]]=move[4];
    ia.mc.updateEnemyRange();
  }
  void simulateMove(int[] move){
    ia.state[move[2]*8+move[3]]=ia.state[move[0]*8+move[1]];
    ia.state[move[0]*8+move[1]]=NOTHING;
    ia.mc.updateEnemyRange();
  }
  void updateAlphaBeta(boolean isMax, float Heuristic){
    if(isMax){
      if(alpha<Heuristic){alpha=Heuristic;}
    }else{
      if(beta>-Heuristic){beta=-Heuristic;}
    }
  }
}
