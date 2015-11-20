//
//  Global.m
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"
#import "Equation.h"
#import "EquationBlock.h"
#import "EquationTextLayer.h"
#import "RadicalBlock.h"
#import "FractionBarLayer.h"


NSMutableArray *gEquationList;
NSMutableArray *gDisplayViewList;
int gCurEqIdx = 0;

@implementation NSMutableArray (Reverse)
- (void)reverse {
    if ([self count] <= 1)
        return;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];

        i++;
        j--;
    }
}
@end



void drawFrame(ViewController *vc, UIView *view, EquationBlock *parentBlock) {
    
    CALayer *layer = [CALayer layer];
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.name = @"drawframe";
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.frame = parentBlock.mainFrame;
    layer.delegate = vc;
    [view.layer addSublayer: layer];
    [layer setNeedsDisplay];
    
    CALayer *layer1 = [CALayer layer];
    layer1.contentsScale = [UIScreen mainScreen].scale;
    layer1.name = @"drawframe";
    layer1.backgroundColor = [UIColor clearColor].CGColor;
    layer1.frame = parentBlock.numerFrame;
    layer1.delegate = vc;
    [view.layer addSublayer: layer1];
    [layer1 setNeedsDisplay];

    CALayer *layer2 = [CALayer layer];
    layer2.contentsScale = [UIScreen mainScreen].scale;
    layer2.name = @"drawframe";
    layer2.backgroundColor = [UIColor clearColor].CGColor;
    layer2.frame = parentBlock.denomFrame;
    layer2.delegate = vc;
    [view.layer addSublayer: layer2];
    [layer2 setNeedsDisplay];
    
    NSMutableArray *blockChildren = parentBlock.children;
    NSEnumerator *enumerator = [blockChildren objectEnumerator];
    id cb;
    while (cb = [enumerator nextObject]) {
        if ([cb isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *tLayer = cb;
            CALayer *layer = [CALayer layer];
            layer.contentsScale = [UIScreen mainScreen].scale;
            layer.name = @"drawframe";
            layer.backgroundColor = [UIColor clearColor].CGColor;
            layer.frame = tLayer.mainFrame;
            layer.delegate = vc;
            [view.layer addSublayer: layer];
            [layer setNeedsDisplay];
            
            CALayer *layer1 = [CALayer layer];
            layer1.contentsScale = [UIScreen mainScreen].scale;
            layer1.name = @"drawframe";
            layer1.backgroundColor = [UIColor clearColor].CGColor;
            layer1.frame = tLayer.frame;
            layer1.delegate = vc;
            [view.layer addSublayer: layer1];
            [layer1 setNeedsDisplay];
            
            if (tLayer.expo != nil) {
                
                drawFrame(vc, view, tLayer.expo);
            } else {
            }
        }
        
        if ([cb isMemberOfClass: [FractionBarLayer class]]) {
            FractionBarLayer *bar = cb;
            CALayer *layer = [CALayer layer];
            layer.contentsScale = [UIScreen mainScreen].scale;
            layer.name = @"drawframe";
            layer.backgroundColor = [UIColor clearColor].CGColor;
            layer.frame = bar.frame;
            layer.delegate = vc;
            [view.layer addSublayer: layer];
            [layer setNeedsDisplay];
        }
        
        if ([cb isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *block = cb;
            drawFrame(vc, view, block);
        }
        
        if ([cb isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *block = cb;
            CALayer *layer = [CALayer layer];
            layer.contentsScale = [UIScreen mainScreen].scale;
            layer.name = @"drawframe";
            layer.backgroundColor = [UIColor clearColor].CGColor;
            layer.frame = block.frame;
            layer.delegate = vc;
            [view.layer addSublayer: layer];
            [layer setNeedsDisplay];
            
            drawFrame(vc, view, block.content);
        }
    }
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

