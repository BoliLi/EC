//
//  EquationBlock.h
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FractionBarLayer;

@interface EquationBlock : NSObject <NSCoding, NSCopying>
@property NSMutableArray *children;
@property CGRect mainFrame;
@property CGRect numerFrame;
@property CGRect denomFrame;
@property FractionBarLayer *bar;
@property (weak) id parent;
@property (weak) Equation *ancestor;
@property int guid;
@property NSUInteger c_idx;
@property int roll;
@property CGFloat numerTopHalf;
@property CGFloat numerBtmHalf;
@property CGFloat denomTopHalf;
@property CGFloat denomBtmHalf;
@property int is_base_expo;
@property int fontLvl;
@property BOOL isCopy;

-(id) init : (Equation *)e;
-(id) init : (CGPoint)inputPos : (Equation *)e;
-(void) updateFrame : (CGRect)frame : (int)r;
-(void) updateFrameWidth : (CGFloat)incrWidth : (int)r;
-(void) updateFrameHeightS2 : (CGFloat)newH : (int)r;
-(void) updateFrameHeightS1 : (id)child;
-(void) updateCIdx;
-(void) destroy;
-(void) moveUp : (CGFloat)distance;
-(void) adjustElementPosition;
-(void) reorganize : (Equation *)anc : (ViewController *)vc;
- (void)updateSize:(int)lvl;
- (void)updateCopyBlock:(Equation *)e;
- (void)copyChildrenTo:(EquationBlock *)newEB;
-(void) moveCopy:(CGPoint)dest;
@end
