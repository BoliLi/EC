//
//  ViewController.m
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import "ViewController.h"
#import "Global.h"
#import "Equation.h"
#import "EquationBlock.h"
#import "EquationTextLayer.h"
#import "RadicalBlock.h"
#import "FractionBarLayer.h"


static UIView *testview;

@interface ViewController ()

@end

@implementation ViewController
@synthesize buttonFont;
@synthesize keyboardView;
@synthesize kbConView;
@synthesize dspConView;
@synthesize borderLayer;
@synthesize E;
@synthesize scnWidth;
@synthesize scnHeight;
@synthesize statusBarHeight;

-(void)handleTap: (UITapGestureRecognizer *)gesture {
    //NSUInteger touchNum = [gesture numberOfTouches];
    //NSUInteger tapNum = [gesture numberOfTapsRequired];
    CGPoint curPoint = [gesture locationOfTouch:0 inView: E.view];
    NSLog(@"%s%i~[%.1f, %.1f]~~~~~~~~~~", __FUNCTION__, __LINE__, curPoint.x, curPoint.y);
    id b = [E lookForElementByPoint:E.root :curPoint];
    if (b != nil) {
        if ([b isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *eBlock = b;
            NSLog(@"%s%i~~%i~~~~~~~~~", __FUNCTION__, __LINE__, eBlock.guid);
            
            id blk;
            
            if (eBlock.is_base_expo == IS_BASE) {
                E.curFont = E.baseFont;
            } else if (eBlock.is_base_expo == IS_EXPO) {
                E.curFont = E.superscriptFont;
            } else {
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            
            if (curPoint.y >= eBlock.numerFrame.origin.y && curPoint.y <= eBlock.numerFrame.origin.y + eBlock.numerFrame.size.height) {
                FractionBarLayer *bar = eBlock.bar;
                if (bar == nil) {
                    NSLog(@"%s%i~~Do nothing~~~~~~~~~", __FUNCTION__, __LINE__);
                    return;
                } else {
                    E.curMode = MODE_INSERT;
                    if (bar.c_idx == 0) {
                        E.insertCIdx = CIDX_0_NUMER;
                        blk = bar;
                    } else {
                        E.insertCIdx = bar.c_idx - 1;
                        blk = [eBlock.children objectAtIndex: E.insertCIdx];
                    }
                }
                
                E.curRoll = ROLL_NUMERATOR;
                E.curParent = eBlock;
            } else if (curPoint.y >= eBlock.denomFrame.origin.y && curPoint.y <= eBlock.denomFrame.origin.y + eBlock.denomFrame.size.height) {
                NSLog(@"%s%i~~~~~~~~~~~", __FUNCTION__, __LINE__);
                E.curMode = MODE_INPUT;
                blk = [eBlock.children lastObject];
                E.curRoll = ROLL_DENOMINATOR;
                E.curParent = eBlock;
            } else {
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            
            if ([blk isMemberOfClass: [EquationTextLayer class]]) {
                EquationTextLayer *layer = blk;
                
                if (layer.type == TEXTLAYER_OP) {
                    
                    CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                    CGFloat y = layer.frame.origin.y;
                    E.view.inpOrg = CGPointMake(x, y);
                    CGFloat tmp = layer.mainFrame.size.height;
                    E.view.cursor.frame = CGRectMake(layer.mainFrame.origin.x + (layer.mainFrame.size.width * 2.0) + (E.curFontW / 2.0), layer.mainFrame.origin.y, CURSOR_W, tmp);
                    E.needNewLayer = YES;
                    E.needX = NO;
                    E.curTextLayer = nil;
                    E.curBlock = layer;
                } else if (layer.type == TEXTLAYER_NUM) {
                    CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                    CGFloat y = layer.frame.origin.y;
                    E.view.inpOrg = CGPointMake(x, y);
                    CGFloat tmp = layer.mainFrame.size.height;
                    E.view.cursor.frame = CGRectMake(layer.mainFrame.origin.x + layer.mainFrame.size.width, layer.mainFrame.origin.y, CURSOR_W, tmp);
                    if (layer.expo == nil) {
                        E.needNewLayer = NO;
                        E.needX = YES;
                        E.curTextLayer = layer;
                        E.curBlock = layer;
                    } else {
                        E.needNewLayer = YES;
                        E.needX = YES;
                        E.curTextLayer = nil;
                        E.curBlock = layer;
                    }
                } else if (layer.type == TEXTLAYER_EMPTY) {
                    if (layer.expo == nil) {
                        CGFloat x = layer.frame.origin.x;
                        CGFloat y = layer.frame.origin.y;
                        E.view.inpOrg = CGPointMake(x, y);
                        CGFloat tmp = layer.frame.size.height;
                        E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, tmp);
                        E.needNewLayer = NO;
                        E.needX = NO;
                        E.curTextLayer = layer;
                        E.curBlock = layer;
                    } else {
                        CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                        CGFloat y = layer.frame.origin.y;
                        E.view.inpOrg = CGPointMake(x, y);
                        CGFloat tmp = layer.mainFrame.size.height;
                        E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                        E.needNewLayer = YES;
                        E.needX = YES;
                        E.curTextLayer = nil;
                        E.curBlock = layer;
                    }
                } else
                    NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                
                NSLog(@"%s%i~Tapped at blank. Input after a textlayer.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, layer.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
            } else if ([blk isMemberOfClass: [EquationBlock class]]) {
                EquationBlock *eBlk = blk;
                E.curTextLayer = nil;
                E.curBlock = eBlk;
                CGFloat x = eBlk.bar.frame.origin.x + eBlk.bar.frame.size.width;
                CGFloat y = eBlk.numerFrame.origin.y + eBlk.numerFrame.size.height - E.curFontH / 2.0;
                E.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = eBlk.mainFrame.size.height;
                E.view.cursor.frame = CGRectMake(eBlk.mainFrame.origin.x + eBlk.mainFrame.size.width, eBlk.mainFrame.origin.y, CURSOR_W, tmp);
                E.needNewLayer = YES;
                E.needX = YES;
                NSLog(@"%s%i~Tapped at blank. Input after a eBlock.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, eBlk.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
            } else if ([blk isMemberOfClass: [RadicalBlock class]]) {
                RadicalBlock *rBlk = blk;
                E.curTextLayer = nil;
                E.curBlock = rBlk;
                CGFloat x = rBlk.frame.origin.x + rBlk.frame.size.width;
                CGFloat y = rBlk.frame.origin.y + rBlk.frame.size.height / 2.0 - E.curFontH / 2.0;
                E.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = rBlk.frame.size.height;
                E.view.cursor.frame = CGRectMake(rBlk.frame.origin.x + rBlk.frame.size.width, rBlk.frame.origin.y, CURSOR_W, tmp);
                E.needNewLayer = YES;
                E.needX = YES;
                NSLog(@"%s%i~Tapped at blank. Input after a rBlock.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, rBlk.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
            } else if ([blk isMemberOfClass: [FractionBarLayer class]]) { // Should not happen anymore
//                EquationBlock *eBlk = ((FractionBarLayer *)blk).parent;
//                if (E.curRoll == ROLL_NUMERATOR) {
//                    E.view.inpOrg.x = eBlk.numerFrame.origin.x;
//                    E.view.inpOrg.y = eBlk.numerFrame.origin.y;
//                    CGFloat tmp = eBlk.numerFrame.size.height;
//                    E.view.cursor.frame = CGRectMake(eBlk.numerFrame.origin.x, eBlk.mainFrame.origin.y, CURSOR_W, tmp);
//                } else if (E.curRoll == ROLL_DENOMINATOR) {
//                    E.view.inpOrg.x = eBlk.denomFrame.origin.x;
//                    E.view.inpOrg.y = eBlk.denomFrame.origin.y;
//                    CGFloat tmp = eBlk.denomFrame.size.height;
//                    E.view.cursor.frame = CGRectMake(eBlk.denomFrame.origin.x, eBlk.denomFrame.origin.y, CURSOR_W, tmp);
//                } else
//                    NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
//                E.curTextLayer = nil;
//                E.needNewLayer = YES;
//                NSLog(@"%s%i~Tapped at blank. First input at Numer or Denom.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, eBlk.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curBlock).guid);
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            } else {
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            
        } else if ([b isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *layer = b;
            NSLog(@"%s%i~~%i~~~~~~~~~", __FUNCTION__, __LINE__, layer.guid);
            
            if (layer.is_base_expo == IS_BASE) {
                E.curFont = E.baseFont;
            } else if (layer.is_base_expo == IS_EXPO) {
                E.curFont = E.superscriptFont;
            } else {
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            
            if (layer.type == TEXTLAYER_OP) {
                CGFloat tmp = layer.frame.size.height;
                E.view.cursor.frame = CGRectMake(layer.frame.origin.x + layer.frame.size.width / 2.0 + E.curFontW / 2.0, layer.frame.origin.y, CURSOR_W, tmp);
                CGFloat x = layer.frame.origin.x + layer.frame.size.width;
                CGFloat y = layer.frame.origin.y;
                E.view.inpOrg = CGPointMake(x, y);
                E.needNewLayer = YES;
                E.needX = NO;
                E.curTextLayer = nil;
            } else if (layer.type == TEXTLAYER_NUM) {
                if (CGRectContainsPoint (layer.frame, curPoint)) {
                    CGFloat x = layer.frame.origin.x + layer.frame.size.width;
                    CGFloat y = layer.frame.origin.y;
                    E.view.inpOrg = CGPointMake(x, y);
                    CGFloat tmp = layer.frame.size.height;
                    E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, tmp);
                    E.needNewLayer = NO;
                    E.needX = YES;
                    E.curTextLayer = layer;
                } else {
                    CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                    CGFloat y = layer.frame.origin.y;
                    E.view.inpOrg = CGPointMake(x, y);
                    CGFloat tmp = layer.mainFrame.size.height;
                    E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                    E.needNewLayer = YES;
                    E.needX = YES;
                    E.curTextLayer = nil;
                }
            } else if (layer.type == TEXTLAYER_EMPTY) {
                if (CGRectContainsPoint (layer.frame, curPoint)) {
                    CGFloat x = layer.frame.origin.x;
                    CGFloat y = layer.frame.origin.y;
                    E.view.inpOrg = CGPointMake(x, y);
                    CGFloat tmp = layer.frame.size.height;
                    E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, tmp);
                    E.needNewLayer = NO;
                    E.needX = NO;
                    E.curTextLayer = layer;
                } else {
                    CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                    CGFloat y = layer.frame.origin.y;
                    E.view.inpOrg = CGPointMake(x, y);
                    CGFloat tmp = layer.mainFrame.size.height;
                    E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                    E.needNewLayer = YES;
                    E.needX = YES;
                    E.curTextLayer = nil;
                }
            } else
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            
            EquationBlock *block = layer.parent;
            id lastBlock = [block.children lastObject];
            if ([lastBlock isMemberOfClass: [EquationTextLayer class]] && layer == (EquationTextLayer *)lastBlock) {
                E.curMode = MODE_INPUT;
            } else {
                E.curMode = MODE_INSERT;
                E.insertCIdx = layer.c_idx;
            }
            E.curRoll = layer.roll;
            E.curParent = block;
            E.curBlock = layer;
        } else if ([b isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *block = b;
            NSLog(@"%s%i~~%i~~~~~~~~~", __FUNCTION__, __LINE__, block.guid);
            if (block.is_base_expo == IS_BASE) {
                E.curFont = E.baseFont;
            } else if (block.is_base_expo == IS_EXPO) {
                E.curFont = E.superscriptFont;
            } else {
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            
            id lastBlock = [((EquationBlock *)block.parent).children lastObject];
            if ([lastBlock isMemberOfClass: [RadicalBlock class]] && block == (RadicalBlock *)lastBlock) {
                E.curMode = MODE_INPUT;
            } else {
                E.curMode = MODE_INSERT;
                E.insertCIdx = block.c_idx;
            }
            E.curParent = block.parent;
            E.curRoll = block.roll;
            E.curTextLayer = nil;
            E.curBlock = block;
            E.needNewLayer = YES;
            E.needX = YES;
            CGFloat tmp = block.frame.size.height;
            E.view.cursor.frame = CGRectMake(block.frame.origin.x + block.frame.size.width, block.frame.origin.y, CURSOR_W, tmp);
            CGFloat x = block.frame.origin.x + block.frame.size.width;
            CGFloat y = block.frame.origin.y + block.frame.size.height / 2.0 - E.curFontH / 2.0;
            E.view.inpOrg = CGPointMake(x, y);
        } else if ([b isMemberOfClass: [FractionBarLayer class]]) {
            FractionBarLayer *bar = b;
            EquationBlock *block = bar.parent;
            
            if (bar.is_base_expo == IS_BASE) {
                E.curFont = E.baseFont;
            } else if (bar.is_base_expo == IS_EXPO) {
                E.curFont = E.superscriptFont;
            } else {
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            
            CGFloat tmp = block.mainFrame.size.height;
            E.view.cursor.frame = CGRectMake(block.mainFrame.origin.x+block.mainFrame.size.width, block.mainFrame.origin.y, CURSOR_W, tmp);
            CGFloat x = block.bar.frame.origin.x + block.bar.frame.size.width;
            CGFloat y = block.numerFrame.origin.y + block.numerFrame.size.height - E.curFontH / 2.0;
            E.view.inpOrg = CGPointMake(x, y);
            E.curTextLayer = nil;
            E.curBlock = block;
            E.needNewLayer = YES;
            E.needX = YES;
            if (block.roll == ROLL_ROOT) {//Root block is a fraction. Need to dump all elements in the root block into new block
                E.curMode = MODE_DUMP_ROOT;
                E.curRoll = ROLL_NUMERATOR;
                NSLog(@"%s%i~Tapped at bar.~GUID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, block.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
            } else if(block.roll == ROLL_ROOT_ROOT) {
                E.curMode = MODE_DUMP_RADICAL;
                E.curRoll = ROLL_NUMERATOR;
                E.curParent = block.parent;
                NSLog(@"%s%i~Tapped at bar.~GUID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, block.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((RadicalBlock *)E.curParent).guid);
            } else if(block.roll == ROLL_EXPO_ROOT) {
                E.curMode = MODE_DUMP_EXPO;
                E.curRoll = ROLL_NUMERATOR;
                E.curParent = block.parent;
                NSLog(@"%s%i~Tapped at bar.~GUID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, block.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((RadicalBlock *)E.curParent).guid);
            } else {
                id lastBlock = [((EquationBlock *)block.parent).children lastObject];
                if ([lastBlock isMemberOfClass: [EquationBlock class]] && block == (EquationBlock *)lastBlock) {
                    E.curMode = MODE_INPUT;
                } else {
                    E.curMode = MODE_INSERT;
                    E.insertCIdx = block.c_idx;
                }
                E.curParent = block.parent;
                E.curRoll = block.roll;
                NSLog(@"%s%i~Tapped at bar.~GUID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, block.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
            }
        } else
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    } else { //Tap outside
        NSLog(@"%s%i~~~~~~~~~~~", __FUNCTION__, __LINE__);
        if (E.root.children.count != 0) {
            
            E.curFont = E.baseFont;
            
            if (E.root.bar != nil) {//Root block has denominator
                CGFloat tmp = E.root.mainFrame.size.height;
                E.view.cursor.frame = CGRectMake(E.root.mainFrame.origin.x + E.root.mainFrame.size.width, E.root.mainFrame.origin.y, CURSOR_W, tmp);
                CGFloat x = E.root.bar.frame.origin.x + E.root.bar.frame.size.width;
                CGFloat y = E.root.numerFrame.origin.y + E.root.numerFrame.size.height - E.curFontH / 2.0;
                E.view.inpOrg = CGPointMake(x, y);
                E.curMode = MODE_DUMP_ROOT;
                E.curTextLayer = nil;
                E.curBlock = E.root;
                E.needNewLayer = YES;
                E.needX = YES;
                E.curRoll = ROLL_NUMERATOR;
                NSLog(@"%s%i~Tapped outside fraction. Root block has denominator.~CIDX: %lu~Mode: %i~Roll: %i~~", __FUNCTION__, __LINE__, (unsigned long)E.insertCIdx, E.curMode, E.curRoll);
            } else {
                id block = [E.root.children lastObject];
                if ([block isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = block;
                    
                    E.curMode = MODE_INPUT;
                    
                    if (layer.type == TEXTLAYER_OP) {
                        CGFloat x = layer.frame.origin.x + layer.frame.size.width;
                        CGFloat y = layer.frame.origin.y;
                        E.view.inpOrg = CGPointMake(x, y);
                        CGFloat tmp = layer.frame.size.height;
                        E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, tmp);
                        E.curTextLayer = nil;
                        E.needNewLayer = YES;
                        E.needX = NO;
                    } else if (layer.type == TEXTLAYER_NUM) {
                        if (layer.expo == nil) {
                            CGFloat x = layer.frame.origin.x + layer.frame.size.width;
                            CGFloat y = layer.frame.origin.y;
                            E.view.inpOrg = CGPointMake(x, y);
                            CGFloat tmp = layer.frame.size.height;
                            E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, tmp);
                            E.curTextLayer = layer;
                            E.needNewLayer = NO;
                        } else {
                            CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                            CGFloat y = layer.frame.origin.y;
                            E.view.inpOrg = CGPointMake(x, y);
                            CGFloat tmp = layer.mainFrame.size.height;
                            E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                            E.curTextLayer = nil;
                            E.needNewLayer = YES;
                        }
                        E.needX = YES;
                    } else if (layer.type == TEXTLAYER_EMPTY) {
                        if (layer.expo == nil) {
                            CGFloat x = layer.frame.origin.x;
                            CGFloat y = layer.frame.origin.y;
                            E.view.inpOrg = CGPointMake(x, y);
                            CGFloat tmp = layer.frame.size.height;
                            E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, tmp);
                            E.curTextLayer = layer;
                            E.needNewLayer = NO;
                        } else {
                            CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                            CGFloat y = layer.frame.origin.y;
                            E.view.inpOrg = CGPointMake(x, y);
                            CGFloat tmp = layer.mainFrame.size.height;
                            E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                            E.curTextLayer = nil;
                            E.needNewLayer = YES;
                        }
                        E.needX = YES;
                    } else
                        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    E.curRoll = layer.roll;
                    E.curParent = layer.parent;
                    E.curBlock = layer;
                    NSLog(@"%s%i~Tapped outside fraction. Last obj is text layer.~Id: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, E.curTextLayer.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
                } else if ([block isMemberOfClass: [EquationBlock class]]) {
                    EquationBlock *b = block;
                    E.curMode = MODE_INPUT;
                    E.curParent = b.parent;
                    E.curRoll = b.roll;
                    E.curTextLayer = nil;
                    E.curBlock = b;
                    E.needNewLayer = YES;
                    E.needX = YES;
                    CGFloat x = b.bar.frame.origin.x + b.bar.frame.size.width;
                    CGFloat y = b.numerFrame.origin.y + b.numerFrame.size.height - E.curFontH / 2.0;
                    E.view.inpOrg = CGPointMake(x, y);
                    CGFloat tmp = b.mainFrame.size.height;
                    E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, b.mainFrame.origin.y, CURSOR_W, tmp);
                    NSLog(@"%s%i~Tapped outside fraction. Last obj is EquationBlock.~Id: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, b.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
                } else if ([block isMemberOfClass: [RadicalBlock class]]) {
                    RadicalBlock *b = block;
                    E.curMode = MODE_INPUT;
                    E.curParent = b.parent;
                    E.curRoll = b.roll;
                    E.curTextLayer = nil;
                    E.curBlock = b;
                    E.needNewLayer = YES;
                    E.needX = YES;
                    CGFloat x = b.frame.origin.x + b.frame.size.width;
                    CGFloat y = b.frame.origin.y + b.frame.size.height / 2.0 - E.curFontH / 2.0;
                    E.view.inpOrg = CGPointMake(x, y);
                    CGFloat tmp = b.frame.size.height;
                    E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, b.frame.origin.y, CURSOR_W, tmp);
                    NSLog(@"%s%i~Tapped outside fraction. Last obj is RadicalBlock.~Id: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, b.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
                } else {
                    NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            }
        }
    }
}

-(void)handleSwipeRight: (UISwipeGestureRecognizer *)gesture {
    NSLog(@"[%s%i]~~~~~~~~~~~", __FUNCTION__, __LINE__);
    DisplayView *orgView = E.view;
    gCurEqIdx--;
    if (gCurEqIdx < 0) {
        gCurEqIdx = 15;
    }
    E = [gEquationList objectAtIndex:gCurEqIdx];
    [E.view.cursor removeAllAnimations];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"hidden"];
    anim.fromValue = [NSNumber numberWithBool:YES];
    anim.toValue = [NSNumber numberWithBool:NO];
    anim.duration = 0.5;
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    [E.view.cursor addAnimation:anim forKey:nil];
    [UIView transitionFromView:orgView toView:E.view duration:0.4 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        // What to do when its finished.
    }];
}

-(void)handleSwipeLeft: (UISwipeGestureRecognizer *)gesture {
    NSLog(@"[%s%i]~~~~~~~~~~~", __FUNCTION__, __LINE__);
    DisplayView *orgView = E.view;
    gCurEqIdx++;
    gCurEqIdx %= 16;
    E = [gEquationList objectAtIndex:gCurEqIdx];
    [E.view.cursor removeAllAnimations];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"hidden"];
    anim.fromValue = [NSNumber numberWithBool:YES];
    anim.toValue = [NSNumber numberWithBool:NO];
    anim.duration = 0.5;
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    [E.view.cursor addAnimation:anim forKey:nil];
    [UIView transitionFromView:orgView toView:E.view duration:0.4 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
        // What to do when its finished.
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    scnWidth = [UIScreen mainScreen].bounds.size.width;
    scnHeight = [UIScreen mainScreen].bounds.size.height;
    statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;

    dspConView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, scnWidth, (scnHeight / 2) - statusBarHeight)];
    dspConView.tag = 1;
    dspConView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:dspConView];
    
    CGRect dspFrame = CGRectMake(0, 0, scnWidth, (scnHeight / 2) - statusBarHeight);
    CGRect cursorFrame = CGRectMake(1, (scnHeight / 2) - statusBarHeight - 30.0, 0.0, 0.0); //Size will update in Equation init
    CGPoint rootPos = CGPointMake(1, (scnHeight / 2) - statusBarHeight - 30.0);
    for (int i = 0; i < 16; i++) {
        [gEquationList addObject:[[Equation alloc] init:rootPos :dspFrame :cursorFrame :self]];
    }
    E = gEquationList.firstObject;

    [dspConView addSubview:E.view];

    keyboardView = [[UIView alloc] initWithFrame:CGRectMake(0, scnHeight / 2, scnWidth, scnHeight / 2)];
    keyboardView.tag = 2;
    keyboardView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:keyboardView];
    
    borderLayer = [CALayer layer];
    borderLayer.contentsScale = [UIScreen mainScreen].scale;
    borderLayer.name = @"btnBorderLayer";
    borderLayer.backgroundColor = [UIColor clearColor].CGColor;
    borderLayer.frame = CGRectMake(0, 0, scnWidth, scnHeight / 2);
    borderLayer.delegate = self;
    [keyboardView.layer addSublayer: borderLayer];
    [borderLayer setNeedsDisplay];
    
    buttonFont = [UIFont systemFontOfSize: 20];
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
        [keyboardView addSubview:bn];
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
        [keyboardView addSubview:bn];
    }
    
    UIButton *bn = [UIButton buttonWithType:UIButtonTypeSystem];
    bn.tag = 33;
    bn.titleLabel.font = buttonFont;
    bn.showsTouchWhenHighlighted = YES;
    [bn setTitle:[btnTitleArr objectAtIndex: 23] forState:UIControlStateNormal];
    bn.frame = CGRectMake(4 * btnWidth, 3 * btnHeight, btnWidth, 2 * btnHeight);
    [bn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [keyboardView addSubview:bn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleNumBtnClick : (NSString *)num {
    CGFloat incrWidth = 0.0;
    
    if (E.needNewLayer) {
        E.needNewLayer = NO;
        
        EquationTextLayer *tLayer = [[EquationTextLayer alloc] init:num :E.view.inpOrg :E :TEXTLAYER_NUM];
        tLayer.name = @"num";
        
        if ([E.curParent isMemberOfClass: [EquationBlock class]]) {
            NSLog(@"%s%i~Input Num %@ with new text layer.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, num, tLayer.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
        } else if ([E.curParent isMemberOfClass: [RadicalBlock class]]) {
            NSLog(@"%s%i~Input Num %@ with new text layer.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, num, tLayer.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((RadicalBlock *)E.curParent).guid);
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        incrWidth = tLayer.frame.size.width;
        
        if(E.curMode == MODE_INPUT) {
            EquationBlock *block = E.curParent;
            if (E.needX) {
                EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
                tLayer1.name = @"×";
                tLayer1.roll = E.curRoll;
                tLayer1.parent = block;
                tLayer1.c_idx = block.children.count;
                [block.children addObject:tLayer1];
                [E.view.layer addSublayer:tLayer1];
                tLayer.c_idx = block.children.count;
                [block.children addObject:tLayer];
                tLayer.frame = CGRectOffset(tLayer.frame, tLayer1.frame.size.width, 0);
                incrWidth += tLayer1.frame.size.width;
            } else {
                tLayer.c_idx = block.children.count;
                [block.children addObject:tLayer];
            }
            
        } else if(E.curMode == MODE_INSERT) {
            //NSLog(@"%s%i~~~%lu~~~~~~~~", __FUNCTION__, __LINE__, (unsigned long)E.insertCIdx);
            EquationBlock *block = E.curParent;
            if (E.needX) {
                EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
                tLayer1.name = @"×";
                tLayer1.roll = E.curRoll;
                tLayer1.parent = block;
                if (E.insertCIdx == CIDX_0_NUMER) {
                    tLayer1.c_idx = 0;
                    E.insertCIdx = 0;
                } else {
                    tLayer1.c_idx = E.insertCIdx + 1;
                }
                [E.view.layer addSublayer:tLayer1];
                [block.children insertObject:tLayer1 atIndex:tLayer1.c_idx];
                
                tLayer.c_idx = tLayer1.c_idx + 1;
                [block.children insertObject:tLayer atIndex:tLayer.c_idx];
                /*Update c_idx*/
                [block updateCIdx];
                tLayer.frame = CGRectOffset(tLayer.frame, tLayer1.frame.size.width, 0);
                incrWidth += tLayer1.frame.size.width;
                E.insertCIdx += 2;
            } else {
                if (E.insertCIdx == CIDX_0_NUMER) {
                    tLayer.c_idx = 0;
                    E.insertCIdx = 0;
                } else {
                    tLayer.c_idx = E.insertCIdx + 1;
                }
                [block.children insertObject:tLayer atIndex:tLayer.c_idx];
                /*Update c_idx*/
                [block updateCIdx];
                E.insertCIdx += 1;
            }
            
        } else if(E.curMode == MODE_DUMP_ROOT) {
            EquationBlock *block = [[EquationBlock alloc] init:E];
            block.roll = ROLL_ROOT;
            block.parent = nil;
            block.numerFrame = E.root.mainFrame;
            block.numerTopHalf = E.root.mainFrame.size.height / 2.0;
            block.numerBtmHalf = E.root.mainFrame.size.height / 2.0;
            block.mainFrame = block.numerFrame;
            E.root.roll = ROLL_NUMERATOR;
            E.root.parent = block;
            E.root.c_idx = 0;
            [block.children addObject:E.root];

            EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
            tLayer1.name = @"×";
            tLayer1.roll = E.curRoll;
            tLayer1.parent = block;
            tLayer1.c_idx = 1;
            [E.view.layer addSublayer:tLayer1];
            [block.children addObject:tLayer1];

            tLayer.frame = CGRectOffset(tLayer.frame, tLayer1.frame.size.width, 0);
            incrWidth += tLayer1.frame.size.width;
            tLayer.c_idx = 2;
            [block.children addObject:tLayer];
            E.root = block;
            E.curParent = block;
            E.curMode = MODE_INPUT;
        } else if(E.curMode == MODE_DUMP_RADICAL) {
            RadicalBlock *rBlock = E.curParent;
            EquationBlock *eBlock = rBlock.content;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            newBlock.roll = ROLL_ROOT_ROOT;
            newBlock.parent = rBlock;
            newBlock.numerFrame = eBlock.mainFrame;
            newBlock.numerTopHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.numerBtmHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.mainFrame = newBlock.numerFrame;
            eBlock.roll = ROLL_NUMERATOR;
            eBlock.parent = newBlock;
            eBlock.c_idx = 0;
            [newBlock.children addObject:eBlock];

            EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
            tLayer1.name = @"×";
            tLayer1.roll = E.curRoll;
            tLayer1.parent = newBlock;
            tLayer1.c_idx = 1;
            [E.view.layer addSublayer:tLayer1];
            [newBlock.children addObject:tLayer1];

            tLayer.frame = CGRectOffset(tLayer.frame, tLayer1.frame.size.width, 0);
            incrWidth += tLayer1.frame.size.width;
            tLayer.c_idx = 2;
            [newBlock.children addObject:tLayer];
            rBlock.content = newBlock;
            E.curParent = newBlock;
            E.curMode = MODE_INPUT;
        } else if(E.curMode == MODE_DUMP_EXPO) {
            EquationTextLayer *layer = E.curParent;
            EquationBlock *eBlock = layer.expo;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            newBlock.roll = ROLL_EXPO_ROOT;
            newBlock.parent = layer;
            newBlock.numerFrame = eBlock.mainFrame;
            newBlock.numerTopHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.numerBtmHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.mainFrame = newBlock.numerFrame;
            eBlock.roll = ROLL_NUMERATOR;
            eBlock.parent = newBlock;
            eBlock.c_idx = 0;
            [newBlock.children addObject:eBlock];
            
            EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
            tLayer1.name = @"×";
            tLayer1.roll = E.curRoll;
            tLayer1.parent = newBlock;
            tLayer1.c_idx = 1;
            [E.view.layer addSublayer:tLayer1];
            [newBlock.children addObject:tLayer1];
            
            tLayer.frame = CGRectOffset(tLayer.frame, tLayer1.frame.size.width, 0);
            incrWidth += tLayer1.frame.size.width;
            tLayer.c_idx = 2;
            [newBlock.children addObject:tLayer];
            layer.expo = newBlock;
            E.curParent = newBlock;
            E.curMode = MODE_INPUT;
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        tLayer.parent = E.curParent;
        [E.view.layer addSublayer:tLayer];
        E.curTextLayer = tLayer;
        E.curBlock = tLayer;
    } else {
        NSLog(@"%s%i~Input Num %@ with exist text layer.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, num, E.curTextLayer.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
        if (E.curTextLayer.type == TEXTLAYER_EMPTY) {
            E.curTextLayer.type = TEXTLAYER_NUM;
            CGFloat orgW = E.curTextLayer.mainFrame.size.width;
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: num];
            CTFontRef ctFont = CTFontCreateWithName((CFStringRef)E.curFont.fontName, E.curFont.pointSize, NULL);
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
            CGSize newStrSize = [attStr size];
            E.curTextLayer.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, newStrSize.width, newStrSize.height);
            E.curTextLayer.mainFrame = E.curTextLayer.frame;
            E.curTextLayer.backgroundColor = [UIColor clearColor].CGColor;
            E.curTextLayer.string = attStr;
            [E.curTextLayer updateFrameBaseOnBase];
            incrWidth += E.curTextLayer.mainFrame.size.width - orgW;
        } else {
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: num];
            CTFontRef ctFont = CTFontCreateWithName((CFStringRef)E.curFont.fontName, E.curFont.pointSize, NULL);
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
            /* Update text info */
            NSMutableAttributedString *orgStr = [[NSMutableAttributedString alloc] initWithAttributedString:E.curTextLayer.string];
            CGSize newStrSize = [attStr size];
            incrWidth = newStrSize.width;
            [orgStr appendAttributedString:attStr];
            
            CGSize strSize = [orgStr size];
            CGRect frame = E.curTextLayer.frame;
            frame.size.width = strSize.width;
            frame.size.height = strSize.height;
            E.curTextLayer.frame = frame;
            E.curTextLayer.string = orgStr;
            [E.curTextLayer updateFrameBaseOnBase];
        }
        
    }
    
    /* Update frame info of current block */
    [(EquationBlock *)E.curParent updateFrameWidth:incrWidth :E.curRoll];
    [E adjustEveryThing:E.root];
    NSLog(@"[%s%i]~%f~%f~~~~~~~~~", __FUNCTION__, __LINE__, E.root.mainFrame.size.width, E.root.numerFrame.size.width);
    
    E.needX = YES;
    
    /* Move cursor */
    CGFloat cursorOrgX = 0.0;
    CGFloat cursorOrgY = 0.0;
    
    cursorOrgX = E.curTextLayer.frame.origin.x + E.curTextLayer.frame.size.width;
    cursorOrgY = E.curTextLayer.frame.origin.y;
    
    E.view.cursor.frame = CGRectMake(cursorOrgX, cursorOrgY, CURSOR_W, E.curFontH);
    E.view.inpOrg = CGPointMake(cursorOrgX, cursorOrgY);
}

- (void)handleOpBtnClick : (NSString *)op {
    E.needX = NO;
    if ([op isEqual: @"×"] || [op isEqual: @"+"] || [op isEqual: @"-"]) {
        if (E.curTextLayer != nil) {
            if (E.curTextLayer.type == TEXTLAYER_EMPTY) {
                if (E.curTextLayer.expo == nil) {
                    NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    return;
                } else if ([E.curTextLayer.expo.children.firstObject isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *l = E.curTextLayer.expo.children.firstObject;
                    if (l.type == TEXTLAYER_EMPTY) {
                        NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        return;
                    }
                }
            }
        }
        
        CGFloat incrWidth = 0.0;
        NSString *str = @" ";
        str = [str stringByAppendingString:op];
        str = [str stringByAppendingString:@" "];
        EquationTextLayer *tLayer = [[EquationTextLayer alloc] init:str :E.view.inpOrg :E :TEXTLAYER_OP];
        tLayer.name = op;
        
        if ([E.curParent isMemberOfClass: [EquationBlock class]]) {
            NSLog(@"%s%i~Input Op %@.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, op, tLayer.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
        } else if ([E.curParent isMemberOfClass: [RadicalBlock class]]) {
            NSLog(@"%s%i~Input Op %@.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, op, tLayer.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((RadicalBlock *)E.curParent).guid);
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        incrWidth = tLayer.frame.size.width;
        
        if(E.curMode == MODE_INPUT) {
            EquationBlock *block = E.curParent;
            
            tLayer.c_idx = block.children.count;
            [block.children addObject:tLayer];
        } else if(E.curMode == MODE_INSERT) {
            EquationBlock *block = E.curParent;
            
            if (E.insertCIdx == CIDX_0_NUMER) {
                tLayer.c_idx = 0;
                E.insertCIdx = 0;
            } else {
                tLayer.c_idx = E.insertCIdx + 1;
            }
            [block.children insertObject:tLayer atIndex:tLayer.c_idx];
            /*Update c_idx*/
            [block updateCIdx];
            E.insertCIdx += 1;
        } else if(E.curMode == MODE_DUMP_ROOT) {
            EquationBlock *block = [[EquationBlock alloc] init:E];
            block.roll = ROLL_ROOT;
            block.parent = nil;
            block.numerFrame = E.root.mainFrame;
            block.numerTopHalf = E.root.mainFrame.size.height / 2.0;
            block.numerBtmHalf = E.root.mainFrame.size.height / 2.0;
            block.mainFrame = block.numerFrame;
            E.root.roll = ROLL_NUMERATOR;
            E.root.parent = block;
            E.root.c_idx = 0;
            [block.children addObject:E.root];
            tLayer.c_idx = 1;
            [block.children addObject:tLayer];
            E.root = block;
            E.curParent = block;
            E.curMode = MODE_INPUT;
        } else if(E.curMode == MODE_DUMP_RADICAL) {
            RadicalBlock *rBlock = E.curParent;
            EquationBlock *eBlock = rBlock.content;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            newBlock.roll = ROLL_ROOT_ROOT;
            newBlock.parent = rBlock;
            newBlock.numerFrame = eBlock.mainFrame;
            newBlock.numerTopHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.numerBtmHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.mainFrame = newBlock.numerFrame;
            eBlock.roll = ROLL_NUMERATOR;
            eBlock.parent = newBlock;
            eBlock.c_idx = 0;
            [newBlock.children addObject:eBlock];
            tLayer.c_idx = 1;
            [newBlock.children addObject:tLayer];
            rBlock.content = newBlock;
            E.curParent = newBlock;
            E.curMode = MODE_INPUT;
        } else if(E.curMode == MODE_DUMP_EXPO) {
            EquationTextLayer *layer = E.curParent;
            EquationBlock *eBlock = layer.expo;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            newBlock.roll = ROLL_EXPO_ROOT;
            newBlock.parent = layer;
            newBlock.numerFrame = eBlock.mainFrame;
            newBlock.numerTopHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.numerBtmHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.mainFrame = newBlock.numerFrame;
            eBlock.roll = ROLL_NUMERATOR;
            eBlock.parent = newBlock;
            eBlock.c_idx = 0;
            [newBlock.children addObject:eBlock];
            tLayer.c_idx = 1;
            [newBlock.children addObject:tLayer];
            layer.expo = newBlock;
            E.curParent = newBlock;
            E.curMode = MODE_INPUT;
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        tLayer.parent = E.curParent;
        [E.view.layer addSublayer:tLayer];
        E.curTextLayer = nil;
        E.curBlock = tLayer;
        E.needNewLayer = YES;
        
        //Update frame info of current block */
        //dumpObj(E.root);
        //NSLog(@"%s%i~%f~%@~~~~~~~~~", __FUNCTION__, __LINE__, strSize.width, E.curRoll == ROLL_NUMERATOR?@"N":@"D");
        [(EquationBlock *)E.curParent updateFrameWidth:incrWidth :E.curRoll];
        NSLog(@"[%s%i]~%f~%f~~~~~~~~~", __FUNCTION__, __LINE__, E.root.mainFrame.size.width, E.root.numerFrame.size.width);
        [E adjustEveryThing:E.root];
        
        /* Move cursor */
        CGFloat cursorOrgX = 0.0;
        CGFloat cursorOrgY = 0.0;
        cursorOrgX = tLayer.frame.origin.x + tLayer.frame.size.width;
        cursorOrgY = tLayer.frame.origin.y;
        E.view.cursor.frame = CGRectMake(cursorOrgX, cursorOrgY, CURSOR_W, E.curFontH);
        E.view.inpOrg = CGPointMake(cursorOrgX, cursorOrgY);
    } else { //Handle "÷"
        
//        if (E.curTextLayer != nil && E.curTextLayer.type == TEXTLAYER_EMPTY) {
//            if (E.curTextLayer.expo != nil) {
//                if ([E.curTextLayer.expo.children.firstObject isMemberOfClass:[EquationTextLayer class]]) {
//                    EquationTextLayer *l = E.curTextLayer.expo.children.firstObject;
//                    if (l.type != TEXTLAYER_EMPTY) {
//                        NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
//                        return;
//                    }
//                } else {
//                    NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
//                    return;
//                }
//            }
//        }
        
        if ([E.curParent isMemberOfClass: [EquationBlock class]]) {
            NSLog(@"%s%i~Input Op %@.~~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, op, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
        } else if ([E.curParent isMemberOfClass: [RadicalBlock class]]) {
            NSLog(@"%s%i~Input Op %@.~~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, op, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((RadicalBlock *)E.curParent).guid);
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        if(E.curMode == MODE_INPUT) {
            EquationBlock *eBlock = E.curParent;
            NSMutableArray *blockChildren = eBlock.children;
            NSEnumerator *enumerator = [blockChildren reverseObjectEnumerator];
            id block;
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            NSUInteger cnt = 0;
            CGFloat newNumerTop = 0.0, newNumerBtm = 0.0;
            if (E.curRoll == ROLL_NUMERATOR) {
                frameY = eBlock.numerFrame.origin.y;
            } else if (E.curRoll == ROLL_DENOMINATOR) {
                frameY = eBlock.denomFrame.origin.y;
            } else
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            
            BOOL lookForLeftParen = NO;
            while (block = [enumerator nextObject]) {
                cnt++;
                if ([block isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = block;
                    if (([layer.name isEqual: @"+"] || [layer.name isEqual: @"-"]) && lookForLeftParen == NO)
                        break;
                    
                    if ([layer.name isEqual: @")"])
                        lookForLeftParen = YES;
                    
                    if ([layer.name isEqual: @"("])
                        lookForLeftParen = NO;
                    
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
                } else {
                    NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            }
            
            frameH = newNumerTop + newNumerBtm;
            
            if (block != nil) { // Need a new block
                EquationBlock *newBlock = [[EquationBlock alloc] init:E];
                newBlock.roll = E.curRoll;
                newBlock.parent = eBlock;
                newBlock.numerFrame = CGRectMake(frameX, frameY - E.curFontH, frameW, frameH);
                newBlock.mainFrame = newBlock.numerFrame;
                newBlock.numerTopHalf = newNumerTop;
                newBlock.numerBtmHalf = newNumerBtm;
                /* The value of start had been double checked */
                NSUInteger start = blockChildren.count - cnt + 1;
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
                    } else {
                        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                }
                /* Remove those elements from old block */
                [blockChildren removeObjectsInRange:NSMakeRange(start, cnt-1)];
                /* Add new block into parent block */
                newBlock.c_idx = blockChildren.count;
                [blockChildren addObject: newBlock];
                eBlock = newBlock;
            } else {
                eBlock.numerFrame = CGRectMake(frameX, frameY - E.curFontH, frameW, frameH);
            }
            
            /* Make an empty denominator frame */
            eBlock.denomFrame = CGRectMake(frameX, frameY + frameH - E.curFontH, 0, E.curFontH);
            eBlock.denomTopHalf = E.curFontH / 2.0;
            eBlock.denomBtmHalf = E.curFontH / 2.0;
            eBlock.mainFrame = CGRectUnion(eBlock.numerFrame, eBlock.denomFrame);
//            NSLog(@"%s%i~[%.1f %.1f %.1f %.1f]~[%.1f %.1f %.1f %.1f]~[%.1f %.1f %.1f %.1f]~~~~~~~~", __FUNCTION__, __LINE__, eBlock.mainFrame.origin.x, eBlock.mainFrame.origin.y, eBlock.mainFrame.size.width, eBlock.mainFrame.size.height, eBlock.numerFrame.origin.x, eBlock.numerFrame.origin.y, eBlock.numerFrame.size.width, eBlock.numerFrame.size.height, eBlock.denomFrame.origin.x, eBlock.denomFrame.origin.y, eBlock.denomFrame.size.width, eBlock.denomFrame.size.height);
            
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
                        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else if ([eBlock.parent isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = eBlock.parent;
                    [layer updateFrameBaseOnExpo];
                    if ([layer.parent isMemberOfClass:[EquationBlock class]]) {
                        [(EquationBlock *)layer.parent updateFrameHeightS1:layer];
                    } else {
                        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else if ([eBlock.parent isMemberOfClass: [EquationBlock class]]) {
                    [(EquationBlock *)eBlock.parent updateFrameHeightS1:eBlock];
                } else {
                    NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                
            }
            E.curParent = eBlock;
//            NSLog(@"%s%i~[%.1f %.1f %.1f %.1f]~[%.1f %.1f %.1f %.1f]~[%.1f %.1f %.1f %.1f]~~~~~~~~", __FUNCTION__, __LINE__, eBlock.mainFrame.origin.x, eBlock.mainFrame.origin.y, eBlock.mainFrame.size.width, eBlock.mainFrame.size.height, eBlock.numerFrame.origin.x, eBlock.numerFrame.origin.y, eBlock.numerFrame.size.width, eBlock.numerFrame.size.height, eBlock.denomFrame.origin.x, eBlock.denomFrame.origin.y, eBlock.denomFrame.size.width, eBlock.denomFrame.size.height);
        } else if(E.curMode == MODE_INSERT) {
            if (E.insertCIdx == CIDX_0_NUMER) { // No division while no numerator
                return;
            }
            NSUInteger i = 0, cnt = 0;
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            CGFloat newNumerTop = 0.0, newNumerBtm = 0.0;
            EquationBlock *eBlock = E.curParent;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            newBlock.roll = E.curRoll;
            newBlock.parent = eBlock;
            
            BOOL lookForLeftParen = NO;
            for (int ii = (int)E.insertCIdx; ii >= 0; ii--) {
                i = ii;
                id block = [eBlock.children objectAtIndex:i];
                if ([block isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = block;
                    if (([layer.name isEqual: @"+"] || [layer.name isEqual: @"-"]) && lookForLeftParen == NO)
                        break;
                    
                    if ([layer.name isEqual: @")"])
                        lookForLeftParen = YES;
                    
                    if ([layer.name isEqual: @"("])
                        lookForLeftParen = NO;
                    
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
                } else {
                    NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                cnt++;
            }
            
            frameH = newNumerTop + newNumerBtm;
            
            if (i != 0)
                i++;
            
            newBlock.numerFrame = CGRectMake(frameX, frameY - E.curFontH, frameW, frameH);
            newBlock.numerTopHalf = newNumerTop;
            newBlock.numerBtmHalf = newNumerBtm;
            newBlock.denomFrame = CGRectMake(frameX, frameY + frameH - E.curFontH, 0, E.curFontH); //Make an empty denominator frame
            newBlock.denomTopHalf = E.curFontH / 2.0;
            newBlock.denomBtmHalf = E.curFontH / 2.0;
            newBlock.mainFrame = CGRectUnion(newBlock.numerFrame, newBlock.denomFrame);

            [newBlock.children reverse];
            [newBlock updateCIdx];
            /* Remove those elements from old block */
            [eBlock.children removeObjectsInRange:NSMakeRange(i, cnt)];
            /* Add new block into parent block */
            [eBlock.children insertObject:newBlock atIndex:i];
            [eBlock updateCIdx];
            eBlock = newBlock;

            E.curMode = MODE_INPUT;
            
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
                        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else if ([eBlock.parent isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = eBlock.parent;
                    [layer updateFrameBaseOnExpo];
                    if ([layer.parent isMemberOfClass:[EquationBlock class]]) {
                        [(EquationBlock *)layer.parent updateFrameHeightS1:layer];
                    } else {
                        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else if ([eBlock.parent isMemberOfClass: [EquationBlock class]]) {
                    [(EquationBlock *)eBlock.parent updateFrameHeightS1:eBlock];
                } else {
                    NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            }
            
            E.curParent = eBlock;
        } else if(E.curMode == MODE_DUMP_ROOT) {
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            newBlock.roll = ROLL_ROOT;
            newBlock.parent = nil;

            frameX = E.root.mainFrame.origin.x;
            frameY = E.root.mainFrame.origin.y - E.curFontH;
            frameW = E.root.mainFrame.size.width;
            frameH = E.root.mainFrame.size.height;

            newBlock.numerFrame = CGRectMake(frameX, frameY, frameW, frameH);
            newBlock.numerTopHalf = frameH / 2.0;
            newBlock.numerBtmHalf = frameH / 2.0;
            newBlock.denomFrame = CGRectMake(frameX, frameY + frameH, 0, E.baseCharHight); //Make an empty denominator frame
            newBlock.denomTopHalf = E.curFontH / 2.0;
            newBlock.denomBtmHalf = E.curFontH / 2.0;
            newBlock.mainFrame = CGRectUnion(newBlock.numerFrame, newBlock.denomFrame);

            E.root.mainFrame = newBlock.numerFrame;
            E.root.c_idx = 0;
            E.root.parent = newBlock;
            E.root.roll = ROLL_NUMERATOR;
            [newBlock.children addObject: E.root];

            E.root = newBlock;
            E.curParent = newBlock;
            E.curMode = MODE_INPUT;
        } else if(E.curMode == MODE_DUMP_RADICAL) {
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            RadicalBlock *rBlock = E.curParent;
            EquationBlock *eBlock = rBlock.content;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            eBlock.roll = ROLL_NUMERATOR;
            newBlock.roll = ROLL_ROOT_ROOT;
            newBlock.parent = rBlock;

            frameX = eBlock.mainFrame.origin.x;
            frameY = eBlock.mainFrame.origin.y - E.curFontH;
            frameW = eBlock.mainFrame.size.width;
            frameH = eBlock.mainFrame.size.height;

            newBlock.numerFrame = CGRectMake(frameX, frameY, frameW, frameH);
            newBlock.numerTopHalf = frameH / 2.0;
            newBlock.numerBtmHalf = frameH / 2.0;
            newBlock.denomFrame = CGRectMake(frameX, frameY + frameH, 0, E.curFontH); //Make an empty denominator frame
            newBlock.denomTopHalf = E.curFontH / 2.0;
            newBlock.denomBtmHalf = E.curFontH / 2.0;
            newBlock.mainFrame = CGRectUnion(newBlock.numerFrame, newBlock.denomFrame);

            eBlock.mainFrame = newBlock.numerFrame;
            eBlock.c_idx = 0;
            eBlock.parent = newBlock;
            [newBlock.children addObject: eBlock];

            rBlock.content = newBlock;
            CGFloat orgW = rBlock.frame.size.width;
            [rBlock updateFrame];
            [rBlock setNeedsDisplay];
            if ([rBlock.parent isMemberOfClass:[EquationBlock class]]) {
                [(EquationBlock *)rBlock.parent updateFrameHeightS1:rBlock];
                [(EquationBlock *)rBlock.parent updateFrameWidth:rBlock.frame.size.width - orgW :rBlock.roll];
            } else {
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            E.curParent = newBlock;
            E.curMode = MODE_INPUT;
        } else if(E.curMode == MODE_DUMP_EXPO) {
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            EquationTextLayer *layer = E.curParent;
            EquationBlock *eBlock = layer.expo;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            eBlock.roll = ROLL_NUMERATOR;
            newBlock.roll = ROLL_EXPO_ROOT;
            newBlock.parent = layer;
            
            frameX = eBlock.mainFrame.origin.x;
            frameY = eBlock.mainFrame.origin.y - E.curFontH;
            frameW = eBlock.mainFrame.size.width;
            frameH = eBlock.mainFrame.size.height;
            
            newBlock.numerFrame = CGRectMake(frameX, frameY, frameW, frameH);
            newBlock.numerTopHalf = frameH / 2.0;
            newBlock.numerBtmHalf = frameH / 2.0;
            newBlock.denomFrame = CGRectMake(frameX, frameY + frameH, 0, E.curFontH); //Make an empty denominator frame
            newBlock.denomTopHalf = E.curFontH / 2.0;
            newBlock.denomBtmHalf = E.curFontH / 2.0;
            newBlock.mainFrame = CGRectUnion(newBlock.numerFrame, newBlock.denomFrame);
            
            eBlock.mainFrame = newBlock.numerFrame;
            eBlock.c_idx = 0;
            eBlock.parent = newBlock;
            [newBlock.children addObject: eBlock];
            
            layer.expo = newBlock;
            [layer updateFrameBaseOnExpo];
            if ([layer.parent isMemberOfClass:[EquationBlock class]]) {
                [(EquationBlock *)layer.parent updateFrameHeightS1:layer];
            } else {
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            
            E.curParent = newBlock;
            E.curMode = MODE_INPUT;
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }

        E.curRoll = ROLL_DENOMINATOR;
        
        EquationBlock *eBlock = E.curParent;
        /* Add a bar into eBlock */
        FractionBarLayer *barLayer = [[FractionBarLayer alloc] init:E];
        NSLog(@"%s%i~Bar id: %i~~~~~~", __FUNCTION__, __LINE__, barLayer.guid);
        barLayer.name = @"/";
        barLayer.hidden = NO;
        barLayer.backgroundColor = [UIColor clearColor].CGColor;
        barLayer.parent = eBlock;
        /*Make bar in the middle of numer and deno*/
        CGRect frame;
        frame.origin.x = eBlock.mainFrame.origin.x;
        frame.size.height = E.curFontH / 2.0;
        frame.origin.y = eBlock.numerFrame.origin.y + eBlock.numerFrame.size.height - (frame.size.height / 2.0);
        frame.size.width = eBlock.mainFrame.size.width;
        NSLog(@"[%s%i]~%.1f~~~~~~~~~~", __FUNCTION__, __LINE__, frame.size.width);
        barLayer.frame = frame;
        barLayer.delegate = self;
        barLayer.c_idx = eBlock.children.count;
        [E.view.layer addSublayer: barLayer];
        [barLayer setNeedsDisplay];
        [eBlock.children addObject: barLayer];
        eBlock.bar = barLayer;
        
        EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :eBlock.denomFrame.origin :E :TEXTLAYER_EMPTY];
        layer.parent = eBlock;
        eBlock.denomFrame = layer.frame;
        NSLog(@"[%s%i]~%.1f~~~~~~~~~~", __FUNCTION__, __LINE__, layer.frame.size.width);
        layer.c_idx = eBlock.children.count;
        [eBlock.children addObject:layer];
        [E.view.layer addSublayer: layer];
        E.curTextLayer = layer;
        E.curBlock = layer;
        E.needNewLayer = NO;
//        NSLog(@"%s%i~[%.1f %.1f %.1f %.1f]~[%.1f %.1f %.1f %.1f]~[%.1f %.1f %.1f %.1f]~~~~~~~~", __FUNCTION__, __LINE__, eBlock.mainFrame.origin.x, eBlock.mainFrame.origin.y, eBlock.mainFrame.size.width, eBlock.mainFrame.size.height, eBlock.numerFrame.origin.x, eBlock.numerFrame.origin.y, eBlock.numerFrame.size.width, eBlock.numerFrame.size.height, eBlock.denomFrame.origin.x, eBlock.denomFrame.origin.y, eBlock.denomFrame.size.width, eBlock.denomFrame.size.height);
        [E adjustEveryThing:E.root];
//        NSLog(@"%s%i~[%.1f %.1f %.1f %.1f]~[%.1f %.1f %.1f %.1f]~[%.1f %.1f %.1f %.1f]~~~~~~~~", __FUNCTION__, __LINE__, eBlock.mainFrame.origin.x, eBlock.mainFrame.origin.y, eBlock.mainFrame.size.width, eBlock.mainFrame.size.height, eBlock.numerFrame.origin.x, eBlock.numerFrame.origin.y, eBlock.numerFrame.size.width, eBlock.numerFrame.size.height, eBlock.denomFrame.origin.x, eBlock.denomFrame.origin.y, eBlock.denomFrame.size.width, eBlock.denomFrame.size.height);
        
        /* Move cursor */
        CGFloat cursorOrgX = 0.0;
        CGFloat cursorOrgY = 0.0;
        cursorOrgX = eBlock.denomFrame.origin.x;
        cursorOrgY = eBlock.denomFrame.origin.y;
        E.view.cursor.frame = CGRectMake(cursorOrgX, cursorOrgY, CURSOR_W, E.curFontH);
        E.view.inpOrg = CGPointMake(cursorOrgX, cursorOrgY);
    }
    
}

- (void)handleRootBtnClick: (int)rootCnt {
    EquationTextLayer *orgLayer = E.curTextLayer;
    CGFloat incrWidth = 0.0;
    
    if (orgLayer != nil) {
        if (orgLayer.type == TEXTLAYER_EMPTY) {
            if (orgLayer.expo == nil) {
                EquationBlock *cb = E.curParent;
                [orgLayer destroy];
                [cb.children removeObjectAtIndex:orgLayer.c_idx];
                [cb updateCIdx];
                incrWidth -= orgLayer.mainFrame.size.width;
            } else if ([orgLayer.expo.children.firstObject isMemberOfClass:[EquationTextLayer class]]) {
                EquationTextLayer *l = orgLayer.expo.children.firstObject;
                if (l.type == TEXTLAYER_EMPTY) {
                    EquationBlock *cb = E.curParent;
                    [orgLayer destroy];
                    [cb.children removeObjectAtIndex:orgLayer.c_idx];
                    [cb updateCIdx];
                    incrWidth -= orgLayer.mainFrame.size.width;
                } else {
                    NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    return;
                }
            } else {
                NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
        }
    }
    
    RadicalBlock *newRBlock = [[RadicalBlock alloc] init:E.view.inpOrg :E :rootCnt];
    NSLog(@"%s%i~Input Root.~ID: %i~Content Id: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, newRBlock.guid, newRBlock.content.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
    
    incrWidth += newRBlock.frame.size.width;
    
//    if (orgLayer != nil && orgLayer.type == TEXTLAYER_EMPTY) {
//        EquationBlock *cb = E.curBlock;
//        [orgLayer destroy];
//        [cb.children removeObjectAtIndex:orgLayer.c_idx];
//        [cb updateCIdx];
//        incrWidth -= orgLayer.mainFrame.size.width;
//    }
    
    
    if(E.curMode == MODE_INPUT) {
        EquationBlock *eBlock = E.curParent;
        if (E.needX) {
            EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
            tLayer1.name = @"×";
            tLayer1.roll = E.curRoll;
            tLayer1.parent = eBlock;
            tLayer1.c_idx = eBlock.children.count;
            [eBlock.children addObject:tLayer1];
            [E.view.layer addSublayer:tLayer1];
            newRBlock.frame = CGRectOffset(newRBlock.frame, tLayer1.frame.size.width, 0);
            incrWidth += tLayer1.frame.size.width;
            E.needX = FALSE;
        }
        
        newRBlock.c_idx = eBlock.children.count;
        [eBlock.children addObject:newRBlock];
    } else if(E.curMode == MODE_INSERT) {
        EquationBlock *eBlock = E.curParent;
        if (E.needX) {
            EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
            tLayer1.name = @"×";
            tLayer1.roll = E.curRoll;
            tLayer1.parent = eBlock;
            [E.view.layer addSublayer:tLayer1];
            if (E.insertCIdx == CIDX_0_NUMER) {
                E.insertCIdx = 0;
                [eBlock.children insertObject:tLayer1 atIndex: E.insertCIdx++];
                [eBlock.children insertObject:newRBlock atIndex: E.insertCIdx++];
            } else {
                [eBlock.children insertObject:tLayer1 atIndex: ++E.insertCIdx];
                [eBlock.children insertObject:newRBlock atIndex: ++E.insertCIdx];
            }
            
            newRBlock.frame = CGRectOffset(newRBlock.frame, tLayer1.frame.size.width, 0);
            incrWidth += tLayer1.frame.size.width;
        } else {
            if (E.insertCIdx == CIDX_0_NUMER) {
                E.insertCIdx = 0;
                [eBlock.children insertObject:newRBlock atIndex: E.insertCIdx++];
            } else {
                [eBlock.children insertObject:newRBlock atIndex: ++E.insertCIdx];
            }
        }
        
        /*Update c_idx*/
        [eBlock updateCIdx];
    } else if(E.curMode == MODE_DUMP_ROOT) {
        EquationBlock *eBlock = [[EquationBlock alloc] init:E];
        eBlock.roll = ROLL_ROOT;
        eBlock.parent = nil;
        eBlock.numerFrame = E.root.mainFrame;
        eBlock.numerTopHalf = E.root.mainFrame.size.height / 2.0;
        eBlock.numerBtmHalf = E.root.mainFrame.size.height / 2.0;
        eBlock.mainFrame = eBlock.numerFrame;
        E.root.roll = ROLL_NUMERATOR;
        E.root.parent = eBlock;
        E.root.c_idx = 0;
        E.root.roll = E.curRoll;
        [eBlock.children addObject:E.root];
        
        EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
        tLayer1.name = @"×";
        tLayer1.roll = E.curRoll;
        tLayer1.parent = eBlock;
        tLayer1.c_idx = 1;
        [eBlock.children addObject: tLayer1];
        [E.view.layer addSublayer: tLayer1];
        newRBlock.frame = CGRectOffset(newRBlock.frame, tLayer1.frame.size.width, 0);
        incrWidth += tLayer1.frame.size.width;
        
        newRBlock.c_idx = 2;
        newRBlock.roll = E.curRoll;
        [eBlock.children addObject: newRBlock];
        E.root = eBlock;
    } else if(E.curMode == MODE_DUMP_RADICAL) {
        RadicalBlock *rBlock = E.curParent;
        EquationBlock *eBlock = rBlock.content;
        EquationBlock *newBlock = [[EquationBlock alloc] init:E];
        newBlock.roll = ROLL_ROOT_ROOT;
        newBlock.parent = rBlock;
        newBlock.numerFrame = eBlock.mainFrame;
        newBlock.numerTopHalf = eBlock.mainFrame.size.height / 2.0;
        newBlock.numerBtmHalf = eBlock.mainFrame.size.height / 2.0;
        newBlock.mainFrame = newBlock.numerFrame;
        eBlock.roll = ROLL_NUMERATOR;
        eBlock.parent = newBlock;
        eBlock.c_idx = 0;
        [newBlock.children addObject:eBlock];

        EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
        tLayer1.name = @"×";
        tLayer1.roll = E.curRoll;
        tLayer1.parent = newBlock;
        tLayer1.c_idx = 1;
        [E.view.layer addSublayer:tLayer1];
        [newBlock.children addObject:tLayer1];
        incrWidth += tLayer1.frame.size.width;

        newRBlock.frame = CGRectOffset(newRBlock.frame, tLayer1.frame.size.width, 0);
        newRBlock.c_idx = 2;
        [newBlock.children addObject:newRBlock];
        rBlock.content = newBlock;
        E.curParent = newBlock;
    } else if(E.curMode == MODE_DUMP_EXPO) {
        EquationTextLayer *layer = E.curParent;
        EquationBlock *eBlock = layer.expo;
        EquationBlock *newBlock = [[EquationBlock alloc] init:E];
        newBlock.roll = ROLL_EXPO_ROOT;
        newBlock.parent = layer;
        newBlock.numerFrame = eBlock.mainFrame;
        newBlock.numerTopHalf = eBlock.mainFrame.size.height / 2.0;
        newBlock.numerBtmHalf = eBlock.mainFrame.size.height / 2.0;
        newBlock.mainFrame = newBlock.numerFrame;
        eBlock.roll = ROLL_NUMERATOR;
        eBlock.parent = newBlock;
        eBlock.c_idx = 0;
        [newBlock.children addObject:eBlock];
        
        EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
        tLayer1.name = @"×";
        tLayer1.roll = E.curRoll;
        tLayer1.parent = newBlock;
        tLayer1.c_idx = 1;
        [E.view.layer addSublayer:tLayer1];
        [newBlock.children addObject:tLayer1];
        incrWidth += tLayer1.frame.size.width;
        
        newRBlock.frame = CGRectOffset(newRBlock.frame, tLayer1.frame.size.width, 0);
        newRBlock.c_idx = 2;
        [newBlock.children addObject:newRBlock];
        layer.expo = newBlock;
        E.curParent = newBlock;
    } else {
        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    newRBlock.parent = E.curParent;

    newRBlock.delegate = self;
    [E.view.layer addSublayer: newRBlock];
    [newRBlock setNeedsDisplay];
    
    [(EquationBlock *)E.curParent updateFrameWidth:incrWidth :E.curRoll];
    [(EquationBlock *)E.curParent updateFrameHeightS1:newRBlock];
    [E adjustEveryThing:E.root];
    
    E.needX = NO;
    E.curMode = MODE_INPUT;
    E.curRoll = ROLL_NUMERATOR;
    E.curParent = newRBlock.content;
    E.view.inpOrg = ((EquationBlock *)E.curParent).mainFrame.origin;
    E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, E.curFontH);
    NSLog(@"%s%i~%.1f~~~~~~~~~~", __FUNCTION__, __LINE__, E.view.inpOrg.x);
}

- (void)handlePowBtnClick {
    if (E.curFont == E.superscriptFont || E.curMode == MODE_DUMP_EXPO) { // TODO
        NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return;
    }
    
    if (E.needNewLayer) {
        CGPoint pos = E.view.inpOrg;
        CGFloat incrWidth = 0.0;
        
        EquationTextLayer *baseLayer = [[EquationTextLayer alloc] init:@"_" :pos :E :TEXTLAYER_EMPTY];
        baseLayer.parent = E.curParent;
        [E.view.layer addSublayer: baseLayer];
        
        pos.x += baseLayer.frame.size.width;
        pos.y = (pos.y + E.baseCharHight * 0.45) - E.expoCharHight;
        
        E.curFont = E.superscriptFont;
        
        EquationBlock *exp = [[EquationBlock alloc] init:pos :E];
        exp.roll = ROLL_EXPO_ROOT;
        exp.parent = baseLayer;
        baseLayer.expo = exp;
        
        EquationTextLayer *expLayer = [[EquationTextLayer alloc] init:@"_" :pos :E :TEXTLAYER_EMPTY];
        expLayer.parent = exp;
        exp.numerFrame = expLayer.frame;
        exp.mainFrame = expLayer.frame;
        expLayer.roll = ROLL_NUMERATOR;
        expLayer.c_idx = 0;
        [exp.children addObject:expLayer];
        [E.view.layer addSublayer: expLayer];
        [baseLayer updateFrameBaseOnExpo];
        
        incrWidth = baseLayer.mainFrame.size.width;
        
        E.curFont = E.baseFont;
        
        if(E.curMode == MODE_INPUT) {
            EquationBlock *eb = E.curParent;
            if (E.needX) {
                EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
                tLayer1.name = @"×";
                tLayer1.parent = eb;
                tLayer1.c_idx = eb.children.count;
                [eb.children addObject:tLayer1];
                [E.view.layer addSublayer:tLayer1];
                baseLayer.frame = CGRectOffset(baseLayer.frame, tLayer1.frame.size.width, 0);
                [baseLayer updateFrameBaseOnBase];
                incrWidth += tLayer1.frame.size.width;
                E.needX = NO;
            }
            
            baseLayer.c_idx = eb.children.count;
            [eb.children addObject:baseLayer];
        } else if(E.curMode == MODE_INSERT) {
            EquationBlock *eb = E.curParent;
            if (E.needX) {
                EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
                tLayer1.name = @"×";
                tLayer1.parent = eb;
                [E.view.layer addSublayer:tLayer1];
                if (E.insertCIdx == CIDX_0_NUMER) {
                    E.insertCIdx = 0;
                    [eb.children insertObject:tLayer1 atIndex: E.insertCIdx++];
                    [eb.children insertObject:baseLayer atIndex: E.insertCIdx++];
                } else {
                    [eb.children insertObject:tLayer1 atIndex: ++E.insertCIdx];
                    [eb.children insertObject:baseLayer atIndex: ++E.insertCIdx];
                }
                
                baseLayer.frame = CGRectOffset(baseLayer.frame, tLayer1.frame.size.width, 0);
                [baseLayer updateFrameBaseOnBase];
                incrWidth += tLayer1.frame.size.width;
            } else {
                if (E.insertCIdx == CIDX_0_NUMER) {
                    E.insertCIdx = 0;
                    [eb.children insertObject:baseLayer atIndex: E.insertCIdx++];
                } else {
                    [eb.children insertObject:baseLayer atIndex: ++E.insertCIdx];
                }
            }
            
            /*Update c_idx*/
            [eb updateCIdx];
        } else if(E.curMode == MODE_DUMP_ROOT) {
            EquationBlock *eBlock = [[EquationBlock alloc] init:E];
            eBlock.roll = ROLL_ROOT;
            eBlock.parent = nil;
            eBlock.numerFrame = E.root.mainFrame;
            eBlock.numerTopHalf = E.root.mainFrame.size.height / 2.0;
            eBlock.numerBtmHalf = E.root.mainFrame.size.height / 2.0;
            eBlock.mainFrame = eBlock.numerFrame;
            E.root.roll = ROLL_NUMERATOR;
            E.root.parent = eBlock;
            E.root.c_idx = 0;
            E.root.roll = E.curRoll;
            [eBlock.children addObject:E.root];
            
            EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
            tLayer1.name = @"×";
            tLayer1.parent = eBlock;
            tLayer1.c_idx = 1;
            [eBlock.children addObject: tLayer1];
            [E.view.layer addSublayer: tLayer1];
            baseLayer.frame = CGRectOffset(baseLayer.frame, tLayer1.frame.size.width, 0);
            [baseLayer updateFrameBaseOnBase];
            incrWidth += tLayer1.frame.size.width;
            
            baseLayer.c_idx = 2;
            [eBlock.children addObject: baseLayer];
            E.root = eBlock;
            E.curMode = MODE_INPUT;
        } else if(E.curMode == MODE_DUMP_RADICAL) {
            RadicalBlock *rBlock = E.curParent;
            EquationBlock *eBlock = rBlock.content;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            newBlock.roll = ROLL_ROOT_ROOT;
            newBlock.parent = rBlock;
            newBlock.numerFrame = eBlock.mainFrame;
            newBlock.numerTopHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.numerBtmHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.mainFrame = newBlock.numerFrame;
            eBlock.roll = ROLL_NUMERATOR;
            eBlock.parent = newBlock;
            eBlock.c_idx = 0;
            [newBlock.children addObject:eBlock];
            
            EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
            tLayer1.name = @"×";
            tLayer1.parent = newBlock;
            tLayer1.c_idx = 1;
            [E.view.layer addSublayer:tLayer1];
            [newBlock.children addObject:tLayer1];
            incrWidth += tLayer1.frame.size.width;
            
            baseLayer.frame = CGRectOffset(baseLayer.frame, tLayer1.frame.size.width, 0);
            [baseLayer updateFrameBaseOnBase];
            baseLayer.c_idx = 2;
            [newBlock.children addObject:baseLayer];
            rBlock.content = newBlock;
            E.curParent = newBlock;
            E.curMode = MODE_INPUT;
        } else
            NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        
        [(EquationBlock *)E.curParent updateFrameWidth:incrWidth :E.curRoll];
        [(EquationBlock *)E.curParent updateFrameHeightS1:baseLayer];
        [E adjustEveryThing:E.root];
        
        E.curTextLayer = baseLayer;
        E.curBlock = baseLayer;
        E.needX = NO;
        E.view.inpOrg = baseLayer.frame.origin;
        E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, E.curFontH);
        E.needNewLayer = NO;
    } else {
        E.curFont = E.superscriptFont;
        
        if (E.curTextLayer.expo == nil) {
            CGFloat orgW = E.curTextLayer.mainFrame.size.width;
            CGFloat x = E.view.inpOrg.x;
            if (E.curTextLayer.type == TEXTLAYER_EMPTY) {
                x += E.curTextLayer.frame.size.width;
            }
            
            CGFloat y = (E.view.inpOrg.y + E.baseCharHight * 0.45) - E.expoCharHight;
            E.view.inpOrg = CGPointMake(x, y);
            E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, E.expoCharHight);
            
            EquationBlock *eBlock = [[EquationBlock alloc] init:E.view.inpOrg :E];
            eBlock.roll = ROLL_EXPO_ROOT;
            eBlock.parent = E.curTextLayer;
            E.curTextLayer.expo = eBlock;
            
            EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :E.view.inpOrg :E :TEXTLAYER_EMPTY];
            layer.parent = eBlock;
            eBlock.numerFrame = layer.frame;
            eBlock.mainFrame = layer.frame;
            layer.roll = ROLL_NUMERATOR;
            layer.c_idx = 0;
            [eBlock.children addObject:layer];
            [E.view.layer addSublayer: layer];
            [E.curTextLayer updateFrameBaseOnExpo];
            
            NSLog(@"[%s%i]~%f~%f~~~~~~~~~", __FUNCTION__, __LINE__, E.curTextLayer.mainFrame.size.width, E.root.numerFrame.size.width);
            CGFloat inc = E.curTextLayer.mainFrame.size.width - orgW;
            [(EquationBlock *)E.curParent updateFrameWidth:inc :E.curRoll];
            [(EquationBlock *)E.curParent updateFrameHeightS1:E.curTextLayer];
            NSLog(@"[%s%i]~%f~%f~~~~~~~~~", __FUNCTION__, __LINE__, E.curTextLayer.mainFrame.size.width, E.root.numerFrame.size.width);
            
            E.curTextLayer = layer;
            E.curBlock = layer;
            E.needNewLayer = NO;
            E.curParent = eBlock;
            E.curRoll = ROLL_NUMERATOR;
            E.curMode = MODE_INPUT;
            E.needX = NO;
        } else {
            EquationBlock *exp = E.curTextLayer.expo;
            id lastObj = exp.children.lastObject;
            if ([lastObj isMemberOfClass:[EquationTextLayer class]]) {
                EquationTextLayer *layer = lastObj;
                CGFloat tmp;
                if (layer.type == TEXTLAYER_EMPTY) {
                    E.view.inpOrg = layer.frame.origin;
                    tmp = E.expoCharHight;
                    E.needNewLayer = NO;
                } else {
                    CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                    CGFloat y = layer.mainFrame.origin.y;
                    E.view.inpOrg = CGPointMake(x, y);
                    tmp = layer.mainFrame.size.height;
                    
                    if (layer.type == TEXTLAYER_OP) {
                        E.needNewLayer = YES;
                    } else {
                        E.needNewLayer = NO;
                        
                    }
                }
                E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, tmp);
                E.curTextLayer = layer;
                E.curBlock = layer;
                E.curParent = exp;
                E.curRoll = layer.roll;
                E.curMode = MODE_INPUT;
                E.needX = NO;
            } else if ([lastObj isMemberOfClass:[EquationBlock class]]) {
                EquationBlock *eb = lastObj;
                CGFloat x = eb.mainFrame.origin.x + eb.mainFrame.size.width;
                CGFloat y = eb.mainFrame.origin.y + eb.mainFrame.size.height / 2.0 - E.curFontH / 2.0;
                E.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = eb.mainFrame.size.height;
                E.view.cursor.frame = CGRectMake(eb.mainFrame.origin.x, eb.mainFrame.origin.y, CURSOR_W, tmp);
                E.needNewLayer = YES;
                E.curTextLayer = nil;
                E.curBlock = eb;
                E.curParent = exp;
                E.curRoll = eb.roll;
                E.curMode = MODE_INPUT;
                E.needX = YES;
            } else if ([lastObj isMemberOfClass:[RadicalBlock class]]) {
                RadicalBlock *rb = lastObj;
                CGFloat x = rb.frame.origin.x + rb.frame.size.width;
                CGFloat y = rb.frame.origin.y + rb.frame.size.height / 2.0 - E.curFontH / 2.0;
                E.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = rb.frame.size.height;
                E.view.cursor.frame = CGRectMake(rb.frame.origin.x, rb.frame.origin.y, CURSOR_W, tmp);
                E.needNewLayer = YES;
                E.curTextLayer = nil;
                E.curBlock = rb;
                E.curParent = exp;
                E.curRoll = rb.roll;
                E.curMode = MODE_INPUT;
                E.needX = YES;
            }
        }
        
    }
}

- (void)handleParenthBtnClick : (NSString *)parenth {
    CGFloat incrWidth = 0.0;
    
    if (E.curTextLayer != nil && E.curTextLayer.type == TEXTLAYER_EMPTY) {
        E.curTextLayer.type = TEXTLAYER_PARENTH;
        CGFloat orgW = E.curTextLayer.mainFrame.size.width;
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: parenth];
        CTFontRef ctFont = CTFontCreateWithName((CFStringRef)E.curFont.fontName, E.curFont.pointSize, NULL);
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        CGSize newStrSize = [attStr size];
        E.curTextLayer.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, newStrSize.width, newStrSize.height);
        E.curTextLayer.mainFrame = E.curTextLayer.frame;
        E.curTextLayer.backgroundColor = [UIColor clearColor].CGColor;
        E.curTextLayer.string = attStr;
        [E.curTextLayer updateFrameBaseOnBase];
        incrWidth += E.curTextLayer.mainFrame.size.width - orgW;
    } else {
        EquationTextLayer *tLayer = [[EquationTextLayer alloc] init:parenth :E.view.inpOrg :E :TEXTLAYER_PARENTH];
        tLayer.name = parenth;
        incrWidth = tLayer.frame.size.width;
        if(E.curMode == MODE_INPUT) {
            EquationBlock *block = E.curParent;
            
            if (E.needX && [parenth isEqual:@"("]) {
                EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
                tLayer1.name = @"×";
                tLayer1.roll = E.curRoll;
                tLayer1.parent = block;
                tLayer1.c_idx = block.children.count;
                [block.children addObject:tLayer1];
                [E.view.layer addSublayer:tLayer1];
                tLayer.c_idx = block.children.count;
                [block.children addObject:tLayer];
                tLayer.frame = CGRectOffset(tLayer.frame, tLayer1.frame.size.width, 0);
                incrWidth += tLayer1.frame.size.width;
            } else {
                tLayer.c_idx = block.children.count;
                [block.children addObject:tLayer];
            }
            
        } else if(E.curMode == MODE_INSERT) {
            //NSLog(@"%s%i~~~%lu~~~~~~~~", __FUNCTION__, __LINE__, (unsigned long)E.insertCIdx);
            EquationBlock *block = E.curParent;
            
            if (E.needX && [parenth isEqual:@"("]) {
                EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
                tLayer1.name = @"×";
                tLayer1.roll = E.curRoll;
                tLayer1.parent = block;
                if (E.insertCIdx == CIDX_0_NUMER) {
                    tLayer1.c_idx = 0;
                    E.insertCIdx = 0;
                } else {
                    tLayer1.c_idx = E.insertCIdx + 1;
                }
                [E.view.layer addSublayer:tLayer1];
                [block.children insertObject:tLayer1 atIndex:tLayer1.c_idx];
                
                tLayer.c_idx = tLayer1.c_idx + 1;
                [block.children insertObject:tLayer atIndex:tLayer.c_idx];
                /*Update c_idx*/
                [block updateCIdx];
                tLayer.frame = CGRectOffset(tLayer.frame, tLayer1.frame.size.width, 0);
                incrWidth += tLayer1.frame.size.width;
                E.insertCIdx += 2;
            } else {
                if (E.insertCIdx == CIDX_0_NUMER) {
                    tLayer.c_idx = 0;
                    E.insertCIdx = 0;
                } else {
                    tLayer.c_idx = E.insertCIdx + 1;
                }
                [block.children insertObject:tLayer atIndex:tLayer.c_idx];
                /*Update c_idx*/
                [block updateCIdx];
                E.insertCIdx += 1;
            }
            
        } else if(E.curMode == MODE_DUMP_ROOT) {
            if ([parenth isEqual:@"("]) {
                EquationBlock *block = [[EquationBlock alloc] init:E];
                block.roll = ROLL_ROOT;
                block.parent = nil;
                block.numerFrame = E.root.mainFrame;
                block.numerTopHalf = E.root.mainFrame.size.height / 2.0;
                block.numerBtmHalf = E.root.mainFrame.size.height / 2.0;
                block.mainFrame = block.numerFrame;
                E.root.roll = ROLL_NUMERATOR;
                E.root.parent = block;
                E.root.c_idx = 0;
                [block.children addObject:E.root];
                
                EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
                tLayer1.name = @"×";
                tLayer1.roll = E.curRoll;
                tLayer1.parent = block;
                tLayer1.c_idx = 1;
                [E.view.layer addSublayer:tLayer1];
                [block.children addObject:tLayer1];
                
                tLayer.frame = CGRectOffset(tLayer.frame, tLayer1.frame.size.width, 0);
                incrWidth += tLayer1.frame.size.width;
                tLayer.c_idx = 2;
                [block.children addObject:tLayer];
                E.root = block;
                E.curParent = block;
                E.curMode = MODE_INPUT;
            } else {
                NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
            
        } else if(E.curMode == MODE_DUMP_RADICAL) {
            if ([parenth isEqual:@"("]) {
                RadicalBlock *rBlock = E.curParent;
                EquationBlock *eBlock = rBlock.content;
                EquationBlock *newBlock = [[EquationBlock alloc] init:E];
                newBlock.roll = ROLL_ROOT_ROOT;
                newBlock.parent = rBlock;
                newBlock.numerFrame = eBlock.mainFrame;
                newBlock.numerTopHalf = eBlock.mainFrame.size.height / 2.0;
                newBlock.numerBtmHalf = eBlock.mainFrame.size.height / 2.0;
                newBlock.mainFrame = newBlock.numerFrame;
                eBlock.roll = ROLL_NUMERATOR;
                eBlock.parent = newBlock;
                eBlock.c_idx = 0;
                [newBlock.children addObject:eBlock];
                
                EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
                tLayer1.name = @"×";
                tLayer1.roll = E.curRoll;
                tLayer1.parent = newBlock;
                tLayer1.c_idx = 1;
                [E.view.layer addSublayer:tLayer1];
                [newBlock.children addObject:tLayer1];
                
                tLayer.frame = CGRectOffset(tLayer.frame, tLayer1.frame.size.width, 0);
                incrWidth += tLayer1.frame.size.width;
                tLayer.c_idx = 2;
                [newBlock.children addObject:tLayer];
                rBlock.content = newBlock;
                E.curParent = newBlock;
                E.curMode = MODE_INPUT;
            } else {
                NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
        } else if(E.curMode == MODE_DUMP_EXPO) {
            if ([parenth isEqual:@"("]) {
                EquationTextLayer *layer = E.curParent;
                EquationBlock *eBlock = layer.expo;
                EquationBlock *newBlock = [[EquationBlock alloc] init:E];
                newBlock.roll = ROLL_EXPO_ROOT;
                newBlock.parent = layer;
                newBlock.numerFrame = eBlock.mainFrame;
                newBlock.numerTopHalf = eBlock.mainFrame.size.height / 2.0;
                newBlock.numerBtmHalf = eBlock.mainFrame.size.height / 2.0;
                newBlock.mainFrame = newBlock.numerFrame;
                eBlock.roll = ROLL_NUMERATOR;
                eBlock.parent = newBlock;
                eBlock.c_idx = 0;
                [newBlock.children addObject:eBlock];
                
                EquationTextLayer *tLayer1 = [[EquationTextLayer alloc] init:@" × " :E.view.inpOrg :E :TEXTLAYER_OP];
                tLayer1.name = @"×";
                tLayer1.roll = E.curRoll;
                tLayer1.parent = newBlock;
                tLayer1.c_idx = 1;
                [E.view.layer addSublayer:tLayer1];
                [newBlock.children addObject:tLayer1];
                
                tLayer.frame = CGRectOffset(tLayer.frame, tLayer1.frame.size.width, 0);
                incrWidth += tLayer1.frame.size.width;
                tLayer.c_idx = 2;
                [newBlock.children addObject:tLayer];
                layer.expo = newBlock;
                E.curParent = newBlock;
                E.curMode = MODE_INPUT;
            } else {
                NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
        
        tLayer.parent = E.curParent;
        [E.view.layer addSublayer:tLayer];
        E.curTextLayer = tLayer;
    }
    
    /* Update frame info of current block */
    [(EquationBlock *)E.curParent updateFrameWidth:incrWidth :E.curRoll];
    [E adjustEveryThing:E.root];
    
    E.needX = [parenth isEqual:@"("] ? NO : YES;
    E.needNewLayer = YES;
    
    /* Move cursor */
    CGFloat cursorOrgX = E.curTextLayer.frame.origin.x + E.curTextLayer.frame.size.width;
    CGFloat cursorOrgY = E.curTextLayer.frame.origin.y;
    
    E.view.cursor.frame = CGRectMake(cursorOrgX, cursorOrgY, CURSOR_W, E.curFontH);
    E.view.inpOrg = CGPointMake(cursorOrgX, cursorOrgY);
    
    E.curBlock = E.curTextLayer;
    E.curTextLayer = nil;
}

- (void)handleDelBtnClick {
    CGFloat incrWidth = 0.0;
    if ([E.curBlock isMemberOfClass:[EquationBlock class]]) {
        
    } else if ([E.curBlock isMemberOfClass:[RadicalBlock class]]) {
    } else if ([E.curBlock isMemberOfClass:[FractionBarLayer class]]) {
    } else if ([E.curBlock isMemberOfClass:[EquationTextLayer class]]) {
        NSMutableAttributedString *orgStr = [[NSMutableAttributedString alloc] initWithAttributedString:E.curTextLayer.string];
        CGFloat orgWidth = [orgStr size].width;
        [orgStr deleteCharactersInRange:NSMakeRange(orgStr.length - 1, 1)];
        CGFloat newWidth = [orgStr size].width;
        incrWidth = newWidth - orgWidth;
        
        CGRect frame = E.curTextLayer.frame;
        frame.size.width = [orgStr size].width;
        E.curTextLayer.frame = frame;
        E.curTextLayer.string = orgStr;
        [E.curTextLayer updateFrameBaseOnBase];
        
        [(EquationBlock *)E.curParent updateFrameWidth:incrWidth :E.curRoll];
        [E adjustEveryThing:E.root];
    } else {
        
    }
    
    
}

-(void)btnClicked: (UIButton *)btn {
    
    if([[btn currentTitle]  isEqual: @"DUMP"]) {
        [E dumpEverything:E.root];
        NSLog(@"InputX: %.1f InputY: %.1f~~~~~~~~~~~", E.view.inpOrg.x, E.view.inpOrg.y);
    } else if([[btn currentTitle]  isEqual: @"DEBUG"]) {
        drawFrame(self, E.view, E.root);
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
        [self handleParenthBtnClick:@"("];
    } else if([[btn currentTitle]  isEqual: @")"]) {
        [self handleParenthBtnClick:@")"];
    } else if([[btn currentTitle]  isEqual: @"<-"]) {
        [self handleDelBtnClick];
    } else
        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
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
        NSLog(@"[%s%i]~~~~~~~~~~~", __FUNCTION__, __LINE__);
        CGContextSetGrayStrokeColor(ctx, 0.0, 1.0);
        CGContextSetLineWidth(ctx, layer.frame.size.width);
        
        CGPoint points[] = {CGPointMake(0, 0), CGPointMake(0, layer.frame.size.height)};
        CGContextStrokeLineSegments(ctx, points, 2);
    } else if ([layer.name isEqual: @"/"]) {
        CGContextSetGrayStrokeColor(ctx, 0.0, 1.0);
        CGContextSetLineWidth(ctx, 1.0);
        FractionBarLayer *bar = (FractionBarLayer *)layer;
        CGPoint points[] = {CGPointMake(0, bar.frame.size.height/2.0 - 1.0), CGPointMake(bar.frame.size.width, bar.frame.size.height/2.0 - 1.0)};
        CGContextStrokeLineSegments(ctx, points, 2);
        //NSLog(@"%s%i~%.2f~~~~~~~~~~", __FUNCTION__, __LINE__, bar.frame.size.width);
    }else if ([layer.name isEqual: @"radical"]) {
        CGContextSetGrayStrokeColor(ctx, 0.0, 1.0);
        CGContextSetLineWidth(ctx, 1.0);
        RadicalBlock *rBlock = (RadicalBlock *)layer;
        CGFloat margineL = RADICAL_MARGINE_L_PERC * rBlock.frame.size.height;
//        CGPoint points[] = {CGPointMake(rBlock.frame.size.width, 1.0), CGPointMake(margineL, 1.0),
//            CGPointMake(margineL, 1.0), CGPointMake(margineL / 2.0, rBlock.frame.size.height - 2.0),
//            CGPointMake(margineL / 2.0, rBlock.frame.size.height - 2.0), CGPointMake(margineL/5.0, rBlock.frame.size.height * 0.75),
//            CGPointMake(margineL / 5.0, rBlock.frame.size.height * 0.75), CGPointMake(0.0, rBlock.frame.size.height * 0.85)};
//        CGContextStrokeLineSegments(ctx, points, 8);
        CGPoint points[] = {CGPointMake(rBlock.frame.size.width, 1.0), CGPointMake(margineL, 1.0),
            CGPointMake(margineL, 1.0), CGPointMake(margineL / 2.0, rBlock.frame.size.height - 2.0),
            CGPointMake(margineL / 2.0, rBlock.frame.size.height - 2.0), CGPointMake(1.0, rBlock.frame.size.height * 0.7)};
        CGContextStrokeLineSegments(ctx, points, 6);
        //NSLog(@"%s%i~%.2f~~~~~~~~~~", __FUNCTION__, __LINE__, bar.frame.size.width);
    } else if ([layer.name isEqual: @"drawframe"]) {
        CGContextSetRGBStrokeColor(ctx, 0, 0, 0.7, 1);
        CGContextSetLineWidth(ctx, 0.5);
        
        CGPoint points[] = {CGPointMake(0.0, 0.0), CGPointMake(layer.frame.size.width - 0.0, 0.0),
            CGPointMake(layer.frame.size.width - 0.5, 0.0), CGPointMake(layer.frame.size.width - 0.5, layer.frame.size.height),
            CGPointMake(layer.frame.size.width - 0.5, layer.frame.size.height - 0.5), CGPointMake(0.5, layer.frame.size.height - 0.5),
            CGPointMake(0.5, layer.frame.size.height), CGPointMake(0.5, 0.0)};
        CGContextStrokeLineSegments(ctx, points, 8);
    } else
        NSLog(@"[%s%i]~~ERR~%@~~~~~~~~", __FUNCTION__, __LINE__, layer.name);
}

@end
