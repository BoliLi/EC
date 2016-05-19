//
//  WrapedEqTxtLyr.h
//  EasyCalc
//
//  Created by LiBoli on 16/2/3.
//  Copyright © 2016年 LiBoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class EquationBlock;
@class Equation;
@class Parentheses;

@interface WrapedEqTxtLyr : NSObject <NSCoding, NSCopying>
@property (weak) id parent;
@property (weak) Equation *ancestor;
@property int guid;
@property NSUInteger c_idx;
@property int roll;
@property CATextLayer *title;
@property EquationBlock *content;
@property Parentheses *left_parenth;
@property Parentheses *right_parenth;
@property CGRect mainFrame;
@property int fontLvl;
@property BOOL isCopy;

-(id) init :(NSString *)pfx :(Equation *)E :(ViewController *)vc;
-(void) updateFrame:(BOOL)updateParenth;
- (void)updateSize:(int)lvl;
- (void)updateCopyBlock:(Equation *)e;
-(void) moveCopy:(CGPoint)dest;
-(void) reorganize :(Equation *)anc :(ViewController *)vc :(int)chld_idx :(id)par;
-(void) updateFrameWidth : (CGFloat)incrWidth : (int)r;
-(void) updateCalcBoardInfo;
-(EquationTextLayer *) lookForEmptyTxtLyr;
-(void) destroy;

@end
