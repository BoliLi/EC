//
//  Parentheses.h
//  EasyCalc
//
//  Created by LiBoli on 16/2/25.
//  Copyright © 2016年 LiBoli. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class Equation;

@interface Parentheses : CALayer <NSCoding, NSCopying>
@property (weak) id parent;
@property (weak) Equation *ancestor;
@property int guid;
@property NSUInteger c_idx;
@property int roll;
@property int l_or_r;
@property EquationBlock *expo;
@property CGRect mainFrame;
@property int fontLvl;
@property BOOL isCopy;
@property NSDate *timeStamp;

-(id) init :(Equation *)E :(int)l_r :(ViewController *)vc;
- (void)updateCopyBlock:(Equation *)e;
-(void) updateFrameBaseOnBase;
-(void) updateFrameBaseOnExpo;
-(void) moveCopy:(CGPoint)dest;
-(void) reorganize :(Equation *)anc :(ViewController *)vc :(int)chld_idx :(id)par;
-(void) updateFrameWidth : (CGFloat)incrWidth : (int)r;
-(void) updateCalcBoardInfo;
-(EquationTextLayer *) lookForEmptyTxtLyr;
-(void) shake;
-(BOOL) isAllowed;
-(void) destroy;
-(void) destroyWithAnim;
@end
