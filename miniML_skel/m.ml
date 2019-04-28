type program = exp
and exp = 
  | CONST of int
  | VAR of var
  | ADD of exp * exp
  | SUB of exp * exp
  | MUL of exp * exp
  | DIV of exp * exp 
  | ISZERO of exp
  | READ
  | IF of exp * exp * exp
  | LET of var * exp * exp
  | LETREC of var * var * exp * exp
  | PROC of var * exp
  | CALL of exp * exp
  | NEWREF of exp 
  | DEREF of exp
  | SETREF of exp * exp
  | SEQ of exp * exp
  | BEGIN of exp
and var = string

type value = 
    Int of int 
  | Bool of bool 
  | Procedure of var * exp * env 
  | RecProcedure of var * var * exp * env
  | Loc of loc
and loc = int
and env = (var * value) list
and mem = (loc * value) list

(* conversion of value to string *)
let value2str v = 
  match v with
  | Int n -> string_of_int n
  | Bool b -> string_of_bool b
  | Loc l -> "Loc "^(string_of_int l)
  | Procedure (x,e,env) -> "Procedure "
  | RecProcedure (f,x,e,env) -> "RecProcedure "^f

(* environment *)
let empty_env = []
let extend_env (x,v) e = (x,v)::e
let rec apply_env e x = 
  match e with
  | [] -> raise (Failure (x ^ " is unbound in Env"))
  | (y,v)::tl -> if x = y then v else apply_env tl x

(* memory *)
let empty_mem = [] 
let extend_mem (l,v) m = (l,v)::m
let rec apply_mem m l = 
  match m with
  | [] -> raise (Failure ("Location " ^ string_of_int l ^ " is unbound in Mem"))
  | (y,v)::tl -> if l = y then v else apply_mem tl l

(* use the function 'new_location' to generate a fresh memory location *)
let counter = ref 0
let new_location () = counter:=!counter+1;!counter

exception NotImplemented
exception UndefinedSemantics

(*****************************************************************)
(* TODO: Implement the eval function. Modify this function only. *)
(*****************************************************************)
let rec eval : exp -> env -> mem -> value * mem
= fun exp env mem -> 
  match exp with
  | CONST n -> ( (Int n) ,mem)
  | VAR x -> 
      let l = (apply_env env x) in 
      let v = apply_mem mem (val2int l) in (v,mem)
  | ADD(e1,e2) ->  
    let (val1,mem') = eval e1 env mem in 
      let (val2,mem'') = eval e2 env mem' in 
        ( Int ((val2int val1)+(val2int val2)) , mem'')
  | MUL(e1,e2) ->   
    let (val1,mem') = eval e1 env mem in 
      let (val2,mem'') = eval e2 env mem' in 
      ( Int ((val2int val1)*(val2int val2)) ,mem'')
  | SUB(e1,e2) ->  
    let (val1,mem') = eval e1 env mem in 
      let (val2,mem'') = eval e2 env mem' in 
        ( Int ((val2int val1)-(val2int val2)) ,mem'')
  | DIV(e1,e2) ->  
    let (val1,mem') = eval e1 env mem in 
      let (val2,mem'') = eval e2 env mem' in 
        (Int ((val2int val1)/(val2int val2)) ,mem'')
  | ISZERO e -> 
    let (val1,mem') = eval e env mem in 
      if (val2int val1) = 0 
        then (Bool true,mem')
        else (Bool false,mem')
  | IF(e1,e2,e3) ->
    let (val1,mem') = eval e1 env mem in 
    if (val2bool val1) = true 
      then eval e2 env mem'
      else eval e3 env mem'
  | LET (v1,e1,e2) ->
      let (val1,mem')  = eval e1 env mem in
        let env' = extend_env (v1, (Int ( (List.length env) +1) ) ) env  in
          let mem'' = extend_mem (val2int(apply_env env' v1) ,val1) mem' in
            eval e2 env' mem''
  | LETREC (v1,v2,e1,e2) ->
    let env' = extend_env (v1, RecProcedure (v1,v2,e1,env)) env in 
      let (val2,mem') = eval e2 env' mem in (val2,mem')
  | PROC (v1,e1) ->
    let val1 = Procedure (v1,e1,env) in (val1,mem)



and val2int value  =
  match value with
    | Int n -> n
    | Loc l -> l
and val2bool value = 
  match value with
    | Bool b -> b

(* driver code *)
let run : program -> value
= fun pgm -> (fun (v,_) -> v) (eval pgm empty_env empty_mem) 

