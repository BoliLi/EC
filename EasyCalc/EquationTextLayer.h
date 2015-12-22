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
@property EquationBlock *expo;
@property CGRect mainFrame;
@property int is_base_expo;
@property int type;
@property NSMutableArray *strLenTbl;

-(id) init : (Equation *)e;
-(id) init : (NSString *)str : (CGPoint)org : (Equation *)e : (int)t;
-(CGFloat) fillEmptyLayer:(NSString *)str oftype:(int)t;
-(CGFloat) addNumChar:(NSString *)str;
-(CGFloat) insertNumChar:(NSString *)str at:(int)idx;
-(CGFloat) delNumCharAt:(int)idx;
-(int) getTxtInsIdx: (CGPoint) p;
-(void) updateFrameBaseOnBase;
-(void) updateFrameBaseOnExpo;
-(BOOL) isExpoEmpty;
-(void) destroy;
@end
