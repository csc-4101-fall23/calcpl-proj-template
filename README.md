# CSC 4101 - Group Project

**This is an group assignment. You can up to 2 team member to work on this project. Bonus part must be done individually.**

**Update** : (10/31) To make things easier, you can assume that `-` and `-.` operators have white space before and after (e.g., `  -  ` and `  -.  `)

## Introduction
The goal of this project is to get you familiar with extend our programming language (CalcPL). 
You need to add the following. 

- Add missing mathematical operators, `-` (subtract), `/` (division), and `=>` (Greater-than-equals).
- A new data type `float`.
- Add same operators for float `+.`, `-.`, `*.`, `/.` (these opertors require both operands as float). 
- float operator shoud support 2-decimal point precision. 
- Handle new kind of errors (e.g., `1 + 1.0 ` is not allowed). 
- Honors option/Bonus Points (5): Customize your operators and generate code on Generative-AI systems (ChatGP or Google Bard), **submit a separate report**. 

## Details

### Addition
For `+.` operator, we expect to pass the following unit tests.

```ocaml
make_f "float" 22.2 "22.2";
make_f "add_f" 22.5 "11.0+.11.5";
make_f "adds_f" 24.1 "(10.3+.1.7)+.(5.7+.6.4)";
```
### Multiplication 
For `*.` operator, we expect to pass the following unit tests.
```ocaml
make_f "mul1_f" 28.5 "2.5*.11.4";
make_f "mul2_f" 26.5 "2.2+.2.7*.9.0";
make_f "mul3_f" 13.9 "2.2*.2.0+.9.5";
make_f "mul4_f" 44.88 "2.0*.2.2*.10.2";
```

### Subraction 
For `-` and `-.` operators, we expect to pass the following unit tests.

```ocaml
make_i "sub" 22 "33-11";
make_i "subs" 22 "(39-1)-(22-6)";
make_i "subadd" 29 "(52-1)-(16+6)";
make_i "subadd2" 31 "(52+1)-(16+6)";
make_f "sub_f" 21.20 "33.0-.11.8";
make_f "subs_f" 20.90 "(39.0-.1.2)-.(22.9-.6.0)";
make_f "subadd_f" 1.5 "(39.0-.1.2)-.(20.1+.16.2)";
make_f "subadd2_f" 30.7 "(52.2+.1.6)-.(16.8+.6.3)";
make_f "submuls_f" 105.02 "(22.2-.17.0)+.(16.1*.6.2)";
```
### Division 
For `/` and `/.` operators, we expect to pass the following unit tests.

```ocaml
make_i "div" 22 "44/2";
make_i "div2" 2 "10*2/10";
make_i "div3" 5 "2*26/9";
make_i "div4" 26 "26+2/10";
make_i "div5" 28 "26+2-8/10";
make_i "div6" 54 "2*26+2-8/10";
make_f "div_f" 20.09 "44.2/.2.2";
make_f "div2_f" 2.35 "10.4*.2.3/.10.2";
make_f "div3_f" 6.55 "2.4*.26.2/.9.6";
make_f "div4_f" 26.5 "26.3+.2.1/.10.6";
make_f "div5_f" 28.19 "26.3+.2.7-.8.3/.10.3";
make_f "div6_f" 67.51 "2.1*.26.4+.12.9-.8.6/.10.4";
```
### LEQ or <=
Now that we have `float` types, our `<=` operator, we expect to pass the following unit tests.

```ocaml
make_b "leq_f" true "1.0<=1.0";
make_b "leq_f" false "5.0<=2.0";
```

### GEQ or >=
For `>=` operator, we expect to pass the following unit tests.

```ocaml
make_b "geq" true "1>=1";
make_b "geq2" false "2>=5";
make_b "geq_f" true "1.0>=1.0";
make_b "geq2_f" false "2.0>=5.0";
```

### Type-Handling
You should not be able to assign `float` to `int` or vice-versa. Also, previous operators should operate on expected types otherwise raise an error. 

```ocaml
 make_t "let_int_err" annotation_err "let x : int = 22.6 in x";
make_t "let_float_err" annotation_err "let x : float = 22 in x";
make_t "invalid plus_float" bop_err "1.0 +. true";
make_t "invalid plus_float_int" bop_err "1.0 +. 1";
make_t "invalid mult_float" bop_err "1.0 *. false";
make_t "invalid mult_float_int" bop_err "1.0 *. 1";
make_t "invalid sub_float" bop_err "1.0 -. true";
make_t "invalid sub_float_int" bop_err "1.0 -. 1";
make_t "invalid div_float" bop_err "1.0 /. true";
make_t "invalid div_float_int" bop_err "1.0 /. 1";
make_t "invalid guard_float" if_guard_err "if 1.0 then 2 else 3";
make_t "invalid leq_float" bop_err "true <= 1.0";
make_t "invalid geq_float" bop_err "true => 1.0";
```
## Honors Option or Bonus Points
Generative-AI tools (e.g., ChatGPT, Bard) are able to generate code for different languages. 
In this part of the project, we want to experiment whether AI systems can generate a valid code our toy language. 

1. Submission report you should contains (single PDF file): 
    1. All the prompts and responses as screenshot (images or PDF). 
    2. Details what kind of changes you made.
    3. Screenshots of generated code failed or succeceded (you can do this by calling `interp` in `utop`). 
2. There are **5 possible points**, we will grade your work based on variety of actions and diversity of prompts. 
3. You can only use **ChatGPT, Google Bard, or LLAMA**. 

### Tips
When you make a change to your language you need to tell you AI system what are the specific changes or what type of features your language offer. 

There are few trivial things to try:
- Try re-ordering operator precedence.
- Try to have ambigious kind of operator tokens. 
- Try to ask generate possible expressions for specific output. 
- If AI system generates some unavailable expressions, tell what kind of mistakes it made. 
