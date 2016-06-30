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

#define TEXTLAYER_NUM 0
#define TEXTLAYER_OP 1
#define TEXTLAYER_EMPTY 2

#define ROLL_ROOT 0
#define ROLL_NUMERATOR 1
#define ROLL_DENOMINATOR 2
#define ROLL_ROOT_ROOT 3
#define ROLL_EXPO_ROOT 4
#define ROLL_WRAP_ROOT 5
#define ROLL_ROOT_NUM 6

#define LEFT_PARENTH 0
#define RIGHT_PARENTH 1

#define PARENTH_HW_R 5.0
#define FRACTION_BAR_H_R 3.0

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
#define MODE_REPLACE_ROOT 6
#define MODE_REPLACE_RADICAL 7
#define MODE_REPLACE_EXPO 8
#define MODE_REPLACE_WETL 9

#define RADICAL_MARGINE_T 3.0
#define RADICAL_MARGINE_B 1.0
#define RADICAL_MARGINE_L_PERC 0.502
#define RADICAL_MARGINE_R 2.0
#define CIDX_0_NUMER 100000

#define BASECHARHIGHT 23.9
#define CURSOR_W 3.0

#define INPUT_NUM_BIT (1)
#define INPUT_OP_BIT (1 << 1)
#define INPUT_EMPTY_BIT (1 << 2)
#define INPUT_RADICAL_BIT (1 << 3)
#define INPUT_WETL_BIT (1 << 4)
#define INPUT_PARENTH_BIT (1 << 5)
#define INPUT_DOT_BIT (1 << 6)
#define INPUT_EB_BIT (1 << 7)
#define INPUT_EXPO_BIT (1 << 8)
#define INPUT_ALL_BIT (INPUT_NUM_BIT | INPUT_OP_BIT | INPUT_EMPTY_BIT | INPUT_RADICAL_BIT | INPUT_WETL_BIT | INPUT_PARENTH_BIT | INPUT_DOT_BIT | INPUT_EB_BIT | INPUT_EXPO_BIT)

#define CLR_BIT(x, y) ((x) &= ~(y))
#define SET_BIT(x, y) ((x) |= (y))
#define TEST_BIT(x, y) ((x) & (y))

#define MAX_FONT_SIZE_LEVEL 3
#define MAX_SETTING_FONT_LEVEL 4

extern NSMutableArray *gCalcBoardList;
extern NSInteger gCurCBIdx;
extern CalcBoard *gCurCB;
extern CGFloat gCharWidthTbl[5][4][20];
extern CGFloat gCharHeightTbl[5][4];
extern NSMutableArray *gTemplateList;
extern UIColor *gDspBGColor;
extern UIColor *gDspFontColor;
extern UIColor *gKbBGColor;
extern UIColor *gBtnBGColor;
extern UIColor *gBtnFontColor;
extern BOOL gSettingThousandSeperator;
extern int gSettingMaxFractionDigits;
extern NSNumber *gSettingMaxDecimal;
extern int gSettingMainFontLevel;
extern NSMutableArray *gTimeTable;

@interface NSMutableArray (EasyCalc)
- (void)reverse;
@end

@interface UIButton (EasyCalc)
- (UIImage *) buttonImageFromColor:(UIColor *)color;
@end

void drawFrame(ViewController *vc, UIView *view, EquationBlock *parentBlock);
int getFontSize(int settingFontLvl, int fontSizeLvl);
CGFloat getLineWidth(int settingFontLvl, int fontSizeLvl);
void initCharSizeTbl(void);
CGFloat getCharWidth(int settingFontLvl, int fontSizeLvl, NSString *s);
void drawStrLenTable(ViewController *vc, UIView *view, EquationTextLayer *etl);
UIFont *getFont(int settingFontLvl, int fontSizeLvl);
#endif /* Global_h */
