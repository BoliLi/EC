//
//  EquationTextLayer.h
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class EquationBlock;

@interface EquationTextLayer : CATextLayer
@property (weak) id parent;
@property (weak) Equation *ancestor;
@property int guid;
@property NSUInteger c_idx;
@property int roll;
@property CGFloat expo_width;
@property CGFloat base_width;
@property int base_len;
@property EquationBlock *expo;
@property CGRect mainFrame;
@property int is_base_expo;
@property int type;

-(id) init : (Equation *)e;
-(id) init : (NSString *)str : (CGPoint)org : (Equation *)e : (int)t;
-(void) updateFrameBaseOnBase;
-(void) updateFrameBaseOnExpo;
-(void) destroy;
@end
