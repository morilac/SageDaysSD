# SageDaysSD
Code and files related to computations of scattering diagrams for Sage Days 64.5

 - *Scattering Diagrams Code* is Sage code which contains the classes
  - ScatteringDiagram
  - SDWall
  - SDTable
  - SDVertex
 - *ScatteringNB* is a Sage Notebook file which contains a version of the above code, as well as several examples.

r=2 To-Do List:
 - [ ] Use knowledge of g-fan to optimize SDTable.multiplicity
 - [ ] Find out if increasing recursion depth causes stack overflows
 - [ ] Eliminate as many perturbations as possible!

r=2 Wish List:
 - [ ] Implement path-ordered products as ring homomorphisms, and compute characteristic automorphism. (Problem: no homomorphisms of multivariate Laurent rings are not implemented yet)
 - [ ] Broken lines/theta functions.  Possibly incorporate this project: https://github.com/Etn40ff/broken-lines
 - [ ] Verify computed multiplicites (compare with Reineke's result?)

r=3 Wish List:
 - [ ] Write new or extend existing classes SDWall, SDVertex and ScatteringDiagram to the r=3 case.
 - [ ] Implement stereographic plots for the above classes
 - [ ] Implement `affine slice' plots for the above classes.  (It may be easier to extend the r=2 code to cover this case)

Research Questions:
 - [ ] Do the non-cluster theta functions of the Markov quiver coincide with the bracelet basis?  (Equivalently,) what is the characteristic automorphism of a scattering diagram of the Markov cluster algebra?
 - [ ] What is the path ordered product of the path in D(2,2) which goes from the all-positive quadrant to the wild wall? (An answer to this coul answer the previous question)
 - [ ] Is there a quiver with 3-vertices that has more than two components of open chambers?
