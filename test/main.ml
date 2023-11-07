open OUnit2
open Interp
open Ast
open Main

(** [make_i n i s] makes an OUnit test named [n] that expects
    [s] to evalute to [Int i]. *)
let make_i n i s =
  n >:: (fun _ -> assert_equal (Int i) (interp s))

(** [make_b n b s] makes an OUnit test named [n] that expects
    [s] to evaluate to [Bool b]. *)
let make_b n b s =
  n >:: (fun _ -> assert_equal (Bool b) (interp s))

(** [make_b n f s] makes an OUnit test named [n] that expects
    [s] to evaluate to [Float b]. *)
let make_f n f s =
  n >:: (fun _ -> assert_equal (Float f) (interp s))

(** [make_t n s] makes an OUnit test named [n] that expects
    [s] to fail type checking with error string [s']. *)
let make_t n s' s =
  n >:: (fun _ -> assert_raises (Failure s') (fun () -> interp s))

let tests = [
  make_i "int" 22 "22";
  make_i "add" 22 "11+11";
  make_i "adds" 22 "(10+1)+(5+6)";
  make_i "let" 22 "let x : int = 22 in x";
  make_i "lets" 22 "let x : int = 0 in let x : int = 22 in x";
  make_i "mul1" 22 "2*11";
  make_i "mul2" 22 "2+2*10";
  make_i "mul3" 14 "2*2+10";
  make_i "mul4" 40 "2*2*10";
  make_i "if1" 22 "if true then 22 else 0";
  make_b "true" true "true";
  make_b "leq" true "1<=1";
  make_i "if2" 22 "if 1+2 <= 3+4 then 22 else 0";
  make_i "if3" 22 "if 1+2 <= 3*4 then let x : int = 22 in x else 0";
  make_i "letif" 22 "let x : bool = 1+2 <= 3*4 in if x then 22 else 0";
  make_t "invalid plus" bop_err "1 + true";
  make_t "invalid mult" bop_err "1 * false";
  make_t "invalid leq" bop_err "true <= 1";
  make_t "invalid guard" if_guard_err "if 1 then 2 else 3";
  make_t "unbound" unbound_var_err "x";

  make_i "sub" 22 "33 - 11";
  make_i "subs" 22 "(39 - 1) - (22 - 6)";
  make_i "subadd" 29 "(52 - 1) - (16+6)";
  make_i "subadd2" 31 "(52+1) - (16+6)";
  make_i "submuls" 101 "(22 - 17)+(16*6)";
  make_i "div" 22 "44/2";
  make_i "div2" 2 "10*2/10";
  make_i "div3" 5 "2*26/9";
  make_i "div4" 26 "26+2/10";
  make_i "div5" 28 "26+2 - 8/10";
  make_i "div6" 54 "2*26+2 - 8/10";
  make_b "geq" true "1>=1";
  make_b "geq2" false "2>=5";
  make_i "if4" 0 "if 1+2 >= 3+4 then 22 else 0";
  make_f "float" 22.2 "22.2";
  make_f "add_f" 22.5 "11.0+.11.5";
  make_f "adds_f" 24.1 "(10.3+.1.7)+.(5.7+.6.4)";
  make_f "let_f" 22.5 "let x : float = 22.5 in x";
  make_f "lets_f" 22.5 "let x : float = 0.0 in let x : float = 22.5 in x";
  make_f "mul1_f" 28.5 "2.5*.11.4";
  make_f "mul2_f" 26.5 "2.2+.2.7*.9.0";
  make_f "mul3_f" 13.9 "2.2*.2.0+.9.5";
  make_f "mul4_f" 44.88 "2.0*.2.2*.10.2";
  make_b "leq_f" true "1.0<=1.0";
  make_b "leq_f" false "5.0<=2.0";
  make_b "geq_f" true "1.0>=1.0";
  make_b "geq2_f" false "2.0>=5.0";
  make_f "sub_f" 21.20 "33.0 -. 11.8";
  make_f "subs_f" 20.90 "(39.0 -. 1.2) -. (22.9 -. 6.0)";
  make_f "subadd_f" 1.5 "(39.0 -. 1.2) -. (20.1+.16.2)";
  make_f "subadd2_f" 30.7 "(52.2+.1.6) -. (16.8+.6.3)";
  make_f "submuls_f" 105.02 "(22.2 -. 17.0)+.(16.1*.6.2)";
  make_f "div_f" 20.09 "44.2/.2.2";
  make_f "div2_f" 2.35 "10.4*.2.3/.10.2";
  make_f "div3_f" 6.55 "2.4*.26.2/.9.6";
  make_f "div4_f" 26.5 "26.3+.2.1/.10.6";
  make_f "div5_f" 28.19 "26.3+.2.7 -. 8.3/.10.3";
  make_f "div6_f" 67.51 "2.1*.26.4+.12.9 -. 8.6/.10.4";
  make_t "let_int_err" annotation_err "let x : int = 22.6 in x";
  make_t "let_float_err" annotation_err "let x : float = 22 in x";
  make_t "invalid plus_float" bop_err "1.0 +. true";
  make_t "invalid plus_float_int" bop_err "1.0 +. 1";
  make_t "invalid mult_float" bop_err "1.0 *. false";
  make_t "invalid mult_float_int" bop_err "1.0 *. 1";
  make_t "invalid sub_float" bop_err "1.0  -. true";
  make_t "invalid sub_float_int" bop_err "1.0 -. 1";
  make_t "invalid div_float" bop_err "1.0 /. true";
  make_t "invalid div_float_int" bop_err "1.0 /. 1";
  make_t "invalid guard_float" if_guard_err "if 1.0 then 2 else 3";
  make_t "invalid leq_float" bop_err "true <= 1.0";
  make_t "invalid geq_float" bop_err "true >= 1.0";
]

let _ = run_test_tt_main ("suite" >::: tests)
