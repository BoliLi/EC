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

EquationTextLayer *findLastTxtLayer(Equation *e, id blk) {
    
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
        e.curTxtLyr = layer;
        e.curBlk = layer;
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

EquationTextLayer *findPrevTxtLayer(Equation *e, id blk) {
    
    if ([blk isMemberOfClass:[EquationBlock class]]) {
        EquationBlock *eb = blk;
        if (eb.roll == ROLL_ROOT) {
            return nil;
        }
        
        if ([eb.parent isMemberOfClass:[EquationBlock class]]) {
            EquationBlock *par = eb.parent;
            if (eb.c_idx == 0) {
                return findPrevTxtLayer(e, par);
            } else {
                return findLastTxtLayer(e, [par.children objectAtIndex:eb.c_idx - 1]);
            }
        } else if ([eb.parent isMemberOfClass:[RadicalBlock class]]) {
            RadicalBlock *rb = eb.parent;
            EquationBlock *par = rb.parent;
            if (rb.c_idx == 0) {
                return findPrevTxtLayer(e, par);
            } else {
                return findLastTxtLayer(e, [par.children objectAtIndex:eb.c_idx - 1]);
            }
        } else if ([eb.parent isMemberOfClass:[EquationTextLayer class]]) {
            return eb.parent;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    } else if ([blk isMemberOfClass:[RadicalBlock class]]) {
        RadicalBlock *rb = blk;
        EquationBlock *par = rb.parent;
        
        if (rb.c_idx == 0) {
            return findPrevTxtLayer(e, par);
        } else {
            return findLastTxtLayer(e, [par.children objectAtIndex:rb.c_idx - 1]);
        }
    } else if ([blk isMemberOfClass:[FractionBarLayer class]]) {
        FractionBarLayer *bar = blk;
        EquationBlock *par = bar.parent;
        return findLastTxtLayer(e, [par.children objectAtIndex:bar.c_idx - 1]);
    } else if ([blk isMemberOfClass:[EquationTextLayer class]]) {
        EquationTextLayer *layer = blk;
        EquationBlock *par = layer.parent;
        if (layer.c_idx == 0) {
            return findPrevTxtLayer(e, par);
        } else {
            return findLastTxtLayer(e, [par.children objectAtIndex:layer.c_idx - 1]);
        }
    } else {
        NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return nil;
    }
    
    return nil;
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
            CGFloat centerX = eBlock.mainFrame.origin.x + eBlock.mainFrame.size.width / 2.0;
            if (curPoint.x < centerX) {
                e.curMode = MODE_INSERT;
                e.insertCIdx = 0;
                blk = [eBlock.children objectAtIndex: 0];
            } else {
                FractionBarLayer *bar = eBlock.bar;
                e.curMode = MODE_INSERT;
                e.insertCIdx = bar.c_idx;
                blk = [eBlock.children objectAtIndex: e.insertCIdx];
            }
            
            e.curRoll = ROLL_NUMERATOR;
            e.curParent = eBlock;
        } else if (curPoint.y >= eBlock.denomFrame.origin.y && curPoint.y <= eBlock.denomFrame.origin.y + eBlock.denomFrame.size.height) {
            CGFloat centerX = eBlock.mainFrame.origin.x + eBlock.mainFrame.size.width / 2.0;
            if (curPoint.x < centerX) {
                FractionBarLayer *bar = eBlock.bar;
                e.curMode = MODE_INSERT;
                e.insertCIdx = bar.c_idx + 1;
                blk = [eBlock.children objectAtIndex: e.insertCIdx];
            } else {
                e.curMode = MODE_INPUT;
                blk = [eBlock.children lastObject];
            }
            
            e.curRoll = ROLL_DENOMINATOR;
            e.curParent = eBlock;
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        if ([blk isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *layer = blk;
            
            if (layer.type == TEXTLAYER_OP) {
                CGFloat x, y;
                if (e.curRoll == ROLL_NUMERATOR) {
                    if (e.insertCIdx == 0) {
                        x = layer.mainFrame.origin.x;
                        y = layer.frame.origin.y;
                        e.curBlk = nil;
                    } else {
                        x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                        y = layer.frame.origin.y;
                        e.curBlk = layer;
                    }
                } else if (e.curRoll == ROLL_DENOMINATOR) {
                    if (e.curMode == MODE_INSERT) {
                        x = layer.mainFrame.origin.x;
                        y = layer.frame.origin.y;
                        e.curBlk = nil;
                    } else {
                        x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                        y = layer.frame.origin.y;
                        e.curBlk = layer;
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.mainFrame.size.height;
                e.view.cursor.frame = CGRectMake(x, y, CURSOR_W, tmp);
                e.curTxtLyr = nil;
            } else if (layer.type == TEXTLAYER_NUM) {
                CGFloat x, y;
                if (e.curRoll == ROLL_NUMERATOR) {
                    if (e.insertCIdx == 0) {
                        x = layer.frame.origin.x;
                        y = layer.frame.origin.y;
                        e.curBlk = layer;
                        e.curTxtLyr = layer;
                        e.txtInsIdx = 0;
                    } else {
                        x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                        y = layer.mainFrame.origin.y;
                        e.curBlk = layer;
                        if (layer.expo == nil) {
                            e.curTxtLyr = layer;
                            e.txtInsIdx = layer.strLenTbl.count;
                        } else {
                            e.curTxtLyr = nil;
                        }
                    }
                } else if (e.curRoll == ROLL_DENOMINATOR) {
                    if (e.curMode == MODE_INSERT) {
                        x = layer.frame.origin.x;
                        y = layer.frame.origin.y;
                        e.curBlk = layer;
                        e.curTxtLyr = layer;
                        e.txtInsIdx = 0;
                    } else {
                        x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                        y = layer.mainFrame.origin.y;
                        e.curBlk = layer;
                        if (layer.expo == nil) {
                            e.curTxtLyr = layer;
                            e.txtInsIdx = layer.strLenTbl.count;
                        } else {
                            e.curTxtLyr = nil;
                        }
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.mainFrame.size.height;
                e.view.cursor.frame = CGRectMake(x, y, CURSOR_W, tmp);
            } else if (layer.type == TEXTLAYER_EMPTY) {
                CGFloat x, y;
                if (e.curRoll == ROLL_NUMERATOR) {
                    if (e.insertCIdx == 0) {
                        x = layer.frame.origin.x;
                        y = layer.frame.origin.y;
                        e.curTxtLyr = layer;
                        e.curBlk = layer;
                    } else {
                        x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                        y = layer.mainFrame.origin.y;
                        if (layer.expo == nil) {
                            e.curTxtLyr = layer;
                            e.curBlk = layer;
                        } else {
                            e.curTxtLyr = nil;
                            e.curBlk = layer;
                        }
                    }
                } else if (e.curRoll == ROLL_DENOMINATOR) {
                    if (e.curMode == MODE_INSERT) {
                        x = layer.frame.origin.x;
                        y = layer.frame.origin.y;
                        e.curTxtLyr = layer;
                        e.curBlk = layer;
                    } else {
                        x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                        y = layer.mainFrame.origin.y;
                        if (layer.expo == nil) {
                            e.curTxtLyr = layer;
                            e.curBlk = layer;
                        } else {
                            e.curTxtLyr = nil;
                            e.curBlk = layer;
                        }
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.mainFrame.size.height;
                e.view.cursor.frame = CGRectMake(x, y, CURSOR_W, tmp);
            } else if (layer.type == TEXTLAYER_PARENTH) {
                CGFloat x, y;
                if (e.curRoll == ROLL_NUMERATOR) {
                    if (e.insertCIdx == 0) {
                        x = layer.mainFrame.origin.x;
                        y = layer.frame.origin.y;
                        e.curBlk = nil;
                    } else {
                        x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                        y = layer.frame.origin.y;
                        e.curBlk = layer;
                    }
                } else if (e.curRoll == ROLL_DENOMINATOR) {
                    if (e.curMode == MODE_INSERT) {
                        x = layer.mainFrame.origin.x;
                        y = layer.frame.origin.y;
                        e.curBlk = nil;
                    } else {
                        x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                        y = layer.frame.origin.y;
                        e.curBlk = layer;
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.mainFrame.size.height;
                e.view.cursor.frame = CGRectMake(x, y, CURSOR_W, tmp);
                e.curTxtLyr = nil;
            } else
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            
            NSLog(@"%s%i~Tapped at blank. Input after a textlayer.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, layer.guid, (unsigned long)e.insertCIdx, e.curMode, e.curRoll, ((EquationBlock *)e.curParent).guid);
        } else if ([blk isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *eBlk = blk;
            e.curTxtLyr = nil;
            e.curBlk = eBlk;
            CGFloat x = eBlk.bar.frame.origin.x + eBlk.bar.frame.size.width;
            CGFloat y = eBlk.numerFrame.origin.y + eBlk.numerFrame.size.height - e.curFontH / 2.0;
            e.view.inpOrg = CGPointMake(x, y);
            CGFloat tmp = eBlk.mainFrame.size.height;
            e.view.cursor.frame = CGRectMake(eBlk.mainFrame.origin.x + eBlk.mainFrame.size.width, eBlk.mainFrame.origin.y, CURSOR_W, tmp);
            NSLog(@"%s%i~Tapped at blank. Input after a eBlock.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, eBlk.guid, (unsigned long)e.insertCIdx, e.curMode, e.curRoll, ((EquationBlock *)e.curParent).guid);
        } else if ([blk isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *rBlk = blk;
            e.curTxtLyr = nil;
            e.curBlk = rBlk;
            CGFloat x = rBlk.frame.origin.x + rBlk.frame.size.width;
            CGFloat y = rBlk.frame.origin.y + rBlk.frame.size.height / 2.0 - e.curFontH / 2.0;
            e.view.inpOrg = CGPointMake(x, y);
            CGFloat tmp = rBlk.frame.size.height;
            e.view.cursor.frame = CGRectMake(rBlk.frame.origin.x + rBlk.frame.size.width, rBlk.frame.origin.y, CURSOR_W, tmp);
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
            //                e.curTxtLyr = nil;
            //                NSLog(@"%s%i~Tapped at blank. First input at Numer or Denom.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, eBlk.guid, (unsigned long)e.insertCIdx, e.curMode, e.curRoll, ((EquationBlock *)e.curBlk).guid);
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
    } else if ([b isMemberOfClass: [EquationTextLayer class]]) {
        EquationTextLayer *layer = b;
        
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
            e.curTxtLyr = nil;
        } else if (layer.type == TEXTLAYER_NUM) {
            if (CGRectContainsPoint (layer.frame, curPoint)) {
                CGFloat x = layer.frame.origin.x + layer.frame.size.width;
                CGFloat y = layer.frame.origin.y;
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.frame.size.height;
                e.view.cursor.frame = CGRectMake(e.view.inpOrg.x, e.view.inpOrg.y, CURSOR_W, tmp);
                e.curTxtLyr = layer;
            } else {
                CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                CGFloat y = layer.frame.origin.y;
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.mainFrame.size.height;
                e.view.cursor.frame = CGRectMake(e.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                e.curTxtLyr = nil;
            }
        } else if (layer.type == TEXTLAYER_EMPTY) {
            if (CGRectContainsPoint (layer.frame, curPoint)) {
                CGFloat x = layer.frame.origin.x;
                CGFloat y = layer.frame.origin.y;
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.frame.size.height;
                e.view.cursor.frame = CGRectMake(e.view.inpOrg.x, e.view.inpOrg.y, CURSOR_W, tmp);
                e.curTxtLyr = layer;
            } else {
                CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                CGFloat y = layer.frame.origin.y;
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.mainFrame.size.height;
                e.view.cursor.frame = CGRectMake(e.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                e.curTxtLyr = nil;
            }
        } else if (layer.type == TEXTLAYER_PARENTH) {
            CGFloat x = layer.frame.origin.x + layer.frame.size.width;
            CGFloat y = layer.frame.origin.y;
            e.view.inpOrg = CGPointMake(x, y);
            CGFloat tmp = layer.frame.size.height;
            e.view.cursor.frame = CGRectMake(e.view.inpOrg.x, e.view.inpOrg.y, CURSOR_W, tmp);
            e.curTxtLyr = nil;
        } else
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        
        EquationBlock *block = layer.parent;
        id lastBlock = [block.children lastObject];
        if ([lastBlock isMemberOfClass: [EquationTextLayer class]] && layer == (EquationTextLayer *)lastBlock) {
            e.curMode = MODE_INPUT;
        } else {
            e.curMode = MODE_INSERT;
            e.insertCIdx = layer.c_idx + 1;
        }
        e.curRoll = layer.roll;
        e.curParent = block;
        e.curBlk = layer;
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
            e.insertCIdx = block.c_idx + 1;
        }
        e.curParent = block.parent;
        e.curRoll = block.roll;
        e.curTxtLyr = nil;
        e.curBlk = block;
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
        e.curTxtLyr = nil;
        e.curBlk = block;
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
                e.insertCIdx = block.c_idx + 1;
            }
            e.curParent = block.parent;
            e.curRoll = block.roll;
            NSLog(@"%s%i~Tapped at bar.~GUID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, block.guid, (unsigned long)e.insertCIdx, e.curMode, e.curRoll, ((EquationBlock *)e.curParent).guid);
        }
    } else
        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
}

bool rectContainsRect(CGRect rect1, CGRect rect2) {
    int x1 = (int)rect1.origin.x;
    int x2 = (int)rect2.origin.x;
    int y1 = (int)rect1.origin.y;
    int y2 = (int)rect2.origin.y;
    int w1 = (int)rect1.size.width;
    int w2 = (int)rect2.size.width;
    int h1 = (int)rect1.size.height;
    int h2 = (int)rect2.size.height;
    if (x1 <= x2) {
        if (x1+w1 >= x2+w2) {
            if (y1 <= y2) {
                if (y1+h1 >= y2+h2) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}