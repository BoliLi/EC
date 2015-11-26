//
//  Utils.m
//  EasyCalc
//
//  Created by LiBoli on 15/11/23.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"
#import "Utils.h"
#import "Equation.h"
#import "EquationBlock.h"
#import "EquationTextLayer.h"
#import "RadicalBlock.h"
#import "FractionBarLayer.h"
#import "DisplayView.h"

EquationTextLayer *findLastTLayer(Equation *e, id blk) {
    
    do {
        if ([blk isMemberOfClass:[EquationBlock class]]) {
            EquationBlock *eb = blk;
            blk = eb.children.lastObject;
        } else if ([blk isMemberOfClass:[RadicalBlock class]]) {
            EquationBlock *eb = ((RadicalBlock *)blk).content;
            blk = eb.children.lastObject;
        } else if ([blk isMemberOfClass:[FractionBarLayer class]]) {
            NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return nil;
        } else if ([blk isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *layer = blk;
            if (layer.expo != nil) {
                blk = layer.expo.children.lastObject;
            } else {
                break;
            }
        } else {
            NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return nil;
        }
    } while (blk != nil);
    
    if (blk != nil) {
        EquationTextLayer *layer = blk;
        e.curTextLayer = layer;
        e.curBlock = layer;
        e.needX = YES;
        e.needNewLayer = NO;
        e.curParent = layer.parent;
        e.curRoll = layer.roll;
        e.curMode = MODE_INPUT;
        
        if (layer.is_base_expo == IS_BASE) {
            e.curFont = e.baseFont;
        } else if (layer.is_base_expo == IS_EXPO) {
            e.curFont = e.superscriptFont;
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        e.view.inpOrg = CGPointMake(layer.frame.origin.x + layer.frame.size.width, layer.frame.origin.y);
        e.view.cursor.frame = CGRectMake(e.view.inpOrg.x, e.view.inpOrg.y, CURSOR_W, e.curFontH);
    } else {
        NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    return blk;
}

void cfgEqnBySlctBlk(Equation *e, id b, CGPoint curPoint) {
    if ([b isMemberOfClass: [EquationBlock class]]) {
        EquationBlock *eBlock = b;
        NSLog(@"%s%i~~%i~~~~~~~~~", __FUNCTION__, __LINE__, eBlock.guid);
        
        id blk;
        
        if (eBlock.is_base_expo == IS_BASE) {
            e.curFont = e.baseFont;
        } else if (eBlock.is_base_expo == IS_EXPO) {
            e.curFont = e.superscriptFont;
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        if (curPoint.y >= eBlock.numerFrame.origin.y && curPoint.y <= eBlock.numerFrame.origin.y + eBlock.numerFrame.size.height) {
            FractionBarLayer *bar = eBlock.bar;
            if (bar == nil) {
                NSLog(@"%s%i~~Do nothing~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            } else {
                e.curMode = MODE_INSERT;
                if (bar.c_idx == 0) {
                    e.insertCIdx = CIDX_0_NUMER;
                    blk = bar;
                } else {
                    e.insertCIdx = bar.c_idx - 1;
                    blk = [eBlock.children objectAtIndex: e.insertCIdx];
                }
            }
            
            e.curRoll = ROLL_NUMERATOR;
            e.curParent = eBlock;
        } else if (curPoint.y >= eBlock.denomFrame.origin.y && curPoint.y <= eBlock.denomFrame.origin.y + eBlock.denomFrame.size.height) {
            NSLog(@"%s%i~~~~~~~~~~~", __FUNCTION__, __LINE__);
            e.curMode = MODE_INPUT;
            blk = [eBlock.children lastObject];
            e.curRoll = ROLL_DENOMINATOR;
            e.curParent = eBlock;
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        if ([blk isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *layer = blk;
            
            if (layer.type == TEXTLAYER_OP) {
                
                CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                CGFloat y = layer.frame.origin.y;
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.mainFrame.size.height;
                e.view.cursor.frame = CGRectMake(layer.mainFrame.origin.x + (layer.mainFrame.size.width * 2.0) + (e.curFontW / 2.0), layer.mainFrame.origin.y, CURSOR_W, tmp);
                e.needNewLayer = YES;
                e.needX = NO;
                e.curTextLayer = nil;
                e.curBlock = layer;
            } else if (layer.type == TEXTLAYER_NUM) {
                CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                CGFloat y = layer.frame.origin.y;
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.mainFrame.size.height;
                e.view.cursor.frame = CGRectMake(layer.mainFrame.origin.x + layer.mainFrame.size.width, layer.mainFrame.origin.y, CURSOR_W, tmp);
                if (layer.expo == nil) {
                    e.needNewLayer = NO;
                    e.needX = YES;
                    e.curTextLayer = layer;
                    e.curBlock = layer;
                } else {
                    e.needNewLayer = YES;
                    e.needX = YES;
                    e.curTextLayer = nil;
                    e.curBlock = layer;
                }
            } else if (layer.type == TEXTLAYER_EMPTY) {
                if (layer.expo == nil) {
                    CGFloat x = layer.frame.origin.x;
                    CGFloat y = layer.frame.origin.y;
                    e.view.inpOrg = CGPointMake(x, y);
                    CGFloat tmp = layer.frame.size.height;
                    e.view.cursor.frame = CGRectMake(e.view.inpOrg.x, e.view.inpOrg.y, CURSOR_W, tmp);
                    e.needNewLayer = NO;
                    e.needX = NO;
                    e.curTextLayer = layer;
                    e.curBlock = layer;
                } else {
                    CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                    CGFloat y = layer.frame.origin.y;
                    e.view.inpOrg = CGPointMake(x, y);
                    CGFloat tmp = layer.mainFrame.size.height;
                    e.view.cursor.frame = CGRectMake(e.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                    e.needNewLayer = YES;
                    e.needX = YES;
                    e.curTextLayer = nil;
                    e.curBlock = layer;
                }
            } else
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            
            NSLog(@"%s%i~Tapped at blank. Input after a textlayer.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, layer.guid, (unsigned long)e.insertCIdx, e.curMode, e.curRoll, ((EquationBlock *)e.curParent).guid);
        } else if ([blk isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *eBlk = blk;
            e.curTextLayer = nil;
            e.curBlock = eBlk;
            CGFloat x = eBlk.bar.frame.origin.x + eBlk.bar.frame.size.width;
            CGFloat y = eBlk.numerFrame.origin.y + eBlk.numerFrame.size.height - e.curFontH / 2.0;
            e.view.inpOrg = CGPointMake(x, y);
            CGFloat tmp = eBlk.mainFrame.size.height;
            e.view.cursor.frame = CGRectMake(eBlk.mainFrame.origin.x + eBlk.mainFrame.size.width, eBlk.mainFrame.origin.y, CURSOR_W, tmp);
            e.needNewLayer = YES;
            e.needX = YES;
            NSLog(@"%s%i~Tapped at blank. Input after a eBlock.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, eBlk.guid, (unsigned long)e.insertCIdx, e.curMode, e.curRoll, ((EquationBlock *)e.curParent).guid);
        } else if ([blk isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *rBlk = blk;
            e.curTextLayer = nil;
            e.curBlock = rBlk;
            CGFloat x = rBlk.frame.origin.x + rBlk.frame.size.width;
            CGFloat y = rBlk.frame.origin.y + rBlk.frame.size.height / 2.0 - e.curFontH / 2.0;
            e.view.inpOrg = CGPointMake(x, y);
            CGFloat tmp = rBlk.frame.size.height;
            e.view.cursor.frame = CGRectMake(rBlk.frame.origin.x + rBlk.frame.size.width, rBlk.frame.origin.y, CURSOR_W, tmp);
            e.needNewLayer = YES;
            e.needX = YES;
            NSLog(@"%s%i~Tapped at blank. Input after a rBlock.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, rBlk.guid, (unsigned long)e.insertCIdx, e.curMode, e.curRoll, ((EquationBlock *)e.curParent).guid);
        } else if ([blk isMemberOfClass: [FractionBarLayer class]]) { // Should not happen anymore
            //                EquationBlock *eBlk = ((FractionBarLayer *)blk).parent;
            //                if (e.curRoll == ROLL_NUMERATOR) {
            //                    e.view.inpOrg.x = eBlk.numerFrame.origin.x;
            //                    e.view.inpOrg.y = eBlk.numerFrame.origin.y;
            //                    CGFloat tmp = eBlk.numerFrame.size.height;
            //                    e.view.cursor.frame = CGRectMake(eBlk.numerFrame.origin.x, eBlk.mainFrame.origin.y, CURSOR_W, tmp);
            //                } else if (e.curRoll == ROLL_DENOMINATOR) {
            //                    e.view.inpOrg.x = eBlk.denomFrame.origin.x;
            //                    e.view.inpOrg.y = eBlk.denomFrame.origin.y;
            //                    CGFloat tmp = eBlk.denomFrame.size.height;
            //                    e.view.cursor.frame = CGRectMake(eBlk.denomFrame.origin.x, eBlk.denomFrame.origin.y, CURSOR_W, tmp);
            //                } else
            //                    NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            //                e.curTextLayer = nil;
            //                e.needNewLayer = YES;
            //                NSLog(@"%s%i~Tapped at blank. First input at Numer or Denom.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, eBlk.guid, (unsigned long)e.insertCIdx, e.curMode, e.curRoll, ((EquationBlock *)e.curBlock).guid);
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
    } else if ([b isMemberOfClass: [EquationTextLayer class]]) {
        EquationTextLayer *layer = b;
        NSLog(@"%s%i~~%i~~~~~~~~~", __FUNCTION__, __LINE__, layer.guid);
        
        if (layer.is_base_expo == IS_BASE) {
            e.curFont = e.baseFont;
        } else if (layer.is_base_expo == IS_EXPO) {
            e.curFont = e.superscriptFont;
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        if (layer.type == TEXTLAYER_OP) {
            CGFloat tmp = layer.frame.size.height;
            e.view.cursor.frame = CGRectMake(layer.frame.origin.x + layer.frame.size.width / 2.0 + e.curFontW / 2.0, layer.frame.origin.y, CURSOR_W, tmp);
            CGFloat x = layer.frame.origin.x + layer.frame.size.width;
            CGFloat y = layer.frame.origin.y;
            e.view.inpOrg = CGPointMake(x, y);
            e.needNewLayer = YES;
            e.needX = NO;
            e.curTextLayer = nil;
        } else if (layer.type == TEXTLAYER_NUM) {
            if (CGRectContainsPoint (layer.frame, curPoint)) {
                CGFloat x = layer.frame.origin.x + layer.frame.size.width;
                CGFloat y = layer.frame.origin.y;
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.frame.size.height;
                e.view.cursor.frame = CGRectMake(e.view.inpOrg.x, e.view.inpOrg.y, CURSOR_W, tmp);
                e.needNewLayer = NO;
                e.needX = YES;
                e.curTextLayer = layer;
            } else {
                CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                CGFloat y = layer.frame.origin.y;
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.mainFrame.size.height;
                e.view.cursor.frame = CGRectMake(e.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                e.needNewLayer = YES;
                e.needX = YES;
                e.curTextLayer = nil;
            }
        } else if (layer.type == TEXTLAYER_EMPTY) {
            if (CGRectContainsPoint (layer.frame, curPoint)) {
                CGFloat x = layer.frame.origin.x;
                CGFloat y = layer.frame.origin.y;
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.frame.size.height;
                e.view.cursor.frame = CGRectMake(e.view.inpOrg.x, e.view.inpOrg.y, CURSOR_W, tmp);
                e.needNewLayer = NO;
                e.needX = NO;
                e.curTextLayer = layer;
            } else {
                CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                CGFloat y = layer.frame.origin.y;
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.mainFrame.size.height;
                e.view.cursor.frame = CGRectMake(e.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                e.needNewLayer = YES;
                e.needX = YES;
                e.curTextLayer = nil;
            }
        } else
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        
        EquationBlock *block = layer.parent;
        id lastBlock = [block.children lastObject];
        if ([lastBlock isMemberOfClass: [EquationTextLayer class]] && layer == (EquationTextLayer *)lastBlock) {
            e.curMode = MODE_INPUT;
        } else {
            e.curMode = MODE_INSERT;
            e.insertCIdx = layer.c_idx;
        }
        e.curRoll = layer.roll;
        e.curParent = block;
        e.curBlock = layer;
    } else if ([b isMemberOfClass: [RadicalBlock class]]) {
        RadicalBlock *block = b;
        NSLog(@"%s%i~~%i~~~~~~~~~", __FUNCTION__, __LINE__, block.guid);
        if (block.is_base_expo == IS_BASE) {
            e.curFont = e.baseFont;
        } else if (block.is_base_expo == IS_EXPO) {
            e.curFont = e.superscriptFont;
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        id lastBlock = [((EquationBlock *)block.parent).children lastObject];
        if ([lastBlock isMemberOfClass: [RadicalBlock class]] && block == (RadicalBlock *)lastBlock) {
            e.curMode = MODE_INPUT;
        } else {
            e.curMode = MODE_INSERT;
            e.insertCIdx = block.c_idx;
        }
        e.curParent = block.parent;
        e.curRoll = block.roll;
        e.curTextLayer = nil;
        e.curBlock = block;
        e.needNewLayer = YES;
        e.needX = YES;
        CGFloat tmp = block.frame.size.height;
        e.view.cursor.frame = CGRectMake(block.frame.origin.x + block.frame.size.width, block.frame.origin.y, CURSOR_W, tmp);
        CGFloat x = block.frame.origin.x + block.frame.size.width;
        CGFloat y = block.frame.origin.y + block.frame.size.height / 2.0 - e.curFontH / 2.0;
        e.view.inpOrg = CGPointMake(x, y);
    } else if ([b isMemberOfClass: [FractionBarLayer class]]) {
        FractionBarLayer *bar = b;
        EquationBlock *block = bar.parent;
        
        if (bar.is_base_expo == IS_BASE) {
            e.curFont = e.baseFont;
        } else if (bar.is_base_expo == IS_EXPO) {
            e.curFont = e.superscriptFont;
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        CGFloat tmp = block.mainFrame.size.height;
        e.view.cursor.frame = CGRectMake(block.mainFrame.origin.x+block.mainFrame.size.width, block.mainFrame.origin.y, CURSOR_W, tmp);
        CGFloat x = block.bar.frame.origin.x + block.bar.frame.size.width;
        CGFloat y = block.numerFrame.origin.y + block.numerFrame.size.height - e.curFontH / 2.0;
        e.view.inpOrg = CGPointMake(x, y);
        e.curTextLayer = nil;
        e.curBlock = block;
        e.needNewLayer = YES;
        e.needX = YES;
        if (block.roll == ROLL_ROOT) {//Root block is a fraction. Need to dump all elements in the root block into new block
            e.curMode = MODE_DUMP_ROOT;
            e.curRoll = ROLL_NUMERATOR;
            NSLog(@"%s%i~Tapped at bar.~GUID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, block.guid, (unsigned long)e.insertCIdx, e.curMode, e.curRoll, ((EquationBlock *)e.curParent).guid);
        } else if(block.roll == ROLL_ROOT_ROOT) {
            e.curMode = MODE_DUMP_RADICAL;
            e.curRoll = ROLL_NUMERATOR;
            e.curParent = block.parent;
            NSLog(@"%s%i~Tapped at bar.~GUID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, block.guid, (unsigned long)e.insertCIdx, e.curMode, e.curRoll, ((RadicalBlock *)e.curParent).guid);
        } else if(block.roll == ROLL_EXPO_ROOT) {
            e.curMode = MODE_DUMP_EXPO;
            e.curRoll = ROLL_NUMERATOR;
            e.curParent = block.parent;
            NSLog(@"%s%i~Tapped at bar.~GUID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, block.guid, (unsigned long)e.insertCIdx, e.curMode, e.curRoll, ((RadicalBlock *)e.curParent).guid);
        } else {
            id lastBlock = [((EquationBlock *)block.parent).children lastObject];
            if ([lastBlock isMemberOfClass: [EquationBlock class]] && block == (EquationBlock *)lastBlock) {
                e.curMode = MODE_INPUT;
            } else {
                e.curMode = MODE_INSERT;
                e.insertCIdx = block.c_idx;
            }
            e.curParent = block.parent;
            e.curRoll = block.roll;
            NSLog(@"%s%i~Tapped at bar.~GUID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, block.guid, (unsigned long)e.insertCIdx, e.curMode, e.curRoll, ((EquationBlock *)e.curParent).guid);
        }
    } else
        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
}
