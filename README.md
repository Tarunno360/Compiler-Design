📌 Compiler Design Assignment
📖 Overview

This repository contains my Compiler Design course assignment, focusing on the analysis and intermediate representation phases of a compiler. The project demonstrates how source code with nested scopes and variable shadowing is processed and translated into Three Address Code (TAC) using proper scope handling and symbol table management.

🎯 Objectives

Understand lexical scoping and nested blocks

Implement symbol table handling with scope resolution

Generate Three Address Code (TAC) for conditional and block-structured programs

Analyze variable shadowing and redeclaration

🧠 Compiler Concepts Covered

Lexical Scoping

Nested Blocks

Symbol Table Construction

Scope Entry and Exit

Three Address Code (TAC) Generation

Intermediate Code Representation

🧩 Problem Description

The assignment takes a C-like input program containing:

Multiple nested if blocks

Repeated variable declarations (int a, float a)

Conditional expressions

The task is to:

Track variable declarations across scopes

Ensure correct binding of identifiers

Generate valid Three Address Code reflecting proper scope resolution

⚙️ Implementation Details

Each block introduces a new scope

Variables declared in inner scopes shadow outer variables

A stack-based symbol table (or hierarchical table) is used

TAC instructions are generated in the form:

t1 = a > 1
ifFalse t1 goto L1

🧪 Example Input
int func() {
    int a;
    if (a > 1) {
        float a;
        if (a > 1) {
            int a;
        }
    }
}

🧾 Example Output (Three Address Code)
a1 = a0 > 1
ifFalse a1 goto L1
a2 = a1 > 1
ifFalse a2 goto L2


(Variable indices indicate scope-specific bindings)

🚀 How to Run

Provide input source code in input.c

Run the compiler script.sh



📚 Learning Outcomes

Clear understanding of scope rules

Practical experience with intermediate code generation

Improved grasp of how real compilers handle nested declarations

🧑‍💻 Author

SM Azmain Faysal
Compiler Design Assignment
