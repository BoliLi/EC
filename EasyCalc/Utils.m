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
