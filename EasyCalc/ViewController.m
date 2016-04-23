//
//  ViewController.m
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Easing.h"
#import "Global.h"
#import "Utils.h"
#import "Equation.h"
#import "EquationBlock.h"
#import "EquationTextLayer.h"
#import "RadicalBlock.h"
#import "FractionBarLayer.h"
#import "WrapedEqTxtLyr.h"
#import "Parentheses.h"
#import "CalcBoard.h"

static UIView *testview;

@interface ViewController ()

@end

@implementation ViewController
@synthesize mainKbView;
@synthesize secondKbView;
@synthesize kbConView;
@synthesize dspConView;
@synthesize borderLayer;
@synthesize scnWidth;
@synthesize scnHeight;
@synthesize statusBarHeight;
@synthesize testeb;
@synthesize delBtnLongPressTmr;

-(void)handleTap: (UITapGestureRecognizer *)gesture {
    //NSUInteger touchNum = [gesture numberOfTouches];
    //NSUInteger tapNum = [gesture numberOfTapsRequired];
    CGPoint curPoint = [gesture locationOfTouch:0 inView: gCurCB.view];
    Equation *curEq = gCurCB.curEq;
    NSLog(@"%s%i~[%.1f, %.1f]~~~~~~~~~~", __FUNCTION__, __LINE__, curPoint.x, curPoint.y);
    id b = [curEq lookForElementByPoint:curEq.root :curPoint];
    if (b != nil) {
        cfgEqnBySlctBlk(curEq, b, curPoint);
    } else { //Tap outside current equation
        id b;
        Equation *eq;
        for (eq in gCurCB.eqList) {
            b = [eq lookForElementByPoint:eq.root :curPoint];
            if (b != nil) {
                break;
            }
        }
        
        if (b != nil) {
            if ([b isMemberOfClass: [Parentheses class]]) { // do not handle parenth
                return;
            }
            
            id copyBlock = [b copy];
            CGFloat incrWidth = 0.0;
            
            if (gCurCB.curTxtLyr != nil && gCurCB.curTxtLyr.type == TEXTLAYER_EMPTY) {
                if (gCurCB.curTxtLyr.expo == nil) {
                    EquationBlock *cb = gCurCB.curParent;
                    [gCurCB.curTxtLyr destroy];
                    [cb.children removeObjectAtIndex:gCurCB.curTxtLyr.c_idx];
                    [cb updateCIdx];
                    incrWidth -= gCurCB.curTxtLyr.mainFrame.size.width;
                    if ([copyBlock isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb = copyBlock;
                        
                        if (cb.roll == ROLL_ROOT) {
                            eb.isCopy = NO;
                            gCurCB.curMode = MODE_REPLACE_ROOT;
                        } else if (cb.roll == ROLL_ROOT_ROOT) {
                            gCurCB.curMode = MODE_REPLACE_RADICAL;
                        } else if (cb.roll == ROLL_WRAP_ROOT) {
                            gCurCB.curMode = MODE_REPLACE_WETL;
                        } else if (cb.roll == ROLL_EXPO_ROOT) {
                            gCurCB.curMode = MODE_REPLACE_EXPO;
                        } else {
                            
                        }
                    }
                } else if ([gCurCB.curTxtLyr.expo.children.firstObject isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *l = gCurCB.curTxtLyr.expo.children.firstObject;
                    if (l.type == TEXTLAYER_EMPTY && gCurCB.curTxtLyr.expo.children.count == 1) {
                        EquationBlock *cb = gCurCB.curParent;
                        [gCurCB.curTxtLyr destroy];
                        [cb.children removeObjectAtIndex:gCurCB.curTxtLyr.c_idx];
                        [cb updateCIdx];
                        incrWidth -= gCurCB.curTxtLyr.mainFrame.size.width;
                        if ([copyBlock isMemberOfClass:[EquationBlock class]]) {
                            EquationBlock *eb = copyBlock;
                            if (cb.roll == ROLL_ROOT) {
                                eb.isCopy = NO;
                                gCurCB.curMode = MODE_REPLACE_ROOT;
                            } else if (cb.roll == ROLL_ROOT_ROOT) {
                                gCurCB.curMode = MODE_REPLACE_RADICAL;
                            } else if (cb.roll == ROLL_WRAP_ROOT) {
                                gCurCB.curMode = MODE_REPLACE_WETL;
                            } else if (cb.roll == ROLL_EXPO_ROOT) {
                                gCurCB.curMode = MODE_REPLACE_EXPO;
                            } else {
                                
                            }
                        }
                    } else {
                        if ([copyBlock isMemberOfClass: [EquationTextLayer class]]) {
                            EquationTextLayer *etl = copyBlock;
                            if (etl.expo == nil && etl.type == TEXTLAYER_NUM) {
                                incrWidth -= gCurCB.curTxtLyr.frame.size.width;
                                [gCurCB.curTxtLyr addNumStr:[etl.string string]];
                                gCurCB.curTxtLyr.type = TEXTLAYER_NUM;
                                gCurCB.txtInsIdx = (int)gCurCB.curTxtLyr.strLenTbl.count - 1;
                                gCurCB.insertCIdx = gCurCB.curTxtLyr.c_idx + 1;
                                [etl destroy];
                                
                                incrWidth += etl.frame.size.width;
                                [(EquationBlock *)gCurCB.curParent updateFrameWidth:incrWidth :gCurCB.curRoll];
                                [gCurCB.curEq.root adjustElementPosition];
                                
                                gCurCB.view.cursor.frame = CGRectMake(gCurCB.curTxtLyr.frame.origin.x + gCurCB.curTxtLyr.frame.size.width, gCurCB.curTxtLyr.frame.origin.y, CURSOR_W, gCurCB.curTxtLyr.frame.size.height);
                                gCurCB.view.inpOrg = CGPointMake(gCurCB.curTxtLyr.frame.origin.x + gCurCB.curTxtLyr.frame.size.width, gCurCB.curTxtLyr.frame.origin.y);
                                
                                return;
                            } else {
                                return;
                            }
                        } else {
                            return;
                        }
                    }
                } else {
                    if ([copyBlock isMemberOfClass: [EquationTextLayer class]]) {
                        EquationTextLayer *etl = copyBlock;
                        if (etl.expo == nil && etl.type == TEXTLAYER_NUM) {
                            incrWidth -= gCurCB.curTxtLyr.frame.size.width;
                            [gCurCB.curTxtLyr addNumStr:[etl.string string]];
                            gCurCB.curTxtLyr.type = TEXTLAYER_NUM;
                            gCurCB.txtInsIdx = (int)gCurCB.curTxtLyr.strLenTbl.count - 1;
                            gCurCB.insertCIdx = gCurCB.curTxtLyr.c_idx + 1;
                            [etl destroy];
                            
                            incrWidth += etl.frame.size.width;
                            [(EquationBlock *)gCurCB.curParent updateFrameWidth:incrWidth :gCurCB.curRoll];
                            [gCurCB.curEq.root adjustElementPosition];
                            
                            gCurCB.view.cursor.frame = CGRectMake(gCurCB.curTxtLyr.frame.origin.x + gCurCB.curTxtLyr.frame.size.width, gCurCB.curTxtLyr.frame.origin.y, CURSOR_W, gCurCB.curTxtLyr.frame.size.height);
                            gCurCB.view.inpOrg = CGPointMake(gCurCB.curTxtLyr.frame.origin.x + gCurCB.curTxtLyr.frame.size.width, gCurCB.curTxtLyr.frame.origin.y);
                            
                            return;
                        } else {
                            return;
                        }
                    } else {
                        return;
                    }
                }
            }
            
            if(gCurCB.curMode == MODE_INPUT) {
                EquationBlock *block = gCurCB.curParent;
                
                [block.children addObject:copyBlock];
                [gCurCB.curParent updateCIdx];
            } else if(gCurCB.curMode == MODE_INSERT) {
                EquationBlock *block = gCurCB.curParent;
                
                [block.children insertObject:copyBlock atIndex:gCurCB.insertCIdx];
                [gCurCB.curParent updateCIdx];
            } else if(gCurCB.curMode == MODE_DUMP_ROOT) {
                Equation *eq = gCurCB.curEq;
                EquationBlock *newRoot = [[EquationBlock alloc] init:eq];
                newRoot.roll = ROLL_ROOT;
                newRoot.parent = nil;
                newRoot.numerFrame = eq.root.mainFrame;
                newRoot.numerTopHalf = eq.root.mainFrame.size.height / 2.0;
                newRoot.numerBtmHalf = eq.root.mainFrame.size.height / 2.0;
                newRoot.mainFrame = newRoot.numerFrame;
                eq.root.roll = ROLL_NUMERATOR;
                eq.root.parent = newRoot;
                if (gCurCB.insertCIdx == 0) {
                    [newRoot.children addObject:copyBlock];
                    [newRoot.children addObject:eq.root];
                    gCurCB.curMode = MODE_INSERT;
                } else {
                    [newRoot.children addObject:eq.root];
                    [newRoot.children addObject:copyBlock];
                    gCurCB.curMode = MODE_INPUT;
                }
                eq.root = newRoot;
                gCurCB.curParent = newRoot;
                [gCurCB.curParent updateCIdx];
                gCurCB.curRoll = ROLL_NUMERATOR;
            } else if(gCurCB.curMode == MODE_DUMP_RADICAL) {
                RadicalBlock *rBlock = gCurCB.curParent;
                EquationBlock *orgRootRoot = rBlock.content;
                EquationBlock *newRootRoot = [[EquationBlock alloc] init:gCurCB.curEq];
                newRootRoot.roll = ROLL_ROOT_ROOT;
                newRootRoot.parent = rBlock;
                newRootRoot.numerFrame = orgRootRoot.mainFrame;
                newRootRoot.numerTopHalf = orgRootRoot.mainFrame.size.height / 2.0;
                newRootRoot.numerBtmHalf = orgRootRoot.mainFrame.size.height / 2.0;
                newRootRoot.mainFrame = newRootRoot.numerFrame;
                orgRootRoot.roll = ROLL_NUMERATOR;
                orgRootRoot.parent = newRootRoot;
                if (gCurCB.insertCIdx == 0) {
                    [newRootRoot.children addObject:copyBlock];
                    [newRootRoot.children addObject:orgRootRoot];
                    gCurCB.curMode = MODE_INSERT;
                } else {
                    [newRootRoot.children addObject:orgRootRoot];
                    [newRootRoot.children addObject:copyBlock];
                    gCurCB.curMode = MODE_INPUT;
                }
                rBlock.content = newRootRoot;
                gCurCB.curParent = newRootRoot;
                [gCurCB.curParent updateCIdx];
                gCurCB.curRoll = ROLL_NUMERATOR;
            } else if(gCurCB.curMode == MODE_DUMP_EXPO) {
                EquationTextLayer *layer = gCurCB.curParent;
                EquationBlock *orgExpoRoot = layer.expo;
                EquationBlock *newExpoRoot = [[EquationBlock alloc] init:gCurCB.curEq];
                newExpoRoot.roll = ROLL_EXPO_ROOT;
                newExpoRoot.parent = layer;
                newExpoRoot.numerFrame = orgExpoRoot.mainFrame;
                newExpoRoot.numerTopHalf = orgExpoRoot.mainFrame.size.height / 2.0;
                newExpoRoot.numerBtmHalf = orgExpoRoot.mainFrame.size.height / 2.0;
                newExpoRoot.mainFrame = newExpoRoot.numerFrame;
                orgExpoRoot.roll = ROLL_NUMERATOR;
                orgExpoRoot.parent = newExpoRoot;
                if (gCurCB.insertCIdx == 0) {
                    [newExpoRoot.children addObject:copyBlock];
                    [newExpoRoot.children addObject:orgExpoRoot];
                    gCurCB.curMode = MODE_INSERT;
                } else {
                    [newExpoRoot.children addObject:orgExpoRoot];
                    [newExpoRoot.children addObject:copyBlock];
                    gCurCB.curMode = MODE_INPUT;
                }
                layer.expo = newExpoRoot;
                gCurCB.curParent = newExpoRoot;
                [gCurCB.curParent updateCIdx];
                gCurCB.curRoll = ROLL_NUMERATOR;
            } else if(gCurCB.curMode == MODE_DUMP_WETL) {
                WrapedEqTxtLyr *wetl = gCurCB.curParent;
                EquationBlock *orgWrapRoot = wetl.content;
                EquationBlock *newWrapRoot = [[EquationBlock alloc] init:gCurCB.curEq];
                newWrapRoot.roll = ROLL_WRAP_ROOT;
                newWrapRoot.parent = wetl;
                newWrapRoot.numerFrame = orgWrapRoot.mainFrame;
                newWrapRoot.numerTopHalf = orgWrapRoot.mainFrame.size.height / 2.0;
                newWrapRoot.numerBtmHalf = orgWrapRoot.mainFrame.size.height / 2.0;
                newWrapRoot.mainFrame = newWrapRoot.numerFrame;
                orgWrapRoot.roll = ROLL_NUMERATOR;
                orgWrapRoot.parent = newWrapRoot;
                if (gCurCB.insertCIdx == 0) {
                    [newWrapRoot.children addObject:copyBlock];
                    [newWrapRoot.children addObject:orgWrapRoot];
                    gCurCB.curMode = MODE_INSERT;
                } else {
                    [newWrapRoot.children addObject:orgWrapRoot];
                    [newWrapRoot.children addObject:copyBlock];
                    gCurCB.curMode = MODE_INPUT;
                }
                wetl.content = newWrapRoot;
                gCurCB.curParent = newWrapRoot;
                [gCurCB.curParent updateCIdx];
                gCurCB.curRoll = ROLL_NUMERATOR;
            } else if(gCurCB.curMode == MODE_REPLACE_ROOT) {
                [gCurCB.curEq.root destroy];
                gCurCB.curEq.root = copyBlock;
                gCurCB.curEq.root.c_idx = 0;
                gCurCB.curParent = nil;
                gCurCB.curRoll = ROLL_ROOT;
                gCurCB.curMode = MODE_DUMP_ROOT;
            } else if(gCurCB.curMode == MODE_REPLACE_RADICAL) {
                RadicalBlock *rb = ((EquationBlock *)gCurCB.curParent).parent;
                [rb.content destroy];
                rb.content = copyBlock;
                rb.content.c_idx = 0;
                gCurCB.curParent = rb;
                gCurCB.curRoll = ROLL_ROOT_ROOT;
                gCurCB.curMode = MODE_DUMP_RADICAL;
            } else if(gCurCB.curMode == MODE_REPLACE_WETL) {
                WrapedEqTxtLyr *wetl = ((EquationBlock *)gCurCB.curParent).parent;
                [wetl.content destroy];
                wetl.content = copyBlock;
                wetl.content.c_idx = 0;
                gCurCB.curParent = wetl;
                gCurCB.curRoll = ROLL_WRAP_ROOT;
                gCurCB.curMode = MODE_DUMP_WETL;
            } else if(gCurCB.curMode == MODE_REPLACE_EXPO) {
                EquationTextLayer *etl = ((EquationBlock *)gCurCB.curParent).parent;
                [etl.expo destroy];
                etl.expo = copyBlock;
                etl.expo.c_idx = 0;
                gCurCB.curParent = etl;
                gCurCB.curRoll = ROLL_EXPO_ROOT;
                gCurCB.curMode = MODE_DUMP_EXPO;
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            
            if ([copyBlock isMemberOfClass: [RadicalBlock class]]) {
                RadicalBlock *rb = copyBlock;
                
                rb.parent = gCurCB.curParent;
                rb.roll = gCurCB.curRoll;
                [rb updateSize:gCurCB.curFontLvl];
                [rb updateCopyBlock:curEq];
                gCurCB.insertCIdx = rb.c_idx + 1;
                gCurCB.curTxtLyr = nil;
                gCurCB.curBlk = rb;
                gCurCB.txtInsIdx = 1;
                
                incrWidth += rb.frame.size.width;
                [(EquationBlock *)gCurCB.curParent updateFrameWidth:incrWidth :gCurCB.curRoll];
                [(EquationBlock *)gCurCB.curParent updateFrameHeightS1:rb];
                [gCurCB.curEq.root adjustElementPosition];
                
                gCurCB.view.cursor.frame = CGRectMake(rb.frame.origin.x + rb.frame.size.width, rb.frame.origin.y, CURSOR_W, rb.frame.size.height);
                gCurCB.view.inpOrg = CGPointMake(rb.frame.origin.x + rb.frame.size.width, rb.frame.origin.y + rb.frame.size.height / 2.0 - gCurCB.curFontH / 2.0);
            } else if ([copyBlock isMemberOfClass: [FractionBarLayer class]]) {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            } else if ([copyBlock isMemberOfClass: [EquationTextLayer class]]) {
                EquationTextLayer *etl = copyBlock;
                
                etl.parent = gCurCB.curParent;
                etl.roll = gCurCB.curRoll;
                [etl updateSize:gCurCB.curFontLvl];
                [etl updateCopyBlock:curEq];
                gCurCB.insertCIdx = etl.c_idx + 1;
                gCurCB.curTxtLyr = etl;
                gCurCB.curBlk = etl;
                gCurCB.txtInsIdx = (int)etl.strLenTbl.count - 1;
                
                incrWidth += etl.mainFrame.size.width;
                [(EquationBlock *)gCurCB.curParent updateFrameWidth:incrWidth :gCurCB.curRoll];
                [(EquationBlock *)gCurCB.curParent updateFrameHeightS1:etl];
                [gCurCB.curEq.root adjustElementPosition];
                
                gCurCB.view.cursor.frame = CGRectMake(etl.mainFrame.origin.x + etl.mainFrame.size.width, etl.mainFrame.origin.y, CURSOR_W, etl.mainFrame.size.height);
                gCurCB.view.inpOrg = CGPointMake(etl.mainFrame.origin.x + etl.mainFrame.size.width, etl.mainFrame.origin.y);
            } else if ([copyBlock isMemberOfClass: [EquationBlock class]]) {
                EquationBlock *eb = copyBlock;
                
                eb.parent = gCurCB.curParent;
                eb.roll = gCurCB.curRoll;
                [eb updateSize:gCurCB.curFontLvl];
                [eb updateCopyBlock:curEq];
                gCurCB.insertCIdx = eb.c_idx + 1;
                gCurCB.curTxtLyr = nil;
                gCurCB.curBlk = eb;
                gCurCB.txtInsIdx = 1;
                
                if (eb.roll == ROLL_ROOT) {
                    CGRect f = eb.mainFrame;
                    f.origin.x = gCurCB.downLeftBasePoint.x;
                    f.origin.y = gCurCB.downLeftBasePoint.y - f.size.height - 1.0;
                    eb.mainFrame = f;
                } else if (eb.roll == ROLL_ROOT_ROOT) {
                    RadicalBlock *rb = eb.parent;
                    incrWidth = -rb.frame.size.width;
                    [rb updateFrame];
                    [rb setNeedsDisplay];
                    incrWidth += rb.frame.size.width;
                    NSLog(@"%s%i>~%.2f~~~~~~~~~~", __FUNCTION__, __LINE__, incrWidth);
                    [gCurCB.curEq dumpEverything:gCurCB.curEq.root];
                    [(EquationBlock *)rb.parent updateFrameWidth:incrWidth :rb.roll];
                    [gCurCB.curEq dumpEverything:gCurCB.curEq.root];
                    [(EquationBlock *)rb.parent updateFrameHeightS1:rb];
                    [gCurCB.curEq dumpEverything:gCurCB.curEq.root];
                } else if (eb.roll == ROLL_WRAP_ROOT) {
                    WrapedEqTxtLyr *wetl = eb.parent;
                    [wetl updateFrame:YES];
                    incrWidth += wetl.content.mainFrame.size.width;
                    [(EquationBlock *)wetl.parent updateFrameWidth:incrWidth :wetl.roll];
                    [(EquationBlock *)wetl.parent updateFrameHeightS1:wetl];
                } else if (eb.roll == ROLL_EXPO_ROOT) {
                    EquationTextLayer *etl = eb.parent;
                    [etl updateFrameBaseOnExpo];
                    incrWidth += etl.expo.mainFrame.size.width;
                    
                    [(EquationBlock *)etl.parent updateFrameWidth:incrWidth :etl.roll];
                    
                    [(EquationBlock *)etl.parent updateFrameHeightS1:etl];
                    
                } else {
                    incrWidth += eb.mainFrame.size.width;
                    [(EquationBlock *)gCurCB.curParent updateFrameWidth:incrWidth :gCurCB.curRoll];
                    [(EquationBlock *)gCurCB.curParent updateFrameHeightS1:eb];
                }
                
                [gCurCB.curEq.root adjustElementPosition];
                
                gCurCB.view.cursor.frame = CGRectMake(eb.mainFrame.origin.x + eb.mainFrame.size.width, eb.mainFrame.origin.y, CURSOR_W, eb.mainFrame.size.height);
                gCurCB.view.inpOrg = CGPointMake(eb.mainFrame.origin.x + eb.mainFrame.size.width, eb.mainFrame.origin.y + eb.mainFrame.size.height / 2.0 - gCurCB.curFontH / 2.0);
            } else if ([copyBlock isMemberOfClass: [WrapedEqTxtLyr class]]) {
                WrapedEqTxtLyr *wetl = copyBlock;
                
                wetl.parent = gCurCB.curParent;
                wetl.roll = gCurCB.curRoll;
                [wetl updateSize:gCurCB.curFontLvl];
                [wetl updateCopyBlock:curEq];
                gCurCB.insertCIdx = wetl.c_idx + 1;
                gCurCB.curTxtLyr = nil;
                gCurCB.curBlk = wetl;
                gCurCB.txtInsIdx = 1;
                
                incrWidth += wetl.mainFrame.size.width;
                [(EquationBlock *)gCurCB.curParent updateFrameWidth:incrWidth :gCurCB.curRoll];
                [(EquationBlock *)gCurCB.curParent updateFrameHeightS1:wetl];
                [gCurCB.curEq.root adjustElementPosition];
                
                gCurCB.view.cursor.frame = CGRectMake(wetl.mainFrame.origin.x + wetl.mainFrame.size.width, wetl.mainFrame.origin.y, CURSOR_W, wetl.mainFrame.size.height);
                gCurCB.view.inpOrg = CGPointMake(wetl.mainFrame.origin.x + wetl.mainFrame.size.width, wetl.mainFrame.origin.y + wetl.mainFrame.size.height / 2.0 - gCurCB.curFontH / 2.0);
            } else if ([copyBlock isMemberOfClass: [Parentheses class]]) {
                // do nothing
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            
            if ((int)gCurCB.curEq.maxRootHeight < (int)gCurCB.curEq.root.mainFrame.size.height) {
                CGFloat dis = gCurCB.curEq.root.mainFrame.size.height - gCurCB.curEq.maxRootHeight;
                gCurCB.curEq.maxRootHeight = gCurCB.curEq.root.mainFrame.size.height;
                for (Equation *eq in gCurCB.eqList) {
                    [eq moveUp:dis];
                }
            }
        } else {
            if (curEq.root.children.count != 0) {
                
                [gCurCB updateFontInfo:0];
                
                if (curEq.root.bar != nil) {//Root block has denominator
                    CGFloat tmp = curEq.root.mainFrame.size.height;
                    gCurCB.view.cursor.frame = CGRectMake(curEq.root.mainFrame.origin.x + curEq.root.mainFrame.size.width, curEq.root.mainFrame.origin.y, CURSOR_W, tmp);
                    CGFloat x = curEq.root.bar.frame.origin.x + curEq.root.bar.frame.size.width;
                    CGFloat y = curEq.root.numerFrame.origin.y + curEq.root.numerFrame.size.height - gCurCB.curFontH / 2.0;
                    gCurCB.view.inpOrg = CGPointMake(x, y);
                    gCurCB.curMode = MODE_DUMP_ROOT;
                    gCurCB.curTxtLyr = nil;
                    gCurCB.curBlk = curEq.root;
                    gCurCB.curRoll = ROLL_NUMERATOR;
                    gCurCB.insertCIdx = curEq.root.c_idx + 1;
                } else {
                    id block = [curEq.root.children lastObject];
                    if ([block isMemberOfClass: [EquationTextLayer class]]) {
                        EquationTextLayer *layer = block;
                        
                        gCurCB.curMode = MODE_INPUT;
                        
                        if (layer.type == TEXTLAYER_OP) {
                            CGFloat x = layer.frame.origin.x + layer.frame.size.width;
                            CGFloat y = layer.frame.origin.y;
                            gCurCB.view.inpOrg = CGPointMake(x, y);
                            CGFloat tmp = layer.frame.size.height;
                            gCurCB.view.cursor.frame = CGRectMake(gCurCB.view.inpOrg.x, gCurCB.view.inpOrg.y, CURSOR_W, tmp);
                            gCurCB.curTxtLyr = nil;
                            gCurCB.txtInsIdx = 1;
                        } else if (layer.type == TEXTLAYER_NUM) {
                            if (layer.expo == nil) {
                                CGFloat x = layer.frame.origin.x + layer.frame.size.width;
                                CGFloat y = layer.frame.origin.y;
                                gCurCB.view.inpOrg = CGPointMake(x, y);
                                CGFloat tmp = layer.frame.size.height;
                                gCurCB.view.cursor.frame = CGRectMake(gCurCB.view.inpOrg.x, gCurCB.view.inpOrg.y, CURSOR_W, tmp);
                                gCurCB.curTxtLyr = layer;
                                gCurCB.txtInsIdx = (int)gCurCB.curTxtLyr.strLenTbl.count - 1;
                            } else {
                                CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                                CGFloat y = layer.frame.origin.y;
                                gCurCB.view.inpOrg = CGPointMake(x, y);
                                CGFloat tmp = layer.mainFrame.size.height;
                                gCurCB.view.cursor.frame = CGRectMake(gCurCB.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                                gCurCB.curTxtLyr = nil;
                            }
                        } else if (layer.type == TEXTLAYER_EMPTY) {
                            if (layer.expo == nil) {
                                CGFloat x = layer.frame.origin.x;
                                CGFloat y = layer.frame.origin.y;
                                gCurCB.view.inpOrg = CGPointMake(x, y);
                                CGFloat tmp = layer.frame.size.height;
                                gCurCB.view.cursor.frame = CGRectMake(gCurCB.view.inpOrg.x, gCurCB.view.inpOrg.y, CURSOR_W, tmp);
                                gCurCB.curTxtLyr = layer;
                                gCurCB.txtInsIdx = 0;
                            } else {
                                CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                                CGFloat y = layer.frame.origin.y;
                                gCurCB.view.inpOrg = CGPointMake(x, y);
                                CGFloat tmp = layer.mainFrame.size.height;
                                gCurCB.view.cursor.frame = CGRectMake(gCurCB.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                                gCurCB.curTxtLyr = nil;
                            }
                        } else
                            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        gCurCB.curRoll = layer.roll;
                        gCurCB.curParent = layer.parent;
                        gCurCB.curBlk = layer;
                        gCurCB.insertCIdx = layer.c_idx + 1;
                    } else if ([block isMemberOfClass: [EquationBlock class]]) {
                        EquationBlock *b = block;
                        gCurCB.curMode = MODE_INPUT;
                        gCurCB.curParent = b.parent;
                        gCurCB.curRoll = b.roll;
                        gCurCB.curTxtLyr = nil;
                        gCurCB.curBlk = b;
                        gCurCB.insertCIdx = b.c_idx + 1;
                        CGFloat x = b.bar.frame.origin.x + b.bar.frame.size.width;
                        CGFloat y = b.numerFrame.origin.y + b.numerFrame.size.height - gCurCB.curFontH / 2.0;
                        gCurCB.view.inpOrg = CGPointMake(x, y);
                        CGFloat tmp = b.mainFrame.size.height;
                        gCurCB.view.cursor.frame = CGRectMake(gCurCB.view.inpOrg.x, b.mainFrame.origin.y, CURSOR_W, tmp);
                    } else if ([block isMemberOfClass: [RadicalBlock class]]) {
                        RadicalBlock *b = block;
                        gCurCB.curMode = MODE_INPUT;
                        gCurCB.curParent = b.parent;
                        gCurCB.curRoll = b.roll;
                        gCurCB.curTxtLyr = nil;
                        gCurCB.curBlk = b;
                        gCurCB.insertCIdx = b.c_idx + 1;
                        CGFloat x = b.frame.origin.x + b.frame.size.width;
                        CGFloat y = b.frame.origin.y + b.frame.size.height / 2.0 - gCurCB.curFontH / 2.0;
                        gCurCB.view.inpOrg = CGPointMake(x, y);
                        CGFloat tmp = b.frame.size.height;
                        gCurCB.view.cursor.frame = CGRectMake(gCurCB.view.inpOrg.x, b.frame.origin.y, CURSOR_W, tmp);
                    } else if ([block isMemberOfClass: [WrapedEqTxtLyr class]]) {
                        WrapedEqTxtLyr *wetl = block;
                        gCurCB.curMode = MODE_INPUT;
                        gCurCB.curParent = wetl.parent;
                        gCurCB.curRoll = wetl.roll;
                        gCurCB.curTxtLyr = nil;
                        gCurCB.curBlk = wetl;
                        gCurCB.insertCIdx = wetl.c_idx + 1;
                        CGFloat x = wetl.mainFrame.origin.x + wetl.mainFrame.size.width;
                        CGFloat y = wetl.mainFrame.origin.y + wetl.mainFrame.size.height / 2.0 - gCurCB.curFontH / 2.0;
                        gCurCB.view.inpOrg = CGPointMake(x, y);
                        gCurCB.view.cursor.frame = CGRectMake(x, wetl.mainFrame.origin.y, CURSOR_W, wetl.mainFrame.size.height);
                    } else if ([block isMemberOfClass: [Parentheses class]]) {
                        Parentheses *p = block;
                        gCurCB.curMode = MODE_INPUT;
                        gCurCB.curParent = p.parent;
                        gCurCB.curRoll = p.roll;
                        gCurCB.curTxtLyr = nil;
                        gCurCB.curBlk = p;
                        gCurCB.insertCIdx = p.c_idx + 1;
                        CGFloat x = p.mainFrame.origin.x + p.mainFrame.size.width;
                        CGFloat y = p.mainFrame.origin.y + p.mainFrame.size.height / 2.0 - gCurCB.curFontH / 2.0;
                        gCurCB.view.inpOrg = CGPointMake(x, y);
                        CGFloat tmp = p.mainFrame.size.height;
                        gCurCB.view.cursor.frame = CGRectMake(gCurCB.view.inpOrg.x, p.mainFrame.origin.y, CURSOR_W, tmp);
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                }
            }
        }
        
        [gCurCB.view updateContentView];
    }
}

-(void)handleDspViewSwipeRight: (UISwipeGestureRecognizer *)gesture {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:gCurCB];
    [user setObject:data forKey:[NSString stringWithFormat:@"calcboard%li", (long)gCurCBIdx]];
    
    DisplayView *orgView = gCurCB.view;
    gCurCBIdx--;
    if (gCurCBIdx < 0) {
        gCurCBIdx = 15;
    }
    gCurCB = [gCalcBoardList objectAtIndex:gCurCBIdx];
    [gCurCB.view.cursor removeAllAnimations];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"hidden"];
    anim.fromValue = [NSNumber numberWithBool:YES];
    anim.toValue = [NSNumber numberWithBool:NO];
    anim.duration = 0.5;
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    [gCurCB.view.cursor addAnimation:anim forKey:nil];
    [UIView transitionFromView:orgView toView:gCurCB.view duration:0.4 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        // What to do when its finished.
    }];
}

-(void)handleDspViewSwipeLeft: (UISwipeGestureRecognizer *)gesture {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:gCurCB];
    [user setObject:data forKey:[NSString stringWithFormat:@"calcboard%li", (long)gCurCBIdx]];
    NSLog(@"%s%i>~%@~~~~~~~~~~", __FUNCTION__, __LINE__, dspConView.subviews);
    DisplayView *orgView = gCurCB.view;
    gCurCBIdx++;
    gCurCBIdx %= 16;
    gCurCB = [gCalcBoardList objectAtIndex:gCurCBIdx];
    
    [gCurCB.view.cursor removeAllAnimations];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"hidden"];
    anim.fromValue = [NSNumber numberWithBool:YES];
    anim.toValue = [NSNumber numberWithBool:NO];
    anim.duration = 0.5;
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    [gCurCB.view.cursor addAnimation:anim forKey:nil];
    
    NSLog(@"%s%i>~%@~%@~%@~%@~%@~%@~~~~~", __FUNCTION__, __LINE__, NSStringFromCGRect(gCurCB.view.cursor.frame), NSStringFromCGPoint(gCurCB.view.inpOrg), orgView, gCurCB.view, gCurCB.view.subviews, gCurCB.view.layer.sublayers);
    [UIView transitionFromView:orgView toView:gCurCB.view duration:0.4 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
        // What to do when its finished.
    }];
    NSLog(@"%s%i>~%@~~~~~~~~~~", __FUNCTION__, __LINE__, dspConView.subviews);
}

-(void)handleKbViewSwipeRight: (UISwipeGestureRecognizer *)gesture {
    mainKbView.frame = CGRectMake(-scnWidth, 0, scnWidth, scnHeight / 2);
    mainKbView.alpha = 1.0;
    mainKbView.hidden = NO;
    [kbConView addSubview:mainKbView];
    
    [UIView animateWithDuration:.5 animations:^{
        
        [mainKbView setEasingFunction:CreateCAMediaTimingFunction(0.175, 0.885, 0.52, 1.25) forKeyPath:@"center"];
        secondKbView.alpha = 0.0;
        mainKbView.frame = CGRectOffset(mainKbView.frame, scnWidth, 0);
        
    } completion:^(BOOL finished) {
        [mainKbView removeEasingFunctionForKeyPath:@"center"];
        
    }];
}

-(void)handleKbViewSwipeLeft: (UISwipeGestureRecognizer *)gesture {
    secondKbView.frame = CGRectMake(scnWidth, 0, scnWidth, scnHeight / 2);
    secondKbView.alpha = 1.0;
    secondKbView.hidden = NO;
    [kbConView addSubview:secondKbView];
    
    [UIView animateWithDuration:.5 animations:^{
        
        [secondKbView setEasingFunction:CreateCAMediaTimingFunction(0.175, 0.885, 0.52, 1.25) forKeyPath:@"center"];
        mainKbView.alpha = 0.0;
        secondKbView.frame = CGRectOffset(secondKbView.frame, -scnWidth, 0);
        
    } completion:^(BOOL finished) {
        [secondKbView removeEasingFunctionForKeyPath:@"center"];
        
    }];
}

- (void)backGroundInit: (CalcBoard *)firstCB {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //Do background work
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString *ver = [user stringForKey:@"version"];
        if (ver != nil) {
            for (int i = 0; i < 16; i++) {
                if (i == gCurCBIdx) {
                    [gCalcBoardList addObject:firstCB];
                    continue;
                }
                CalcBoard *cb = [NSKeyedUnarchiver unarchiveObjectWithData:[user objectForKey:[NSString stringWithFormat: @"calcboard%li", (long)i]]];
                [cb.curEq.root reorganize:cb.curEq :self];
                
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
                tapGesture.numberOfTapsRequired = 1;
                tapGesture.numberOfTouchesRequired = 1;
                [cb.view addGestureRecognizer:tapGesture];
                
//                UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDspViewSwipeRight:)];
//                right.numberOfTouchesRequired = 1;
//                right.direction = UISwipeGestureRecognizerDirectionRight;
//                [eq.view addGestureRecognizer:right];
//                
//                UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDspViewSwipeLeft:)];
//                left.numberOfTouchesRequired = 1;
//                left.direction = UISwipeGestureRecognizerDirectionLeft;
//                [eq.view addGestureRecognizer:left];
                
                [cb.view.layer addSublayer:cb.view.cursor];
                cb.view.cursor.delegate = self;
                [cb.view.cursor setNeedsDisplay];
                [gCalcBoardList addObject:cb];
            }
        } else {
            [user setObject:@"1.0" forKey:@"version"];
            [user setInteger:gCurCBIdx forKey:@"gCurCBIdx"];
            
            [gCalcBoardList addObject:firstCB];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:firstCB];
            [user setObject:data forKey:@"calcboard0"];
            
            CGRect dspFrame = CGRectMake(0, 0, scnWidth, (scnHeight / 2) - statusBarHeight);
            CGPoint downLeft = CGPointMake(1, (scnHeight / 2) - statusBarHeight);
            for (int i = 1; i < 16; i++) {
                CalcBoard *cb = [[CalcBoard alloc] init:downLeft :dspFrame :self];
                [gCalcBoardList addObject:cb];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cb];
                [user setObject:data forKey:[NSString stringWithFormat:@"calcboard%li", (long)i]];
            }
            NSLog(@"%s%i>~%i~~~~~~~~~~", __FUNCTION__, __LINE__, [user synchronize]);
        }
        
        secondKbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scnWidth, scnHeight / 2)];
        secondKbView.backgroundColor = [UIColor whiteColor];
        
        UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleKbViewSwipeRight:)];
        right.numberOfTouchesRequired = 1;
        right.direction = UISwipeGestureRecognizerDirectionRight;
        [secondKbView addGestureRecognizer:right];
        
        UIFont *buttonFont = [UIFont systemFontOfSize: 30];
        NSArray *btnTitleArr = [NSArray arrayWithObjects:@"save", @"load", @"reset", @"C", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", nil];
        CGFloat btnHeight = scnHeight / 10;
        CGFloat btnWidth = scnWidth / 5;
        for (int i = 0; i < 25; i++) {
            UIButton *bn = [UIButton buttonWithType:UIButtonTypeSystem];
            bn.tag = i + 10;
            bn.titleLabel.font = buttonFont;
            bn.showsTouchWhenHighlighted = YES;
            [bn setTitle:[btnTitleArr objectAtIndex:i] forState:UIControlStateNormal];
            int j = i % 5;
            int k = i / 5;
            bn.frame = CGRectMake(j * btnWidth, k * btnHeight, btnWidth, btnHeight);
            [bn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [secondKbView addSubview:bn];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //Update UI
            
        });
        
    });
    
}

- (void)foreGroundInit: (CalcBoard *)firstCB {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *ver = [user stringForKey:@"version"];
#if 0
    if (ver != nil) {
#else
    if (0) {
#endif
        for (int i = 0; i < 16; i++) {
            if (i == gCurCBIdx) {
                [gCalcBoardList addObject:firstCB];
                continue;
            }
            CalcBoard *cb = [NSKeyedUnarchiver unarchiveObjectWithData:[user objectForKey:[NSString stringWithFormat: @"calcboard%li", (long)i]]];
            [cb.curEq.root reorganize:cb.curEq :self];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            tapGesture.numberOfTapsRequired = 1;
            tapGesture.numberOfTouchesRequired = 1;
            [cb.view addGestureRecognizer:tapGesture];
            
//            UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDspViewSwipeRight:)];
//            right.numberOfTouchesRequired = 1;
//            right.direction = UISwipeGestureRecognizerDirectionRight;
//            [cb.view addGestureRecognizer:right];
//            
//            UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDspViewSwipeLeft:)];
//            left.numberOfTouchesRequired = 1;
//            left.direction = UISwipeGestureRecognizerDirectionLeft;
//            [cb.view addGestureRecognizer:left];
            
            [cb.view.layer addSublayer:cb.view.cursor];
            cb.view.cursor.delegate = self;
            [cb.view.cursor setNeedsDisplay];
            [gCalcBoardList addObject:cb];
        }
    } else {
        [user setObject:@"1.0" forKey:@"version"];
        [user setInteger:gCurCBIdx forKey:@"gCurCBIdx"];
        
        [gCalcBoardList addObject:firstCB];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:firstCB];
        [user setObject:data forKey:@"calcboard0"];
        
        CGRect dspFrame = CGRectMake(0, 0, scnWidth, (scnHeight / 2) - statusBarHeight);
        CGPoint downLeft = CGPointMake(1, ((scnHeight / 2) - statusBarHeight) * 3.0);
        for (int i = 1; i < 16; i++) {
            CalcBoard *cb = [[CalcBoard alloc] init:downLeft :dspFrame :self];
            [gCalcBoardList addObject:cb];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cb];
            [user setObject:data forKey:[NSString stringWithFormat:@"calcboard%li", (long)i]];
        }
        NSLog(@"%s%i>~%i~~~~~~~~~~", __FUNCTION__, __LINE__, [user synchronize]);
    }
    
    secondKbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scnWidth, scnHeight / 2)];
    secondKbView.backgroundColor = [UIColor whiteColor];
    
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleKbViewSwipeRight:)];
    right.numberOfTouchesRequired = 1;
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [secondKbView addGestureRecognizer:right];
    
    UIFont *buttonFont = [UIFont systemFontOfSize: 30];
    NSArray *btnTitleArr = [NSArray arrayWithObjects:@"save", @"load", @"reset", @"C", @"COS", @"<", @">", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", nil];
    CGFloat btnHeight = scnHeight / 10;
    CGFloat btnWidth = scnWidth / 5;
    for (int i = 0; i < 25; i++) {
        UIButton *bn = [UIButton buttonWithType:UIButtonTypeSystem];
        bn.tag = i + 10;
        bn.titleLabel.font = buttonFont;
        bn.showsTouchWhenHighlighted = YES;
        [bn setTitle:[btnTitleArr objectAtIndex:i] forState:UIControlStateNormal];
        int j = i % 5;
        int k = i / 5;
        bn.frame = CGRectMake(j * btnWidth, k * btnHeight, btnWidth, btnHeight);
        [bn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [secondKbView addSubview:bn];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    initCharSizeTbl();
    
    scnWidth = [UIScreen mainScreen].bounds.size.width;
    scnHeight = [UIScreen mainScreen].bounds.size.height;
    statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    dspConView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, scnWidth, (scnHeight / 2) - statusBarHeight)];
    dspConView.tag = 1;
    dspConView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:dspConView];
    
    CGRect dspFrame = CGRectMake(0, 0, scnWidth, (scnHeight / 2) - statusBarHeight);
    CGPoint downLeft = CGPointMake(1, ((scnHeight / 2) - statusBarHeight) * 3.0);
    //CGRect cursorFrame = CGRectMake(1, rootPos.y, 0.0, 0.0); //Size will update in Equation init
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *ver = [user stringForKey:@"version"];
#if 0
    if (ver != nil) {
#else
    if (0) {
#endif
        NSLog(@"%s%i>~~~~~~~~~~~", __FUNCTION__, __LINE__);
        gCurCBIdx = [user integerForKey:@"gCurCBIdx"];
        gCurCB = [NSKeyedUnarchiver unarchiveObjectWithData:[user objectForKey:[NSString stringWithFormat: @"calcboard%li", (long)gCurCBIdx]]];
        [gCurCB.curEq.root reorganize:gCurCB.curEq :self];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [gCurCB.view addGestureRecognizer:tapGesture];
        
//        UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDspViewSwipeRight:)];
//        right.numberOfTouchesRequired = 1;
//        right.direction = UISwipeGestureRecognizerDirectionRight;
//        [gCurCB.view addGestureRecognizer:right];
//        
//        UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDspViewSwipeLeft:)];
//        left.numberOfTouchesRequired = 1;
//        left.direction = UISwipeGestureRecognizerDirectionLeft;
//        [gCurCB.view addGestureRecognizer:left];
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"hidden"];
        anim.fromValue = [NSNumber numberWithBool:YES];
        anim.toValue = [NSNumber numberWithBool:NO];
        anim.duration = 0.5;
        anim.autoreverses = YES;
        anim.repeatCount = HUGE_VALF;
        [gCurCB.view.cursor addAnimation:anim forKey:nil];
        [gCurCB.view.layer addSublayer:gCurCB.view.cursor];
        gCurCB.view.cursor.delegate = self;
        [gCurCB.view.cursor setNeedsDisplay];
    } else {
        NSLog(@"%s%i>~~~~~~~~~~~", __FUNCTION__, __LINE__);
//        for (int i = 0; i < 16; i++) {
//            gCurCB = [[Equation alloc] init:downLeft :dspFrame :self];
//            [gCalcBoardList addObject:gCurCB];
//            //[dspConView addSubview:gCurCB.view];
//        }
//        gCurCB = gCalcBoardList.firstObject;
        gCurCB = [[CalcBoard alloc] init:downLeft :dspFrame :self];
    }
    
    [self foreGroundInit:gCurCB];
    
    [dspConView addSubview:gCurCB.view];

    kbConView = [[UIView alloc] initWithFrame:CGRectMake(0, scnHeight / 2, scnWidth, scnHeight / 2)];
    kbConView.tag = 2;
    kbConView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:kbConView];
    
    mainKbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scnWidth, scnHeight / 2)];
    mainKbView.backgroundColor = [UIColor whiteColor];
    [kbConView addSubview:mainKbView];
    
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleKbViewSwipeLeft:)];
    left.numberOfTouchesRequired = 1;
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    [mainKbView addGestureRecognizer:left];
    
    borderLayer = [CALayer layer];
    borderLayer.contentsScale = [UIScreen mainScreen].scale;
    borderLayer.name = @"btnBorderLayer";
    borderLayer.backgroundColor = [UIColor clearColor].CGColor;
    borderLayer.frame = CGRectMake(0, 0, scnWidth, scnHeight / 2);
    borderLayer.delegate = self;
    [mainKbView.layer addSublayer: borderLayer];
    [borderLayer setNeedsDisplay];
    
    UIFont *buttonFont = [UIFont systemFontOfSize: 30];
    NSArray *btnTitleArr = [NSArray arrayWithObjects:@"DUMP", @"DEBUG", @"Root", @"<-", @"7", @"8", @"9", @"÷", @"4", @"5", @"6", @"×", @"1", @"2", @"3", @"-", @"%", @"0", @"·", @"+", @"x^", @"(", @")", @"=", nil];
    CGFloat btnHeight = scnHeight / 10;
    CGFloat btnWidth = scnWidth / 5;
    for (int i = 0; i < 20; i++) {
        UIButton *bn = [UIButton buttonWithType:UIButtonTypeSystem];
        bn.tag = i + 10;
        bn.titleLabel.font = buttonFont;
        bn.showsTouchWhenHighlighted = YES;
        [bn setTitle:[btnTitleArr objectAtIndex:i] forState:UIControlStateNormal];
        int j = i % 4;
        int k = i / 4;
        bn.frame = CGRectMake(j * btnWidth, k * btnHeight, btnWidth, btnHeight);
        [bn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 3) {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnDelLongPress:)];
            longPress.minimumPressDuration = 1; //定义按的时间
            [bn addGestureRecognizer:longPress];
        }
        [mainKbView addSubview:bn];
    }
    
    for (int i = 20; i < 23; i++) {
        UIButton *bn = [UIButton buttonWithType:UIButtonTypeSystem];
        bn.tag = i + 10;
        bn.titleLabel.font = buttonFont;
        bn.showsTouchWhenHighlighted = YES;
        [bn setTitle:[btnTitleArr objectAtIndex:i] forState:UIControlStateNormal];
        int k = i % 4;
        bn.frame = CGRectMake(4 * btnWidth, k * btnHeight, btnWidth, btnHeight);
        [bn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [mainKbView addSubview:bn];
    }
    
    UIButton *bn = [UIButton buttonWithType:UIButtonTypeSystem];
    bn.tag = 33;
    bn.titleLabel.font = buttonFont;
    bn.showsTouchWhenHighlighted = YES;
    [bn setTitle:[btnTitleArr objectAtIndex: 23] forState:UIControlStateNormal];
    bn.frame = CGRectMake(4 * btnWidth, 3 * btnHeight, btnWidth, 2 * btnHeight);
    [bn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [mainKbView addSubview:bn];
    
    NSLog(@"%s%i>~%@~~~~~~~~~~", __FUNCTION__, __LINE__, NSStringFromCGRect(gCurCB.view.bounds));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleNumBtnClick : (NSString *)num {
    CGFloat incrWidth = 0.0;
    CGFloat cursorOffset = 0.0;
    BOOL needNewLayer;
    
    if (gCurCB.curTxtLyr == nil) {
        if ([gCurCB.curBlk isMemberOfClass:[EquationBlock class]]) {
            EquationBlock *eb = gCurCB.curBlk;
            if ([eb.parent isMemberOfClass:[RadicalBlock class]]) {
                needNewLayer = YES;
            } else if ([eb.parent isMemberOfClass:[WrapedEqTxtLyr class]]) {
                needNewLayer = YES;
            } else if ([eb.parent isMemberOfClass:[EquationBlock class]]) {
                EquationBlock *par = eb.parent;
                if (gCurCB.insertCIdx == eb.c_idx) {
                    if (eb.c_idx == 0) {
                        needNewLayer = YES;
                    } else {
                        id b = [par.children objectAtIndex:eb.c_idx - 1];
                        if ([b isMemberOfClass:[EquationTextLayer class]]) {
                            EquationTextLayer *l = b;
                            if (l.type == TEXTLAYER_NUM) {
                                if (l.expo == nil) {
                                    needNewLayer = NO;
                                    cfgEqnBySlctBlk(gCurCB.curEq, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                                } else {
                                    needNewLayer = YES;
                                }
                            } else {
                                needNewLayer = YES;
                            }
                        } else {
                            needNewLayer = YES;
                        }
                    }
                } else if (gCurCB.insertCIdx == eb.c_idx + 1) {
                    if (eb.c_idx == par.children.count - 1) {
                        needNewLayer = YES;
                    } else {
                        id b = [par.children objectAtIndex:eb.c_idx + 1];
                        if ([b isMemberOfClass:[EquationTextLayer class]]) {
                            EquationTextLayer *l = b;
                            if (l.type == TEXTLAYER_NUM) {
                                needNewLayer = NO;
                                cfgEqnBySlctBlk(gCurCB.curEq, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
                            } else {
                                needNewLayer = YES;
                            }
                        } else {
                            needNewLayer = YES;
                        }
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    return;
                }
            } else if (eb.roll == ROLL_ROOT || eb.roll == ROLL_ROOT_ROOT || eb.roll == ROLL_WRAP_ROOT || eb.roll == ROLL_EXPO_ROOT) {
                needNewLayer = YES;
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
        } else if ([gCurCB.curBlk isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *curLayer = gCurCB.curBlk;
            EquationBlock *par = curLayer.parent;
            if (gCurCB.insertCIdx == curLayer.c_idx) {
                if (curLayer.c_idx == 0) {
                    needNewLayer = YES;
                } else {
                    id b = [par.children objectAtIndex:curLayer.c_idx - 1];
                    if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        if (l.type == TEXTLAYER_NUM) {
                            if (l.expo == nil) {
                                needNewLayer = NO;
                                cfgEqnBySlctBlk(gCurCB.curEq, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                            } else {
                                needNewLayer = YES;
                            }
                        } else {
                            needNewLayer = YES;
                        }
                    } else {
                        needNewLayer = YES;
                    }
                }
            } else if (gCurCB.insertCIdx == curLayer.c_idx + 1) {
                if (curLayer.c_idx == par.children.count - 1) {
                    needNewLayer = YES;
                } else {
                    id b = [par.children objectAtIndex:curLayer.c_idx + 1];
                    if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        if (l.type == TEXTLAYER_NUM) {
                            needNewLayer = NO;
                            cfgEqnBySlctBlk(gCurCB.curEq, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
                        } else {
                            needNewLayer = YES;
                        }
                    } else {
                        needNewLayer = YES;
                    }
                }
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
        } else if ([gCurCB.curBlk isMemberOfClass:[FractionBarLayer class]]) {
            needNewLayer = YES;
        } else if ([gCurCB.curBlk isMemberOfClass:[RadicalBlock class]]) {
            RadicalBlock *rb = gCurCB.curBlk;
            EquationBlock *par = rb.parent;
            if (gCurCB.insertCIdx == rb.c_idx) {
                if (rb.c_idx == 0) {
                    needNewLayer = YES;
                } else {
                    id b = [par.children objectAtIndex:rb.c_idx - 1];
                    if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        if (l.type == TEXTLAYER_NUM) {
                            if (l.expo == nil) {
                                needNewLayer = NO;
                                cfgEqnBySlctBlk(gCurCB.curEq, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                            } else {
                                needNewLayer = YES;
                            }
                        } else {
                            needNewLayer = YES;
                        }
                    } else {
                        needNewLayer = YES;
                    }
                }
            } else if (gCurCB.insertCIdx == rb.c_idx + 1) {
                if (rb.c_idx == par.children.count - 1) {
                    needNewLayer = YES;
                } else {
                    id b = [par.children objectAtIndex:rb.c_idx + 1];
                    if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        if (l.type == TEXTLAYER_NUM) {
                            needNewLayer = NO;
                            cfgEqnBySlctBlk(gCurCB.curEq, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
                        } else {
                            needNewLayer = YES;
                        }
                    } else {
                        needNewLayer = YES;
                    }
                }
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
        } else if ([gCurCB.curBlk isMemberOfClass:[WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *wetl = gCurCB.curBlk;
            EquationBlock *par = wetl.parent;
            if (gCurCB.insertCIdx == wetl.c_idx) {
                if (wetl.c_idx == 0) {
                    needNewLayer = YES;
                } else {
                    id b = [par.children objectAtIndex:wetl.c_idx - 1];
                    if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        if (l.type == TEXTLAYER_NUM) {
                            if (l.expo == nil) {
                                needNewLayer = NO;
                                cfgEqnBySlctBlk(gCurCB.curEq, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                            } else {
                                needNewLayer = YES;
                            }
                        } else {
                            needNewLayer = YES;
                        }
                    } else {
                        needNewLayer = YES;
                    }
                }
            } else if (gCurCB.insertCIdx == wetl.c_idx + 1) {
                if (wetl.c_idx == par.children.count - 1) {
                    needNewLayer = YES;
                } else {
                    id b = [par.children objectAtIndex:wetl.c_idx + 1];
                    if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        if (l.type == TEXTLAYER_NUM) {
                            needNewLayer = NO;
                            cfgEqnBySlctBlk(gCurCB.curEq, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
                        } else {
                            needNewLayer = YES;
                        }
                    } else {
                        needNewLayer = YES;
                    }
                }
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
        } else if ([gCurCB.curBlk isMemberOfClass:[Parentheses class]]) {
            Parentheses *p = gCurCB.curBlk;
            EquationBlock *par = p.parent;
            if (gCurCB.insertCIdx == p.c_idx) {
                if (p.c_idx == 0) {
                    needNewLayer = YES;
                } else {
                    id b = [par.children objectAtIndex:p.c_idx - 1];
                    if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        if (l.type == TEXTLAYER_NUM) {
                            if (l.expo == nil) {
                                needNewLayer = NO;
                                cfgEqnBySlctBlk(gCurCB.curEq, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                            } else {
                                needNewLayer = YES;
                            }
                        } else {
                            needNewLayer = YES;
                        }
                    } else {
                        needNewLayer = YES;
                    }
                }
            } else if (gCurCB.insertCIdx == p.c_idx + 1) {
                if (p.c_idx == par.children.count - 1) {
                    needNewLayer = YES;
                } else {
                    id b = [par.children objectAtIndex:p.c_idx + 1];
                    if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        if (l.type == TEXTLAYER_NUM) {
                            needNewLayer = NO;
                            cfgEqnBySlctBlk(gCurCB.curEq, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
                        } else {
                            needNewLayer = YES;
                        }
                    } else {
                        needNewLayer = YES;
                    }
                }
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
    } else {
        needNewLayer = NO;
    }
    
    if (needNewLayer) {
        
        EquationTextLayer *tLayer = [[EquationTextLayer alloc] init:num :gCurCB.view.inpOrg :gCurCB.curEq :TEXTLAYER_NUM];
        
        incrWidth = tLayer.frame.size.width;
        
        if(gCurCB.curMode == MODE_INPUT) {
            EquationBlock *block = gCurCB.curParent;

            tLayer.c_idx = block.children.count;
            [block.children addObject:tLayer];
        } else if(gCurCB.curMode == MODE_INSERT) {
            EquationBlock *block = gCurCB.curParent;

            tLayer.c_idx = gCurCB.insertCIdx;
            [block.children insertObject:tLayer atIndex:tLayer.c_idx];
            /*Update c_idx*/
            [block updateCIdx];
        } else if(gCurCB.curMode == MODE_DUMP_ROOT) {
            Equation *eq = gCurCB.curEq;
            EquationBlock *newRoot = [[EquationBlock alloc] init:eq];
            newRoot.roll = ROLL_ROOT;
            newRoot.parent = nil;
            newRoot.numerFrame = eq.root.mainFrame;
            newRoot.numerTopHalf = eq.root.mainFrame.size.height / 2.0;
            newRoot.numerBtmHalf = eq.root.mainFrame.size.height / 2.0;
            newRoot.mainFrame = newRoot.numerFrame;
            eq.root.roll = ROLL_NUMERATOR;
            eq.root.parent = newRoot;
            if (gCurCB.insertCIdx == 0) {
                tLayer.c_idx = 0;
                [newRoot.children addObject:tLayer];
                eq.root.c_idx = 1;
                [newRoot.children addObject:eq.root];
                gCurCB.curMode = MODE_INSERT;
            } else {
                eq.root.c_idx = 0;
                [newRoot.children addObject:eq.root];
                tLayer.c_idx = 1;
                [newRoot.children addObject:tLayer];
                gCurCB.curMode = MODE_INPUT;
            }
            gCurCB.curRoll = ROLL_NUMERATOR;
            tLayer.roll = ROLL_NUMERATOR;
            eq.root = newRoot;
            gCurCB.curParent = newRoot;
        } else if(gCurCB.curMode == MODE_DUMP_RADICAL) {
            RadicalBlock *rBlock = gCurCB.curParent;
            EquationBlock *orgRootRoot = rBlock.content;
            EquationBlock *newRootRoot = [[EquationBlock alloc] init:gCurCB.curEq];
            newRootRoot.roll = ROLL_ROOT_ROOT;
            newRootRoot.parent = rBlock;
            newRootRoot.numerFrame = orgRootRoot.mainFrame;
            newRootRoot.numerTopHalf = orgRootRoot.mainFrame.size.height / 2.0;
            newRootRoot.numerBtmHalf = orgRootRoot.mainFrame.size.height / 2.0;
            newRootRoot.mainFrame = newRootRoot.numerFrame;
            orgRootRoot.roll = ROLL_NUMERATOR;
            orgRootRoot.parent = newRootRoot;
            if (gCurCB.insertCIdx == 0) {
                tLayer.c_idx = 0;
                [newRootRoot.children addObject:tLayer];
                orgRootRoot.c_idx = 1;
                [newRootRoot.children addObject:orgRootRoot];
                gCurCB.curMode = MODE_INSERT;
            } else {
                orgRootRoot.c_idx = 0;
                [newRootRoot.children addObject:orgRootRoot];
                tLayer.c_idx = 1;
                [newRootRoot.children addObject:tLayer];
                gCurCB.curMode = MODE_INPUT;
            }
            gCurCB.curRoll = ROLL_NUMERATOR;
            tLayer.roll = ROLL_NUMERATOR;
            rBlock.content = newRootRoot;
            gCurCB.curParent = newRootRoot;
        } else if(gCurCB.curMode == MODE_DUMP_EXPO) {
            EquationBlock *newExpo = [[EquationBlock alloc] init:gCurCB.curEq];
            EquationBlock *orgExpo = nil;
            if ([gCurCB.curParent isMemberOfClass:[EquationTextLayer class]]) {
                EquationTextLayer *layer = gCurCB.curParent;
                orgExpo = layer.expo;
                layer.expo = newExpo;
            } else if ([gCurCB.curParent isMemberOfClass:[Parentheses class]]) {
                Parentheses *p = gCurCB.curParent;
                orgExpo = p.expo;
                p.expo = newExpo;
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            
            newExpo.roll = ROLL_EXPO_ROOT;
            newExpo.parent = gCurCB.curParent;
            newExpo.numerFrame = orgExpo.mainFrame;
            newExpo.numerTopHalf = orgExpo.mainFrame.size.height / 2.0;
            newExpo.numerBtmHalf = orgExpo.mainFrame.size.height / 2.0;
            newExpo.mainFrame = newExpo.numerFrame;
            orgExpo.roll = ROLL_NUMERATOR;
            orgExpo.parent = newExpo;
            if (gCurCB.insertCIdx == 0) {
                tLayer.c_idx = 0;
                [newExpo.children addObject:tLayer];
                orgExpo.c_idx = 1;
                [newExpo.children addObject:orgExpo];
                gCurCB.curMode = MODE_INSERT;
            } else {
                orgExpo.c_idx = 0;
                [newExpo.children addObject:orgExpo];
                tLayer.c_idx = 1;
                [newExpo.children addObject:tLayer];
                gCurCB.curMode = MODE_INPUT;
            }
            gCurCB.curRoll = ROLL_NUMERATOR;
            tLayer.roll = ROLL_NUMERATOR;
            gCurCB.curParent = newExpo;
        } else if(gCurCB.curMode == MODE_DUMP_WETL) {
            WrapedEqTxtLyr *wetl = gCurCB.curParent;
            EquationBlock *orgWrapRoot = wetl.content;
            EquationBlock *newWrapRoot = [[EquationBlock alloc] init:gCurCB.curEq];
            newWrapRoot.roll = ROLL_WRAP_ROOT;
            newWrapRoot.parent = wetl;
            newWrapRoot.numerFrame = orgWrapRoot.mainFrame;
            newWrapRoot.numerTopHalf = orgWrapRoot.mainFrame.size.height / 2.0;
            newWrapRoot.numerBtmHalf = orgWrapRoot.mainFrame.size.height / 2.0;
            newWrapRoot.mainFrame = newWrapRoot.numerFrame;
            orgWrapRoot.roll = ROLL_NUMERATOR;
            orgWrapRoot.parent = newWrapRoot;
            if (gCurCB.insertCIdx == 0) {
                tLayer.c_idx = 0;
                [newWrapRoot.children addObject:tLayer];
                orgWrapRoot.c_idx = 1;
                [newWrapRoot.children addObject:orgWrapRoot];
                gCurCB.curMode = MODE_INSERT;
            } else {
                orgWrapRoot.c_idx = 0;
                [newWrapRoot.children addObject:orgWrapRoot];
                tLayer.c_idx = 1;
                [newWrapRoot.children addObject:tLayer];
                gCurCB.curMode = MODE_INPUT;
            }
            gCurCB.curRoll = ROLL_NUMERATOR;
            tLayer.roll = ROLL_NUMERATOR;
            wetl.content = newWrapRoot;
            gCurCB.curParent = newWrapRoot;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        tLayer.parent = gCurCB.curParent;
        [gCurCB.view.layer addSublayer:tLayer];
        
        gCurCB.insertCIdx = tLayer.c_idx + 1;
        gCurCB.curTxtLyr = tLayer;
        gCurCB.curBlk = tLayer;
        gCurCB.txtInsIdx = 1;
        cursorOffset = tLayer.mainFrame.size.width;
    } else {
        if (gCurCB.curTxtLyr.type == TEXTLAYER_EMPTY) {
            CGFloat orgW = gCurCB.curTxtLyr.mainFrame.size.width;
            cursorOffset = [gCurCB.curTxtLyr addNumStr:num];
            incrWidth += gCurCB.curTxtLyr.mainFrame.size.width - orgW;
            gCurCB.txtInsIdx = 1;
            gCurCB.insertCIdx = gCurCB.curTxtLyr.c_idx + 1;
        } else {
            CGFloat orgW = gCurCB.curTxtLyr.mainFrame.size.width;
            if (gCurCB.txtInsIdx == gCurCB.curTxtLyr.strLenTbl.count - 1) {
                cursorOffset = [gCurCB.curTxtLyr addNumStr:num];
            } else {
                cursorOffset = [gCurCB.curTxtLyr insertNumChar:num at:gCurCB.txtInsIdx];
            }
            gCurCB.txtInsIdx++;
            incrWidth += gCurCB.curTxtLyr.mainFrame.size.width - orgW;
        }
        
    }
    
    /* Update frame info of current block */
    [(EquationBlock *)gCurCB.curParent updateFrameWidth:incrWidth :gCurCB.curRoll];
    [gCurCB.curEq.root adjustElementPosition];
    
    /* Move cursor */
    CGFloat cursorOrgX = gCurCB.curTxtLyr.frame.origin.x + cursorOffset;
    CGFloat cursorOrgY = gCurCB.curTxtLyr.frame.origin.y;
    NSLog(@"%s%i>~%.2f~~~~~~~~~~", __FUNCTION__, __LINE__, cursorOffset);
    gCurCB.view.cursor.frame = CGRectMake(cursorOrgX, cursorOrgY, CURSOR_W, gCurCB.curFontH);
    gCurCB.view.inpOrg = CGPointMake(cursorOrgX, cursorOrgY);
    
    [gCurCB.view updateContentView];
    
    NSLog(@"%s%i>~%@~~~~~~~~~~", __FUNCTION__, __LINE__, [gCurCB.curTxtLyr.string string]);
}

- (void)handleOpBtnClick : (NSString *)op {
    if ([op isEqual: @"×"] || [op isEqual: @"+"] || [op isEqual: @"-"]) {
        CGFloat incrWidth = 0.0;
        
        if (gCurCB.curTxtLyr != nil && gCurCB.curTxtLyr.type == TEXTLAYER_EMPTY) {
            if (gCurCB.curTxtLyr.expo == nil) {
                EquationBlock *cb = gCurCB.curParent;
                [gCurCB.curTxtLyr destroy];
                [cb.children removeObjectAtIndex:gCurCB.curTxtLyr.c_idx];
                [cb updateCIdx];
                incrWidth -= gCurCB.curTxtLyr.mainFrame.size.width;
            } else if ([gCurCB.curTxtLyr.expo.children.firstObject isMemberOfClass:[EquationTextLayer class]]) {
                EquationTextLayer *l = gCurCB.curTxtLyr.expo.children.firstObject;
                if (l.type == TEXTLAYER_EMPTY) {
                    EquationBlock *cb = gCurCB.curParent;
                    [gCurCB.curTxtLyr destroy];
                    [cb.children removeObjectAtIndex:gCurCB.curTxtLyr.c_idx];
                    [cb updateCIdx];
                    incrWidth -= gCurCB.curTxtLyr.mainFrame.size.width;
                } else {
                    gCurCB.curMode = MODE_INSERT;
                    gCurCB.insertCIdx = gCurCB.curTxtLyr.c_idx;
                }
            } else {
                gCurCB.curMode = MODE_INSERT;
                gCurCB.insertCIdx = gCurCB.curTxtLyr.c_idx;
            }
        }
        
        EquationTextLayer *tLayer = [[EquationTextLayer alloc] init:op :gCurCB.view.inpOrg :gCurCB.curEq :TEXTLAYER_OP];
        
        incrWidth += tLayer.frame.size.width;
        
        if(gCurCB.curMode == MODE_INPUT) {
            EquationBlock *block = gCurCB.curParent;
            
            tLayer.c_idx = block.children.count;
            [block.children addObject:tLayer];
        } else if(gCurCB.curMode == MODE_INSERT) {
            EquationBlock *block = gCurCB.curParent;
            
            tLayer.c_idx = gCurCB.insertCIdx;
            [block.children insertObject:tLayer atIndex:tLayer.c_idx];
            /*Update c_idx*/
            [block updateCIdx];
        } else if(gCurCB.curMode == MODE_DUMP_ROOT) {
            Equation *eq = gCurCB.curEq;
            EquationBlock *newRoot = [[EquationBlock alloc] init:eq];
            newRoot.roll = ROLL_ROOT;
            newRoot.parent = nil;
            newRoot.numerFrame = eq.root.mainFrame;
            newRoot.numerTopHalf = eq.root.mainFrame.size.height / 2.0;
            newRoot.numerBtmHalf = eq.root.mainFrame.size.height / 2.0;
            newRoot.mainFrame = newRoot.numerFrame;
            eq.root.roll = ROLL_NUMERATOR;
            eq.root.parent = newRoot;
            if (gCurCB.insertCIdx == 0) {
                tLayer.c_idx = 0;
                [newRoot.children addObject:tLayer];
                eq.root.c_idx = 1;
                [newRoot.children addObject:eq.root];
                gCurCB.curMode = MODE_INSERT;
            } else {
                eq.root.c_idx = 0;
                [newRoot.children addObject:eq.root];
                tLayer.c_idx = 1;
                [newRoot.children addObject:tLayer];
                gCurCB.curMode = MODE_INPUT;
            }
            gCurCB.curRoll = ROLL_NUMERATOR;
            tLayer.roll = ROLL_NUMERATOR;
            eq.root = newRoot;
            gCurCB.curParent = newRoot;
        } else if(gCurCB.curMode == MODE_DUMP_RADICAL) {
            RadicalBlock *rBlock = gCurCB.curParent;
            EquationBlock *orgRootRoot = rBlock.content;
            EquationBlock *newRootRoot = [[EquationBlock alloc] init:gCurCB.curEq];
            newRootRoot.roll = ROLL_ROOT_ROOT;
            newRootRoot.parent = rBlock;
            newRootRoot.numerFrame = orgRootRoot.mainFrame;
            newRootRoot.numerTopHalf = orgRootRoot.mainFrame.size.height / 2.0;
            newRootRoot.numerBtmHalf = orgRootRoot.mainFrame.size.height / 2.0;
            newRootRoot.mainFrame = newRootRoot.numerFrame;
            orgRootRoot.roll = ROLL_NUMERATOR;
            orgRootRoot.parent = newRootRoot;
            if (gCurCB.insertCIdx == 0) {
                tLayer.c_idx = 0;
                [newRootRoot.children addObject:tLayer];
                orgRootRoot.c_idx = 1;
                [newRootRoot.children addObject:orgRootRoot];
                gCurCB.curMode = MODE_INSERT;
            } else {
                orgRootRoot.c_idx = 0;
                [newRootRoot.children addObject:orgRootRoot];
                tLayer.c_idx = 1;
                [newRootRoot.children addObject:tLayer];
                gCurCB.curMode = MODE_INPUT;
            }
            gCurCB.curRoll = ROLL_NUMERATOR;
            tLayer.roll = ROLL_NUMERATOR;
            rBlock.content = newRootRoot;
            gCurCB.curParent = newRootRoot;
        } else if(gCurCB.curMode == MODE_DUMP_EXPO) {
            EquationBlock *newExpoRoot = [[EquationBlock alloc] init:gCurCB.curEq];
            EquationBlock *orgExpoRoot = nil;
            if ([gCurCB.curParent isMemberOfClass:[EquationTextLayer class]]) {
                EquationTextLayer *layer = gCurCB.curParent;
                orgExpoRoot = layer.expo;
                layer.expo = newExpoRoot;
            } else if ([gCurCB.curParent isMemberOfClass:[Parentheses class]]) {
                Parentheses *p = gCurCB.curParent;
                orgExpoRoot = p.expo;
                p.expo = newExpoRoot;
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            
            newExpoRoot.roll = ROLL_EXPO_ROOT;
            newExpoRoot.parent = gCurCB.curParent;
            newExpoRoot.numerFrame = orgExpoRoot.mainFrame;
            newExpoRoot.numerTopHalf = orgExpoRoot.mainFrame.size.height / 2.0;
            newExpoRoot.numerBtmHalf = orgExpoRoot.mainFrame.size.height / 2.0;
            newExpoRoot.mainFrame = newExpoRoot.numerFrame;
            orgExpoRoot.roll = ROLL_NUMERATOR;
            orgExpoRoot.parent = newExpoRoot;
            if (gCurCB.insertCIdx == 0) {
                tLayer.c_idx = 0;
                [newExpoRoot.children addObject:tLayer];
                orgExpoRoot.c_idx = 1;
                [newExpoRoot.children addObject:orgExpoRoot];
                gCurCB.curMode = MODE_INSERT;
            } else {
                orgExpoRoot.c_idx = 0;
                [newExpoRoot.children addObject:orgExpoRoot];
                tLayer.c_idx = 1;
                [newExpoRoot.children addObject:tLayer];
                gCurCB.curMode = MODE_INPUT;
            }
            gCurCB.curRoll = ROLL_NUMERATOR;
            tLayer.roll = ROLL_NUMERATOR;
            gCurCB.curParent = newExpoRoot;
        } else if(gCurCB.curMode == MODE_DUMP_WETL) {
            WrapedEqTxtLyr *wetl = gCurCB.curParent;
            EquationBlock *orgWrapRoot = wetl.content;
            EquationBlock *newWrapRoot = [[EquationBlock alloc] init:gCurCB.curEq];
            newWrapRoot.roll = ROLL_WRAP_ROOT;
            newWrapRoot.parent = wetl;
            newWrapRoot.numerFrame = orgWrapRoot.mainFrame;
            newWrapRoot.numerTopHalf = orgWrapRoot.mainFrame.size.height / 2.0;
            newWrapRoot.numerBtmHalf = orgWrapRoot.mainFrame.size.height / 2.0;
            newWrapRoot.mainFrame = newWrapRoot.numerFrame;
            orgWrapRoot.roll = ROLL_NUMERATOR;
            orgWrapRoot.parent = newWrapRoot;
            if (gCurCB.insertCIdx == 0) {
                tLayer.c_idx = 0;
                [newWrapRoot.children addObject:tLayer];
                orgWrapRoot.c_idx = 1;
                [newWrapRoot.children addObject:orgWrapRoot];
                gCurCB.curMode = MODE_INSERT;
            } else {
                orgWrapRoot.c_idx = 0;
                [newWrapRoot.children addObject:orgWrapRoot];
                tLayer.c_idx = 1;
                [newWrapRoot.children addObject:tLayer];
                gCurCB.curMode = MODE_INPUT;
            }
            gCurCB.curRoll = ROLL_NUMERATOR;
            tLayer.roll = ROLL_NUMERATOR;
            wetl.content = newWrapRoot;
            gCurCB.curParent = newWrapRoot;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        tLayer.parent = gCurCB.curParent;
        [gCurCB.view.layer addSublayer:tLayer];
        
        gCurCB.insertCIdx = tLayer.c_idx + 1;
        gCurCB.txtInsIdx = 1;
        gCurCB.curTxtLyr = nil;
        gCurCB.curBlk = tLayer;
        
        //Update frame info of current block */
        //dumpObj(gCurCB.root);
        //NSLog(@"%s%i~%f~%@~~~~~~~~~", __FUNCTION__, __LINE__, strSize.width, gCurCB.curRoll == ROLL_NUMERATOR?@"N":@"D");
        [(EquationBlock *)gCurCB.curParent updateFrameWidth:incrWidth :gCurCB.curRoll];
        [gCurCB.curEq.root adjustElementPosition];
        
        /* Move cursor */
        CGFloat cursorOrgX = 0.0;
        CGFloat cursorOrgY = 0.0;
        cursorOrgX = tLayer.frame.origin.x + tLayer.frame.size.width;
        cursorOrgY = tLayer.frame.origin.y;
        gCurCB.view.cursor.frame = CGRectMake(cursorOrgX, cursorOrgY, CURSOR_W, gCurCB.curFontH);
        gCurCB.view.inpOrg = CGPointMake(cursorOrgX, cursorOrgY);
        
        [gCurCB.view updateContentView];
        
        NSLog(@"%s%i>~%@~~~~~~~~~~", __FUNCTION__, __LINE__, [tLayer.string string]);
    } else { //Handle "÷"
        if (gCurCB.insertCIdx == 0) {
            return;
        }
        
        if ([gCurCB.curParent isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *par = gCurCB.curParent;
            if (par.bar != nil) {
                if (par.bar.c_idx == gCurCB.insertCIdx - 1) {
                    return;
                }
            }
        }
        
        if(gCurCB.curMode == MODE_INPUT) {
            EquationBlock *eBlock = gCurCB.curParent;
            NSMutableArray *blockChildren = eBlock.children;
            NSEnumerator *enumerator = [blockChildren reverseObjectEnumerator];
            id block;
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            NSUInteger cnt = 0;
            CGFloat newNumerTop = 0.0, newNumerBtm = 0.0;
            if (gCurCB.curRoll == ROLL_NUMERATOR) {
                frameY = eBlock.numerFrame.origin.y;
            } else if (gCurCB.curRoll == ROLL_DENOMINATOR) {
                frameY = eBlock.denomFrame.origin.y;
            } else
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            
            int parenCnt = 0;
            while (block = [enumerator nextObject]) {
                if ([block isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = block;
                    if (([layer.name isEqual: @"+"] || [layer.name isEqual: @"-"]) && parenCnt <= 0)
                        break;
                    
                    /* Move numerators */
                    layer.roll = ROLL_NUMERATOR;
                    frameW += layer.mainFrame.size.width;
                    frameX = layer.mainFrame.origin.x;
                    if (newNumerTop < layer.mainFrame.size.height - layer.frame.size.height / 2.0) {
                        newNumerTop = layer.mainFrame.size.height - layer.frame.size.height / 2.0;
                        frameY = layer.mainFrame.origin.y;
                    }
                    
                    if (newNumerBtm < layer.frame.size.height / 2.0) {
                        newNumerBtm = layer.frame.size.height / 2.0;
                    }
                }else if ([block isMemberOfClass: [FractionBarLayer class]]) {
                    break;
                }else if ([block isMemberOfClass: [EquationBlock class]]) {
                    EquationBlock *b = block;
                    b.roll = ROLL_NUMERATOR;
                    frameW += b.mainFrame.size.width;
                    frameX = b.mainFrame.origin.x;
                    if (newNumerTop < b.mainFrame.size.height / 2.0) {
                        newNumerTop = b.mainFrame.size.height / 2.0;
                        frameY = b.mainFrame.origin.y;
                    }
                    
                    if (newNumerBtm < b.mainFrame.size.height / 2.0) {
                        newNumerBtm = b.mainFrame.size.height / 2.0;
                    }
                }else if ([block isMemberOfClass: [RadicalBlock class]]) {
                    RadicalBlock *b = block;
                    b.roll = ROLL_NUMERATOR;
                    frameW += b.frame.size.width;
                    frameX = b.frame.origin.x;
                    if (newNumerTop < b.frame.size.height / 2.0) {
                        newNumerTop = b.frame.size.height / 2.0;
                        frameY = b.frame.origin.y;
                    }
                    
                    if (newNumerBtm < b.frame.size.height / 2.0) {
                        newNumerBtm = b.frame.size.height / 2.0;
                    }
                }else if ([block isMemberOfClass: [WrapedEqTxtLyr class]]) {
                    WrapedEqTxtLyr *wetl = block;
                    wetl.roll = ROLL_NUMERATOR;
                    frameW += wetl.mainFrame.size.width;
                    frameX = wetl.mainFrame.origin.x;
                    if (newNumerTop < wetl.mainFrame.size.height / 2.0) {
                        newNumerTop = wetl.mainFrame.size.height / 2.0;
                        frameY = wetl.mainFrame.origin.y;
                    }
                    
                    if (newNumerBtm < wetl.mainFrame.size.height / 2.0) {
                        newNumerBtm = wetl.mainFrame.size.height / 2.0;
                    }
                }else if ([block isMemberOfClass: [Parentheses class]]) {
                    Parentheses *p = block;
                    if (p.l_or_r == RIGHT_PARENTH)
                        parenCnt++;
                    else {
                        if (parenCnt <= 0) {
                            break;
                        } else {
                            parenCnt--;
                        }
                    }
                    
                    p.roll = ROLL_NUMERATOR;
                    frameW += p.mainFrame.size.width;
                    frameX = p.mainFrame.origin.x;
                    CGFloat top = p.mainFrame.size.height - p.frame.size.height / 2.0;
                    CGFloat btm = p.mainFrame.size.height - top;
                    if (newNumerTop < top) {
                        newNumerTop = top;
                        frameY = p.mainFrame.origin.y;
                    }
                    
                    if (newNumerBtm < btm) {
                        newNumerBtm = btm;
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                
                cnt++;
            }
            
            if (cnt == 0) {
                return;
            }
            
            frameH = newNumerTop + newNumerBtm;
            
            if (block != nil) { // Need a new block
                EquationBlock *newBlock = [[EquationBlock alloc] init:gCurCB.curEq];
                newBlock.roll = gCurCB.curRoll;
                newBlock.parent = eBlock;
                newBlock.numerFrame = CGRectMake(frameX, frameY - gCurCB.curFontH, frameW, frameH);
                newBlock.mainFrame = newBlock.numerFrame;
                newBlock.numerTopHalf = newNumerTop;
                newBlock.numerBtmHalf = newNumerBtm;
                /* The value of start had been double checked */
                NSUInteger start = blockChildren.count - cnt;
                /* Add potential numerators into new block */
                for (NSUInteger i = start; i < blockChildren.count; i++) {
                    block = [blockChildren objectAtIndex:i];
                    if ([block isMemberOfClass: [EquationTextLayer class]]) {
                        EquationTextLayer *layer = block;
                        layer.c_idx = newBlock.children.count;
                        layer.parent = newBlock;
                        [newBlock.children addObject:layer];
                    } else if ([block isMemberOfClass: [EquationBlock class]]) {
                        EquationBlock *b = block;
                        b.c_idx = newBlock.children.count;
                        b.parent = newBlock;
                        [newBlock.children addObject:b];
                    } else if ([block isMemberOfClass: [RadicalBlock class]]) {
                        RadicalBlock *b = block;
                        b.c_idx = newBlock.children.count;
                        b.parent = newBlock;
                        [newBlock.children addObject:b];
                    } else if ([block isMemberOfClass: [WrapedEqTxtLyr class]]) {
                        WrapedEqTxtLyr *b = block;
                        b.c_idx = newBlock.children.count;
                        b.parent = newBlock;
                        [newBlock.children addObject:b];
                    } else if ([block isMemberOfClass: [Parentheses class]]) {
                        Parentheses *p = block;
                        p.c_idx = newBlock.children.count;
                        p.parent = newBlock;
                        [newBlock.children addObject:p];
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                }
                /* Remove those elements from old block */
                [blockChildren removeObjectsInRange:NSMakeRange(start, cnt)];
                /* Add new block into parent block */
                newBlock.c_idx = blockChildren.count;
                [blockChildren addObject: newBlock];
                eBlock = newBlock;
            } else {
                eBlock.numerFrame = CGRectMake(frameX, frameY - gCurCB.curFontH, frameW, frameH);
            }
            
            /* Make an empty denominator frame */
            eBlock.denomFrame = CGRectMake(frameX, frameY + frameH - gCurCB.curFontH, 0, gCurCB.curFontH);
            eBlock.denomTopHalf = gCurCB.curFontH / 2.0;
            eBlock.denomBtmHalf = gCurCB.curFontH / 2.0;
            eBlock.mainFrame = CGRectUnion(eBlock.numerFrame, eBlock.denomFrame);
            
            if (eBlock.parent != nil) {
                if ([eBlock.parent isMemberOfClass: [RadicalBlock class]]) {
                    RadicalBlock *rb = eBlock.parent;
                    CGFloat orgW = rb.frame.size.width;
                    [rb updateFrame];
                    [rb setNeedsDisplay];
                    if ([rb.parent isMemberOfClass:[EquationBlock class]]) {
                        [(EquationBlock *)rb.parent updateFrameHeightS1:rb];
                        [(EquationBlock *)rb.parent updateFrameWidth:rb.frame.size.width - orgW :rb.roll];
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else if ([eBlock.parent isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = eBlock.parent;
                    [layer updateFrameBaseOnExpo];
                    if ([layer.parent isMemberOfClass:[EquationBlock class]]) {
                        [(EquationBlock *)layer.parent updateFrameHeightS1:layer];
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else if ([eBlock.parent isMemberOfClass: [EquationBlock class]]) {
                    [(EquationBlock *)eBlock.parent updateFrameHeightS1:eBlock];
                } else if ([eBlock.parent isMemberOfClass: [WrapedEqTxtLyr class]]) {
                    WrapedEqTxtLyr *wetl = eBlock.parent;
                    CGFloat orgW = wetl.mainFrame.size.width;
                    
                    [wetl updateFrame:YES];
                    
                    if ([wetl.parent isMemberOfClass:[EquationBlock class]]) {
                        [(EquationBlock *)wetl.parent updateFrameHeightS1:wetl];
                        [(EquationBlock *)wetl.parent updateFrameWidth:wetl.mainFrame.size.width - orgW :wetl.roll];
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else if ([eBlock.parent isMemberOfClass: [Parentheses class]]) {
                    Parentheses *p = eBlock.parent;
                    [p updateFrameBaseOnExpo];
                    if ([p.parent isMemberOfClass:[EquationBlock class]]) {
                        [(EquationBlock *)p.parent updateFrameHeightS1:p];
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                
            }
            gCurCB.curParent = eBlock;
        } else if(gCurCB.curMode == MODE_INSERT) {
            if (gCurCB.insertCIdx == 0) { // No division while no numerator
                return;
            }
            NSUInteger i = 0, cnt = 0;
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            CGFloat newNumerTop = 0.0, newNumerBtm = 0.0;
            EquationBlock *eBlock = gCurCB.curParent;
            EquationBlock *newBlock = [[EquationBlock alloc] init:gCurCB.curEq];
            newBlock.roll = gCurCB.curRoll;
            newBlock.parent = eBlock;
            
            int parenCnt = 0;
            int tmp = 0;
            for (int ii = (int)gCurCB.insertCIdx - 1; ii >= 0; ii--) {
                i = ii;
                id block = [eBlock.children objectAtIndex:i];
                if ([block isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = block;
                    if (([layer.name isEqual: @"+"] || [layer.name isEqual: @"-"]) && parenCnt <= 0) {
                        tmp = 1;
                        break;
                    }
                    
                    layer.roll = ROLL_NUMERATOR;
                    frameW += layer.mainFrame.size.width;
                    frameX = layer.frame.origin.x;
                    if (newNumerTop < layer.mainFrame.size.height - layer.frame.size.height / 2.0) {
                        newNumerTop = layer.mainFrame.size.height - layer.frame.size.height / 2.0;
                        frameY = layer.mainFrame.origin.y;
                    }
                    
                    if (newNumerBtm < layer.frame.size.height / 2.0) {
                        newNumerBtm = layer.frame.size.height / 2.0;
                    }
                    layer.parent = newBlock;
                    [newBlock.children addObject:layer];
                } else if ([block isMemberOfClass: [FractionBarLayer class]]) {
                    tmp = 1;
                    break;
                } else if ([block isMemberOfClass: [EquationBlock class]]) {
                    EquationBlock *b = block;
                    b.roll = ROLL_NUMERATOR;
                    frameW += b.mainFrame.size.width;
                    frameX = b.mainFrame.origin.x;
                    if (newNumerTop < b.mainFrame.size.height / 2.0) {
                        newNumerTop = b.mainFrame.size.height / 2.0;
                        frameY = b.mainFrame.origin.y;
                    }
                    
                    if (newNumerBtm < b.mainFrame.size.height / 2.0) {
                        newNumerBtm = b.mainFrame.size.height / 2.0;
                    }
                    b.parent = newBlock;
                    [newBlock.children addObject:b];
                } else if ([block isMemberOfClass: [RadicalBlock class]]) {
                    RadicalBlock *b = block;
                    b.roll = ROLL_NUMERATOR;
                    frameW += b.frame.size.width;
                    frameX = b.frame.origin.x;
                    if (newNumerTop < b.frame.size.height / 2.0) {
                        newNumerTop = b.frame.size.height / 2.0;
                        frameY = b.frame.origin.y;
                    }
                    
                    if (newNumerBtm < b.frame.size.height / 2.0) {
                        newNumerBtm = b.frame.size.height / 2.0;
                    }
                    b.parent = newBlock;
                    [newBlock.children addObject:b];
                } else if ([block isMemberOfClass: [WrapedEqTxtLyr class]]) {
                    WrapedEqTxtLyr *wetl = block;
                    wetl.roll = ROLL_NUMERATOR;
                    frameW += wetl.mainFrame.size.width;
                    frameX = wetl.mainFrame.origin.x;
                    if (newNumerTop < wetl.mainFrame.size.height / 2.0) {
                        newNumerTop = wetl.mainFrame.size.height / 2.0;
                        frameY = wetl.mainFrame.origin.y;
                    }
                    
                    if (newNumerBtm < wetl.mainFrame.size.height / 2.0) {
                        newNumerBtm = wetl.mainFrame.size.height / 2.0;
                    }
                    wetl.parent = newBlock;
                    [newBlock.children addObject:wetl];
                }else if ([block isMemberOfClass: [Parentheses class]]) {
                    Parentheses *p = block;
                    if (p.l_or_r == RIGHT_PARENTH)
                        parenCnt++;
                    else {
                        if (parenCnt <= 0) {
                            tmp = 1;
                            break;
                        } else {
                            parenCnt--;
                        }
                    }
                    
                    p.roll = ROLL_NUMERATOR;
                    frameW += p.mainFrame.size.width;
                    frameX = p.mainFrame.origin.x;
                    CGFloat top = p.mainFrame.size.height - p.frame.size.height / 2.0;
                    CGFloat btm = p.mainFrame.size.height - top;
                    if (newNumerTop < top) {
                        newNumerTop = top;
                        frameY = p.mainFrame.origin.y;
                    }
                    
                    if (newNumerBtm < btm) {
                        newNumerBtm = btm;
                    }
                    
                    p.parent = newBlock;
                    [newBlock.children addObject:p];
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                cnt++;
            }
            
            if (cnt == 0) {
                return;
            }
            
            frameH = newNumerTop + newNumerBtm;
            
            i += tmp;
            
            newBlock.numerFrame = CGRectMake(frameX, frameY - gCurCB.curFontH, frameW, frameH);
            newBlock.numerTopHalf = newNumerTop;
            newBlock.numerBtmHalf = newNumerBtm;
            newBlock.denomFrame = CGRectMake(frameX, frameY + frameH - gCurCB.curFontH, 0, gCurCB.curFontH); //Make an empty denominator frame
            newBlock.denomTopHalf = gCurCB.curFontH / 2.0;
            newBlock.denomBtmHalf = gCurCB.curFontH / 2.0;
            newBlock.mainFrame = CGRectUnion(newBlock.numerFrame, newBlock.denomFrame);

            [newBlock.children reverse];
            [newBlock updateCIdx];
            /* Remove those elements from old block */
            [eBlock.children removeObjectsInRange:NSMakeRange(i, cnt)];
            /* Add new block into parent block */
            [eBlock.children insertObject:newBlock atIndex:i];
            [eBlock updateCIdx];
            eBlock = newBlock;

            gCurCB.curMode = MODE_INPUT;
            
            if (eBlock.parent != nil) {
                if ([eBlock.parent isMemberOfClass: [RadicalBlock class]]) {
                    RadicalBlock *rb = eBlock.parent;
                    CGFloat orgW = rb.frame.size.width;
                    [rb updateFrame];
                    [rb setNeedsDisplay];
                    if ([rb.parent isMemberOfClass:[EquationBlock class]]) {
                        [(EquationBlock *)rb.parent updateFrameHeightS1:rb];
                        [(EquationBlock *)rb.parent updateFrameWidth:rb.frame.size.width - orgW :rb.roll];
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else if ([eBlock.parent isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = eBlock.parent;
                    [layer updateFrameBaseOnExpo];
                    if ([layer.parent isMemberOfClass:[EquationBlock class]]) {
                        [(EquationBlock *)layer.parent updateFrameHeightS1:layer];
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else if ([eBlock.parent isMemberOfClass: [EquationBlock class]]) {
                    [(EquationBlock *)eBlock.parent updateFrameHeightS1:eBlock];
                } else if ([eBlock.parent isMemberOfClass: [WrapedEqTxtLyr class]]) {
                    WrapedEqTxtLyr *wetl = eBlock.parent;
                    CGFloat orgW = wetl.mainFrame.size.width;
                    
                    [wetl updateFrame:YES];
                    
                    if ([wetl.parent isMemberOfClass:[EquationBlock class]]) {
                        [(EquationBlock *)wetl.parent updateFrameHeightS1:wetl];
                        [(EquationBlock *)wetl.parent updateFrameWidth:wetl.mainFrame.size.width - orgW :wetl.roll];
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else if ([eBlock.parent isMemberOfClass: [Parentheses class]]) {
                    Parentheses *p = eBlock.parent;
                    [p updateFrameBaseOnExpo];
                    if ([p.parent isMemberOfClass:[EquationBlock class]]) {
                        [(EquationBlock *)p.parent updateFrameHeightS1:p];
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            }
            
            gCurCB.curParent = eBlock;
        } else if(gCurCB.curMode == MODE_DUMP_ROOT) {
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            Equation *eq = gCurCB.curEq;
            EquationBlock *newRoot = [[EquationBlock alloc] init:eq];
            newRoot.roll = ROLL_ROOT;
            newRoot.parent = nil;

            frameX = eq.root.mainFrame.origin.x;
            frameY = eq.root.mainFrame.origin.y - gCurCB.curFontH;
            frameW = eq.root.mainFrame.size.width;
            frameH = eq.root.mainFrame.size.height;

            newRoot.numerFrame = CGRectMake(frameX, frameY, frameW, frameH);
            newRoot.numerTopHalf = frameH / 2.0;
            newRoot.numerBtmHalf = frameH / 2.0;
            newRoot.denomFrame = CGRectMake(frameX, frameY + frameH, 0, gCurCB.curFontH); //Make an empty denominator frame
            newRoot.denomTopHalf = gCurCB.curFontH / 2.0;
            newRoot.denomBtmHalf = gCurCB.curFontH / 2.0;
            newRoot.mainFrame = CGRectUnion(newRoot.numerFrame, newRoot.denomFrame);

            eq.root.mainFrame = newRoot.numerFrame;
            eq.root.c_idx = 0;
            eq.root.parent = newRoot;
            eq.root.roll = ROLL_NUMERATOR;
            [newRoot.children addObject: eq.root];

            eq.root = newRoot;
            gCurCB.curParent = newRoot;
            gCurCB.curMode = MODE_INPUT;
        } else if(gCurCB.curMode == MODE_DUMP_RADICAL) {
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            RadicalBlock *rBlock = gCurCB.curParent;
            EquationBlock *orgRootRoot = rBlock.content;
            EquationBlock *newRootRoot = [[EquationBlock alloc] init:gCurCB.curEq];
            orgRootRoot.roll = ROLL_NUMERATOR;
            newRootRoot.roll = ROLL_ROOT_ROOT;
            newRootRoot.parent = rBlock;

            frameX = orgRootRoot.mainFrame.origin.x;
            frameY = orgRootRoot.mainFrame.origin.y - gCurCB.curFontH;
            frameW = orgRootRoot.mainFrame.size.width;
            frameH = orgRootRoot.mainFrame.size.height;

            newRootRoot.numerFrame = CGRectMake(frameX, frameY, frameW, frameH);
            newRootRoot.numerTopHalf = frameH / 2.0;
            newRootRoot.numerBtmHalf = frameH / 2.0;
            newRootRoot.denomFrame = CGRectMake(frameX, frameY + frameH, 0, gCurCB.curFontH); //Make an empty denominator frame
            newRootRoot.denomTopHalf = gCurCB.curFontH / 2.0;
            newRootRoot.denomBtmHalf = gCurCB.curFontH / 2.0;
            newRootRoot.mainFrame = CGRectUnion(newRootRoot.numerFrame, newRootRoot.denomFrame);

            orgRootRoot.mainFrame = newRootRoot.numerFrame;
            orgRootRoot.c_idx = 0;
            orgRootRoot.parent = newRootRoot;
            [newRootRoot.children addObject: orgRootRoot];

            rBlock.content = newRootRoot;
            CGFloat orgW = rBlock.frame.size.width;
            [rBlock updateFrame];
            [rBlock setNeedsDisplay];
            if ([rBlock.parent isMemberOfClass:[EquationBlock class]]) {
                [(EquationBlock *)rBlock.parent updateFrameHeightS1:rBlock];
                [(EquationBlock *)rBlock.parent updateFrameWidth:rBlock.frame.size.width - orgW :rBlock.roll];
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            gCurCB.curParent = newRootRoot;
            gCurCB.curMode = MODE_INPUT;
        } else if(gCurCB.curMode == MODE_DUMP_EXPO) {
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            EquationBlock *newExpo = [[EquationBlock alloc] init:gCurCB.curEq];
            EquationBlock *orgExpo = nil;
            if ([gCurCB.curParent isMemberOfClass:[EquationTextLayer class]]) {
                EquationTextLayer *l = gCurCB.curParent;
                orgExpo = l.expo;
                l.expo = newExpo;
            } else if ([gCurCB.curParent isMemberOfClass:[Parentheses class]]) {
                Parentheses *p = gCurCB.curParent;
                orgExpo = p.expo;
                p.expo = newExpo;
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            
            orgExpo.roll = ROLL_NUMERATOR;
            newExpo.roll = ROLL_EXPO_ROOT;
            newExpo.parent = gCurCB.curParent;
            
            frameX = orgExpo.mainFrame.origin.x;
            frameY = orgExpo.mainFrame.origin.y - gCurCB.curFontH;
            frameW = orgExpo.mainFrame.size.width;
            frameH = orgExpo.mainFrame.size.height;
            
            newExpo.numerFrame = CGRectMake(frameX, frameY, frameW, frameH);
            newExpo.numerTopHalf = frameH / 2.0;
            newExpo.numerBtmHalf = frameH / 2.0;
            newExpo.denomFrame = CGRectMake(frameX, frameY + frameH, 0, gCurCB.curFontH); //Make an empty denominator frame
            newExpo.denomTopHalf = gCurCB.curFontH / 2.0;
            newExpo.denomBtmHalf = gCurCB.curFontH / 2.0;
            newExpo.mainFrame = CGRectUnion(newExpo.numerFrame, newExpo.denomFrame);
            
            orgExpo.mainFrame = newExpo.numerFrame;
            orgExpo.c_idx = 0;
            orgExpo.parent = newExpo;
            [newExpo.children addObject: orgExpo];
            
            if ([gCurCB.curParent isMemberOfClass:[EquationTextLayer class]]) {
                EquationTextLayer *l = gCurCB.curParent;
                [l updateFrameBaseOnExpo];
                if ([l.parent isMemberOfClass:[EquationBlock class]]) {
                    [(EquationBlock *)l.parent updateFrameHeightS1:l];
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            } else if ([gCurCB.curParent isMemberOfClass:[Parentheses class]]) {
                Parentheses *p = gCurCB.curParent;
                [p updateFrameBaseOnExpo];
                if ([p.parent isMemberOfClass:[EquationBlock class]]) {
                    [(EquationBlock *)p.parent updateFrameHeightS1:p];
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            
            gCurCB.curParent = newExpo;
            gCurCB.curMode = MODE_INPUT;
        } else if(gCurCB.curMode == MODE_DUMP_WETL) {
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            WrapedEqTxtLyr *wetl = gCurCB.curParent;
            CGFloat orgW = wetl.mainFrame.size.width;
            EquationBlock *orgWrapRoot = wetl.content;
            EquationBlock *newWrapRoot = [[EquationBlock alloc] init:gCurCB.curEq];
            orgWrapRoot.roll = ROLL_NUMERATOR;
            newWrapRoot.roll = ROLL_WRAP_ROOT;
            newWrapRoot.parent = wetl;
            
            frameX = orgWrapRoot.mainFrame.origin.x;
            frameY = orgWrapRoot.mainFrame.origin.y - gCurCB.curFontH;
            frameW = orgWrapRoot.mainFrame.size.width;
            frameH = orgWrapRoot.mainFrame.size.height;
            
            newWrapRoot.numerFrame = CGRectMake(frameX, frameY, frameW, frameH);
            newWrapRoot.numerTopHalf = frameH / 2.0;
            newWrapRoot.numerBtmHalf = frameH / 2.0;
            newWrapRoot.denomFrame = CGRectMake(frameX, frameY + frameH, 0, gCurCB.curFontH); //Make an empty denominator frame
            newWrapRoot.denomTopHalf = gCurCB.curFontH / 2.0;
            newWrapRoot.denomBtmHalf = gCurCB.curFontH / 2.0;
            newWrapRoot.mainFrame = CGRectUnion(newWrapRoot.numerFrame, newWrapRoot.denomFrame);
            
            orgWrapRoot.mainFrame = newWrapRoot.numerFrame;
            orgWrapRoot.c_idx = 0;
            orgWrapRoot.parent = newWrapRoot;
            [newWrapRoot.children addObject: orgWrapRoot];
            
            wetl.content = newWrapRoot;
            
            [wetl updateFrame:YES];
            
            if ([wetl.parent isMemberOfClass:[EquationBlock class]]) {
                [(EquationBlock *)wetl.parent updateFrameHeightS1:wetl];
                [(EquationBlock *)wetl.parent updateFrameWidth:wetl.mainFrame.size.width - orgW :wetl.roll];
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            gCurCB.curParent = newWrapRoot;
            gCurCB.curMode = MODE_INPUT;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }

        gCurCB.curRoll = ROLL_DENOMINATOR;
        
        EquationBlock *eBlock = gCurCB.curParent;
        
        testeb = eBlock;
        
        /* Add a bar into eBlock */
        FractionBarLayer *barLayer = [[FractionBarLayer alloc] init:gCurCB.curEq :self];
        barLayer.name = @"/";
        barLayer.hidden = NO;
        barLayer.backgroundColor = [UIColor clearColor].CGColor;
        barLayer.parent = eBlock;
        /*Make bar in the middle of numer and deno*/
        CGRect frame;
        frame.origin.x = eBlock.mainFrame.origin.x;
        frame.size.height = gCurCB.curFontH / FRACTION_BAR_H_R;
        frame.origin.y = eBlock.numerFrame.origin.y + eBlock.numerFrame.size.height - (frame.size.height / 2.0);
        frame.size.width = eBlock.mainFrame.size.width;
        
        barLayer.frame = frame;
        barLayer.c_idx = eBlock.children.count;
        [gCurCB.view.layer addSublayer: barLayer];
        [barLayer setNeedsDisplay];
        [eBlock.children addObject: barLayer];
        eBlock.bar = barLayer;
        
        EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :eBlock.denomFrame.origin :gCurCB.curEq :TEXTLAYER_EMPTY];
        layer.parent = eBlock;
        eBlock.denomFrame = layer.frame;
        layer.c_idx = eBlock.children.count;
        [eBlock.children addObject:layer];
        [gCurCB.view.layer addSublayer: layer];
        
        gCurCB.insertCIdx = layer.c_idx + 1;
        gCurCB.txtInsIdx = 0;
        gCurCB.curTxtLyr = layer;
        gCurCB.curBlk = layer;
        [gCurCB.curEq.root adjustElementPosition];
        
        /* Move cursor */
        CGFloat cursorOrgX = 0.0;
        CGFloat cursorOrgY = 0.0;
        cursorOrgX = eBlock.denomFrame.origin.x;
        cursorOrgY = eBlock.denomFrame.origin.y;
        gCurCB.view.cursor.frame = CGRectMake(cursorOrgX, cursorOrgY, CURSOR_W, gCurCB.curFontH);
        gCurCB.view.inpOrg = CGPointMake(cursorOrgX, cursorOrgY);
        
        if ((int)gCurCB.curEq.maxRootHeight < (int)gCurCB.curEq.root.mainFrame.size.height) {
            CGFloat dis = gCurCB.curEq.root.mainFrame.size.height - gCurCB.curEq.maxRootHeight;
            gCurCB.curEq.maxRootHeight = gCurCB.curEq.root.mainFrame.size.height;
            for (Equation *eq in gCurCB.eqList) {
                [eq moveUp:dis];
            }
        }
        
        [gCurCB.view updateContentView];
    }
    
}

- (void)handleRootBtnClick: (int)rootCnt {
    CGFloat incrWidth = 0.0;
    
    if (gCurCB.curTxtLyr != nil && gCurCB.curTxtLyr.type == TEXTLAYER_EMPTY) {
        if (gCurCB.curTxtLyr.expo == nil) {
            EquationBlock *cb = gCurCB.curParent;
            [gCurCB.curTxtLyr destroy];
            [cb.children removeObjectAtIndex:gCurCB.curTxtLyr.c_idx];
            [cb updateCIdx];
            incrWidth -= gCurCB.curTxtLyr.mainFrame.size.width;
        } else if ([gCurCB.curTxtLyr.expo.children.firstObject isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *l = gCurCB.curTxtLyr.expo.children.firstObject;
            if (l.type == TEXTLAYER_EMPTY) {
                EquationBlock *cb = gCurCB.curParent;
                [gCurCB.curTxtLyr destroy];
                [cb.children removeObjectAtIndex:gCurCB.curTxtLyr.c_idx];
                [cb updateCIdx];
                incrWidth -= gCurCB.curTxtLyr.mainFrame.size.width;
            } else {
                gCurCB.curMode = MODE_INSERT;
                gCurCB.insertCIdx = gCurCB.curTxtLyr.c_idx;
            }
        } else {
            gCurCB.curMode = MODE_INSERT;
            gCurCB.insertCIdx = gCurCB.curTxtLyr.c_idx;
        }
    }
    
    RadicalBlock *newRBlock = [[RadicalBlock alloc] init:gCurCB.view.inpOrg :gCurCB.curEq :rootCnt :self];
    
    incrWidth += newRBlock.frame.size.width;
    
//    if (orgLayer != nil && orgLayer.type == TEXTLAYER_EMPTY) {
//        EquationBlock *cb = gCurCB.curBlk;
//        [orgLayer destroy];
//        [cb.children removeObjectAtIndex:orgLayer.c_idx];
//        [cb updateCIdx];
//        incrWidth -= orgLayer.mainFrame.size.width;
//    }
    
    
    if(gCurCB.curMode == MODE_INPUT) {
        EquationBlock *eBlock = gCurCB.curParent;
        
        newRBlock.c_idx = eBlock.children.count;
        
        [eBlock.children addObject:newRBlock];
    } else if(gCurCB.curMode == MODE_INSERT) {
        EquationBlock *eBlock = gCurCB.curParent;

        [eBlock.children insertObject:newRBlock atIndex: gCurCB.insertCIdx];
        
        /*Update c_idx*/
        [eBlock updateCIdx];
    } else if(gCurCB.curMode == MODE_DUMP_ROOT) {
        Equation *eq = gCurCB.curEq;
        EquationBlock *newRoot = [[EquationBlock alloc] init:eq];
        newRoot.roll = ROLL_ROOT;
        newRoot.parent = nil;
        newRoot.numerFrame = eq.root.mainFrame;
        newRoot.numerTopHalf = eq.root.mainFrame.size.height / 2.0;
        newRoot.numerBtmHalf = eq.root.mainFrame.size.height / 2.0;
        newRoot.mainFrame = newRoot.numerFrame;
        eq.root.roll = ROLL_NUMERATOR;
        eq.root.parent = newRoot;
        if (gCurCB.insertCIdx == 0) {
            eq.root.c_idx = 1;
            newRBlock.c_idx = 0;
            [newRoot.children addObject:newRBlock];
            [newRoot.children addObject:eq.root];
            gCurCB.curMode = MODE_INSERT;
        } else {
            eq.root.c_idx = 0;
            [newRoot.children addObject:eq.root];
            newRBlock.c_idx = 1;
            [newRoot.children addObject:newRBlock];
            gCurCB.curMode = MODE_INPUT;
        }
        gCurCB.curRoll = ROLL_NUMERATOR;
        newRBlock.roll = ROLL_NUMERATOR;
        gCurCB.curParent = newRoot;
        eq.root = newRoot;
    } else if(gCurCB.curMode == MODE_DUMP_RADICAL) {
        RadicalBlock *rBlock = gCurCB.curParent;
        EquationBlock *orgRootRoot = rBlock.content;
        EquationBlock *newRootRoot = [[EquationBlock alloc] init:gCurCB.curEq];
        newRootRoot.roll = ROLL_ROOT_ROOT;
        newRootRoot.parent = rBlock;
        newRootRoot.numerFrame = orgRootRoot.mainFrame;
        newRootRoot.numerTopHalf = orgRootRoot.mainFrame.size.height / 2.0;
        newRootRoot.numerBtmHalf = orgRootRoot.mainFrame.size.height / 2.0;
        newRootRoot.mainFrame = newRootRoot.numerFrame;
        orgRootRoot.roll = ROLL_NUMERATOR;
        orgRootRoot.parent = newRootRoot;
        
        if (gCurCB.insertCIdx == 0) {
            orgRootRoot.c_idx = 1;
            newRBlock.c_idx = 0;
            [newRootRoot.children addObject:newRBlock];
            [newRootRoot.children addObject:orgRootRoot];
            gCurCB.curMode = MODE_INSERT;
        } else {
            orgRootRoot.c_idx = 0;
            [newRootRoot.children addObject:orgRootRoot];
            newRBlock.c_idx = 1;
            [newRootRoot.children addObject:newRBlock];
            gCurCB.curMode = MODE_INPUT;
        }
        newRBlock.roll = ROLL_NUMERATOR;
        rBlock.content = newRootRoot;
        gCurCB.curParent = newRootRoot;
        gCurCB.curRoll = ROLL_NUMERATOR;
    } else if(gCurCB.curMode == MODE_DUMP_EXPO) {
        EquationBlock *newExpo = [[EquationBlock alloc] init:gCurCB.curEq];
        EquationBlock *orgExpo = nil;
        if ([gCurCB.curParent isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *l = gCurCB.curParent;
            orgExpo = l.expo;
            l.expo = newExpo;
        } else if ([gCurCB.curParent isMemberOfClass:[Parentheses class]]) {
            Parentheses *p = gCurCB.curParent;
            orgExpo = p.expo;
            p.expo = newExpo;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        newExpo.roll = ROLL_EXPO_ROOT;
        newExpo.parent = gCurCB.curParent;
        newExpo.numerFrame = orgExpo.mainFrame;
        newExpo.numerTopHalf = orgExpo.mainFrame.size.height / 2.0;
        newExpo.numerBtmHalf = orgExpo.mainFrame.size.height / 2.0;
        newExpo.mainFrame = newExpo.numerFrame;
        orgExpo.roll = ROLL_NUMERATOR;
        orgExpo.parent = newExpo;
        
        if (gCurCB.insertCIdx == 0) {
            newRBlock.c_idx = 0;
            [newExpo.children addObject:newRBlock];
            orgExpo.c_idx = 1;
            [newExpo.children addObject:orgExpo];
            gCurCB.curMode = MODE_INSERT;
        } else {
            orgExpo.c_idx = 0;
            [newExpo.children addObject:orgExpo];
            newRBlock.c_idx = 1;
            [newExpo.children addObject:newRBlock];
            gCurCB.curMode = MODE_INPUT;
        }
        newRBlock.roll = ROLL_NUMERATOR;
        gCurCB.curParent = newExpo;
        gCurCB.curRoll = ROLL_NUMERATOR;
    } else if(gCurCB.curMode == MODE_DUMP_WETL) {
        WrapedEqTxtLyr *wetl = gCurCB.curParent;
        EquationBlock *orgWrapRoot = wetl.content;
        EquationBlock *newWrapRoot = [[EquationBlock alloc] init:gCurCB.curEq];
        newWrapRoot.roll = ROLL_ROOT_ROOT;
        newWrapRoot.parent = wetl;
        newWrapRoot.numerFrame = orgWrapRoot.mainFrame;
        newWrapRoot.numerTopHalf = orgWrapRoot.mainFrame.size.height / 2.0;
        newWrapRoot.numerBtmHalf = orgWrapRoot.mainFrame.size.height / 2.0;
        newWrapRoot.mainFrame = newWrapRoot.numerFrame;
        orgWrapRoot.roll = ROLL_NUMERATOR;
        orgWrapRoot.parent = newWrapRoot;
        
        if (gCurCB.insertCIdx == 0) {
            orgWrapRoot.c_idx = 1;
            newRBlock.c_idx = 0;
            [newWrapRoot.children addObject:newRBlock];
            [newWrapRoot.children addObject:orgWrapRoot];
            gCurCB.curMode = MODE_INSERT;
        } else {
            orgWrapRoot.c_idx = 0;
            [newWrapRoot.children addObject:orgWrapRoot];
            newRBlock.c_idx = 1;
            [newWrapRoot.children addObject:newRBlock];
            gCurCB.curMode = MODE_INPUT;
        }
        newRBlock.roll = ROLL_NUMERATOR;
        wetl.content = newWrapRoot;
        gCurCB.curParent = newWrapRoot;
        gCurCB.curRoll = ROLL_NUMERATOR;
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    newRBlock.parent = gCurCB.curParent;

    [gCurCB.view.layer addSublayer: newRBlock];
    [newRBlock setNeedsDisplay];
    
    [(EquationBlock *)gCurCB.curParent updateFrameWidth:incrWidth :gCurCB.curRoll];
    [(EquationBlock *)gCurCB.curParent updateFrameHeightS1:newRBlock];
    [gCurCB.curEq.root adjustElementPosition];
    
    gCurCB.insertCIdx = 1;
    gCurCB.txtInsIdx = 0;
    gCurCB.curMode = MODE_INPUT;
    gCurCB.curRoll = ROLL_NUMERATOR;
    gCurCB.curParent = newRBlock.content;
    gCurCB.view.inpOrg = ((EquationBlock *)gCurCB.curParent).mainFrame.origin;
    gCurCB.view.cursor.frame = CGRectMake(gCurCB.view.inpOrg.x, gCurCB.view.inpOrg.y, CURSOR_W, gCurCB.curFontH);
    
    if ((int)gCurCB.curEq.maxRootHeight < (int)gCurCB.curEq.root.mainFrame.size.height) {
        CGFloat dis = gCurCB.curEq.root.mainFrame.size.height - gCurCB.curEq.maxRootHeight;
        gCurCB.curEq.maxRootHeight = gCurCB.curEq.root.mainFrame.size.height;
        for (Equation *eq in gCurCB.eqList) {
            [eq moveUp:dis];
        }
    }
    
    [gCurCB.view updateContentView];
}

- (void)handlePowBtnClick {
    
    if (gCurCB.curTxtLyr == nil) {
        if ([gCurCB.curBlk isMemberOfClass:[Parentheses class]] && ((Parentheses *)gCurCB.curBlk).l_or_r == RIGHT_PARENTH && gCurCB.insertCIdx == ((Parentheses *)gCurCB.curBlk).c_idx + 1) {
            Parentheses *p = gCurCB.curBlk;
            if (p.expo == nil) {
                [gCurCB updateFontInfo:gCurCB.curFontLvl + 1];
                
                CGPoint pos = CGPointMake(p.frame.origin.x + p.frame.size.width, p.frame.origin.y - gCurCB.curFontH / 2.0);
                
                EquationBlock *exp = [[EquationBlock alloc] init:pos :gCurCB.curEq];
                exp.roll = ROLL_EXPO_ROOT;
                exp.parent = p;
                p.expo = exp;
                
                EquationTextLayer *expLayer = [[EquationTextLayer alloc] init:@"_" :pos :gCurCB.curEq :TEXTLAYER_EMPTY];
                expLayer.parent = exp;
                exp.numerFrame = expLayer.frame;
                exp.mainFrame = expLayer.frame;
                expLayer.roll = ROLL_NUMERATOR;
                expLayer.c_idx = 0;
                [exp.children addObject:expLayer];
                [gCurCB.view.layer addSublayer: expLayer];
                NSLog(@"%s%i>~%@~%@~~~~~~~~~", __FUNCTION__, __LINE__, NSStringFromCGRect(exp.mainFrame), NSStringFromCGRect(p.frame));
                p.mainFrame = CGRectUnion(exp.mainFrame, p.frame);
                
                CGFloat inc = exp.mainFrame.size.width;
                [(EquationBlock *)gCurCB.curParent updateFrameWidth:inc :gCurCB.curRoll];
                [(EquationBlock *)gCurCB.curParent updateFrameHeightS1:p];
                [gCurCB.curEq.root adjustElementPosition];
                
                gCurCB.insertCIdx = expLayer.c_idx + 1;
                gCurCB.txtInsIdx = 0;
                gCurCB.curTxtLyr = expLayer;
                gCurCB.curBlk = expLayer;
                gCurCB.curParent = exp;
                gCurCB.curRoll = ROLL_NUMERATOR;
                gCurCB.curMode = MODE_INPUT;
                
                gCurCB.view.inpOrg = expLayer.frame.origin;
                gCurCB.view.cursor.frame = CGRectMake(gCurCB.view.inpOrg.x, gCurCB.view.inpOrg.y, CURSOR_W, gCurCB.curFontH);
            } else {
                EquationBlock *exp = p.expo;
                id lastObj = exp.children.lastObject;
                
                locaLastLyr(gCurCB.curEq, lastObj);
            }
        } else {
            CGPoint pos = gCurCB.view.inpOrg;
            CGFloat incrWidth = 0.0;
            
            EquationTextLayer *baseLayer = [[EquationTextLayer alloc] init:@"_" :pos :gCurCB.curEq :TEXTLAYER_EMPTY];
            //baseLayer.parent = gCurCB.curParent;
            [gCurCB.view.layer addSublayer: baseLayer];
            
            [gCurCB updateFontInfo:gCurCB.curFontLvl + 1];
            
            pos.x += baseLayer.frame.size.width;
            pos.y = (pos.y + baseLayer.frame.size.height * 0.45) - gCurCB.curFontH;
            
            EquationBlock *exp = [[EquationBlock alloc] init:pos :gCurCB.curEq];
            exp.roll = ROLL_EXPO_ROOT;
            exp.parent = baseLayer;
            baseLayer.expo = exp;
            
            EquationTextLayer *expLayer = [[EquationTextLayer alloc] init:@"_" :pos :gCurCB.curEq :TEXTLAYER_EMPTY];
            expLayer.parent = exp;
            exp.numerFrame = expLayer.frame;
            exp.mainFrame = expLayer.frame;
            expLayer.roll = ROLL_NUMERATOR;
            expLayer.c_idx = 0;
            [exp.children addObject:expLayer];
            [gCurCB.view.layer addSublayer: expLayer];
            [baseLayer updateFrameBaseOnExpo];
            
            incrWidth = baseLayer.mainFrame.size.width;
            
            [gCurCB updateFontInfo:gCurCB.curFontLvl - 1];
            
            if(gCurCB.curMode == MODE_INPUT) {
                EquationBlock *eb = gCurCB.curParent;
                
                baseLayer.c_idx = eb.children.count;
                [eb.children addObject:baseLayer];
            } else if(gCurCB.curMode == MODE_INSERT) {
                EquationBlock *eb = gCurCB.curParent;
                
                [eb.children insertObject:baseLayer atIndex: gCurCB.insertCIdx];
                
                /*Update c_idx*/
                [eb updateCIdx];
            } else if(gCurCB.curMode == MODE_DUMP_ROOT) {
                Equation *eq = gCurCB.curEq;
                EquationBlock *newRoot = [[EquationBlock alloc] init:eq];
                newRoot.roll = ROLL_ROOT;
                newRoot.parent = nil;
                newRoot.numerFrame = eq.root.mainFrame;
                newRoot.numerTopHalf = eq.root.mainFrame.size.height / 2.0;
                newRoot.numerBtmHalf = eq.root.mainFrame.size.height / 2.0;
                newRoot.mainFrame = newRoot.numerFrame;
                eq.root.roll = ROLL_NUMERATOR;
                eq.root.parent = newRoot;
                
                if (gCurCB.insertCIdx == 0) {
                    baseLayer.c_idx = 0;
                    [newRoot.children addObject:baseLayer];
                    eq.root.c_idx = 1;
                    [newRoot.children addObject:eq.root];
                    gCurCB.curMode = MODE_INSERT;
                } else {
                    eq.root.c_idx = 0;
                    [newRoot.children addObject:eq.root];
                    baseLayer.c_idx = 1;
                    [newRoot.children addObject:baseLayer];
                    gCurCB.curMode = MODE_INPUT;
                }
                
                baseLayer.roll = ROLL_NUMERATOR;
                eq.root = newRoot;
                gCurCB.curParent = newRoot;
                gCurCB.curRoll = ROLL_NUMERATOR;
            } else if(gCurCB.curMode == MODE_DUMP_RADICAL) {
                RadicalBlock *rBlock = gCurCB.curParent;
                EquationBlock *orgRootRoot = rBlock.content;
                EquationBlock *newRootRoot = [[EquationBlock alloc] init:gCurCB.curEq];
                newRootRoot.roll = ROLL_ROOT_ROOT;
                newRootRoot.parent = rBlock;
                newRootRoot.numerFrame = orgRootRoot.mainFrame;
                newRootRoot.numerTopHalf = orgRootRoot.mainFrame.size.height / 2.0;
                newRootRoot.numerBtmHalf = orgRootRoot.mainFrame.size.height / 2.0;
                newRootRoot.mainFrame = newRootRoot.numerFrame;
                orgRootRoot.roll = ROLL_NUMERATOR;
                orgRootRoot.parent = newRootRoot;
                
                if (gCurCB.insertCIdx == 0) {
                    baseLayer.c_idx = 0;
                    [newRootRoot.children addObject:baseLayer];
                    orgRootRoot.c_idx = 1;
                    [newRootRoot.children addObject:orgRootRoot];
                    gCurCB.curMode = MODE_INSERT;
                } else {
                    orgRootRoot.c_idx = 0;
                    [newRootRoot.children addObject:orgRootRoot];
                    baseLayer.c_idx = 1;
                    [newRootRoot.children addObject:baseLayer];
                    gCurCB.curMode = MODE_INPUT;
                }
                
                baseLayer.roll = ROLL_NUMERATOR;
                rBlock.content = newRootRoot;
                gCurCB.curParent = newRootRoot;
                gCurCB.curRoll = ROLL_NUMERATOR;
            } else if(gCurCB.curMode == MODE_DUMP_WETL) {
                WrapedEqTxtLyr *wetl = gCurCB.curParent;
                EquationBlock *orgWrapRoot = wetl.content;
                EquationBlock *newWrapRoot = [[EquationBlock alloc] init:gCurCB.curEq];
                newWrapRoot.roll = ROLL_WRAP_ROOT;
                newWrapRoot.parent = wetl;
                newWrapRoot.numerFrame = orgWrapRoot.mainFrame;
                newWrapRoot.numerTopHalf = orgWrapRoot.mainFrame.size.height / 2.0;
                newWrapRoot.numerBtmHalf = orgWrapRoot.mainFrame.size.height / 2.0;
                newWrapRoot.mainFrame = newWrapRoot.numerFrame;
                orgWrapRoot.roll = ROLL_NUMERATOR;
                orgWrapRoot.parent = newWrapRoot;
                
                if (gCurCB.insertCIdx == 0) {
                    baseLayer.c_idx = 0;
                    [newWrapRoot.children addObject:baseLayer];
                    orgWrapRoot.c_idx = 1;
                    [newWrapRoot.children addObject:orgWrapRoot];
                    gCurCB.curMode = MODE_INSERT;
                } else {
                    orgWrapRoot.c_idx = 0;
                    [newWrapRoot.children addObject:orgWrapRoot];
                    baseLayer.c_idx = 1;
                    [newWrapRoot.children addObject:baseLayer];
                    gCurCB.curMode = MODE_INPUT;
                }
                
                baseLayer.roll = ROLL_NUMERATOR;
                wetl.content = newWrapRoot;
                gCurCB.curParent = newWrapRoot;
                gCurCB.curRoll = ROLL_NUMERATOR;
            } else
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            
            baseLayer.parent = gCurCB.curParent;
            
            [(EquationBlock *)gCurCB.curParent updateFrameWidth:incrWidth :gCurCB.curRoll];
            [(EquationBlock *)gCurCB.curParent updateFrameHeightS1:baseLayer];
            [gCurCB.curEq.root adjustElementPosition];
            
            gCurCB.insertCIdx = baseLayer.c_idx + 1;
            gCurCB.txtInsIdx = 0;
            gCurCB.curTxtLyr = baseLayer;
            gCurCB.curBlk = baseLayer;
            gCurCB.view.inpOrg = baseLayer.frame.origin;
            gCurCB.view.cursor.frame = CGRectMake(gCurCB.view.inpOrg.x, gCurCB.view.inpOrg.y, CURSOR_W, gCurCB.curFontH);
        }
    } else {
        [gCurCB updateFontInfo:gCurCB.curFontLvl + 1];
        
        if (gCurCB.curTxtLyr.expo == nil) {
            CGFloat orgW = gCurCB.curTxtLyr.mainFrame.size.width;
            CGFloat x = gCurCB.curTxtLyr.frame.origin.x + orgW;
            
            CGFloat y = (gCurCB.view.inpOrg.y + gCurCB.curTxtLyr.mainFrame.size.height * 0.45) - gCurCB.curFontH;
            gCurCB.view.inpOrg = CGPointMake(x, y);
            gCurCB.view.cursor.frame = CGRectMake(gCurCB.view.inpOrg.x, gCurCB.view.inpOrg.y, CURSOR_W, gCurCB.curFontH);
            
            EquationBlock *eBlock = [[EquationBlock alloc] init:gCurCB.view.inpOrg :gCurCB.curEq];
            eBlock.roll = ROLL_EXPO_ROOT;
            eBlock.parent = gCurCB.curTxtLyr;
            gCurCB.curTxtLyr.expo = eBlock;
            
            EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :gCurCB.view.inpOrg :gCurCB.curEq :TEXTLAYER_EMPTY];
            layer.parent = eBlock;
            eBlock.numerFrame = layer.frame;
            eBlock.mainFrame = layer.frame;
            layer.roll = ROLL_NUMERATOR;
            layer.c_idx = 0;
            [eBlock.children addObject:layer];
            [gCurCB.view.layer addSublayer: layer];
            [gCurCB.curTxtLyr updateFrameBaseOnExpo];
            
            CGFloat inc = gCurCB.curTxtLyr.mainFrame.size.width - orgW;
            [(EquationBlock *)gCurCB.curParent updateFrameWidth:inc :gCurCB.curRoll];
            [(EquationBlock *)gCurCB.curParent updateFrameHeightS1:gCurCB.curTxtLyr];
            [gCurCB.curEq.root adjustElementPosition];
            
            gCurCB.insertCIdx = layer.c_idx + 1;
            gCurCB.txtInsIdx = 0;
            gCurCB.curTxtLyr = layer;
            gCurCB.curBlk = layer;
            gCurCB.curParent = eBlock;
            gCurCB.curRoll = ROLL_NUMERATOR;
            gCurCB.curMode = MODE_INPUT;
            
//            if ((gCurCB.root.mainFrame.origin.y < 0.0 || gCurCB.root.mainFrame.origin.x + gCurCB.root.mainFrame.size.width > scnWidth) && gCurCB.zoomInLvl < 2) {
//                gCurCB.zoomInLvl++;
//                [self zoom];
//            }
        } else {
            EquationBlock *exp = gCurCB.curTxtLyr.expo;
            id lastObj = exp.children.lastObject;

            locaLastLyr(gCurCB.curEq, lastObj);
        }
        
    }
    
    if ((int)gCurCB.curEq.maxRootHeight < (int)gCurCB.curEq.root.mainFrame.size.height) {
        CGFloat dis = gCurCB.curEq.root.mainFrame.size.height - gCurCB.curEq.maxRootHeight;
        gCurCB.curEq.maxRootHeight = gCurCB.curEq.root.mainFrame.size.height;
        for (Equation *eq in gCurCB.eqList) {
            [eq moveUp:dis];
        }
    }
    
    [gCurCB.view updateContentView];
}

- (void)handleParenthBtnClick : (int)l_r {
    CGFloat incrWidth = 0.0;
    Parentheses *needUpdateH = nil;
    
    if (gCurCB.curTxtLyr != nil && gCurCB.curTxtLyr.type == TEXTLAYER_EMPTY) {
        if (gCurCB.curTxtLyr.expo == nil) {
            EquationBlock *cb = gCurCB.curParent;
            [gCurCB.curTxtLyr destroy];
            [cb.children removeObjectAtIndex:gCurCB.curTxtLyr.c_idx];
            [cb updateCIdx];
            incrWidth -= gCurCB.curTxtLyr.mainFrame.size.width;
        } else if ([gCurCB.curTxtLyr.expo.children.firstObject isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *l = gCurCB.curTxtLyr.expo.children.firstObject;
            if (l.type == TEXTLAYER_EMPTY) {
                EquationBlock *cb = gCurCB.curParent;
                [gCurCB.curTxtLyr destroy];
                [cb.children removeObjectAtIndex:gCurCB.curTxtLyr.c_idx];
                [cb updateCIdx];
                incrWidth -= gCurCB.curTxtLyr.mainFrame.size.width;
            } else {
                gCurCB.curMode = MODE_INSERT;
                gCurCB.insertCIdx = gCurCB.curTxtLyr.c_idx;
            }
        } else {
            gCurCB.curMode = MODE_INSERT;
            gCurCB.insertCIdx = gCurCB.curTxtLyr.c_idx;
        }
    }

    Parentheses *parenth = [[Parentheses alloc] init:gCurCB.view.inpOrg :gCurCB.curEq :l_r :self];
    
    if(gCurCB.curMode == MODE_INPUT) {
        EquationBlock *block = gCurCB.curParent;
        
        parenth.c_idx = block.children.count;
        [block.children addObject:parenth];
    } else if(gCurCB.curMode == MODE_INSERT) {
        EquationBlock *block = gCurCB.curParent;
        
        parenth.c_idx = gCurCB.insertCIdx;
        [block.children insertObject:parenth atIndex:parenth.c_idx];
        /*Update c_idx*/
        [block updateCIdx];
    } else if(gCurCB.curMode == MODE_DUMP_ROOT) {
        Equation *eq = gCurCB.curEq;
        EquationBlock *newRoot = [[EquationBlock alloc] init:eq];
        newRoot.roll = ROLL_ROOT;
        newRoot.parent = nil;
        newRoot.numerFrame = eq.root.mainFrame;
        newRoot.numerTopHalf = eq.root.mainFrame.size.height / 2.0;
        newRoot.numerBtmHalf = eq.root.mainFrame.size.height / 2.0;
        newRoot.mainFrame = newRoot.numerFrame;
        eq.root.roll = ROLL_NUMERATOR;
        eq.root.parent = newRoot;
        
        if (gCurCB.insertCIdx == 0) {
            parenth.c_idx = 0;
            [newRoot.children addObject:parenth];
            eq.root.c_idx = 1;
            [newRoot.children addObject:eq.root];
            gCurCB.curMode = MODE_INSERT;
        } else {
            eq.root.c_idx = 0;
            [newRoot.children addObject:eq.root];
            parenth.c_idx = 1;
            [newRoot.children addObject:parenth];
            gCurCB.curMode = MODE_INPUT;
        }
        gCurCB.curRoll = ROLL_NUMERATOR;
        parenth.roll = ROLL_NUMERATOR;
        eq.root = newRoot;
        gCurCB.curParent = newRoot;
    } else if(gCurCB.curMode == MODE_DUMP_RADICAL) {
        RadicalBlock *rBlock = gCurCB.curParent;
        EquationBlock *orgRootRoot = rBlock.content;
        EquationBlock *newRootRoot = [[EquationBlock alloc] init:gCurCB.curEq];
        newRootRoot.roll = ROLL_ROOT_ROOT;
        newRootRoot.parent = rBlock;
        newRootRoot.numerFrame = orgRootRoot.mainFrame;
        newRootRoot.numerTopHalf = orgRootRoot.mainFrame.size.height / 2.0;
        newRootRoot.numerBtmHalf = orgRootRoot.mainFrame.size.height / 2.0;
        newRootRoot.mainFrame = newRootRoot.numerFrame;
        orgRootRoot.roll = ROLL_NUMERATOR;
        orgRootRoot.parent = newRootRoot;
        
        if (gCurCB.insertCIdx == 0) {
            parenth.c_idx = 0;
            [newRootRoot.children addObject:parenth];
            orgRootRoot.c_idx = 1;
            [newRootRoot.children addObject:orgRootRoot];
            gCurCB.curMode = MODE_INSERT;
            gCurCB.insertCIdx = 1;
        } else {
            orgRootRoot.c_idx = 0;
            [newRootRoot.children addObject:orgRootRoot];
            parenth.c_idx = 1;
            [newRootRoot.children addObject:parenth];
            gCurCB.curMode = MODE_INPUT;
        }
        gCurCB.curRoll = ROLL_NUMERATOR;
        parenth.roll = ROLL_NUMERATOR;
        rBlock.content = newRootRoot;
        gCurCB.curParent = newRootRoot;
    } else if(gCurCB.curMode == MODE_DUMP_EXPO) {
        EquationBlock *newExpo = [[EquationBlock alloc] init:gCurCB.curEq];
        EquationBlock *orgExpo = nil;
        if ([gCurCB.curParent isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *l = gCurCB.curParent;
            orgExpo = l.expo;
            l.expo = newExpo;
        } else if ([gCurCB.curParent isMemberOfClass:[Parentheses class]]) {
            Parentheses *p = gCurCB.curParent;
            orgExpo = p.expo;
            p.expo = newExpo;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        newExpo.roll = ROLL_EXPO_ROOT;
        newExpo.parent = gCurCB.curParent;
        newExpo.numerFrame = orgExpo.mainFrame;
        newExpo.numerTopHalf = orgExpo.mainFrame.size.height / 2.0;
        newExpo.numerBtmHalf = orgExpo.mainFrame.size.height / 2.0;
        newExpo.mainFrame = newExpo.numerFrame;
        orgExpo.roll = ROLL_NUMERATOR;
        orgExpo.parent = newExpo;
        
        if (gCurCB.insertCIdx == 0) {
            orgExpo.c_idx = 1;
            parenth.c_idx = 0;
            [newExpo.children addObject:parenth];
            [newExpo.children addObject:orgExpo];
            gCurCB.curMode = MODE_INSERT;
            gCurCB.insertCIdx = 1;
        } else {
            orgExpo.c_idx = 0;
            [newExpo.children addObject:orgExpo];
            parenth.c_idx = 1;
            [newExpo.children addObject:parenth];
            gCurCB.curMode = MODE_INPUT;
        }
        gCurCB.curRoll = ROLL_NUMERATOR;
        parenth.roll = ROLL_NUMERATOR;
        gCurCB.curParent = newExpo;
    } else if(gCurCB.curMode == MODE_DUMP_WETL) {
        WrapedEqTxtLyr *wetl = gCurCB.curParent;
        EquationBlock *orgWrapRoot = wetl.content;
        EquationBlock *newWrapRoot = [[EquationBlock alloc] init:gCurCB.curEq];
        newWrapRoot.roll = ROLL_ROOT_ROOT;
        newWrapRoot.parent = wetl;
        newWrapRoot.numerFrame = orgWrapRoot.mainFrame;
        newWrapRoot.numerTopHalf = orgWrapRoot.mainFrame.size.height / 2.0;
        newWrapRoot.numerBtmHalf = orgWrapRoot.mainFrame.size.height / 2.0;
        newWrapRoot.mainFrame = newWrapRoot.numerFrame;
        orgWrapRoot.roll = ROLL_NUMERATOR;
        orgWrapRoot.parent = newWrapRoot;
        
        if (gCurCB.insertCIdx == 0) {
            parenth.c_idx = 0;
            [newWrapRoot.children addObject:parenth];
            orgWrapRoot.c_idx = 1;
            [newWrapRoot.children addObject:orgWrapRoot];
            gCurCB.curMode = MODE_INSERT;
            gCurCB.insertCIdx = 1;
        } else {
            orgWrapRoot.c_idx = 0;
            [newWrapRoot.children addObject:orgWrapRoot];
            parenth.c_idx = 1;
            [newWrapRoot.children addObject:parenth];
            gCurCB.curMode = MODE_INPUT;
        }
        gCurCB.curRoll = ROLL_NUMERATOR;
        parenth.roll = ROLL_NUMERATOR;
        wetl.content = newWrapRoot;
        gCurCB.curParent = newWrapRoot;
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return;
    }
    
    parenth.parent = gCurCB.curParent;
    
    if(l_r == LEFT_PARENTH) {
        EquationBlock *par = parenth.parent;
        CGFloat h = gCurCB.curFontH;
        int pcnt = 1;
        for (int i = (int)parenth.c_idx + 1; i < par.children.count; i++) {
            id b = [par.children objectAtIndex:i];
            if([b isMemberOfClass:[EquationBlock class]]) {
                EquationBlock * eb = b;
                if (h < eb.mainFrame.size.height)
                    h = eb.mainFrame.size.height;
            } else if([b isMemberOfClass:[RadicalBlock class]]) {
                RadicalBlock * rb = b;
                if (h < rb.frame.size.height)
                    h = rb.frame.size.height;
            } else if([b isMemberOfClass:[EquationTextLayer class]]) {
                EquationTextLayer *layer = b;
                if (h < layer.mainFrame.size.height)
                    h = layer.mainFrame.size.height;
            } else if([b isMemberOfClass:[FractionBarLayer class]]) {
                break;
            } else if([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                WrapedEqTxtLyr *wetl = b;
                if (h < wetl.mainFrame.size.height)
                    h = wetl.mainFrame.size.height;
            } else if([b isMemberOfClass:[Parentheses class]]) {
                Parentheses *p = b;
                if (p.l_or_r == RIGHT_PARENTH) {
                    pcnt--;
                    
                    if (pcnt == 0) {
                        parenth.frame = CGRectMake(parenth.frame.origin.x, parenth.frame.origin.y, h / PARENTH_HW_R, h);
                        
                        if ((int)p.frame.size.height != (int)h) {
                            if (p.expo != nil) {
                                needUpdateH = p;
                            }
                            
                            CGFloat orgW = p.frame.size.width;
                            p.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, h / PARENTH_HW_R, h);
                            [p setNeedsDisplay];
                            [p updateFrameBaseOnBase];
                            incrWidth += (p.frame.size.width - orgW);
                        }
                        
                        break;
                    }
                } else
                    pcnt++;
                
                if (h < p.frame.size.height)
                    h = p.frame.size.height;
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
        }
    } else {
        EquationBlock *par = parenth.parent;
        CGFloat h = gCurCB.curFontH;
        int pcnt = 1;
        for (int i = (int)parenth.c_idx - 1; i >= 0; i--) {
            id b = [par.children objectAtIndex:i];
            if([b isMemberOfClass:[EquationBlock class]]) {
                EquationBlock * eb = b;
                if (h < eb.mainFrame.size.height)
                    h = eb.mainFrame.size.height;
            } else if([b isMemberOfClass:[RadicalBlock class]]) {
                RadicalBlock * rb = b;
                if (h < rb.frame.size.height)
                    h = rb.frame.size.height;
            } else if([b isMemberOfClass:[EquationTextLayer class]]) {
                EquationTextLayer *layer = b;
                if (h < layer.mainFrame.size.height)
                    h = layer.mainFrame.size.height;
            } else if([b isMemberOfClass:[FractionBarLayer class]]) {
                break;
            } else if([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                WrapedEqTxtLyr *wetl = b;
                if (h < wetl.mainFrame.size.height)
                    h = wetl.mainFrame.size.height;
            } else if([b isMemberOfClass:[Parentheses class]]) {
                Parentheses *p = b;
                if (p.l_or_r == LEFT_PARENTH) {
                    pcnt--;
                    
                    if (pcnt == 0) {
                        parenth.frame = CGRectMake(parenth.frame.origin.x, parenth.frame.origin.y, h / PARENTH_HW_R, h);
                        
                        if ((int)p.frame.size.height != (int)h) {
                            CGFloat orgW = p.frame.size.width;
                            p.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, h / PARENTH_HW_R, h);
                            [p setNeedsDisplay];
                            [p updateFrameBaseOnBase];
                            incrWidth += (p.frame.size.width - orgW);
                        }
                        
                        break;
                    }
                } else
                    pcnt++;
                
                if (h < p.frame.size.height)
                    h = p.frame.size.height;
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
        }
    }
    
    [gCurCB.view.layer addSublayer:parenth];
    [parenth setNeedsDisplay];
    [parenth updateFrameBaseOnBase];
    
    incrWidth += parenth.frame.size.width;
    
    /* Update frame info of current block */
    [(EquationBlock *)gCurCB.curParent updateFrameWidth:incrWidth :gCurCB.curRoll];
    if (needUpdateH)
        [(EquationBlock *)gCurCB.curParent updateFrameHeightS1:needUpdateH];
    [gCurCB.curEq.root adjustElementPosition];
    
    /* Move cursor */
    CGFloat cursorOrgX = parenth.frame.origin.x + parenth.frame.size.width;
    CGFloat cursorOrgY = parenth.frame.origin.y;
    
    gCurCB.view.cursor.frame = CGRectMake(cursorOrgX, cursorOrgY, CURSOR_W, parenth.frame.size.height);
    gCurCB.view.inpOrg = CGPointMake(cursorOrgX, cursorOrgY + parenth.frame.size.height / 2.0 - gCurCB.curFontH / 2.0);
    
    gCurCB.insertCIdx = parenth.c_idx + 1;
    gCurCB.curBlk = parenth;
    gCurCB.curTxtLyr = nil;
    
    if ((int)gCurCB.curEq.maxRootHeight < (int)gCurCB.curEq.root.mainFrame.size.height) {
        CGFloat dis = gCurCB.curEq.root.mainFrame.size.height - gCurCB.curEq.maxRootHeight;
        gCurCB.curEq.maxRootHeight = gCurCB.curEq.root.mainFrame.size.height;
        for (Equation *eq in gCurCB.eqList) {
            [eq moveUp:dis];
        }
    }
    
    [gCurCB.view updateContentView];
}

- (void)handleDelBtnClick {
    if ([gCurCB.curBlk isMemberOfClass:[EquationBlock class]]) {
        EquationBlock *eb = gCurCB.curBlk;
        if (gCurCB.insertCIdx == eb.c_idx) {
            id pre = getPrevBlk(gCurCB.curEq, eb);
            if (pre == nil) {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
            
            EquationBlock *par = eb.parent;
            if (eb.c_idx == 0 || [[par.children objectAtIndex:eb.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *layer = pre;
                    if (layer.is_base_expo == eb.is_base_expo) {
                        (void)locaLastLyr(gCurCB.curEq, pre);
                    } else { //Switch from expo to base in a same text layer
                        cfgEqnBySlctBlk(gCurCB.curEq, layer, CGPointMake(layer.frame.origin.x + layer.frame.size.width - 1.0, layer.frame.origin.y + 1.0));
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    Parentheses *p = pre;
                    if (p.is_base_expo == eb.is_base_expo) {
                        (void)locaLastLyr(gCurCB.curEq, pre);
                    } else { //Switch from expo to base in a same text layer
                        cfgEqnBySlctBlk(gCurCB.curEq, p, CGPointMake(p.frame.origin.x + p.frame.size.width - 1.0, p.frame.origin.y + 1.0));
                    }
                } else {
                    (void)locaLastLyr(gCurCB.curEq, pre);
                }
            } else {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *l = pre;
                    if (l.expo != nil) {
                        (void)locaLastLyr(gCurCB.curEq, l);
                    } else {
                        if (l.strLenTbl.count == 2 || l.strLenTbl.count == 1) { // 1 char num/op/empty
                            [gCurCB.curEq removeElement:l];
                        } else {
                            CGFloat orgW = l.mainFrame.size.width;
                            [l delNumCharAt:(int)l.strLenTbl.count - 1];
                            CGFloat incrWidth = l.mainFrame.size.width - orgW;
                            [(EquationBlock *)l.parent updateFrameWidth:incrWidth :l.roll];
                            [gCurCB.curEq.root adjustElementPosition];
                            cfgEqnBySlctBlk(gCurCB.curEq, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                        }
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    Parentheses *p = pre;
                    if (p.expo == nil) {
                        [gCurCB.curEq removeElement:pre];
                    } else {
                        (void)locaLastLyr(gCurCB.curEq, pre);
                    }
                } else {
                    (void)locaLastLyr(gCurCB.curEq, pre);
                }
            }
        } else if (gCurCB.insertCIdx == eb.c_idx + 1) {
            (void)locaLastLyr(gCurCB.curEq, eb);
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
    } else if ([gCurCB.curBlk isMemberOfClass:[RadicalBlock class]]) {
        RadicalBlock *rb = gCurCB.curBlk;
        if (gCurCB.insertCIdx == rb.c_idx) {
            id pre = getPrevBlk(gCurCB.curEq, rb);
            if (pre == nil) {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
            
            EquationBlock *par = rb.parent;
            if (rb.c_idx == 0 || [[par.children objectAtIndex:rb.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *layer = pre;
                    if (layer.is_base_expo == rb.is_base_expo) {
                        (void)locaLastLyr(gCurCB.curEq, pre);
                    } else { //Switch from expo to base in a same text layer
                        cfgEqnBySlctBlk(gCurCB.curEq, layer, CGPointMake(layer.frame.origin.x + layer.frame.size.width - 1.0, layer.frame.origin.y + 1.0));
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    Parentheses *p = pre;
                    if (p.is_base_expo == rb.is_base_expo) {
                        (void)locaLastLyr(gCurCB.curEq, pre);
                    } else { //Switch from expo to base in a same text layer
                        cfgEqnBySlctBlk(gCurCB.curEq, p, CGPointMake(p.frame.origin.x + p.frame.size.width - 1.0, p.frame.origin.y + 1.0));
                    }
                } else {
                    (void)locaLastLyr(gCurCB.curEq, pre);
                }
            } else {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *l = pre;
                    if (l.expo != nil) {
                        (void)locaLastLyr(gCurCB.curEq, l);
                    } else {
                        if (l.strLenTbl.count == 2 || l.strLenTbl.count == 1) { // 1 char num/op/empty
                            [gCurCB.curEq removeElement:l];
                        } else {
                            CGFloat orgW = l.mainFrame.size.width;
                            [l delNumCharAt:(int)l.strLenTbl.count - 1];
                            CGFloat incrWidth = l.mainFrame.size.width - orgW;
                            [(EquationBlock *)l.parent updateFrameWidth:incrWidth :l.roll];
                            [gCurCB.curEq.root adjustElementPosition];
                            cfgEqnBySlctBlk(gCurCB.curEq, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                        }
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    Parentheses *p = pre;
                    if (p.expo == nil) {
                        [gCurCB.curEq removeElement:pre];
                    } else {
                        (void)locaLastLyr(gCurCB.curEq, pre);
                    }
                } else {
                    (void)locaLastLyr(gCurCB.curEq, pre);
                }
            }
        } else if (gCurCB.insertCIdx == rb.c_idx + 1) {
            (void)locaLastLyr(gCurCB.curEq, rb);
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
    } else if ([gCurCB.curBlk isMemberOfClass:[WrapedEqTxtLyr class]]) {
        WrapedEqTxtLyr *wetl = gCurCB.curBlk;
        if (gCurCB.insertCIdx == wetl.c_idx) {
            id pre = getPrevBlk(gCurCB.curEq, wetl);
            if (pre == nil) {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
            
            EquationBlock *par = wetl.parent;
            if (wetl.c_idx == 0 || [[par.children objectAtIndex:wetl.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *layer = pre;
                    if (layer.is_base_expo == wetl.is_base_expo) {
                        (void)locaLastLyr(gCurCB.curEq, pre);
                    } else { //Switch from expo to base in a same text layer
                        cfgEqnBySlctBlk(gCurCB.curEq, layer, CGPointMake(layer.frame.origin.x + layer.frame.size.width - 1.0, layer.frame.origin.y + 1.0));
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    Parentheses *p = pre;
                    if (p.is_base_expo == wetl.is_base_expo) {
                        (void)locaLastLyr(gCurCB.curEq, pre);
                    } else { //Switch from expo to base in a same text layer
                        cfgEqnBySlctBlk(gCurCB.curEq, p, CGPointMake(p.frame.origin.x + p.frame.size.width - 1.0, p.frame.origin.y + 1.0));
                    }
                } else {
                    (void)locaLastLyr(gCurCB.curEq, pre);
                }
            } else {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *l = pre;
                    if (l.expo != nil) {
                        (void)locaLastLyr(gCurCB.curEq, l);
                    } else {
                        if (l.strLenTbl.count == 2 || l.strLenTbl.count == 1) { // 1 char num/op/empty
                            [gCurCB.curEq removeElement:l];
                        } else {
                            CGFloat orgW = l.mainFrame.size.width;
                            [l delNumCharAt:(int)l.strLenTbl.count - 1];
                            CGFloat incrWidth = l.mainFrame.size.width - orgW;
                            [(EquationBlock *)l.parent updateFrameWidth:incrWidth :l.roll];
                            [gCurCB.curEq.root adjustElementPosition];
                            cfgEqnBySlctBlk(gCurCB.curEq, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                        }
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    Parentheses *p = pre;
                    if (p.expo == nil) {
                        [gCurCB.curEq removeElement:pre];
                    } else {
                        (void)locaLastLyr(gCurCB.curEq, pre);
                    }
                } else {
                    (void)locaLastLyr(gCurCB.curEq, pre);
                }
            }
        } else if (gCurCB.insertCIdx == wetl.c_idx + 1) {
            (void)locaLastLyr(gCurCB.curEq, wetl);
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
    } else if ([gCurCB.curBlk isMemberOfClass:[FractionBarLayer class]]) {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return;
    } else if ([gCurCB.curBlk isMemberOfClass:[EquationTextLayer class]]) {
        EquationTextLayer *curLayer = gCurCB.curBlk;
        EquationBlock *par = curLayer.parent;
        if (gCurCB.insertCIdx == curLayer.c_idx) {
            id pre = getPrevBlk(gCurCB.curEq, curLayer);
            if (pre == nil) {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
            
            if (curLayer.c_idx == 0 || [[par.children objectAtIndex:curLayer.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *layer = pre;
                    if (layer.is_base_expo == curLayer.is_base_expo) {
                        (void)locaLastLyr(gCurCB.curEq, pre);
                    } else { //Switch from expo to base in a same text layer
                        cfgEqnBySlctBlk(gCurCB.curEq, layer, CGPointMake(layer.frame.origin.x + layer.frame.size.width - 1.0, layer.frame.origin.y + 1.0));
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    Parentheses *p = pre;
                    if (p.is_base_expo == curLayer.is_base_expo) {
                        (void)locaLastLyr(gCurCB.curEq, pre);
                    } else { //Switch from expo to base in a same text layer
                        cfgEqnBySlctBlk(gCurCB.curEq, p, CGPointMake(p.frame.origin.x + p.frame.size.width - 1.0, p.frame.origin.y + 1.0));
                    }
                } else {
                    (void)locaLastLyr(gCurCB.curEq, pre);
                }
            } else {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *l = pre;
                    if (l.expo != nil) {
                        (void)locaLastLyr(gCurCB.curEq, l);
                    } else {
                        if (l.strLenTbl.count == 2 || l.strLenTbl.count == 1) { // 1 char num/op/empty
                            [gCurCB.curEq removeElement:l];
                        } else {
                            CGFloat orgW = l.mainFrame.size.width;
                            [l delNumCharAt:(int)l.strLenTbl.count - 1];
                            CGFloat incrWidth = l.mainFrame.size.width - orgW;
                            [(EquationBlock *)l.parent updateFrameWidth:incrWidth :l.roll];
                            [gCurCB.curEq.root adjustElementPosition];
                            cfgEqnBySlctBlk(gCurCB.curEq, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                        }
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    Parentheses *p = pre;
                    if (p.expo == nil) {
                        [gCurCB.curEq removeElement:pre];
                    } else {
                        (void)locaLastLyr(gCurCB.curEq, pre);
                    }
                } else {
                    (void)locaLastLyr(gCurCB.curEq, pre);
                }
            }
        } else if (gCurCB.insertCIdx == curLayer.c_idx + 1) {
            if (curLayer.expo != nil && gCurCB.curTxtLyr == nil) {
                id blk = curLayer.expo.children.lastObject;
                (void)locaLastLyr(gCurCB.curEq, blk);
            } else if (curLayer.expo != nil && gCurCB.curTxtLyr != nil) {
                if (curLayer.strLenTbl.count == 2 && gCurCB.txtInsIdx == 1) { // Number 1 char
                    NSMutableAttributedString *orgStr = [[NSMutableAttributedString alloc] initWithAttributedString:curLayer.string];
                    CGFloat orgWidth = [orgStr size].width;
                    [orgStr replaceCharactersInRange:NSMakeRange(0, 1) withString:@"_"];
                    [orgStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0,1)];
                    CGFloat newWidth = [orgStr size].width;
                    CGFloat incrWidth = newWidth - orgWidth;
                    
                    CGRect frame = curLayer.frame;
                    frame.size.width = [orgStr size].width;
                    curLayer.frame = frame;
                    curLayer.string = orgStr;
                    [curLayer updateFrameBaseOnBase];
                    
                    [(EquationBlock *)gCurCB.curParent updateFrameWidth:incrWidth :curLayer.roll];
                    [gCurCB.curEq.root adjustElementPosition];
                    
                    gCurCB.view.inpOrg = CGPointMake(curLayer.frame.origin.x, curLayer.frame.origin.y);
                    gCurCB.view.cursor.frame = CGRectMake(gCurCB.view.inpOrg.x, gCurCB.view.inpOrg.y, CURSOR_W, gCurCB.curFontH);
                    
                    curLayer.type = TEXTLAYER_EMPTY;
                    [curLayer.strLenTbl removeLastObject];
                    gCurCB.txtInsIdx = 0;
                } else if (curLayer.strLenTbl.count == 1 && gCurCB.txtInsIdx == 0) { // Empty layer
                    id pre = getPrevBlk(gCurCB.curEq, curLayer);
                    EquationBlock *par = curLayer.parent;
                    if (curLayer.c_idx == 0 || [[par.children objectAtIndex:curLayer.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                        if (pre != nil) {
                            if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                                EquationTextLayer *layer = pre;
                                if (layer.is_base_expo == curLayer.is_base_expo) {
                                    (void)locaLastLyr(gCurCB.curEq, pre);
                                } else { //Switch from expo to base in a same text layer
                                    cfgEqnBySlctBlk(gCurCB.curEq, layer, CGPointMake(layer.frame.origin.x + layer.frame.size.width - 1.0, layer.frame.origin.y + 1.0));
                                }
                            } else if ([pre isMemberOfClass:[Parentheses class]]) {
                                Parentheses *p = pre;
                                if (p.is_base_expo == curLayer.is_base_expo) {
                                    (void)locaLastLyr(gCurCB.curEq, pre);
                                } else { //Switch from expo to base in a same text layer
                                    cfgEqnBySlctBlk(gCurCB.curEq, p, CGPointMake(p.frame.origin.x + p.frame.size.width - 1.0, p.frame.origin.y + 1.0));
                                }
                            } else {
                                (void)locaLastLyr(gCurCB.curEq, pre);
                            }
                        } else {
                            return;
                        }
                    } else {
                        if (pre != nil) {
                            if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                                EquationTextLayer *l = pre;
                                if (l.expo != nil) {
                                    (void)locaLastLyr(gCurCB.curEq, l);
                                } else {
                                    if (l.strLenTbl.count == 2 || l.strLenTbl.count == 1) { // 1 char num/op/empty
                                        [gCurCB.curEq removeElement:l];
                                    } else {
                                        CGFloat orgW = l.mainFrame.size.width;
                                        [l delNumCharAt:(int)l.strLenTbl.count - 1];
                                        CGFloat incrWidth = l.mainFrame.size.width - orgW;
                                        [(EquationBlock *)l.parent updateFrameWidth:incrWidth :l.roll];
                                        [gCurCB.curEq.root adjustElementPosition];
                                        cfgEqnBySlctBlk(gCurCB.curEq, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                                    }
                                }
                            } else if ([pre isMemberOfClass:[Parentheses class]]) {
                                Parentheses *p = pre;
                                if (p.expo == nil) {
                                    [gCurCB.curEq removeElement:pre];
                                } else {
                                    (void)locaLastLyr(gCurCB.curEq, pre);
                                }
                            } else {
                                (void)locaLastLyr(gCurCB.curEq, pre);
                            }
                        } else {
                            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                            return;
                        }
                    }
                } else { // Number > 1 char
                    CGFloat orgW = curLayer.mainFrame.size.width;
                    CGFloat offset = [curLayer delNumCharAt:gCurCB.txtInsIdx--];
                    CGFloat incrWidth = curLayer.mainFrame.size.width - orgW;
                    [(EquationBlock *)gCurCB.curParent updateFrameWidth:incrWidth :gCurCB.curRoll];
                    [gCurCB.curEq.root adjustElementPosition];
                    gCurCB.view.inpOrg = CGPointMake(curLayer.frame.origin.x + offset, curLayer.frame.origin.y);
                    gCurCB.view.cursor.frame = CGRectMake(gCurCB.view.inpOrg.x, gCurCB.view.inpOrg.y, CURSOR_W, gCurCB.curFontH);
                    if (gCurCB.txtInsIdx == 0) {
                        gCurCB.insertCIdx = curLayer.c_idx;
                    }
                }
            } else { // expo == nil
                if (curLayer.strLenTbl.count == 2 && gCurCB.txtInsIdx == 1) { // Number/Op/Paren
                    [gCurCB.curEq removeElement:curLayer];
                } else if (curLayer.strLenTbl.count == 1 && gCurCB.txtInsIdx == 0) { // Empty layer
                    [gCurCB.curEq removeElement:curLayer];
                } else { // Number > 1 char
                    CGFloat orgW = curLayer.mainFrame.size.width;
                    CGFloat offset = [curLayer delNumCharAt:gCurCB.txtInsIdx--];
                    CGFloat incrWidth = curLayer.mainFrame.size.width - orgW;
                    [(EquationBlock *)gCurCB.curParent updateFrameWidth:incrWidth :gCurCB.curRoll];
                    [gCurCB.curEq.root adjustElementPosition];
                    gCurCB.view.inpOrg = CGPointMake(curLayer.frame.origin.x + offset, curLayer.frame.origin.y);
                    gCurCB.view.cursor.frame = CGRectMake(gCurCB.view.inpOrg.x, gCurCB.view.inpOrg.y, CURSOR_W, gCurCB.curFontH);
                    if (gCurCB.txtInsIdx == 0) {
                        gCurCB.insertCIdx = curLayer.c_idx;
                    }
                }
            }
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    } else if ([gCurCB.curBlk isMemberOfClass:[Parentheses class]]) {
        Parentheses *p = gCurCB.curBlk;
        if (gCurCB.insertCIdx == p.c_idx) {
            id pre = getPrevBlk(gCurCB.curEq, p);
            if (pre == nil) {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
            
            EquationBlock *par = p.parent;
            if (p.c_idx == 0 || [[par.children objectAtIndex:p.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *layer = pre;
                    if (layer.is_base_expo == p.is_base_expo) {
                        (void)locaLastLyr(gCurCB.curEq, pre);
                    } else { //Switch from expo to base in a same text layer
                        cfgEqnBySlctBlk(gCurCB.curEq, layer, CGPointMake(layer.frame.origin.x + layer.frame.size.width - 1.0, layer.frame.origin.y + 1.0));
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    Parentheses *pp = pre;
                    if (pp.is_base_expo == p.is_base_expo) {
                        (void)locaLastLyr(gCurCB.curEq, pre);
                    } else { //Switch from expo to base in a same text layer
                        cfgEqnBySlctBlk(gCurCB.curEq, pp, CGPointMake(pp.frame.origin.x + pp.frame.size.width - 1.0, pp.frame.origin.y + 1.0));
                    }
                } else {
                    (void)locaLastLyr(gCurCB.curEq, pre);
                }
            } else {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *l = pre;
                    if (l.expo != nil) {
                        (void)locaLastLyr(gCurCB.curEq, l);
                    } else {
                        if (l.strLenTbl.count == 2 || l.strLenTbl.count == 1) { // 1 char num/op/empty
                            [gCurCB.curEq removeElement:l];
                        } else {
                            CGFloat orgW = l.mainFrame.size.width;
                            [l delNumCharAt:(int)l.strLenTbl.count - 1];
                            CGFloat incrWidth = l.mainFrame.size.width - orgW;
                            [(EquationBlock *)l.parent updateFrameWidth:incrWidth :l.roll];
                            [gCurCB.curEq.root adjustElementPosition];
                            cfgEqnBySlctBlk(gCurCB.curEq, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                        }
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    Parentheses *pp = pre;
                    if (pp.expo == nil) {
                        [gCurCB.curEq removeElement:pre];
                    } else {
                        (void)locaLastLyr(gCurCB.curEq, pre);
                    }
                } else {
                    (void)locaLastLyr(gCurCB.curEq, pre);
                }
            }
        } else if (gCurCB.insertCIdx == p.c_idx + 1) {
            if (p.expo == nil) {
                [gCurCB.curEq removeElement:p];
            } else {
                (void)locaLastLyr(gCurCB.curEq, p);
            }
            
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    [gCurCB.view updateContentView];
}

-(void)delBlock:(NSTimer *)timer{
    [self handleDelBtnClick];
}

-(void)btnDelLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        delBtnLongPressTmr = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(delBlock:) userInfo:nil repeats:YES];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([delBtnLongPressTmr isValid] == YES) {
            [delBtnLongPressTmr invalidate];
            delBtnLongPressTmr = nil;
        }
    }
}

- (void)handleReturnBtnClick {
    int i = 0;
    NSMutableString *str = equationToString(gCurCB.curEq.root, &i);
    if (str == nil) {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return;
    }
    
    NSNumber *result = calculate(str);
    
    NSLog(@"%s%i>~%@~~~~~%@~~~~~", __FUNCTION__, __LINE__, str, result);
    
    if (result != nil) {
        [gCurCB updateFontInfo:0];
        
        for (Equation *eq in gCurCB.eqList) {
            [eq moveUp:gCurCB.curFontH];
        }
        
        [gCurCB.curEq.root moveUp:gCurCB.curFontH];
        
        CGRect f = gCurCB.curEq.root.mainFrame;
        CGPoint pos = CGPointMake(f.size.width, f.origin.y + (f.size.height / 2.0) - (gCurCB.curFontH / 2.0));
        
        gCurCB.curEq.equalsign = [[EquationTextLayer alloc] init:@"=" :pos :gCurCB.curEq :TEXTLAYER_OP];
        gCurCB.curEq.equalsign.opacity = 0.0;
        [gCurCB.view.layer addSublayer:gCurCB.curEq.equalsign];
        
        pos.x += gCurCB.curEq.equalsign.frame.size.width;
        
        gCurCB.curEq.result = [[EquationTextLayer alloc] init:[result stringValue] :pos :gCurCB.curEq :TEXTLAYER_NUM];
        gCurCB.curEq.result.opacity = 0.0;
        [gCurCB.view.layer addSublayer:gCurCB.curEq.result];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.fromValue = [NSNumber numberWithFloat:0.0];
        animation.toValue = [NSNumber numberWithFloat:1.0];
        animation.duration = 0.4;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        
        [gCurCB.curEq.equalsign addAnimation:animation forKey:nil];
        [gCurCB.curEq.result addAnimation:animation forKey:nil];
        
        
        [gCurCB.eqList addObject:gCurCB.curEq];
        
        [gCurCB resetParam];
        
        CGPoint rootPos = CGPointMake(gCurCB.downLeftBasePoint.x, gCurCB.downLeftBasePoint.y - gCurCB.curFontH - 1.0);
        gCurCB.view.cursor.frame = CGRectMake(rootPos.x, rootPos.y, 3.0, gCurCB.curFontH);
        gCurCB.view.inpOrg = gCurCB.view.cursor.frame.origin;
        
        gCurCB.curEq = [[Equation alloc] init:gCurCB :self];
        
        [gCurCB.view updateContentView];
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
}

- (void)handleCleanBtnClick {
    for (Equation *eq in gCurCB.eqList) {
        [eq destroy];
    }
    
    [gCurCB.eqList removeAllObjects];
    
    [gCurCB.curEq destroy];
    
    [gCurCB resetParam];
    
    CGPoint rootPos = CGPointMake(gCurCB.downLeftBasePoint.x, gCurCB.downLeftBasePoint.y - gCurCB.curFontH - 1.0);
    gCurCB.view.cursor.frame = CGRectMake(rootPos.x, rootPos.y, 3.0, gCurCB.curFontH);
    gCurCB.view.inpOrg = gCurCB.view.cursor.frame.origin;

    gCurCB.curEq = [[Equation alloc] init:gCurCB :self];
    
    [gCurCB.view updateContentView];
}

- (void)handleWETLInput: (NSString *)pfx {
    CGFloat incrWidth = 0.0;
    
    if (gCurCB.curTxtLyr != nil && gCurCB.curTxtLyr.type == TEXTLAYER_EMPTY) {
        if (gCurCB.curTxtLyr.expo == nil) {
            EquationBlock *cb = gCurCB.curParent;
            [gCurCB.curTxtLyr destroy];
            [cb.children removeObjectAtIndex:gCurCB.curTxtLyr.c_idx];
            [cb updateCIdx];
            incrWidth -= gCurCB.curTxtLyr.mainFrame.size.width;
        } else if ([gCurCB.curTxtLyr.expo.children.firstObject isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *l = gCurCB.curTxtLyr.expo.children.firstObject;
            if (l.type == TEXTLAYER_EMPTY) {
                EquationBlock *cb = gCurCB.curParent;
                [gCurCB.curTxtLyr destroy];
                [cb.children removeObjectAtIndex:gCurCB.curTxtLyr.c_idx];
                [cb updateCIdx];
                incrWidth -= gCurCB.curTxtLyr.mainFrame.size.width;
            } else {
                gCurCB.curMode = MODE_INSERT;
                gCurCB.insertCIdx = gCurCB.curTxtLyr.c_idx;
            }
        } else {
            gCurCB.curMode = MODE_INSERT;
            gCurCB.insertCIdx = gCurCB.curTxtLyr.c_idx;
        }
    }
    
    WrapedEqTxtLyr *wetl = [[WrapedEqTxtLyr alloc] init:pfx :gCurCB.view.inpOrg :gCurCB.curEq :self];
    
    incrWidth += wetl.mainFrame.size.width;
    
    //    if (orgLayer != nil && orgLayer.type == TEXTLAYER_EMPTY) {
    //        EquationBlock *cb = gCurCB.curBlk;
    //        [orgLayer destroy];
    //        [cb.children removeObjectAtIndex:orgLayer.c_idx];
    //        [cb updateCIdx];
    //        incrWidth -= orgLayer.mainFrame.size.width;
    //    }
    
    
    if(gCurCB.curMode == MODE_INPUT) {
        EquationBlock *eBlock = gCurCB.curParent;
        
        wetl.c_idx = eBlock.children.count;
        
        [eBlock.children addObject:wetl];
    } else if(gCurCB.curMode == MODE_INSERT) {
        EquationBlock *eBlock = gCurCB.curParent;
        
        [eBlock.children insertObject:wetl atIndex: gCurCB.insertCIdx];
        
        /*Update c_idx*/
        [eBlock updateCIdx];
    } else if(gCurCB.curMode == MODE_DUMP_ROOT) {
        Equation *eq = gCurCB.curEq;
        EquationBlock *newRoot = [[EquationBlock alloc] init:eq];
        newRoot.roll = ROLL_ROOT;
        newRoot.parent = nil;
        newRoot.numerFrame = eq.root.mainFrame;
        newRoot.numerTopHalf = eq.root.mainFrame.size.height / 2.0;
        newRoot.numerBtmHalf = eq.root.mainFrame.size.height / 2.0;
        newRoot.mainFrame = newRoot.numerFrame;
        eq.root.roll = ROLL_NUMERATOR;
        eq.root.parent = newRoot;
        if (gCurCB.insertCIdx == 0) {
            eq.root.c_idx = 1;
            wetl.c_idx = 0;
            [newRoot.children addObject:wetl];
            [newRoot.children addObject:eq.root];
            gCurCB.curMode = MODE_INSERT;
        } else {
            eq.root.c_idx = 0;
            [newRoot.children addObject:eq.root];
            wetl.c_idx = 1;
            [newRoot.children addObject:wetl];
            gCurCB.curMode = MODE_INPUT;
        }
        gCurCB.curRoll = ROLL_NUMERATOR;
        wetl.roll = ROLL_NUMERATOR;
        gCurCB.curParent = newRoot;
        eq.root = newRoot;
    } else if(gCurCB.curMode == MODE_DUMP_RADICAL) {
        RadicalBlock *rBlock = gCurCB.curParent;
        EquationBlock *orgRootRoot = rBlock.content;
        EquationBlock *newRootRoot = [[EquationBlock alloc] init:gCurCB.curEq];
        newRootRoot.roll = ROLL_ROOT_ROOT;
        newRootRoot.parent = rBlock;
        newRootRoot.numerFrame = orgRootRoot.mainFrame;
        newRootRoot.numerTopHalf = orgRootRoot.mainFrame.size.height / 2.0;
        newRootRoot.numerBtmHalf = orgRootRoot.mainFrame.size.height / 2.0;
        newRootRoot.mainFrame = newRootRoot.numerFrame;
        orgRootRoot.roll = ROLL_NUMERATOR;
        orgRootRoot.parent = newRootRoot;
        
        if (gCurCB.insertCIdx == 0) {
            orgRootRoot.c_idx = 1;
            wetl.c_idx = 0;
            [newRootRoot.children addObject:wetl];
            [newRootRoot.children addObject:orgRootRoot];
            gCurCB.curMode = MODE_INSERT;
        } else {
            orgRootRoot.c_idx = 0;
            [newRootRoot.children addObject:orgRootRoot];
            wetl.c_idx = 1;
            [newRootRoot.children addObject:wetl];
            gCurCB.curMode = MODE_INPUT;
        }
        gCurCB.curRoll = ROLL_NUMERATOR;
        wetl.roll = ROLL_NUMERATOR;
        rBlock.content = newRootRoot;
        gCurCB.curParent = newRootRoot;
    } else if(gCurCB.curMode == MODE_DUMP_EXPO) {
        EquationBlock *newExpo = [[EquationBlock alloc] init:gCurCB.curEq];
        EquationBlock *orgExpo = nil;
        if ([gCurCB.curParent isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *l = gCurCB.curParent;
            orgExpo = l.expo;
            l.expo = newExpo;
        } else if ([gCurCB.curParent isMemberOfClass:[Parentheses class]]) {
            Parentheses *p = gCurCB.curParent;
            orgExpo = p.expo;
            p.expo = newExpo;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        newExpo.roll = ROLL_EXPO_ROOT;
        newExpo.parent = gCurCB.curParent;
        newExpo.numerFrame = orgExpo.mainFrame;
        newExpo.numerTopHalf = orgExpo.mainFrame.size.height / 2.0;
        newExpo.numerBtmHalf = orgExpo.mainFrame.size.height / 2.0;
        newExpo.mainFrame = newExpo.numerFrame;
        orgExpo.roll = ROLL_NUMERATOR;
        orgExpo.parent = newExpo;
        
        if (gCurCB.insertCIdx == 0) {
            wetl.c_idx = 0;
            [newExpo.children addObject:wetl];
            orgExpo.c_idx = 1;
            [newExpo.children addObject:orgExpo];
            gCurCB.curMode = MODE_INSERT;
        } else {
            orgExpo.c_idx = 0;
            [newExpo.children addObject:orgExpo];
            wetl.c_idx = 1;
            [newExpo.children addObject:wetl];
            gCurCB.curMode = MODE_INPUT;
        }
        gCurCB.curRoll = ROLL_NUMERATOR;
        wetl.roll = ROLL_NUMERATOR;
        gCurCB.curParent = newExpo;
    } else if(gCurCB.curMode == MODE_DUMP_WETL) {
        WrapedEqTxtLyr *orgWETL = gCurCB.curParent;
        EquationBlock *orgWrapRoot = orgWETL.content;
        EquationBlock *newWrapRoot = [[EquationBlock alloc] init:gCurCB.curEq];
        newWrapRoot.roll = ROLL_ROOT_ROOT;
        newWrapRoot.parent = orgWETL;
        newWrapRoot.numerFrame = orgWrapRoot.mainFrame;
        newWrapRoot.numerTopHalf = orgWrapRoot.mainFrame.size.height / 2.0;
        newWrapRoot.numerBtmHalf = orgWrapRoot.mainFrame.size.height / 2.0;
        newWrapRoot.mainFrame = newWrapRoot.numerFrame;
        orgWrapRoot.roll = ROLL_NUMERATOR;
        orgWrapRoot.parent = newWrapRoot;
        
        if (gCurCB.insertCIdx == 0) {
            orgWrapRoot.c_idx = 1;
            wetl.c_idx = 0;
            [newWrapRoot.children addObject:wetl];
            [newWrapRoot.children addObject:orgWrapRoot];
            gCurCB.curMode = MODE_INSERT;
        } else {
            orgWrapRoot.c_idx = 0;
            [newWrapRoot.children addObject:orgWrapRoot];
            wetl.c_idx = 1;
            [newWrapRoot.children addObject:wetl];
            gCurCB.curMode = MODE_INPUT;
        }
        gCurCB.curRoll = ROLL_NUMERATOR;
        wetl.roll = ROLL_NUMERATOR;
        orgWETL.content = newWrapRoot;
        gCurCB.curParent = newWrapRoot;
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    wetl.parent = gCurCB.curParent;
    
    [(EquationBlock *)gCurCB.curParent updateFrameWidth:incrWidth :gCurCB.curRoll];
    [gCurCB.curEq.root adjustElementPosition];
    
    gCurCB.insertCIdx = 1;
    gCurCB.txtInsIdx = 0;
    gCurCB.curMode = MODE_INPUT;
    gCurCB.curRoll = ROLL_NUMERATOR;
    gCurCB.curParent = wetl.content;
    gCurCB.view.inpOrg = ((EquationBlock *)gCurCB.curParent).mainFrame.origin;
    gCurCB.view.cursor.frame = CGRectMake(gCurCB.view.inpOrg.x, gCurCB.view.inpOrg.y, CURSOR_W, gCurCB.curFontH);
    
    [gCurCB.view updateContentView];
}

-(void)btnClicked: (UIButton *)btn {
    
    if([[btn currentTitle]  isEqual: @"DUMP"]) {
        NSLog(@"-----------curEq--------------");
        [gCurCB.curEq dumpEverything:gCurCB.curEq.root];
        NSLog(@"InputX: %.1f InputY: %.1f~~~~~~~~~~~", gCurCB.view.inpOrg.x, gCurCB.view.inpOrg.y);
        int i = 0;
        for (Equation *eq in gCurCB.eqList) {
            NSLog(@"-----------Eq%i--------------", i++);
            [eq dumpEverything:eq.root];
        }
    } else if([[btn currentTitle]  isEqual: @"DEBUG"]) {
        drawFrame(self, gCurCB.view, gCurCB.curEq.root);
    } else if([[btn currentTitle]  isEqual: @"0"]) {
        [self handleNumBtnClick: @"0"];
    } else if([[btn currentTitle]  isEqual: @"1"]) {
        [self handleNumBtnClick: @"1"];
    } else if([[btn currentTitle]  isEqual: @"2"]) {
        [self handleNumBtnClick: @"2"];
    } else if([[btn currentTitle]  isEqual: @"3"]) {
        [self handleNumBtnClick: @"3"];
    } else if([[btn currentTitle]  isEqual: @"4"]) {
        [self handleNumBtnClick: @"4"];
    } else if([[btn currentTitle]  isEqual: @"5"]) {
        [self handleNumBtnClick: @"5"];
    } else if([[btn currentTitle]  isEqual: @"6"]) {
        [self handleNumBtnClick: @"6"];
    } else if([[btn currentTitle]  isEqual: @"7"]) {
        [self handleNumBtnClick: @"7"];
    } else if([[btn currentTitle]  isEqual: @"8"]) {
        [self handleNumBtnClick: @"8"];
    } else if([[btn currentTitle]  isEqual: @"9"]) {
        [self handleNumBtnClick: @"9"];
    } else if([[btn currentTitle]  isEqual: @"+"]) {
        [self handleOpBtnClick: @"+"];
    } else if([[btn currentTitle]  isEqual: @"-"]) {
        [self handleOpBtnClick: @"-"];
    } else if([[btn currentTitle]  isEqual: @"×"]) {
        [self handleOpBtnClick: @"×"];
    } else if([[btn currentTitle]  isEqual: @"÷"]) {
        [self handleOpBtnClick: @"÷"];
    } else if([[btn currentTitle]  isEqual: @"Root"]) {
        [self handleRootBtnClick:3];
    } else if([[btn currentTitle]  isEqual: @"x^"]) {
        [self handlePowBtnClick];
    } else if([[btn currentTitle]  isEqual: @"("]) {
        [self handleParenthBtnClick: LEFT_PARENTH];
    } else if([[btn currentTitle]  isEqual: @")"]) {
        [self handleParenthBtnClick: RIGHT_PARENTH];
    } else if([[btn currentTitle]  isEqual: @"<-"]) {
        [self handleDelBtnClick];
    } else if([[btn currentTitle]  isEqual: @"·"]) {
        
        
    } else if([[btn currentTitle]  isEqual: @"%"]) {
        NSLog(@"%s%i>~~~~~~~~~~~", __FUNCTION__, __LINE__);
        CGPoint point = CGPointMake(gCurCB.curTxtLyr.position.x + 30, gCurCB.curTxtLyr.position.y);
        NSLog(@"%s%i>~%@~~~~~~~~~~", __FUNCTION__, __LINE__, NSStringFromCGPoint(gCurCB.curTxtLyr.position));
        [gCurCB.curTxtLyr moveFrom:gCurCB.curTxtLyr.position :point];
        
    } else if([[btn currentTitle]  isEqual: @"="]) {
        [self handleReturnBtnClick];
    } else if([[btn currentTitle]  isEqual: @"save"]) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:gCurCB];
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:data forKey:[NSString stringWithFormat:@"calcboard%li", (long)gCurCBIdx]];
        [user setObject:@"1.0" forKey:@"version"];
        [user setInteger:gCurCBIdx forKey:@"gCurCBIdx"];
        NSLog(@"%s%i>~%i~~~~~~~~~~", __FUNCTION__, __LINE__, [user synchronize]);
    } else if([[btn currentTitle]  isEqual: @"load"]) {
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        gCurCBIdx = [user integerForKey:@"gCurCBIdx"];
        NSData *data = [user objectForKey:[NSString stringWithFormat:@"calcboard%li", (long)gCurCBIdx]];
        if (data != nil) {
            CalcBoard *cb = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [cb.curEq dumpEverything:cb.curEq.root];
            [cb.curEq.root reorganize:cb.curEq :self];
            
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"hidden"];
            anim.fromValue = [NSNumber numberWithBool:YES];
            anim.toValue = [NSNumber numberWithBool:NO];
            anim.duration = 0.5;
            anim.autoreverses = YES;
            anim.repeatCount = HUGE_VALF;
            [cb.view.cursor addAnimation:anim forKey:nil];
            [cb.view.layer addSublayer:cb.view.cursor];
            cb.view.cursor.delegate = self;
            [cb.view.cursor setNeedsDisplay];
            
            //locaLastLyr(eq, eq.root);
            DisplayView *orgView = gCurCB.view;
            [UIView transitionFromView:orgView toView:cb.view duration:0.4 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
                // What to do when its finished.
            }];
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
    } else if([[btn currentTitle]  isEqual: @"reset"]) {
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSDictionary *dictionary = [user dictionaryRepresentation];
        for(NSString* key in [dictionary allKeys]){
            [user removeObjectForKey:key];
        }
        [user synchronize];
    } else if([[btn currentTitle]  isEqual: @"C"]) {
        [self handleCleanBtnClick];
    } else if([[btn currentTitle]  isEqual: @"COS"]) {
        [self handleWETLInput:@"COS"];
    } else if([[btn currentTitle]  isEqual: @"<"]) {
        [self handleDspViewSwipeRight:nil];
    } else if([[btn currentTitle]  isEqual: @">"]) {
        [self handleDspViewSwipeLeft:nil];
    } else
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
}

-(void)zoom:(int)zoomLvl {
    if (gCurCB.curEq.result == nil) {
        return;
    }
    
    [gCurCB updateFontInfo:zoomLvl];
    [gCurCB.curEq.root updateSize:zoomLvl];
    
    CGRect f = gCurCB.curEq.root.mainFrame;
    f.origin.x = gCurCB.downLeftBasePoint.x;
    f.origin.y = gCurCB.downLeftBasePoint.y - f.size.height - 1.0;
    gCurCB.curEq.root.mainFrame = f;
    [gCurCB.curEq.root adjustElementPosition];
    
    if ([gCurCB.curBlk isMemberOfClass:[EquationBlock class]]) {
        EquationBlock *eb = gCurCB.curBlk;
        cfgEqnBySlctBlk(gCurCB.curEq, eb, CGPointMake(eb.bar.frame.origin.x + eb.bar.frame.size.width - 1.0, eb.bar.frame.origin.y + 1.0));
    } else if ([gCurCB.curBlk isMemberOfClass:[EquationTextLayer class]]) {
        EquationTextLayer *l = gCurCB.curBlk;
        cfgEqnBySlctBlk(gCurCB.curEq, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
    } else if ([gCurCB.curBlk isMemberOfClass:[RadicalBlock class]]) {
        RadicalBlock *rb = gCurCB.curBlk;
        cfgEqnBySlctBlk(gCurCB.curEq, rb, CGPointMake(rb.frame.origin.x + rb.frame.size.width - 1.0, rb.frame.origin.y + 1.0));
    } else if ([gCurCB.curBlk isMemberOfClass:[WrapedEqTxtLyr class]]) {
        WrapedEqTxtLyr *wetl = gCurCB.curBlk;
        cfgEqnBySlctBlk(gCurCB.curEq, wetl, CGPointMake(wetl.right_parenth.frame.origin.x + wetl.right_parenth.frame.size.width - 1.0, wetl.right_parenth.frame.origin.y + 1.0));
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    if ([layer.name isEqual: @"btnBorderLayer"]) {
        CGContextSetGrayStrokeColor(ctx, 0.0, 1.0);
        CGContextSetLineWidth(ctx, 0.5);
        CGFloat col = scnWidth / 5;
        CGFloat row = scnHeight / 10;
        CGPoint points[] = {CGPointMake(0, row), CGPointMake(scnWidth, row), CGPointMake(0, row * 2), CGPointMake(scnWidth, row * 2), CGPointMake(0, row * 3), CGPointMake(scnWidth, row * 3), CGPointMake(0, row * 4), CGPointMake(col * 4, row * 4), CGPointMake(col, 0), CGPointMake(col, scnHeight / 2), CGPointMake(col * 2, 0), CGPointMake(col * 2, scnHeight / 2), CGPointMake(col * 3, 0), CGPointMake(col * 3, scnHeight / 2), CGPointMake(col * 4, 0), CGPointMake(col * 4, scnHeight / 2)};
        CGContextStrokeLineSegments(ctx, points, 16);
    } else if ([layer.name isEqual: @"cursorLayer"]) {
        CGContextSetGrayStrokeColor(ctx, 0.0, 1.0);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextSetLineWidth(ctx, 1.5);
        
        CGPoint points[] = {CGPointMake(1.0, 1.0), CGPointMake(1.0, layer.frame.size.height - 1.0)};
        CGContextStrokeLineSegments(ctx, points, 2);
    } else if ([layer.name isEqual: @"/"]) {
        FractionBarLayer *bar = (FractionBarLayer *)layer;
        CGFloat lw = getLineWidth(bar.fontLvl);
        CGContextSetGrayStrokeColor(ctx, 0.0, 1.0);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextSetLineWidth(ctx, lw);
        
        CGPoint points[] = {CGPointMake(lw, bar.frame.size.height / 2.0 - lw / 2.0), CGPointMake(bar.frame.size.width - lw, bar.frame.size.height / 2.0 - lw / 2.0)};
        CGContextStrokeLineSegments(ctx, points, 2);
    }else if ([layer.name isEqual: @"radical"]) {
        RadicalBlock *rBlock = (RadicalBlock *)layer;
        CGFloat lw = getLineWidth(rBlock.fontLvl);
        
        CGContextSetGrayStrokeColor(ctx, 0.0, 1.0);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextSetLineWidth(ctx, lw);
        
        CGFloat margineL = RADICAL_MARGINE_L_PERC * rBlock.frame.size.height;
//        CGPoint points[] = {CGPointMake(rBlock.frame.size.width, 1.0), CGPointMake(margineL, 1.0),
//            CGPointMake(margineL, 1.0), CGPointMake(margineL / 2.0, rBlock.frame.size.height - 2.0),
//            CGPointMake(margineL / 2.0, rBlock.frame.size.height - 2.0), CGPointMake(margineL/5.0, rBlock.frame.size.height * 0.75),
//            CGPointMake(margineL / 5.0, rBlock.frame.size.height * 0.75), CGPointMake(0.0, rBlock.frame.size.height * 0.85)};
//        CGContextStrokeLineSegments(ctx, points, 8);
        CGPoint points[] = {CGPointMake(rBlock.frame.size.width - lw, lw), CGPointMake(margineL, lw),
            CGPointMake(margineL, lw), CGPointMake(margineL / 2.0, rBlock.frame.size.height - 2.0),
            CGPointMake(margineL / 2.0, rBlock.frame.size.height - 2.0), CGPointMake(1.0, rBlock.frame.size.height * 0.7)};
        CGContextStrokeLineSegments(ctx, points, 6);
    } else if ([layer.name isEqual: @"drawframe"]) {
        CGContextSetRGBStrokeColor(ctx, 0, 0, 0.7, 1);
        CGContextSetLineWidth(ctx, 0.5);
        
        CGPoint points[] = {CGPointMake(0.0, 0.0), CGPointMake(layer.frame.size.width - 0.0, 0.0),
            CGPointMake(layer.frame.size.width - 0.5, 0.0), CGPointMake(layer.frame.size.width - 0.5, layer.frame.size.height),
            CGPointMake(layer.frame.size.width - 0.5, layer.frame.size.height - 0.5), CGPointMake(0.5, layer.frame.size.height - 0.5),
            CGPointMake(0.5, layer.frame.size.height), CGPointMake(0.5, 0.0)};
        CGContextStrokeLineSegments(ctx, points, 8);
    } else if ([layer.name isEqual: @"parentheses"]) {
        Parentheses *p = (Parentheses *)layer;
        
        CGContextSetGrayStrokeColor(ctx, 0.0, 1.0);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextSetLineWidth(ctx, getLineWidth(p.fontLvl));
        
        if (p.l_or_r == LEFT_PARENTH) {
            CGContextMoveToPoint(ctx, p.frame.size.width - 2, 2);
            CGContextAddQuadCurveToPoint(ctx, 0.0, layer.frame.size.height / 2.0, layer.frame.size.width - 2.0, layer.frame.size.height - 2.0);
            CGContextStrokePath(ctx);
        } else {
            CGContextMoveToPoint(ctx, 2, 2);
            CGContextAddQuadCurveToPoint(ctx, layer.frame.size.width, layer.frame.size.height / 2.0, 2.0, layer.frame.size.height - 2.0);
            CGContextStrokePath(ctx);
        }
        
    } else
        NSLog(@"%s%i>~~ERR~%@~~~~~~~~", __FUNCTION__, __LINE__, layer.name);
}

@end
