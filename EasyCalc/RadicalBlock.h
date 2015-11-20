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

@interface RadicalBlock : CALayer
@property EquationBlock *content;
@property (weak) id parent;
@property (weak) Equation *ancestor;
@property int guid;
@property NSUInteger c_idx;
@property int roll;
@property int is_base_expo;

-(id) init : (Equation *)e;
-(id) init : (CGPoint)inputPos : (Equation *)e;
-(void) updateFrame;
-(void) destroy;
@end
