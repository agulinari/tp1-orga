#!/usr/bin/env bash


function TestDefault () {
  echo "Test Default"
  ../src/tp1 -o temp.pgm;
  DIFF=$(diff temp.pgm default.pgm); 
  if [ "$DIFF" != "" ]
  then
    echo "Test failed: $DIFF";
  else
    echo "Test passed";
  fi 
  rm temp.pgm
}

function TestPuntoPertenece() {
  echo "Test Punto Pertenece"
  ../src/tp1 -c 0.01+0i -r 1x1 -o temp.pgm;
  DIFF=$(diff temp.pgm punto_pertenece.pgm); 
  if [ "$DIFF" != "" ]
  then
    echo "Test failed: $DIFF";
  else
    echo "Test passed";
  fi
  rm temp.pgm
}

function TestPuntoNoPertenece() {
  echo "Test Punto No Pertenece"
  ../src/tp1 -c 10+0i -r 1x1 -o temp.pgm;
  DIFF=$(diff temp.pgm punto_no_pertenece.pgm); 
  if [ "$DIFF" != "" ]
  then
    echo "Test failed: $DIFF";
  else
    echo "Test passed";
  fi
  rm temp.pgm
}

function Test1() {
  echo "Test 1"
  ../src/tp1 -C 0.285+0i -o temp.pgm;
  DIFF=$(diff temp.pgm uno.pgm); 
  if [ "$DIFF" != "" ]
  then
    echo "Test failed: $DIFF";
  else
    echo "Test passed";
  fi
  rm temp.pgm
}

function Test2() {
  echo "Test 2"
  ../src/tp1 -C -0.8+0.156i -o temp.pgm;
  DIFF=$(diff temp.pgm dos.pgm); 
  if [ "$DIFF" != "" ]
  then
    echo "Test failed: $DIFF";
  else
    echo "Test passed";
  fi
  rm temp.pgm
}

function Test3() {
  echo "Test 3"
  ../src/tp1 -C 0+0.8i -o temp.pgm;
  DIFF=$(diff temp.pgm tres.pgm); 
  if [ "$DIFF" != "" ]
  then
    echo "Test failed: $DIFF";
  else
    echo "Test passed";
  fi
  rm temp.pgm
}

function Test2Zoom() {
  echo "Test 2 Zoom"
  ../src/tp1 -C -0.8+0.156i -w 0.5 -H 0.5 -o temp.pgm;
  DIFF=$(diff temp.pgm dos_zoom.pgm); 
  if [ "$DIFF" != "" ]
  then
    echo "Test failed: $DIFF";
  else
    echo "Test passed";
  fi
  rm temp.pgm
}


TestDefault
TestPuntoPertenece
TestPuntoNoPertenece
Test1
Test2
Test2Zoom
Test3


