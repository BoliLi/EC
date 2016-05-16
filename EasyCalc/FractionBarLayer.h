//
//  FractionBarLayer.h
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface FractionBarLayer : CALayer <NSCoding, NSCopying>

@property int guid;
@property NSUInteger c_idx;
@property (weak) id parent;
@property (weak) Equation *ancestor;
@property int fontLvl;
@property BOOL isCopy;

-(id) init :(Equation *)e :(ViewController *)vc;
- (void)updateCopyBlock:(Equation *)e;
-(void) moveCopy:(CGPoint)dest;
-(void) reorganize :(Equation *)anc :(ViewController *)vc :(int)chld_idx :(id)par;
-(EquationTextLayer *) lookForEmptyTxtLyr;
-(void) destroy;

@end
