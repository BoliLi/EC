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

@interface EquationTextLayer : CATextLayer <NSCoding, NSCopying>
@property (weak) id parent;
@property (weak) Equation *ancestor;
@property int guid;
@property NSUInteger c_idx;
@property int roll;
@property EquationBlock *expo;
@property CGRect mainFrame;
@property int type;
@property NSMutableArray *strLenTbl;
@property int fontLvl;
@property BOOL isCopy;
@property NSDate *timeStamp;
@property NSMutableString *pureStr;
@property BOOL hasFraction;

//-(id) init : (Equation *)e;
-(id) init : (NSString *)str : (Equation *)e : (int)t;
//-(CGFloat) fillEmptyLayer:(NSString *)str oftype:(int)t;
-(CGFloat) addNumStr:(NSString *)str;
-(CGFloat) insertNumChar:(NSString *)str at:(int)idx;
-(CGFloat) delNumCharAt:(int)idx;
-(int) getTxtInsIdx: (CGPoint) p;
-(void) updateFrameBaseOnBase;
-(void) updateFrameBaseOnExpo;
-(BOOL) isExpoEmpty;
-(void) updateStrLenTbl;
- (void)updateSize:(int)lvl;
- (void)updateCopyBlock:(Equation *)e;
-(void) moveFrom:(CGPoint)orgF :(CGPoint)desF;
-(void) moveCopy:(CGPoint)dest;
-(void) reorganize :(Equation *)anc :(ViewController *)vc :(int)chld_idx :(id)par;
-(void) updateFrameWidth : (CGFloat)incrWidth : (int)r;
-(void) updateCalcBoardInfo;
-(EquationTextLayer *) lookForEmptyTxtLyr;
-(void) shake;
-(CGFloat) replaceWithEmpty;
-(BOOL) isAllowed;
-(void) handleDelete;

-(void) destroyWithAnim;
-(void) destroy;

@end
