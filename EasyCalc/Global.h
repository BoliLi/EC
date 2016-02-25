//
//  Global.h
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#ifndef Global_h
#define Global_h
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "ViewController.h"


#define TEXTLAYER_SPACING 3.0
#define TEXTLAYER_NUM 0
#define TEXTLAYER_OP 1
#define TEXTLAYER_EMPTY 2
#define TEXTLAYER_PARENTH 3
#define ROLL_ROOT 0
#define ROLL_NUMERATOR 1
#define ROLL_DENOMINATOR 2
#define ROLL_ROOT_ROOT 3
#define ROLL_EXPO_ROOT 4
#define ROLL_WRAP_ROOT 5

#define LEFT_PARENTH 0
#define RIGHT_PARENTH 1

#define IS_BASE 0
#define IS_EXPO 1

#define NUMER_NOT_EXISTS 0
#define NUMER_EMPTY 1
#define NUMER_NOT_EMPTY 3
#define DENOM_NOT_EXISTS 0
#define DENOM_EMPTY 1
#define DENOM_NOT_EMPTY 3

#define MODE_INPUT 0
#define MODE_INSERT 1
#define MODE_DUMP_ROOT 2
#define MODE_DUMP_RADICAL 3
#define MODE_DUMP_EXPO 4
#define MODE_DUMP_WETL 5
#define RADICAL_MARGINE_T 3.0
#define RADICAL_MARGINE_B 1.0
#define RADICAL_MARGINE_L_PERC 0.502
#define RADICAL_MARGINE_R 2.0
#define CIDX_0_NUMER 100000

#define BASECHARHIGHT 23.9
#define CURSOR_W 3.0

extern NSMutableArray *gEquationList;
extern NSInteger gCurEqIdx;
extern Equation *gCurE;
extern CGFloat gBaseCharWidthTbl[3][16];
extern CGFloat gExpoCharWidthTbl[3][16];

@interface NSMutableArray (Reverse)
- (void)reverse;
@end


void drawFrame(ViewController *vc, UIView *view, EquationBlock *parentBlock);
int getBaseFontSize(int level);
void initCharWidthTbl(void);
CGFloat getCharWidth(int level, int base_expo, NSString *s);
#endif /* Global_h */
