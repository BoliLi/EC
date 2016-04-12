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
@property int is_base_expo;
@property EquationTextLayer *rootNum;
@property int fontLvl;

-(id) init :(Equation *)e :(ViewController *)vc;
-(id) init : (CGPoint)inputPos : (Equation *)e : (int)rootCnt :(ViewController *)vc;
- (void)updateSize:(int)lvl;
- (void)updateCopyBlock:(Equation *)e;
-(void) updateFrame;
-(void) destroy;
@end
