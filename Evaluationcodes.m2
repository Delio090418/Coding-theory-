needsPackage "SRdeformations"
needsPackage "Polyhedra"

EvaluationCode = new Type of HashTable

evaluationCode = method(Options => {})

evaluationCode(Ring,List,List) := EvaluationCode => opts -> (F,P,S) -> (
    -- constructor for the evaluation code
    -- input: a field, a list of points, a set of polynomials.
    -- outputs: a monomial code over the list of points.
    
    -- We should check if all the points lives in the same F-vector space.
    -- Should we check if all the monomials lives in the same ring?
    
    R := ring S#0;

    I := intersect apply(P,i->ideal apply(numgens R,j->R_j-i#j)); -- Vanishing ideal of the set of points.

    S = toList apply(apply(S,i->promote(i,R/I)),j->lift(j,R))-set{0*S#0}; -- Drop the elements in S that was already in I.

    G := matrix apply(P,i->flatten entries sub(matrix(R,{S}),matrix(F,{i}))); -- Evaluate the elements in S over the elements on P.
    
    G = (transpose G)//(groebnerBasis transpose G);
    
    new EvaluationCode from{
	symbol Points => P,
	symbol VanishingIdeal => I,
	symbol PolynomialSet => S,
	symbol GeneratingMatrix => G,
	symbol LinearCode => linearCode(G)
	}
    )

evaluationCode(Ring,List,Matrix) := EvaluationCode => opts -> (F,P,M) -> (
    -- Constructor for a evaluation (monomial) code.
    -- inputs: a field, a list of points (as a tuples) of the same length and a matrix of exponents.
    -- outputs: a F-module.
    
    -- We should check if all the points of P are in the same F-vector space.

    m := numgens image M; -- number of monomials.

    R := F[t_1..t_m];

    I := intersect apply(P,i->ideal apply(m,j->R_j-i#(j))); -- Vanishing ideal of P.

    G := transpose matrix apply(entries M,i->toList apply(P,j->product apply(m,k->(j#k)^(i#k))));    

    G := transpose((transpose G)//(groebnerBasis transpose G));
    
    new EvaluationCode from{,
	symbol Points => P,
	symbol VanishingIdeal => I,
	symbol ExponentsMatrix => M,
	symbol GeneratingMatrix => G,
	symbol LinearCode => linearCode(G)
	}
    )

   
ToricCode = method(Options => {})

ToricCode(ZZ,Matrix) := EvaluationCode => opts -> (q,M) -> (
    -- Constructor for a toric code.
    -- inputs: size of a field, an integer matrix 
    -- outputs: the evaluation code defined by evaluating all monomials corresponding to integer 
    ---         points in the convex hull (lattice polytope) of the columns of M at the points of the algebraic torus (F*)^n
    
    F:=GF(q, Variable=>z);  --- finite field of q elements
    s:=set apply(q-1,i->z^i); -- set of non-zero elements in the field
    m:=numgens target M; --- the length of the exponent vectors, i.e. number of variables for monomials, i.e.the dim of the ambient space containing the polytope
    ss:=s; 
    for i from 1 to m-1 do (
    	ss=set toList ss/splice**s;  
    );
    P:=toList ss/splice;   -- the loop above creates the list of all m-tuples of non-zero elements of F, i.e. the list of points in the algebraic torus (F*)^m
    Polytop:=convexHull M; -- the convex hull of the columns of M
    L:=latticePoints Polytop; -- the list of lattice points in Polytop
    LL:=matrix apply(L, i-> first entries transpose i); --converts the list of lattice points to a matrix of exponents
    G:=matrix apply(entries LL,i->apply(P,j->product apply(m,k->(j#k)^(i#k)))); -- the matrix of generators; rows form a generating set of codewords
    
    R:=F[t_1..t_m]; --- defines the ring containing monomials corresponding to exponents
    I := ideal apply(m,j->R_j^(q-1)-1); --  the vanishing ideal of (F*)^m
    
    new EvaluationCode from{
	symbol AmbientSpace => F^(#P),

	symbol ExponentsMatrix => transpose LL, -- the matrix of exponents, exponent vectors are columns
	symbol LinearCode => linearCode(transpose G), -- the code 
	symbol Points => P,  --- the points of (F*)^m
	symbol Dimension => rank image G, -- dimension of the code
	symbol Length => (q-1)^m,  -- length of the code
	symbol VanishingIdeal => I --the vanishing ideal of (F*)^m

	}
)   
    
----------------- Example of ToricCode method ----

M=matrix{{1,2,10},{4,5,6}} -- martrix of exponent vectors definind the polytope P, exponents vectors are columns
T=ToricCode(4,M) --- a toric code over F_4 with polytope P
T.Code
T.ExponentsMatrix

M=matrix{{1,2,10,1},{4,5,6,1},{2,1,0,1}}
T=ToricCode(4,M)

------------------    
    
    
       
------------This an example of an evaluation code----------------------------------------

needsPackage "NormalToricVarieties"
needsPackage "NAGtypes"

d=2
q=2
S=3
F_2=GF 2-- Galois fiel
---------------------Defining  points in the Fano plane-----
A=affineSpace(S, CoefficientRing => F_2, Variable => y)
aff=rays A
matrix aff
--------------Points in Fano plane------------------
LL=apply(apply(toList (set(0..q-1))^**(S)-(set{0})^**(3),toList),x -> (matrix aff)*vector deepSplice x)
X=apply(LL,x->flatten entries x)
------------------Defining the ring and the vector space of  homogeneous polynomials with degree 2----------------------------------
R=F_2[vars(0..2)]
LE=apply(apply(toList (set(0..q-1))^**(hilbertFunction(2,R))-(set{0})^**(hilbertFunction(2,R)),toList),x -> basis(2,R)*vector deepSplice x)
Poly=apply(LE,x-> entries x)
-----------------------for each point p_k in Fano plane exists a polynomial f_i s.t f_i(p_k)not=0 ---------------------------------------
f={b^2,c^2,a^2,a^2,b^2,a^2,a^2}
----------------------------Using the package  numerial algebraic geometry----------------------------------
Polynum=apply(0..length LE-1, x->polySystem{LE#x#0})
PolyDem=apply(f,x->polySystem{x})
XX=apply(X,x->point{x})
---------------------Reed-Muller-type code of order 2------------------------------------------
C_d=apply(Polynum,y->apply(0..length f -1,x->(flatten entries evaluate(y,XX#x))#0/(flatten entries evaluate(PolyDem#x,XX#x))#0))
   
    
------------------------------------------------------------------------------------------------------------------------------



----------The incidence matrix code of a Graph G-------
needsPackage  "Graphs"
needsPackage  "NAGtypes"

--These are two procedure for obtain an incidence matrix code of a Graph G
-- be sure that p is a prime number 


--1-- this procedure computes the generatrix matrix of the code---
-- M is the incidence matrix of the Graph G

codeGrahpIncM = method(TypicalValue => Module);
codeGrahpIncM (Matrix,ZZ):= (M,p)->(
tInc:=transpose M;
X:=entries tInc;
R:=ZZ/p[t_(0)..t_(numgens target M-1)];
SetPol:=flatten entries basis(1,R);
SetPolSys:=apply(0..length SetPol-1, x->polySystem{SetPol#x});
XX:=apply(X,x->point{x});
C:=apply(apply(SetPolSys,y->apply(0..length XX -1,x->(flatten entries evaluate(y,XX#x))#0)),toList);
image transpose matrix{C}
)


--2-- this an alternative process. It computes all the points in the code. It computes all the linear forms. 

codeGrahpInc = method(TypicalValue => Sequence);
codeGrahpInc (Graph,ZZ):= (G,p)->(
tInc:=transpose incidenceMatrix G;
X:=entries tInc;
R:=ZZ/p[t_(0)..t_(lentgh vertexSet G-1)];
Poly1:=apply(apply(toList (set(0..p-1))^**(hilbertFunction(1,R))-(set{0})^**(hilbertFunction(1,R)),toList),x -> basis(1,R)*vector deepSplice x); 
Polynums1:=apply(0..length Poly1-1, x->polySystem{Poly1#x#0});
XX:=apply(X,x->point{x});
apply(Polynums1,y->apply(0..length XX -1,x->(flatten entries evaluate(y,XX#x))#0))
)





cartesianCode = method(Options => {})

cartesianCode(Ring,List,List) := EvaluationCode => opts -> (F,S,M) -> (
    --constructor for a cartesian code
    --input: a field, a list of subsets of F and a list of polynomials.
    --outputs: The evaluation code using the cartesian product of the elements in S and the polynomials in M.
    
    m := #S;
    R := ring M#0;
    I := ideal apply(m,i->product apply(S#i,j->R_i-j));
    P := set S#0;
    for i from 1 to m-1 do P=P**set S#i;
    P = apply(toList(P/deepSplice),i->toList i);
    Mm := toList apply(apply(M,i->promote(i,R/I)),j->lift(j,R))-set{0*M#0};
    G := matrix apply(P,i->flatten entries sub(matrix(R,{Mm}),matrix(F,{i})));
    G = (transpose G)//(groebnerBasis transpose G);
    
    new EvaluationCode from{
	symbol Sets => S,
	symbol VanishingIdeal => I,
	symbol PolynomialSet => Mm,
	symbol GeneratingMatrix => G,
	symbol LinearCode => linearCode(G)
	}
    )

cartesianCode(Ring,List,ZZ) := EvaluationCode => opts -> (F,S,d) -> (
    -- Constructor for cartesian codes.
    -- inputs: A field F, a set of tuples representing the subsets of F and the degree d.
    -- outputs: the cartesian code of degree d.
    m:=#S;
    R:=F[t_0..t_(m-1)];
    M:=apply(flatten entries basis(R/monomialIdeal basis(d+1,R)),i->lift(i,R));
    
    cartesianCode(F,S,M)
    )
   
cartesianCode(Ring,List,Matrix) := EvaluationCode => opts -> (F,S,M) -> (
    -- constructor for a monomial cartesian code.
    -- inputs: a field, a list of sets, a matrix representing as rows the exponents of the variables
    -- outputs: a cartesian code evaluated with monomials
    
    -- Should we add a second version of this function with a third argument an ideal? For the case of decreasing monomial codes.
    
    m := #S;
    R := F[t_0..t_(m-1)];
    I := ideal apply(m,i->product apply(S#i,j->R_i-j));
    P := set S#0;
    for i from 1 to m-1 do P=P**set S#i;
    P = apply(toList(P/deepSplice),i->toList i);
    G := transpose matrix apply(entries M,i->toList apply(P,j->product apply(m,k->(j#k)^(i#k))));
    G := ((transpose G)//(groebnerBasis transpose G));
    
    new EvaluationCode from{
	symbol VanishingIdeal => I,
	symbol ExponentsMatrix => M,
	symbol GeneratingMatrix => G,
	symbol LinearCode => linearCode(G)
	}
    )


RMCode = method(TypicalValue => EvaluationCode)
    
RMCode(ZZ,ZZ,ZZ) := CartesianCode => (q,m,d) -> (
    -- Contructor for a generalized Reed-Muller code.
    -- Inputs: A prime power q (the order of the finite field), m the number of variables in the defining ring  and an integer d (the degree of the code).
    -- outputs: The cartesian code of the GRM code.
    
    F := GF(q);
    S := apply(q-1, i->F_0^i)|{0*F_0};
    S = apply(m, i->S);
    
    cartesianCode(F,S,d)
    )


orderCode = method(Options => {})

orderCode(Ring,List,List,ZZ) := EvaluationCode => opts -> (F,G,P,l) -> (
    -- Order codes are defined through a set of points and a numerical semigroup.
    -- Inputs: A field, a list of points P, the minimal generating set of the semigroup (where G_1<G_2<...) of the order function, a bound l.
    -- Outputs: the evaluation code evaluated in P by the polynomials with weight less or equal than l.
    
    -- We should add a check to way if all the points are of the same length.
    
    m := length P#0;
    R := F[t_0..t_(m-1), Degrees=>G];
    M := matrix apply(toList sum apply(l+1, i -> set flatten entries basis(i,R)),j->first exponents j);
    
    evaluationCode(F,P,M)
    )

orderCode(Ideal,List,List,ZZ) := EvaluationCode => opts -> (I,P,G,l) -> (
    -- If we know the defining ideal of the finite algebra associated to the order function, we can obtain the generating matrix.
    -- Inputs: The ideal I that defines the finite algebra of the order function, the points to evaluate over, the minimal generating set of the semigroups associated to the order function and the bound.
    -- Outpus: an evaluation code.
    
    m := #flatten entries basis(1,I.ring);
    R := (coefficientRing I.ring)[t_1..t_m, Degrees=>G, MonomialOrder => (reverse apply(flatten entries basis(1,I.ring),i -> Weights => first exponents i))];
    J := sub(I,matrix{gens R});
    S := R/J;
    M := matrix apply(toList sum apply(l+1,i->set flatten entries basis(i,S)),i->first exponents i);
    
    evaluationCode(coefficientRing I.ring, P, M)
    )

orderCode(Ideal,List,ZZ) := EvaluationCode => opts -> (I,G,l) -> (
    -- The same as before, but taking P as the rational points of I.
    
    P := rationalPoints I;
    orderCode(I,P,G,l)
    )

    
-*
Example:

-- Order codes is just another way to write one-point AG-codes. For example, take the curve x^3=y^2+y over F_4.

F=GF(4)
R=F[x,y]
I=ideal(x^3+y^2+y)

-- Take Q the common pole of x and y. R/I is already the algebra L(\infty Q) (this is, the sum of all the Riemann-Roch spaces L(lQ) for l>= 0).
-- The Weierstrass semigroup of Q is the generated by {2,3}. Then the code C(\sum P,lQ) is

l=7
C=orderCode(I,{2,3},l)

In this case we can guarantee that the matrix generated by orderCode is in fact the generating matrix. 

Example: 

-- The Suzuki curve is defined by the equation y^q-y=x^q_0(x^q-x), where q_0=2^n and q=2^(2n+1) for som positive integer n.
-- The Weierstrass semigroup of the common pole of x and y is generated by four elements, so we have to add the elements 
-- v=y^(q/q_0)-x^(q/q0+1), w=y^(q/q0)x^(q/q0^2+1)+v^(q/q0) (http://www.math.clemson.edu/~gmatthe/suzuki.pdf)

n=1
q0=2^n
q=2^(2*n+1)
F=GF(q)

R=F[x,y,v,w]
I=ideal(y^q-y-x^q0*(x^q-x),v-y^(2*q0)+x^(2*q0+1),w-y^(2*q0)*x-v^(2*q0))

-- If D is the sum of all rational places os the curve but Q, the AG code C(D,lQ) is

l=8
C=orderCode(I,{q,q+q0,q+q//q0,q+q//q0+1},l)
*-


© 2020 GitHub, Inc.
Terms
Privacy
Security
Status
Help
Contact GitHub
Pricing
API
Training
Blog
About

