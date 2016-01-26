//
//  FractionBarLayer.h
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface FractionBarLayer : CALayer <NSCoding>

@property int guid;
@property NSUInteger c_idx;
@property (weak) id parent;
@property (weak) Equation *ancestor;
@property int is_base_expo;

-(id) init : (Equation *)e;
-(void) destroy;
@end
