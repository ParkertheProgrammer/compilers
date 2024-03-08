CXX := g++

SRCS := cmos.cpp
TARGET := cmos
LEXYY := lex.yy.c

all: $(TARGET) lexer scanner

$(TARGET): $(SRCS)
	$(CXX) $^ -o cmos

lexer: cmos.l
	lex cmos.l

scanner: lexer
	$(CXX) $(LEXYY) -o scanner


clean:
	rm -f $(LEXYY) scanner $(TARGET) *.txt