//
//  CalcBoard.h
//  EasyCalc
//
//  Created by LiBoli on 16/3/30.
//  Copyright © 2016年 LiBoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Equation;
@class DisplayView;
@class EquationTextLayer;
@class ViewController;
@class EquationBlock;

@interface CalcBoard : NSObject <NSCoding>
@property DisplayView *view;
@property NSMutableArray *eqList;
@property Equation *curEq;
@property CGPoint downLeftBasePoint;
@property id curParent;
@property id curBlk;
@property EquationTextLayer *curTxtLyr;
@property int curRoll;
@property int curMode;
@property UIFont *curFont;
@property CGFloat curFontH;
@property CGFloat curFontW;
@property NSUInteger insertCIdx;
@property int txtInsIdx;
@property int curFontLvl;
@property int allowInputBitMap;

-(id) init : (CGPoint)downLeft : (CGRect)dspFrame : (ViewController *)vc;
-(void) resetParam;
-(void)updateFontInfo: (int)lvl :(int)settingFontLvl;
-(void) reorganize : (ViewController *)vc;
-(void) insertTemplate :(EquationBlock *)rootBlk :(ViewController *)vc;
-(void)adjustEquationHistoryPostion;
@end
