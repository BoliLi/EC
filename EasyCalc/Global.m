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
NSInteger gCurEqIdx = 0;
Equation *gCurE;
CGFloat gBaseCharWidthTbl[3][16];
CGFloat gExpoCharWidthTbl[3][16];

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

int getBaseFontSize(int level) {
    if (level == 0) {
        return 30;
    } else if (level == 1) {
        return 20;
    } else {
        return 15;
    }
}

void initCharWidthTbl(void) {
    
    for (int j = 0; j < 3; j++) {
        int i, baseFS = getBaseFontSize(j);
        
        UIFont *baseFont = [UIFont systemFontOfSize:baseFS];
        UIFont *superscriptFont = [UIFont systemFontOfSize:baseFS/2];
        
        CTFontRef ctFont = CTFontCreateWithName((CFStringRef)baseFont.fontName, baseFont.pointSize, NULL);
        for (i = 0; i < 10; i++) {
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%d",i]];
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
            gBaseCharWidthTbl[j][i] = [attStr size].width;
        }
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"."];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gBaseCharWidthTbl[j][i++] = [attStr size].width;
        
        attStr = [[NSMutableAttributedString alloc] initWithString:@"+"];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gBaseCharWidthTbl[j][i++] = [attStr size].width;
        
        attStr = [[NSMutableAttributedString alloc] initWithString:@"-"];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gBaseCharWidthTbl[j][i++] = [attStr size].width;
        
        attStr = [[NSMutableAttributedString alloc] initWithString:@"×"];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gBaseCharWidthTbl[j][i++] = [attStr size].width;
        
        attStr = [[NSMutableAttributedString alloc] initWithString:@"("];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gBaseCharWidthTbl[j][i++] = [attStr size].width;
        
        attStr = [[NSMutableAttributedString alloc] initWithString:@")"];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gBaseCharWidthTbl[j][i++] = [attStr size].width;
        
        CFRelease(ctFont);
        
        ctFont = CTFontCreateWithName((CFStringRef)superscriptFont.fontName, superscriptFont.pointSize, NULL);
        for (i = 0; i < 10; i++) {
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%d",i]];
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
            gExpoCharWidthTbl[j][i] = [attStr size].width;
        }
        
        attStr = [[NSMutableAttributedString alloc] initWithString:@"."];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gExpoCharWidthTbl[j][i++] = [attStr size].width;
        
        attStr = [[NSMutableAttributedString alloc] initWithString:@"+"];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gExpoCharWidthTbl[j][i++] = [attStr size].width;
        
        attStr = [[NSMutableAttributedString alloc] initWithString:@"-"];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gExpoCharWidthTbl[j][i++] = [attStr size].width;
        
        attStr = [[NSMutableAttributedString alloc] initWithString:@"×"];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gExpoCharWidthTbl[j][i++] = [attStr size].width;
        
        attStr = [[NSMutableAttributedString alloc] initWithString:@"("];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gExpoCharWidthTbl[j][i++] = [attStr size].width;
        
        attStr = [[NSMutableAttributedString alloc] initWithString:@")"];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gExpoCharWidthTbl[j][i++] = [attStr size].width;
        
        CFRelease(ctFont);
    }
    
}

CGFloat getCharWidth(int level, int base_expo, NSString *s) {
    if (base_expo == IS_BASE) {
        if ([s isEqual:@"0"]) {
            return gBaseCharWidthTbl[level][0];
        } else if ([s isEqual:@"1"]) {
            return gBaseCharWidthTbl[level][1];
        } else if ([s isEqual:@"2"]) {
            return gBaseCharWidthTbl[level][2];
        } else if ([s isEqual:@"3"]) {
            return gBaseCharWidthTbl[level][3];
        } else if ([s isEqual:@"4"]) {
            return gBaseCharWidthTbl[level][4];
        } else if ([s isEqual:@"5"]) {
            return gBaseCharWidthTbl[level][5];
        } else if ([s isEqual:@"6"]) {
            return gBaseCharWidthTbl[level][6];
        } else if ([s isEqual:@"7"]) {
            return gBaseCharWidthTbl[level][7];
        } else if ([s isEqual:@"8"]) {
            return gBaseCharWidthTbl[level][8];
        } else if ([s isEqual:@"9"]) {
            return gBaseCharWidthTbl[level][9];
        } else if ([s isEqual:@"."]) {
            return gBaseCharWidthTbl[level][10];
        } else if ([s isEqual:@"+"]) {
            return gBaseCharWidthTbl[level][11];
        } else if ([s isEqual:@"-"]) {
            return gBaseCharWidthTbl[level][12];
        } else if ([s isEqual:@"×"]) {
            return gBaseCharWidthTbl[level][13];
        } else if ([s isEqual:@"("]) {
            return gBaseCharWidthTbl[level][14];
        } else if ([s isEqual:@")"]) {
            return gBaseCharWidthTbl[level][15];
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return 0.0;
        }
    } else {
        if ([s isEqual:@"0"]) {
            return gExpoCharWidthTbl[level][0];
        } else if ([s isEqual:@"1"]) {
            return gExpoCharWidthTbl[level][1];
        } else if ([s isEqual:@"2"]) {
            return gExpoCharWidthTbl[level][2];
        } else if ([s isEqual:@"3"]) {
            return gExpoCharWidthTbl[level][3];
        } else if ([s isEqual:@"4"]) {
            return gExpoCharWidthTbl[level][4];
        } else if ([s isEqual:@"5"]) {
            return gExpoCharWidthTbl[level][5];
        } else if ([s isEqual:@"6"]) {
            return gExpoCharWidthTbl[level][6];
        } else if ([s isEqual:@"7"]) {
            return gExpoCharWidthTbl[level][7];
        } else if ([s isEqual:@"8"]) {
            return gExpoCharWidthTbl[level][8];
        } else if ([s isEqual:@"9"]) {
            return gExpoCharWidthTbl[level][9];
        } else if ([s isEqual:@"."]) {
            return gExpoCharWidthTbl[level][10];
        } else if ([s isEqual:@"+"]) {
            return gExpoCharWidthTbl[level][11];
        } else if ([s isEqual:@"-"]) {
            return gExpoCharWidthTbl[level][12];
        } else if ([s isEqual:@"×"]) {
            return gExpoCharWidthTbl[level][13];
        } else if ([s isEqual:@"("]) {
            return gExpoCharWidthTbl[level][14];
        } else if ([s isEqual:@")"]) {
            return gExpoCharWidthTbl[level][15];
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



