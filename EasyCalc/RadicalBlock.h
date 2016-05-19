//
//  RadicalBlock.h
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class Equation;
@class EquationBlock;
@class EquationTextLayer;

@interface RadicalBlock : CALayer <NSCoding, NSCopying>
@property EquationBlock *content;
@property (weak) id parent;
@property (weak) Equation *ancestor;
@property int guid;
@property NSUInteger c_idx;
@property int roll;
@property EquationTextLayer *rootNum;
@property int fontLvl;
@property BOOL isCopy;
@property CGRect mainFrame;

//-(id) init :(Equation *)e :(ViewController *)vc;
-(id) init : (Equation *)e :(ViewController *)vc;
- (void)updateSize:(int)lvl;
- (void)updateCopyBlock:(Equation *)e;
-(void) updateFrame;
-(void) moveCopy:(CGPoint)dest;
-(void) reorganize :(Equation *)anc :(ViewController *)vc :(int)chld_idx :(id)par;
-(void) updateFrameWidth : (CGFloat)incrWidth : (int)r;
-(void) updateCalcBoardInfo;
-(EquationTextLayer *) lookForEmptyTxtLyr;
-(void) destroy;
@end
