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
int gCurEqIdx = 0;
CGFloat gBaseCharWidthTbl[11];
CGFloat gExpoCharWidthTbl[11];

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

void initCharWidthTbl(void) {
    int i;
    UIFont *baseFont = [UIFont systemFontOfSize: 20];
    UIFont *superscriptFont = [UIFont systemFontOfSize:10];
    
    for (i = 0; i < 10; i++) {
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%d",i]];
        CTFontRef ctFont = CTFontCreateWithName((CFStringRef)baseFont.fontName, baseFont.pointSize, NULL);
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        CFRelease(ctFont);
        CGSize strSize = [attStr size];
        gBaseCharWidthTbl[i] = strSize.width;
    }
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"."];
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)baseFont.fontName, baseFont.pointSize, NULL);
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
    CFRelease(ctFont);
    CGSize strSize = [attStr size];
    gBaseCharWidthTbl[i] = strSize.width;
    
    for (i = 0; i < 10; i++) {
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%d",i]];
        CTFontRef ctFont = CTFontCreateWithName((CFStringRef)superscriptFont.fontName, superscriptFont.pointSize, NULL);
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        CFRelease(ctFont);
        CGSize strSize = [attStr size];
        gExpoCharWidthTbl[i] = strSize.width;
    }
    
    attStr = [[NSMutableAttributedString alloc] initWithString:@"."];
    ctFont = CTFontCreateWithName((CFStringRef)superscriptFont.fontName, superscriptFont.pointSize, NULL);
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
    CFRelease(ctFont);
    strSize = [attStr size];
    gExpoCharWidthTbl[i] = strSize.width;
}

CGFloat getCharWidth(int base_expo, NSString *s) {
    if (base_expo == IS_BASE) {
        if ([s isEqual:@"0"]) {
            return gBaseCharWidthTbl[0];
        } else if ([s isEqual:@"1"]) {
            return gBaseCharWidthTbl[1];
        } else if ([s isEqual:@"2"]) {
            return gBaseCharWidthTbl[2];
        } else if ([s isEqual:@"3"]) {
            return gBaseCharWidthTbl[3];
        } else if ([s isEqual:@"4"]) {
            return gBaseCharWidthTbl[4];
        } else if ([s isEqual:@"5"]) {
            return gBaseCharWidthTbl[5];
        } else if ([s isEqual:@"6"]) {
            return gBaseCharWidthTbl[6];
        } else if ([s isEqual:@"7"]) {
            return gBaseCharWidthTbl[7];
        } else if ([s isEqual:@"8"]) {
            return gBaseCharWidthTbl[8];
        } else if ([s isEqual:@"9"]) {
            return gBaseCharWidthTbl[9];
        } else if ([s isEqual:@"."]) {
            return gBaseCharWidthTbl[10];
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return 0.0;
        }
    } else {
        if ([s isEqual:@"0"]) {
            return gExpoCharWidthTbl[0];
        } else if ([s isEqual:@"1"]) {
            return gExpoCharWidthTbl[1];
        } else if ([s isEqual:@"2"]) {
            return gExpoCharWidthTbl[2];
        } else if ([s isEqual:@"3"]) {
            return gExpoCharWidthTbl[3];
        } else if ([s isEqual:@"4"]) {
            return gExpoCharWidthTbl[4];
        } else if ([s isEqual:@"5"]) {
            return gExpoCharWidthTbl[5];
        } else if ([s isEqual:@"6"]) {
            return gExpoCharWidthTbl[6];
        } else if ([s isEqual:@"7"]) {
            return gExpoCharWidthTbl[7];
        } else if ([s isEqual:@"8"]) {
            return gExpoCharWidthTbl[8];
        } else if ([s isEqual:@"9"]) {
            return gExpoCharWidthTbl[9];
        } else if ([s isEqual:@"."]) {
            return gExpoCharWidthTbl[10];
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return 0.0;
        }
    }
}

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



