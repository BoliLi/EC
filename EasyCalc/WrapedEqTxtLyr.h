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

@interface WrapedEqTxtLyr : NSObject <NSCoding, NSCopying>
@property (weak) id parent;
@property (weak) Equation *ancestor;
@property int guid;
@property NSUInteger c_idx;
@property int roll;
@property CATextLayer *prefix;
@property EquationBlock *content;
@property CATextLayer *suffix;
@property CGRect mainFrame;
@property int is_base_expo;

-(id) init : (NSString *)str : (CGPoint)inputPos : (Equation *)E;
@end
