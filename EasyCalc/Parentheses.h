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
@property int is_base_expo;
@property int l_or_r;
@property EquationBlock *expo;
@property CGRect mainFrame;
@property int fontLvl;

-(id) init :(CGPoint)inputPos :(Equation *)E :(int)l_r :(ViewController *)vc;
- (void)updateCopyBlock:(Equation *)e;
-(void) updateFrameBaseOnBase;
-(void) updateFrameBaseOnExpo;
-(void) destroy;
@end
