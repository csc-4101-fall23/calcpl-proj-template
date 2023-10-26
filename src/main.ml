open Ast

(** [parse s] parses [s] into an AST. *)
let parse (s : string) : expr =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast

(** The error message produced if a variable is unbound. *)
let unbound_var_err = "Unbound variable"

(** The error message produced if binary operators and their
    operands do not have the correct types. *)
let bop_err = "Operator and operand type mismatch"

(** The error message produced if the [then] and [else] branches
    of an [if] do not have the same type. *)
let if_branch_err = "Branches of if must have same type"

(** The error message produced if the guard
    of an [if] does not have type [bool]. *)
let if_guard_err = "Guard of if must have type bool"

(** The error message produced if type mismatches on let. *)
let annotation_err = "Let expression type mismatch"

module type StaticEnvironment = sig
  (** [t] is the type of a static environment. *)
  type t

  (** [empty] is the empty static environment. *)
  val empty : t

  (** [lookup env x] gets the binding of [x] in [env].
      Raises: [Failure] if [x] is not bound in [env]. *)
  val lookup : t -> string -> typ

  (** [extend env x ty] is [env] extended with a binding
      of [x] to [ty]. *)
  val extend : t -> string -> typ -> t
end

module StaticEnvironment : StaticEnvironment = struct
  type t = (string * typ) list

  let empty = []

  let lookup env x =
    try List.assoc x env
    with Not_found -> failwith "Unbound variable"

  let extend env x ty =
    (x, ty) :: env
end

open StaticEnvironment

(** Converts x float to d point float ex. round_dfrac 2 3.140000009 returns 3.14*)
let round_dfrac d x =
  if x -. (Float.round x) = 0. then x else                   (* x is an integer. *)
  let m = 10. ** (float d) in                       (* m moves 10^-d to 1. *)
  (floor ((x *. m) +. 0.5)) /. m

(** [typeof env e] is the type of [e] in context [env]. 
    Raises: [Failure] if [e] is not well typed in [env]. *)
let rec typeof env = function
  | Int _ -> TInt
  | Bool _ -> TBool
  | Var x -> lookup env x
  | Let (x, t ,e1, e2) -> typeof_let env x t e1 e2
  | Binop (bop, e1, e2) -> typeof_bop env bop e1 e2
  | If (e1, e2, e3) -> typeof_if env e1 e2 e3
  | _ -> failwith "TODO"
  
(** Helper function for [typeof]. *)
and typeof_let env x t e1 e2 = 
  let t' = typeof env e1 in
  if t = t' then
    let env' = extend env x t' in 
    typeof env' e2
  else 
      failwith annotation_err
  
(** Helper function for [typeof]. *)
and typeof_bop env bop e1 e2 =
  let t1, t2 = typeof env e1, typeof env e2 in
  match bop, t1, t2 with
  | Add, TInt, TInt 
  | Mult, TInt, TInt -> TInt
  | Leq, TInt, TInt -> TBool
  | _ -> failwith bop_err
  
(** Helper function for [typeof]. *)
and typeof_if env e1 e2 e3 =
  let t1 = typeof env e1 in 
  if t1 <> TBool then
    failwith if_guard_err
  else
    let t2 = typeof env e2 in
    let t3 = typeof env e3 in
    if t2 <> t3 then 
      failwith if_branch_err
    else 
      t2

(** [typecheck e] checks whether [e] is well typed in
  the empty environment. Raises: [Failure] if not. *)
let typecheck e =
  ignore (typeof empty e)

(** [subst e v x] is [e] with [v] substituted for [x], that
    is, [e{v/x}]. *)
let rec subst e v x = match e with
  | Var y -> if x = y then v else e
  | Bool _ -> e
  | Int _ -> e
  | Binop (bop, e1, e2) -> Binop (bop, subst e1 v x, subst e2 v x)
  | Let (y, t, e1, e2) ->
    let e1' = subst e1 v x in
    if x = y
    then Let (y, t, e1', e2)
    else Let (y, t, e1', subst e2 v x)
  | If (e1, e2, e3) -> 
    If (subst e1 v x, subst e2 v x, subst e3 v x)
  | _ -> failwith "TODO"
  
(** [eval e] the [v]such that [e ==> v]. *)
let rec eval (e : expr) : expr = match e with
  | Int _ | Bool _ -> e
  | Var _ -> failwith unbound_var_err
  | Binop (bop, e1, e2) -> eval_bop bop e1 e2
  | Let (x, _, e1, e2) -> subst e2 (eval e1) x|> eval
  | If (e1, e2, e3) -> eval_if e1 e2 e3
  | _ -> failwith "TODO"

(** [eval_let x e1 e2] is the [v] such that [let x = e1 in e2 ==> v]. *) 
and eval_let x e1 e2 = 
  let v1 = eval e1 in 
  let e2' = subst e2 v1 x in 
  eval e2'

(** [eval_bop bop e1 e2] is the [v] such that [e1 bop e2 ==> v]. *) 
and eval_bop bop e1 e2 = 
  match bop, eval e1, eval e2 with
  | Add, Int a, Int b -> Int (a + b)
  | Mult, Int a, Int b -> Int (a * b)
  | Leq , Int a, Int b -> Bool (a <= b)
  | _ -> failwith bop_err

(** [eval_if e1 e2 e3] is the [v] such that [if e1 then e2 ==> v]. *) 
and eval_if e1 e2 e3 = 
  match eval e1 with 
  | Bool true -> eval e2
  | Bool false -> eval e3
  | _ -> failwith if_guard_err

(** [interp s] interprets [s] by lexing and parsing,
    evaluating, and converting the result to string. *)
let interp (s : string) : expr =
  let e = parse s in
  typecheck e;
  eval e