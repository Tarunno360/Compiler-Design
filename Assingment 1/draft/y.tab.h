/* A Bison parser, made by GNU Bison 2.7.  */

/* Bison interface for Yacc-like parsers in C
   
      Copyright (C) 1984, 1989-1990, 2000-2012 Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     IF = 258,
     FOR = 259,
     DO = 260,
     INT = 261,
     FLOAT = 262,
     VOID = 263,
     SWITCH = 264,
     DEFAULT = 265,
     GOTO = 266,
     ELSE = 267,
     WHILE = 268,
     BREAK = 269,
     CHAR = 270,
     DOUBLE = 271,
     RETURN = 272,
     CASE = 273,
     CONTINUE = 274,
     PRINTF = 275,
     ID = 276,
     ADDOP = 277,
     MULOP = 278,
     INCOP = 279,
     RELOP = 280,
     LOGICOP = 281,
     ASSIGNOP = 282,
     NOT = 283,
     LPAREN = 284,
     RPAREN = 285,
     LCURL = 286,
     RCURL = 287,
     LTHIRD = 288,
     RTHIRD = 289,
     COMMA = 290,
     COLON = 291,
     SEMICOLON = 292,
     CONST_FLOAT = 293,
     CONST_INT = 294,
     DECOP = 295
   };
#endif
/* Tokens.  */
#define IF 258
#define FOR 259
#define DO 260
#define INT 261
#define FLOAT 262
#define VOID 263
#define SWITCH 264
#define DEFAULT 265
#define GOTO 266
#define ELSE 267
#define WHILE 268
#define BREAK 269
#define CHAR 270
#define DOUBLE 271
#define RETURN 272
#define CASE 273
#define CONTINUE 274
#define PRINTF 275
#define ID 276
#define ADDOP 277
#define MULOP 278
#define INCOP 279
#define RELOP 280
#define LOGICOP 281
#define ASSIGNOP 282
#define NOT 283
#define LPAREN 284
#define RPAREN 285
#define LCURL 286
#define RCURL 287
#define LTHIRD 288
#define RTHIRD 289
#define COMMA 290
#define COLON 291
#define SEMICOLON 292
#define CONST_FLOAT 293
#define CONST_INT 294
#define DECOP 295



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;

#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
