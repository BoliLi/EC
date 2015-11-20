//
//  Equation.h
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DisplayView.h"
#import "ViewController.h"

@class EquationTextLayer;
@class EquationBlock;

@interface Equation : NSObject
@property int guid_cnt;
@property EquationBlock *root;
@property CGPoint curPoint;
@property id curParent;
@property id curBlock;
@property EquationTextLayer *curTextLayer;
@property int curRoll;
@property int curMode;
@property UIFont *baseFont;
@property UIFont *superscriptFont;
@property UIFont *curFont;
@property CGFloat baseCharWidth;
@property CGFloat baseCharHight;
@property CGFloat expoCharWidth;
@property CGFloat expoCharHight;
@property CGFloat curFontH;
@property CGFloat curFontW;
@property NSUInteger insertCIdx;
@property BOOL needX;
@property DisplayView *view;
@property BOOL needNewLayer;

-(id) init;
-(id) init : (CGPoint)rootPos : (CGRect)dspFrame : (CGRect)cursorFrame : (ViewController *)vc;
-(void) dumpObj : (EquationBlock *)parentBlock;
-(void) dumpEverything : (EquationBlock *)eb;
-(id) lookForElementByPoint : (EquationBlock *)rootB : (CGPoint) point;
-(void) adjustEveryThing : (EquationBlock *)parentBlock;
@end
